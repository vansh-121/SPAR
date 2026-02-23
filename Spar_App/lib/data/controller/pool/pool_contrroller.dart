import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/agreement_helper.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/account/profile_controller.dart';
import 'package:hyip_lab/data/model/authorization/authorization_response_model.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/pool/pool_response_model.dart';
import 'package:hyip_lab/data/model/user/user.dart';
import 'package:hyip_lab/data/repo/pool/pool_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class PoolController extends GetxController {
  PoolRepo poolRepo;
  ProfileController profileController;

  PoolController({required this.poolRepo, required this.profileController});

  bool isLoading = true;
  TextEditingController amountController = TextEditingController();
  FocusNode amountFocused = FocusNode();

  String currency = '';
  String curSymbol = '';

  List<Pool> poolList = [];

  int selectedIndex = 0;
  void changeSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }

  String planID = '';
  void changePlanID(String id) {
    planID = id;
    update();
  }

  String selectedWallet = MyStrings.selectOne;
  //List<String> list = [profileController.depositWallet, profileController.interestWallet];
  List<String> walletList = [
    MyStrings.selectOne,
    MyStrings.depositWallet,
    MyStrings.interestWallet
  ];
  void selectwallet(String wallet) {
    selectedWallet = wallet;
    update();
  }

  Future<void> loadData() async {
    selectedIndex = -1;
    poolList.clear();
    selectedWallet = '';
    planID = "-1";
    curSymbol = poolRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    currency = poolRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    isLoading = true;
    update();

    await getPoolData();
    await profileController.loadProfileInfo();

    walletList[1] =
        "${MyStrings.depositWallet} - ${Converter.twoDecimalPlaceFixedWithoutRounding(profileController.depositWallet)}";
    walletList[2] =
        "${MyStrings.interestWallet} - ${Converter.twoDecimalPlaceFixedWithoutRounding(profileController.interestWallet)}";

    isLoading = false;
    update();
  }

  Future<void> getPoolData() async {
    selectedIndex = -1;

    isLoading = true;
    update();

    final responseModal = await poolRepo.getPoolPlans();
    if (responseModal.statusCode == 200) {
      PoolResponseModel model =
          PoolResponseModel.fromJson(jsonDecode(responseModal.responseJson));
      if (model.status == MyStrings.success) {
        if (model.data != null) {
          List<Pool> tempPoolList = model.data?.pools?.toList() ?? [];
          print(tempPoolList.length.toString() + ">>>>>>templist>>>>>>>>>");

          if (tempPoolList.isNotEmpty) {
            poolList.clear();
            poolList.addAll(tempPoolList);
            print(poolList.length.toString() + ">>>>>>>pollist>>>>>>>>");
          }
          update();
        }
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModal.message]);
    }
    isLoading = false;
    update();
  }

  bool isSubmitLoading = false;

  Future<void> submitPool() async {
    isSubmitLoading = true;
    update();
    
    // Check agreement verification before proceeding with pool investment
    User? user = profileController.model.data?.user;
    if (!AgreementHelper.checkAndShowError(user, userEmail: user?.email)) {
      isSubmitLoading = false;
      update();
      return;
    }
    
    if (planID == '' || planID == '-1') {
      CustomSnackBar.error(errorList: ["Select a Pool"]);
      Get.back();
    } else if (selectedWallet == '' || selectedWallet == MyStrings.selectOne) {
      CustomSnackBar.error(errorList: [MyStrings.selectWallet]);
    } else if (amountController.text == '' || amountController.text.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.enterAmount]);
    } else {
      String wallet =
          Converter.replaceSpaceToUnderscore(selectedWallet.split(" -")[0]);

      ResponseModel responseModel = await poolRepo.savePool(
          poolID: planID, amount: amountController.text, wallet: wallet);
      if (responseModel.statusCode == 200) {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
            jsonDecode(responseModel.responseJson));
        if (model.status.toString().toLowerCase() ==
            MyStrings.success.toLowerCase()) {
          Get.offNamed(RouteHelper.homeScreen);
          CustomSnackBar.success(
              successList:
                  model.message?.success ?? [MyStrings.requestSuccess]);
        } else {
          CustomSnackBar.error(
              errorList:
                  model.message?.error ?? [MyStrings.somethingWentWrong]);
        }
      } else {
        CustomSnackBar.error(errorList: [responseModel.message]);
      }
    }
    isSubmitLoading = false;
    update();
  }

  double getPercent(int index) {
    double percent = 0;
    try {
      double investedAmount =
          double.tryParse(poolList[index].investedAmount ?? '0') ?? 0;
      double amount = double.tryParse(poolList[index].amount ?? '0') ?? 0;
      percent = (investedAmount / amount);
    } catch (e) {
      percent = 0;
    }
    return percent;
  }
}
