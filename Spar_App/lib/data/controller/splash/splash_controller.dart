import 'dart:convert';

import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/messages.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/localization/localization_controller.dart';

import '../../../../view/components/show_custom_snackbar.dart';
import '../../model/general_setting/general_settings_response_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../repo/auth/general_setting_repo.dart';

class SplashController extends GetxController {
  GeneralSettingRepo repo;
  LocalizationController localizationController;
  bool isLoading = true;

  SplashController({required this.repo, required this.localizationController});

  gotoNextPage() async {
    await loadLanguage();
    // Check if user has valid stored token (automatic login)
    bool hasValidToken = _hasValidStoredToken();
    noInternet = false;
    update();

    storeLangDataInLocalStorage();
    loadAndSaveGeneralSettingsData(hasValidToken);
  }

  /// Check if a valid access token exists in SharedPreferences
  /// This enables automatic login without asking user to login again
  bool _hasValidStoredToken() {
    String? accessToken = repo.apiClient.sharedPreferences
        .getString(SharedPreferenceHelper.accessTokenKey);

    // Token exists and is not empty - user can be auto-logged in
    return accessToken != null && accessToken.isNotEmpty;
  }

  bool noInternet = false;
  void loadAndSaveGeneralSettingsData(bool hasValidToken) async {
    ResponseModel response = await repo.getGeneralSetting();

    if (response.statusCode == 200) {
      GeneralSettingResponseModel model = GeneralSettingResponseModel.fromJson(
          jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success) {
        repo.apiClient.storeGeneralSetting(model);
      } else {
        List<String> message = [MyStrings.somethingWentWrong];
        CustomSnackBar.error(errorList: model.message?.error ?? message);
      }
    } else {
      if (response.statusCode == 503) {
        noInternet = true;
        update();
      }
      CustomSnackBar.error(errorList: [response.message]);
    }

    isLoading = false;
    update();

    bool appOpeningStatus = repo.apiClient.sharedPreferences
            .getBool(SharedPreferenceHelper.firstTimeAppOpeningStatus) ??
        true;

    if (appOpeningStatus) {
      Get.toNamed(RouteHelper.onboardScreen);
    } else {
      // If user has a valid stored token, skip login screen
      if (hasValidToken) {
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAndToNamed(RouteHelper.homeScreen);
        });
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAndToNamed(RouteHelper.loginScreen);
        });
      }
    }
  }

  Future<bool> storeLangDataInLocalStorage() {
    if (!repo.apiClient.sharedPreferences
        .containsKey(SharedPreferenceHelper.countryCode)) {
      return repo.apiClient.sharedPreferences.setString(
          SharedPreferenceHelper.countryCode,
          MyStrings.myLanguages[0].countryCode);
    }
    if (!repo.apiClient.sharedPreferences
        .containsKey(SharedPreferenceHelper.languageCode)) {
      return repo.apiClient.sharedPreferences.setString(
          SharedPreferenceHelper.languageCode,
          MyStrings.myLanguages[0].languageCode);
    }
    return Future.value(true);
  }

  Future<void> loadLanguage() async {
    localizationController.loadCurrentLanguage();
    String languageCode = localizationController.locale.languageCode;

    ResponseModel response = await repo.getLanguage(languageCode);
    if (response.statusCode == 200) {
      try {
        Map<String, Map<String, String>> language = {};
        var resJson = jsonDecode(response.responseJson);
        saveLanguageList(response.responseJson);
        var value = resJson['data']['file'].toString() == '[]'
            ? {}
            : resJson['data']['file'];
        Map<String, String> json = {};
        value.forEach((key, value) {
          json[key] = value.toString();
        });
        language[
                '${localizationController.locale.languageCode}_${localizationController.locale.countryCode}'] =
            json;
        Get.addTranslations(Messages(languages: language).keys);
      } catch (e) {
        CustomSnackBar.error(errorList: [e.toString()]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  void saveLanguageList(String languageJson) async {
    await repo.apiClient.sharedPreferences
        .setString(SharedPreferenceHelper.languageListKey, languageJson);
    return;
  }
}
