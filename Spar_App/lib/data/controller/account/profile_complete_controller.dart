import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/profile/profile_response_model.dart';

import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/routes/route.dart';
import '../../../environment.dart';
import '../../../view/components/profile_complete/profile_complete_response_model.dart';
import '../../../view/components/show_custom_snackbar.dart';
import '../../model/country_model/country_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/profile_complete/profile_complete_post_model.dart';
import '../../model/user/user.dart';
import '../../repo/account/profile_repo.dart';
import '../../services/push_notification_service.dart';

class ProfileCompleteController extends GetxController {
  ProfileRepo profileRepo;

  ProfileResponseModel model = ProfileResponseModel();

  ProfileCompleteController({required this.profileRepo});

  bool isLoading = false;
  TextEditingController countryController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController userNameController = TextEditingController();

  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode userNameFocusNode = FocusNode();

  bool countryLoading = true;
  List<Countries> countryList = [];
  List<Countries> filteredCountries = [];

  String? countryName;
  String? countryCode;
  String? mobileCode;

  Future<dynamic> getCountryData() async {
    ResponseModel mainResponse = await profileRepo.getCountryList();

    if (mainResponse.statusCode == 200) {
      CountryModel model =
          CountryModel.fromJson(jsonDecode(mainResponse.responseJson));
      List<Countries>? tempList = model.data?.countries;

      if (tempList != null && tempList.isNotEmpty) {
        countryList.clear();
        filteredCountries.clear();
        countryList.addAll(tempList);
        filteredCountries.addAll(tempList);
      }
      var selectDefCountry = tempList!.firstWhere(
        (country) =>
            country.countryCode!.toLowerCase() ==
            Environment.defaultCountryCode.toLowerCase(),
        orElse: () => Countries(),
      );
      if (selectDefCountry.dialCode != null) {
        setCountryNameAndCode(
            selectDefCountry.country.toString(),
            selectDefCountry.countryCode.toString(),
            selectDefCountry.dialCode.toString());
      }
    } else {
      CustomSnackBar.error(errorList: [mainResponse.message]);
    }

    countryLoading = false;
    update();
  }

  bool submitLoading = false;
  updateProfile() async {
    if (mobileNoController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterYourPhoneNumber.tr]);
      return;
    }

    String username = userNameController.text;
    String mobileNumber = mobileNoController.text;
    String address = addressController.text.toString();
    String city = cityController.text.toString();
    String zip = zipCodeController.text.toString();
    String state = stateController.text.toString();

    submitLoading = true;
    update();

    ProfileCompletePostModel model = ProfileCompletePostModel(
      username: username,
      countryName: countryName ?? "",
      countryCode: countryCode ?? "",
      mobileNumber: mobileNumber,
      mobileCode: mobileCode ?? "",
      address: address,
      state: state,
      zip: zip,
      city: city,
      image: null,
    );

    ResponseModel responseModel = await profileRepo.completeProfile(model);

    if (responseModel.statusCode == 200) {
      ProfileCompleteResponseModel model =
          ProfileCompleteResponseModel.fromJson(
              jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        checkAndGotoNextStep(model.data?.user);
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    submitLoading = false;
    update();
  }

  void setCountryNameAndCode(
      String cName, String countryCode, String mobileCode) {
    countryName = cName;
    this.countryCode = countryCode;
    this.mobileCode = mobileCode;
    update();
  }

  void initData() {
    getCountryData();
  }

  void checkAndGotoNextStep(User? user) async {
    bool needEmailVerification = user?.ev == "1" ? false : true;
    bool needSmsVerification = user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = user?.tv == '1' ? false : true;

    await profileRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userIdKey, user?.id.toString() ?? '-1');
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.userEmailKey, user?.email ?? '');
    await profileRepo.apiClient.sharedPreferences.setString(
        SharedPreferenceHelper.userPhoneNumberKey, user?.mobile ?? '');
    await profileRepo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.userNameKey, user?.username ?? '');

    if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen);
    } else {
      PushNotificationService(apiClient: Get.find()).sendUserToken();
      Get.offAndToNamed(RouteHelper.homeScreen);
    }
  }
}
