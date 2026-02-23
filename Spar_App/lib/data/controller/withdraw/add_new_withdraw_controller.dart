import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/agreement_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/amount_validator.dart';
import 'package:hyip_lab/data/controller/account/profile_controller.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/user/user.dart';
import 'package:hyip_lab/data/model/withdraw/withdraw_method_response_model.dart';
import 'package:hyip_lab/data/model/withdraw/withdraw_request_response_model.dart';
import 'package:hyip_lab/data/repo/withdraw/withdraw_repo.dart';

import '../../../core/helper/string_format_helper.dart';
import '../../../view/components/show_custom_snackbar.dart';
import '../../model/profile/profile_response_model.dart';

class AddNewWithdrawController extends GetxController {
  WithdrawRepo repo;
  AddNewWithdrawController({required this.repo});
  bool isLoading = true;
  List<WithdrawMethod> withdrawMethodList = [];
  String currency = '';

  TextEditingController amountController = TextEditingController();
  bool submitLoading = false;

  // Wallet selection
  List<String> walletList = [
    MyStrings.selectAWallet.tr,
    MyStrings.depositWallet.tr,
    MyStrings.interestWallet.tr
  ];
  String selectedWallet = MyStrings.selectAWallet.tr;

  // User wallet balances for debugging
  String depositWalletBalance = '0.00';
  String interestWalletBalance = '0.00';

  void changeWallet(String value) {
    selectedWallet = value;
    developer.log('🔄 WALLET CHANGED: $value', name: 'WithdrawController');
    developer.log('💰 Current Deposit Wallet: $depositWalletBalance $currency',
        name: 'WithdrawController');
    developer.log(
        '💰 Current Interest Wallet: $interestWalletBalance $currency',
        name: 'WithdrawController');
    update();
  }

  WithdrawMethod? withdrawMethod = WithdrawMethod();
  String depositLimit = '';
  String charge = '';
  String payableText = '';
  String conversionRate = '';
  String inLocal = '';

  double rate = 1;
  double mainAmount = 0;
  setWithdrawMethod(WithdrawMethod? method) {
    withdrawMethod = method;
    depositLimit =
        '${MyStrings.depositLimit.tr}: ${Converter.twoDecimalPlaceFixedWithoutRounding(method?.minLimit ?? '-1')} - ${Converter.twoDecimalPlaceFixedWithoutRounding(method?.maxLimit?.toString() ?? '-1')} ${method?.currency}';
    charge =
        '${MyStrings.charge.tr}: ${Converter.twoDecimalPlaceFixedWithoutRounding(method?.fixedCharge?.toString() ?? '0')} + ${Converter.twoDecimalPlaceFixedWithoutRounding(method?.percentCharge?.toString() ?? '0')} %';
    update();

    String amt = amountController.text.toString();
    mainAmount = amt.isEmpty ? 0 : double.tryParse(amt) ?? 0;
    withdrawMethod = method;
    depositLimit =
        '${Converter.twoDecimalPlaceFixedWithoutRounding(method?.minLimit?.toString() ?? '-1')} - ${Converter.twoDecimalPlaceFixedWithoutRounding(method?.maxLimit?.toString() ?? '-1')} $currency';
    changeInfoWidgetValue(mainAmount);
    update();
  }

  void changeInfoWidgetValue(double amount) {
    mainAmount = amount;
    double percent = double.tryParse(withdrawMethod?.percentCharge ?? '0') ?? 0;
    double percentCharge = (amount * percent) / 100;
    double temCharge = double.tryParse(withdrawMethod?.fixedCharge ?? '0') ?? 0;
    double totalCharge = percentCharge + temCharge;
    charge =
        '${Converter.twoDecimalPlaceFixedWithoutRounding('$totalCharge')} $currency';
    double payable = amount - totalCharge;
    payableText = '$payable $currency';

    rate = double.tryParse(withdrawMethod?.rate ?? '0') ?? 0;
    conversionRate = '1 $currency = $rate ${withdrawMethod?.currency ?? ''}';
    inLocal =
        Converter.twoDecimalPlaceFixedWithoutRounding('${payable * rate}');
    update();
    return;
  }

  WithdrawMethodResponseModel model = WithdrawMethodResponseModel();
  Future<void> loadDepositMethod() async {
    currency = repo.apiClient.getCurrencyOrUsername();
    clearPreviousValue();
    WithdrawMethod method1 = WithdrawMethod(
        id: -1,
        name: MyStrings.selectOne,
        currency: "",
        minLimit: "0",
        maxLimit: "0",
        percentCharge: "",
        fixedCharge: "",
        rate: "");
    withdrawMethodList.insert(0, method1);
    setWithdrawMethod(withdrawMethodList[0]);

    isLoading = true;
    update();

    // Fetch user wallet balances for debugging
    await fetchUserWalletBalances();

    ResponseModel responseModel = await repo.getAllWithdrawMethod();

    if (responseModel.statusCode == 200) {
      model = WithdrawMethodResponseModel.fromJson(
          jsonDecode(responseModel.responseJson));
      calculateTime(model.data?.nextWorkingDay ?? "0.00");

      if (model.status == 'success') {
        List<WithdrawMethod>? tempMethodList = model.data?.withdrawMethod;
        if (tempMethodList != null && tempMethodList.isNotEmpty) {
          withdrawMethodList.addAll(tempMethodList);
        }
      } else {
        CustomSnackBar.error(
          errorList: model.message?.error ?? [MyStrings.somethingWentWrong],
        );
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }

  // Fetch user wallet balances for debugging
  Future<void> fetchUserWalletBalances() async {
    try {
      ResponseModel response = await repo.getUserWalletBalances();
      if (response.statusCode == 200) {
        ProfileResponseModel profileModel =
            ProfileResponseModel.fromJson(jsonDecode(response.responseJson));
        if (profileModel.status?.toLowerCase() == 'success') {
          depositWalletBalance =
              profileModel.data?.user?.depositWallet ?? '0.00';
          interestWalletBalance =
              profileModel.data?.user?.interestWallet ?? '0.00';

          developer.log('═══════════════════════════════════════',
              name: 'WithdrawController');
          developer.log('📊 USER WALLET BALANCES LOADED',
              name: 'WithdrawController');
          developer.log('💵 Deposit Wallet: $depositWalletBalance $currency',
              name: 'WithdrawController');
          developer.log('💵 Interest Wallet: $interestWalletBalance $currency',
              name: 'WithdrawController');
          developer.log('═══════════════════════════════════════',
              name: 'WithdrawController');
          update();
        } else {
          developer.log(
              '⚠️ Unexpected wallet balance status: '
              '${profileModel.status}',
              name: 'WithdrawController');
        }
      } else {
        developer.log(
            '⚠️ Wallet balance request failed '
            'with message: ${response.message}',
            name: 'WithdrawController');
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error fetching wallet balances: $e',
          name: 'WithdrawController', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> submitWithdrawRequest() async {
    String amount = amountController.text;
    String id = withdrawMethod?.id.toString() ?? '-1';

    developer.log('═══════════════════════════════════════',
        name: 'WithdrawController');
    developer.log('🚀 WITHDRAWAL REQUEST INITIATED',
        name: 'WithdrawController');

    // Check agreement verification before proceeding with withdrawal
    try {
      ProfileController profileController = Get.find<ProfileController>();
      User? user = profileController.model.data?.user;
      if (!AgreementHelper.checkAndShowError(user, userEmail: user?.email)) {
        return;
      }
    } catch (_) {
      // ProfileController not found, continue without agreement check
    }

    if (amount.isEmpty) {
      CustomSnackBar.error(errorList: [
        '${MyStrings.please} ${MyStrings.enterAmount.toLowerCase()}'
      ]);
      return;
    }

    // Validate amount is in multiples of 100
    String? validationError =
        AmountValidator.validateHundredDenomination(amount);
    if (validationError != null) {
      CustomSnackBar.error(errorList: [validationError]);
      return;
    }

    if (selectedWallet == MyStrings.selectAWallet.tr) {
      CustomSnackBar.error(errorList: [
        '${MyStrings.please} ${MyStrings.selectAWallet.toLowerCase()}'
      ]);
      return;
    }

    if (id == '-1') {
      CustomSnackBar.error(errorList: [
        '${MyStrings.please} ${MyStrings.selectGateway.toLowerCase()}'
      ]);
      return;
    }

    double amount1 = 0;
    double maxAmount = 0;
    try {
      amount1 = double.parse(amount);
      maxAmount = double.parse(withdrawMethod?.maxLimit ?? '0');
    } catch (e) {
      developer.log('❌ Error parsing amount: $e', name: 'WithdrawController');
      return;
    }
    if (maxAmount == 0 || amount1 == 0) {
      List<String> errorList = [MyStrings.invalidAmount];
      CustomSnackBar.showCustomSnackBar(
          errorList: errorList, msg: [], isError: true);
      return;
    }

    submitLoading = true;
    update();

    String wallet = selectedWallet.toLowerCase().replaceAll(' ', '_');

    // Debug logging before API call
    developer.log('📤 REQUEST DETAILS:', name: 'WithdrawController');
    developer.log('   • Selected Wallet: $selectedWallet',
        name: 'WithdrawController');
    developer.log('   • Wallet Parameter: $wallet', name: 'WithdrawController');
    developer.log('   • Method Code: ${withdrawMethod?.id}',
        name: 'WithdrawController');
    developer.log('   • Method Name: ${withdrawMethod?.name}',
        name: 'WithdrawController');
    developer.log('   • Amount Requested: $amount1 $currency',
        name: 'WithdrawController');
    developer.log('   • Max Limit: $maxAmount $currency',
        name: 'WithdrawController');
    developer.log('', name: 'WithdrawController');
    developer.log('💰 CURRENT BALANCES:', name: 'WithdrawController');
    developer.log('   • Deposit Wallet: $depositWalletBalance $currency',
        name: 'WithdrawController');
    developer.log('   • Interest Wallet: $interestWalletBalance $currency',
        name: 'WithdrawController');

    ResponseModel response = await repo.addWithdrawRequest(
        withdrawMethod?.id ?? -1, amount1, wallet);

    developer.log('', name: 'WithdrawController');
    developer.log('📥 RESPONSE RECEIVED:', name: 'WithdrawController');
    developer.log('   • Status Code: ${response.statusCode}',
        name: 'WithdrawController');
    developer.log('   • Response Message: ${response.message}',
        name: 'WithdrawController');

    if (response.statusCode == 200) {
      WithdrawRequestResponseModel model =
          WithdrawRequestResponseModel.fromJson(
              jsonDecode(response.responseJson));

      developer.log('   • API Status: ${model.status}',
          name: 'WithdrawController');
      developer.log('   • Full Response: ${response.responseJson}',
          name: 'WithdrawController');

      if (model.status == MyStrings.success) {
        developer.log('✅ WITHDRAWAL REQUEST SUCCESS',
            name: 'WithdrawController');
        developer.log('═══════════════════════════════════════',
            name: 'WithdrawController');
        Get.offAndToNamed(RouteHelper.confirmWithdrawRequest,
            arguments: [model, withdrawMethod?.name]);
      } else {
        developer.log('❌ WITHDRAWAL REQUEST FAILED',
            name: 'WithdrawController');
        developer.log('   • Error Messages: ${model.message?.error}',
            name: 'WithdrawController');
        developer.log('═══════════════════════════════════════',
            name: 'WithdrawController');
        CustomSnackBar.showCustomSnackBar(
            errorList: model.message?.error ?? [MyStrings.requestFail],
            msg: [],
            isError: true);
      }
    } else {
      developer.log('❌ HTTP ERROR', name: 'WithdrawController');
      developer.log('   • Message: ${response.message}',
          name: 'WithdrawController');
      developer.log('═══════════════════════════════════════',
          name: 'WithdrawController');
      CustomSnackBar.showCustomSnackBar(
          errorList: [response.message], msg: [], isError: true);
    }

    submitLoading = false;
    update();
  }

  bool isShowRate() {
    if (rate > 1 &&
        currency.toLowerCase() != withdrawMethod?.currency?.toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  void clearPreviousValue() {
    withdrawMethodList.clear();
    amountController.text = '';
    rate = 1;
    submitLoading = false;
    withdrawMethod = WithdrawMethod();
    selectedWallet = MyStrings.selectAWallet.tr;
  }

  int days = 0;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  void calculateTime(String secStr) {
    double sec = double.tryParse(secStr) ?? 0.0; // Convert string to double
    int totalSeconds =
        sec.toInt(); // Convert double to int for time calculations
    days = totalSeconds ~/ (24 * 60 * 60);
    hours = (totalSeconds % (24 * 60 * 60)) ~/ (60 * 60);
    minutes = (totalSeconds % (60 * 60)) ~/ 60;
    seconds = totalSeconds % 60;
    update();
  }
}
