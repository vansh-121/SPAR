import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/agreement_helper.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/amount_validator.dart';
import 'package:hyip_lab/data/controller/account/profile_controller.dart';
import 'package:hyip_lab/data/model/authorization/authorization_response_model.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/staking/staking_response_model.dart';
import 'package:hyip_lab/data/model/user/user.dart';
import 'package:hyip_lab/data/repo/staking/staking_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class StakingController extends GetxController {
  StakingRepo stakingRepo;
  ProfileController profileController;

  StakingController({required this.stakingRepo, required this.profileController});

  bool isLoading = false;
  TextEditingController amountController = TextEditingController();
  FocusNode amountFocused = FocusNode();

  String currency = '';
  String curSymbol = '';

  List<Staking> staking = [];
  List<MyStakings> myStakings = [];
  String? nextpageUrl;
  int currentPage = 0;
  String selectedWallet = MyStrings.selectOne;

  List<String> walletList = [MyStrings.selectOne,MyStrings.depositWallet, MyStrings.interestWallet];
  void selectwallet(String wallet) {
    selectedWallet = wallet;
    update();
  }

  Staking? selectedStak = Staking(id: -1);

  selectStak(Staking? stak) {
    selectedStak = stak;
    String amount = amountController.text;
    if(amount.isNotEmpty){
      calculateReturnAmount(amount);
    }
    update();
  }

  String stackingLimit = '';
  Future<void> loadData() async {
    isLoading = true;
    update();
    currentPage = 0;
    curSymbol = stakingRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    currency = stakingRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    nextpageUrl;


    String stackingMin = Converter.twoDecimalPlaceFixedWithoutRounding(stakingRepo.apiClient.getGSData().data?.generalSetting?.stakingMinAmount ?? "0.0");
    String stackingMax = Converter.twoDecimalPlaceFixedWithoutRounding(stakingRepo.apiClient.getGSData().data?.generalSetting?.stakingMaxAmount ?? "0.0");

    stackingLimit = "($stackingMin - $stackingMax)";

    update();
    await getStakingData();
    await profileController.loadProfileInfo();

    isLoading = false;
    update();
  }

  Future<void> getStakingData() async {
    if (currentPage == 0) {
      currentPage = currentPage + 1;
    } else {
      currentPage++;
    }
    update();
    ResponseModel responseModel = await stakingRepo.getStakData(currentPage);
    if (responseModel.statusCode == 200) {
      StakingResponseModel model = StakingResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status!.toLowerCase() == MyStrings.success.toLowerCase()) {
        final data = model.data;
        if (data != null) {
          nextpageUrl = data.myStakings?.nextPageUrl;

          List<Staking> temstaking = data.staking?.toList() ?? [];

          staking.add(Staking(id: -1));
          staking.addAll(temstaking);
          selectedStak = staking[0];

          List<MyStakings> tempMystaking = data.myStakings?.data?.toList() ?? [];
          myStakings.addAll(tempMystaking);
          update();

          log(staking.length.toString());
          log(myStakings.length.toString());
        }
        log(staking.length.toString());
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  Future<void> getStakingPaginateData() async {
    if (currentPage == 0) {
      currentPage = currentPage + 1;
    } else {
      currentPage++;
    }
    update();
    ResponseModel responseModel = await stakingRepo.getStakData(currentPage);
    if (responseModel.statusCode == 200) {
      StakingResponseModel model = StakingResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status!.toLowerCase() == MyStrings.success.toLowerCase()) {
        final data = model.data;
        if (data != null) {
          nextpageUrl = data.myStakings?.nextPageUrl;

          List<Staking> temstaking = data.staking?.toList() ?? [];
          staking.addAll(temstaking);

          List<MyStakings> tempMystaking = data.myStakings?.data?.toList() ?? [];
          myStakings.addAll(tempMystaking);
          update();
        }

        log(staking.length.toString());
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  bool isSubmitLoading = false;
  Future<void> submiStaking() async {

    isSubmitLoading = true;
    update();
    
    // Check agreement verification before proceeding with staking investment
    User? user = profileController.model.data?.user;
    if (!AgreementHelper.checkAndShowError(user, userEmail: user?.email)) {
      isSubmitLoading = false;
      update();
      return;
    }
    
    if (selectedStak == null || selectedStak?.id == -1) {
      CustomSnackBar.error(errorList: [MyStrings.selectDuration]);
    } else if (selectedWallet == '' || selectedWallet == MyStrings.selectOne) {
      CustomSnackBar.error(errorList: [MyStrings.selectWallet]);
    } else if (amountController.text == '' || amountController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
    } else {
      // Validate amount is in multiples of 100
      String? validationError = AmountValidator.validateHundredDenomination(amountController.text);
      if(validationError != null){
        CustomSnackBar.error(errorList: [validationError]);
        isSubmitLoading = false;
        update();
        return;
      }

      String wallet = Converter.replaceSpaceToUnderscore(selectedWallet);
      ResponseModel responseModel = await stakingRepo.submitStak(duration: selectedStak!.id.toString(), amount: amountController.text, wallet: wallet);
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
        if (model.status == MyStrings.success) {
          Get.offAllNamed(RouteHelper.homeScreen);
          CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.stackingSuccessMsg]);
        } else {
          CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    }

    isSubmitLoading = false;
    update();
  }

  bool hasNext() {
    return nextpageUrl != null && nextpageUrl!.isNotEmpty ? true : false;
  }

  String returnAmount = "";
  void calculateReturnAmount(String value) {
    double userInputAmount = double.tryParse(value)??0.0;
    double interest = double.tryParse(selectedStak?.interestPercent??"0.0")??0.0;
    double amount = (userInputAmount * interest)/100;
    returnAmount = Converter.twoDecimalPlaceFixedWithoutRounding("${amount + userInputAmount}");
    update();
  }
}
