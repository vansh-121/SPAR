import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/data/model/auth/sign_up_model/error_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/my_strings.dart';
import '../../../../environment.dart';
import '../../../../view/components/profile_complete/profile_complete_response_model.dart';
import '../../../../view/components/show_custom_snackbar.dart';
import '../../../model/auth/sign_up_model/registration_response_model.dart';
import '../../../model/auth/sign_up_model/sign_up_model.dart';
import '../../../model/country_model/country_model.dart';
import '../../../model/general_setting/general_settings_response_model.dart';
import '../../../model/global/response_model/response_model.dart';
import '../../../model/profile_complete/profile_complete_post_model.dart';
import '../../../model/user/user.dart';
import '../../../repo/account/profile_repo.dart';
import '../../../repo/auth/general_setting_repo.dart';
import '../../../repo/auth/signup_repo.dart';

class RegistrationController extends GetxController {
  RegistrationRepo registrationRepo;
  GeneralSettingRepo generalSettingRepo;
  ProfileRepo profileRepo;

  RegistrationController({
    required this.registrationRepo,
    required this.generalSettingRepo,
    required this.profileRepo,
  });

  String _sanitizePhone(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String _sanitizeUsername(String input) {
    // Remove special characters and spaces, keep only alphanumeric, underscore, and hyphen
    // This matches common backend username validation rules
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '').toLowerCase();
  }

  bool isLoading = true;
  bool agreeTC = false;

  GeneralSettingResponseModel generalSettingMainModel =
      GeneralSettingResponseModel();

  //it will come from general setting api
  bool checkPasswordStrength = false;
  bool needAgree = true;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode countryNameFocusNode = FocusNode();
  final FocusNode mobileFocusNode = FocusNode();
  final FocusNode userNameFocusNode = FocusNode();
  final FocusNode referralCodeFocusNode = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController cPasswordController = TextEditingController();
  final TextEditingController fNameController = TextEditingController();
  final TextEditingController lNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController referralCodeController = TextEditingController();

  String? email;
  String? password;
  String? confirmPassword;
  String? countryName;
  String? countryCode;
  String? mobileCode;
  String? userName;
  String? phoneNo;
  String? firstName;
  String? lastName;

  RegExp regex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  bool submitLoading = false;
  signUpUser() async {
    if (needAgree && !agreeTC) {
      CustomSnackBar.error(
        errorList: [MyStrings.agreePolicyMessage],
      );
      return;
    }

    submitLoading = true;
    update();

    log('Attempting sign up for email: ${emailController.text.trim()}');

    SignUpModel model = getUserData();
    ResponseModel responseModel = await registrationRepo.registerUser(model);
    log('Sign up API status: ${responseModel.statusCode}');

    if (responseModel.statusCode == 200) {
      RegistrationResponseModel model = RegistrationResponseModel.fromJson(
          jsonDecode(responseModel.responseJson));
      final bool statusOk =
          model.status?.toLowerCase() == MyStrings.success.toLowerCase();
      final bool hasToken = (model.data?.accessToken ?? '').trim().isNotEmpty;
      final bool hasUser = model.data?.user != null;

      if (statusOk && hasToken && hasUser) {
        CustomSnackBar.success(
            successList: model.message?.success ?? [MyStrings.success.tr]);
        log('Sign up succeeded for ${emailController.text.trim()}');
        await checkAndGotoNextStep(model);
      } else {
        final List<String> errorList =
            model.message?.error ?? [MyStrings.somethingWentWrong.tr];
        CustomSnackBar.error(errorList: errorList);
        log('Sign up rejected: status=$statusOk token=$hasToken user=$hasUser errors=$errorList');
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
      log('Sign up failed: ${responseModel.message}');
    }

    submitLoading = false;
    update();
  }

  updateAgreeTC() {
    agreeTC = !agreeTC;
    update();
  }

  SignUpModel getUserData() {
    // String referenceValue = referralCodeController.text.toString().split('=').last;

    String referenceValue =
        referralCodeController.text.toString().split('=').last;

    SignUpModel model = SignUpModel(
      firstName: fNameController.text.toString(),
      lastName: lNameController.text.toString(),
      email: emailController.text.toString(),
      password: passwordController.text.toString(),
      refference: referenceValue.toString(),
      agree: agreeTC ? true : false,
      username: userNameController.text.trim().isNotEmpty
          ? _sanitizeUsername(userNameController.text.trim())
          : null,
      mobile: mobileController.text.trim().isNotEmpty
          ? _sanitizePhone(mobileController.text.trim())
          : null,
      countryCode:
          (countryCode != null && countryCode!.isNotEmpty) ? countryCode : null,
      mobileCode:
          (mobileCode != null && mobileCode!.isNotEmpty) ? mobileCode : null,
      country:
          (countryName != null && countryName!.isNotEmpty) ? countryName : null,
    );

    return model;
  }

  Future<void> checkAndGotoNextStep(
      RegistrationResponseModel responseModel) async {
    SharedPreferences preferences =
        registrationRepo.apiClient.sharedPreferences;

    await preferences.setString(SharedPreferenceHelper.userIdKey,
        responseModel.data?.user?.id.toString() ?? '-1');
    await preferences.setString(SharedPreferenceHelper.accessTokenKey,
        responseModel.data?.accessToken ?? '');
    await preferences.setString(SharedPreferenceHelper.accessTokenType,
        responseModel.data?.tokenType ?? '');
    await preferences.setString(SharedPreferenceHelper.userEmailKey,
        responseModel.data?.user?.email ?? '');
    await preferences.setString(
        SharedPreferenceHelper.userNameKey,
        userNameController.text.trim().isEmpty
            ? (responseModel.data?.user?.username ?? '')
            : userNameController.text.trim());

    final String storedPhone = _sanitizePhone(mobileController.text.trim());
    final String selectedDialCode = (mobileCode == null || mobileCode!.isEmpty)
        ? Environment.defaultPhoneCode
        : mobileCode!;
    final String fallbackPhone = responseModel.data?.user?.mobile ?? '';
    final String phoneForStorage = storedPhone.isNotEmpty
        ? '+$selectedDialCode$storedPhone'
        : fallbackPhone;

    await preferences.setString(
        SharedPreferenceHelper.userPhoneNumberKey, phoneForStorage);
    log('Persisted phone number: $phoneForStorage');

    // Get the user object from the response
    User? targetUser = responseModel.data?.user;

    // Check if username and mobile are already filled from registration API
    bool hasUsername = (targetUser?.username ?? '').isNotEmpty;
    bool hasMobile = (targetUser?.mobile ?? '').isNotEmpty;

    // If username or mobile are missing, try to complete profile
    if (!hasUsername || !hasMobile) {
      log('Username or mobile missing, attempting auto-complete profile');
      User? updatedUser = await _completeProfileAfterSignup();

      if (updatedUser != null) {
        targetUser = updatedUser;
        log('Profile auto-completed successfully');
      } else {
        // If auto-complete failed but we have the data locally, set it manually
        if (targetUser != null) {
          if (!hasUsername && userNameController.text.trim().isNotEmpty) {
            targetUser.username = userNameController.text.trim();
          }
          if (!hasMobile && phoneForStorage.isNotEmpty) {
            targetUser.mobile = phoneForStorage;
          }
          // Mark profile as complete since we have all required data
          targetUser.profileComplete = '1';
          log('Profile data set manually from controllers');
        }
      }
    } else {
      log('Username and mobile already present in registration response');
      // If we already have the data, mark profile as complete
      if (targetUser != null) {
        targetUser.profileComplete = '1';
      }
    }

    await RouteHelper.checkUserStatusAndGoToNextStep(targetUser,
        accessToken: responseModel.data?.accessToken ?? '',
        tokenType: responseModel.data?.tokenType ?? '');
  }

  Future<User?> _completeProfileAfterSignup() async {
    final username = userNameController.text.trim();
    final mobileNumber = mobileController.text.trim();

    if (username.isEmpty || mobileNumber.isEmpty) {
      return null;
    }

    final String selectedCountryName =
        (countryName == null || countryName!.isEmpty) ? 'N/A' : countryName!;
    final String selectedCountryCode =
        (countryCode == null || countryCode!.isEmpty)
            ? Environment.defaultCountryCode
            : countryCode!;
    final String selectedDialCode = (mobileCode == null || mobileCode!.isEmpty)
        ? Environment.defaultPhoneCode
        : mobileCode!;
    final String sanitizedMobileNumber = _sanitizePhone(mobileNumber);
    final String sanitizedUsername = _sanitizeUsername(username);

    log('Auto completing profile for $sanitizedUsername with $selectedCountryName (+$selectedDialCode) $sanitizedMobileNumber');

    final ProfileCompletePostModel profileModel = ProfileCompletePostModel(
      username: sanitizedUsername,
      countryName: selectedCountryName,
      countryCode: selectedCountryCode,
      mobileNumber: sanitizedMobileNumber,
      mobileCode: selectedDialCode,
      address: 'N/A',
      state: 'N/A',
      zip: 'N/A',
      city: 'N/A',
      image: null,
    );

    ResponseModel response = await profileRepo.completeProfile(profileModel);

    if (response.statusCode == 200) {
      try {
        ProfileCompleteResponseModel model =
            ProfileCompleteResponseModel.fromJson(
                jsonDecode(response.responseJson));

        if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
          log('Profile auto-complete success for $username');
          return model.data?.user;
        } else {
          CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.requestFail.tr],
          );
          log('Profile auto-complete failure: ${model.message?.error}');
        }
      } catch (_) {
        log('Profile auto-complete parsing failed');
        return null;
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
      log('Profile auto-complete request failed: ${response.message}');
    }

    return null;
  }

  void closeAllController() {
    isLoading = false;
    emailController.text = '';
    passwordController.text = '';
    cPasswordController.text = '';
    fNameController.text = '';
    lNameController.text = '';
    mobileController.text = '';
    countryController.text = '';
    userNameController.text = '';
  }

  clearAllData() {
    closeAllController();
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return MyStrings.enterYourPassword_.tr;
    } else {
      if (checkPasswordStrength) {
        if (!regex.hasMatch(value)) {
          return MyStrings.invalidPassMsg.tr;
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  List<ErrorModel> passwordValidationRulse = [
    ErrorModel(text: MyStrings.hasUpperLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasLowerLetter.tr, hasError: true),
    ErrorModel(text: MyStrings.hasDigit.tr, hasError: true),
    ErrorModel(text: MyStrings.hasSpecialChar.tr, hasError: true),
    ErrorModel(text: MyStrings.minSixChar.tr, hasError: true),
  ];

  void initData() async {
    isLoading = true;
    update();

    ResponseModel response = await generalSettingRepo.getGeneralSetting();
    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(
          jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == 'success') {
        generalSettingMainModel = model;
        registrationRepo.apiClient.storeGeneralSetting(model);
      } else {
        List<String> message = [MyStrings.somethingWentWrong.tr];
        CustomSnackBar.showCustomSnackBar(
            errorList: model.message?.error ?? message, msg: [], isError: true);
        return;
      }
    } else {
      if (response.statusCode == 503) {
        noInternet = true;
        update();
      }
      CustomSnackBar.showCustomSnackBar(
          errorList: [response.message], msg: [], isError: true);
      return;
    }

    needAgree =
        generalSettingMainModel.data?.generalSetting?.agree.toString() == '0'
            ? false
            : true;
    checkPasswordStrength = generalSettingMainModel
                .data?.generalSetting?.securePassword
                .toString() ==
            '0'
        ? false
        : true;

    await loadCountryData();

    isLoading = false;
    update();
  }

  // country data
  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  bool noInternet = false;
  void changeInternet(bool hasInternet) {
    noInternet = false;
    initData();
    update();
  }

  Future<void> loadCountryData() async {
    countryLoading = true;
    update();

    ResponseModel response = await profileRepo.getCountryList();
    if (response.statusCode == 200) {
      CountryModel model =
          CountryModel.fromJson(jsonDecode(response.responseJson));
      List<Countries>? tempList = model.data?.countries;
      if (tempList != null && tempList.isNotEmpty) {
        countryList
          ..clear()
          ..addAll(tempList);
        filteredCountries = List<Countries>.from(countryList);

        Countries? defaultCountry = countryList.firstWhere(
          (country) =>
              country.countryCode?.toLowerCase() ==
              Environment.defaultCountryCode.toLowerCase(),
          orElse: () => Countries(),
        );

        if ((defaultCountry.dialCode ?? '').isNotEmpty) {
          setCountryNameAndCode(
              defaultCountry.country ?? '',
              defaultCountry.countryCode ?? Environment.defaultCountryCode,
              defaultCountry.dialCode ?? Environment.defaultPhoneCode);
        } else {
          setCountryNameAndCode('N/A', Environment.defaultCountryCode,
              Environment.defaultPhoneCode);
        }

        log('Country list loaded: ${countryList.length} items');
      } else {
        setCountryNameAndCode('N/A', Environment.defaultCountryCode,
            Environment.defaultPhoneCode);
        log('Country list empty, using defaults');
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
      log('Country list load failed: ${response.message}');
    }

    countryLoading = false;
    update();
  }

  void filterCountries(String query) {
    if (query.isEmpty) {
      filteredCountries = List<Countries>.from(countryList);
    } else {
      filteredCountries = countryList
          .where((country) =>
              (country.country ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (country.dialCode ?? '').contains(query))
          .toList();
    }
    update();
  }

  void setCountryNameAndCode(
      String cName, String countryCode, String mobileCode) {
    countryName = cName;
    this.countryCode = countryCode;
    this.mobileCode = mobileCode;
    countryController.text = '';
    log('Selected country: $countryName (+$mobileCode)');
    update();
  }

  void updateValidationList(String value) {
    passwordValidationRulse[0].hasError =
        value.contains(RegExp(r'[A-Z]')) ? false : true;
    passwordValidationRulse[1].hasError =
        value.contains(RegExp(r'[a-z]')) ? false : true;
    passwordValidationRulse[2].hasError =
        value.contains(RegExp(r'[0-9]')) ? false : true;
    passwordValidationRulse[3].hasError =
        value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')) ? false : true;
    passwordValidationRulse[4].hasError = value.length >= 6 ? false : true;

    update();
  }

  bool hasPasswordFocus = false;
  void changePasswordFocus(bool hasFocus) {
    hasPasswordFocus = hasFocus;
    update();
  }

  void setMobileFocus() {
    try {
      FocusScope.of(Get.context!).requestFocus(mobileFocusNode);
    } catch (e) {
      print(e.toString());
    }

    update();
  }
}
