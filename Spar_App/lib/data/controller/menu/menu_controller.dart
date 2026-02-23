import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/authorization/authorization_response_model.dart';
import 'package:hyip_lab/data/model/general_setting/general_settings_response_model.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/user/user_info_response_model.dart';
import 'package:hyip_lab/data/repo/auth/general_setting_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';
import '../../../core/helper/shared_preference_helper.dart';

class MenuController extends GetxController  {

  GeneralSettingRepo repo;
  bool isLoading = true;
  bool noInternet = false;

  bool balTransferEnable = true;
  bool langSwitchEnable = true;
  bool poolInvestEnable = true;
  bool scheduleInvestEnable = true;
  bool stackingInvestEnable = true;
  bool userRankEnable = true;

  MenuController({required this.repo});

  void loadData()async{
    isLoading = true;
    update();
    await configureMenuItem();
    await loadUserInfo();
    isLoading = false;
    update();
  }

  configureMenuItem()async{

    ResponseModel response = await repo.getGeneralSetting();

    if(response.statusCode==200){
      GeneralSettingResponseModel model =
      GeneralSettingResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase()==MyStrings.success.toLowerCase()) {
        bool bTransferStatus  = model.data?.generalSetting?.bTransfer== '0'?false:true;
        poolInvestEnable  = model.data?.generalSetting?.poolOption == '0'?false:true;
        scheduleInvestEnable  = model.data?.generalSetting?.scheduleInvest == '0'?false:true;
        stackingInvestEnable  = model.data?.generalSetting?.stakingOption == '0'?false:true;
        userRankEnable  = model.data?.generalSetting?.userRanking == '0'?false:true;
        langSwitchEnable = model.data?.generalSetting?.multiLanguage == '0'?false:true;
        balTransferEnable = bTransferStatus;
        repo.apiClient.storeGeneralSetting(model);
        update();
      }
      else {
        List<String>message=[MyStrings.somethingWentWrong];
        CustomSnackBar.error(errorList:model.message?.error??message);
        return;
      }
    }else{
      if(response.statusCode==503){
        noInternet=true;
        update();
      }
      CustomSnackBar.error(errorList:[response.message]);
      return;
    }
  }


  TextEditingController passwordDeleteController = TextEditingController();
  bool isDeleteBtnLoading = false;
  Future<void>deleteAccount() async{
    String password = passwordDeleteController.text;
    if(password.isEmpty){
      CustomSnackBar.error(errorList: [MyStrings.passwordEmptyMsg]);
      return;
    }

    isDeleteBtnLoading = true;
    update();

    ResponseModel response = await repo.deleteAccount(password);

    if(response.statusCode==200){
      AuthorizationResponseModel model =
      AuthorizationResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase()==MyStrings.success.toLowerCase()) {
       repo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
       repo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, "");

       Get.offAllNamed(RouteHelper.loginScreen);
       CustomSnackBar.error(errorList:model.message?.success??[MyStrings.accountDeletedSuccessfully]);
      }
      else {
        List<String>message=[MyStrings.somethingWentWrong];
        CustomSnackBar.error(errorList:model.message?.error??message);
      }
    }else{
      if(response.statusCode==503){
        noInternet=true;
        update();
      }
      CustomSnackBar.error(errorList:[response.message]);
    }

    isDeleteBtnLoading = false;
    update();
  }


  bool isSocialSignIn = false;
  Future<void>loadUserInfo()async{

    ResponseModel response = await repo.getUserInfo();

    if(response.statusCode == 200){

      UserInfoResponseModel model =  UserInfoResponseModel.fromJson(jsonDecode(response.responseJson));

      if(model.status == 'success'){
        isSocialSignIn = model.data?.user?.provider == "google" || model.data?.user?.provider == "linkedin";
      }else{
        CustomSnackBar.error(errorList: model.message?.error??[MyStrings.somethingWentWrong]);
      }
    }else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

}