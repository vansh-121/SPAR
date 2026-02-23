import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/utils/messages.dart';
import 'package:hyip_lab/data/controller/localization/localization_controller.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/language/language_model.dart';
import 'package:hyip_lab/data/model/language/main_language_response_model.dart';
import 'package:hyip_lab/data/repo/auth/general_setting_repo.dart';
import '../../../core/utils/url.dart';
import '../../../view/components/show_custom_snackbar.dart';


class MyLanguageController extends GetxController {
  GeneralSettingRepo repo;
  LocalizationController localizationController;
  MyLanguageController({required this.repo, required this.localizationController});

  bool isLoading = true;
  String languageImagePath = "";
  List<MyLanguageModel> langList = [];

  void loadLanguage() {
    langList.clear();
    isLoading = true;

    SharedPreferences pref = repo.apiClient.sharedPreferences;
    String languageString = pref.getString(SharedPreferenceHelper.languageListKey) ?? '';

    print(languageString);

    var language = jsonDecode(languageString);

    print("decode ----------- ");
    print(language);
    MainLanguageResponseModel model = MainLanguageResponseModel.fromJson(language);
    languageImagePath = "${UrlContainer.domainUrl}/${model.data?.imagePath ?? ''}";

    print(model.data?.languages);

    if (model.data?.languages != null && model.data!.languages!.isNotEmpty) {
      for (var listItem in model.data!.languages!) {
        MyLanguageModel model = MyLanguageModel(languageCode: listItem.code ?? '', countryCode: listItem.name ?? '', languageName: listItem.name ?? '', imageUrl: listItem.image ?? '');
        langList.add(model);
      }
    }
    print(langList);

    String languageCode = pref.getString(SharedPreferenceHelper.languageCode) ?? 'en';

    if (kDebugMode) {
      print('current lang code: $languageCode');
    }

    if (langList.isNotEmpty) {
      int index = langList.indexWhere((element) => element.languageCode.toLowerCase() == languageCode.toLowerCase());

      changeSelectedIndex(index);
    }

    isLoading = false;
    update();
  }

  String selectedLangCode = 'en';

  bool isChangeLangLoading = false;
  void changeLanguage(int index) async {
    isChangeLangLoading = true;
    update();

    MyLanguageModel selectedLangModel = langList[index];
    String languageCode = selectedLangModel.languageCode;
    try {
      ResponseModel response = await repo.getLanguage(languageCode);

      if (response.statusCode == 200) {
        try{

          Map<String,Map<String,String>> language = {};
          var resJson = jsonDecode(response.responseJson);
          await repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.languageListKey, response.responseJson);
          var value = resJson['data']['file'].toString() == '[]' ? {} : resJson['data']['file'];
          print("pppppp");

          Map<String,String> json = {};
          value.forEach((key, value) {
            json[key] = value.toString();
          });

          language['${langList[index].languageCode}_${'US'}'] = json;

          Get.clearTranslations();
          Get.addTranslations(Messages(languages: language).keys);

          Locale local = Locale(langList[index].languageCode,'US');
          localizationController.setLanguage(local);

          Get.back();
        }catch(e){
          CustomSnackBar.error(errorList: [e.toString()]);
          Get.back();
        }
      } else {
        CustomSnackBar.error(errorList: [response.message]);
      }
    } catch (e) {
      print(e.toString());
    }

    isChangeLangLoading = false;
    update();
  }

  int selectedIndex = 0;
  void changeSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }
}
