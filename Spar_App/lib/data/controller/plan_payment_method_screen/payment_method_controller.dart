import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/agreement_helper.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/amount_validator.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_method_response_model.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_insert_response_model.dart'
    as DepositInsert;
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/data/model/plan/plan_response_model.dart';
import 'package:hyip_lab/data/model/profile/profile_response_model.dart';
import 'package:hyip_lab/data/model/user/user.dart';
import 'package:hyip_lab/data/repo/deposit_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class PaymentMethodController extends GetxController {
  DepositRepo repo;
  PaymentMethodController({required this.repo});

  late Plans plan;
  loadData(Plans plan) async {
    isScheduleInvestOn = repo.apiClient.getSheduleStatus();
    print(isScheduleInvestOn + "--------------------------");

    this.plan = plan;
    investmentPeriodMonths = _deriveInvestmentPeriodMonths(plan);
    investmentPeriodController.text =
        investmentPeriodMonths > 0 ? '$investmentPeriodMonths' : '';

    // SIP is independent of compound interest - show for all plans if enabled from backend
    if (isScheduleInvestOn == "0") {
      // SIP feature is disabled from backend
      investMethod = MyStrings.investNow_;
      enableSip = false;
    } else {
      // SIP is enabled - auto-enable schedule mode for all plans
      investMethod = MyStrings.schedule;
      enableSip = true;
      calculateSipSchedule();
    }

    configureAmountField(plan);
    isLoading = true;
    update();
    await beforeInitLoadData();
    // Auto-select the only available gateway (no dropdown shown)
    if (paymentMethodList.isNotEmpty) {
      setPaymentMethod(paymentMethodList.first);
    } else {
      CustomSnackBar.error(
          errorList: ['No payment gateway available. Please contact support.']);
    }
    isLoading = false;
    update();
  }

  bool isFixed = false;
  String investAmount = '';
  String interestAmount = '';
  void configureAmountField(Plans plan) {
    String fixed = Converter.twoDecimalPlaceFixedWithoutRounding(
        plan.fixedAmount ?? '0.0');
    double fixedAmt = double.tryParse(fixed) ?? 0.0;
    if (fixedAmt > 0) {
      investAmount = '$curSymbol$fixed';
      isFixed = true;
      amountController.text = fixed;
    } else {
      String minAmount =
          Converter.twoDecimalPlaceFixedWithoutRounding(plan.minimum ?? '0');
      String maxAmount =
          Converter.twoDecimalPlaceFixedWithoutRounding(plan.maximum ?? '0');
      investAmount = '$curSymbol$minAmount - $curSymbol$maxAmount';
    }
    interestAmount = plan.return_ ?? '0.0';
    update();
  }

  TextEditingController amountController = TextEditingController();
  TextEditingController sheduleForController = TextEditingController();
  TextEditingController afterController = TextEditingController();
  TextEditingController investmentPeriodController = TextEditingController();

  bool isLoading = true;
  String currency = '';
  String curSymbol = '';
  Methods? paymentMethod;
  String investMethod = MyStrings.selectOne;
  bool isTopup = false;
  int? topupInvestId;
  String depositLimit = '';
  String charge = '';
  String payableText = '';
  String conversionRate = '';
  String inLocal = '';
  String isScheduleInvestOn = "0";

  // SIP Frequency variables
  String sipFrequency = 'Monthly';
  int calculatedScheduleTimes = 12;
  int calculatedHours = 730;
  int investmentPeriodMonths = 12;
  bool enableSip = false;

  List<Methods> paymentMethodList = [];
  List<String> investMethodList = [
    MyStrings.selectOne,
    MyStrings.schedule,
    MyStrings.investNow_
  ];

  setInvestMethod(String value) {
    investMethod = value;
    enableSip = value.toLowerCase() == 'schedule';
    if (value.toLowerCase() == 'invest_now') {
      enableSip = false;
      sipFrequency = 'Monthly';
      calculateSipSchedule();
    } else if (value.toLowerCase() == 'schedule') {
      enableSip = true;
      calculateSipSchedule();
    }
    update();
  }

  void setSipFrequency(String frequency) {
    sipFrequency = frequency;
    calculateSipSchedule();
    update();
  }

  void calculateSipSchedule() {
    final int periodMonths =
        investmentPeriodMonths > 0 ? investmentPeriodMonths : 12;

    switch (sipFrequency) {
      case 'Hourly':
        calculatedScheduleTimes = periodMonths * 30 * 24;
        calculatedHours = 1;
        break;
      case 'Weekly':
        int weeklyCycles = periodMonths * 4;
        calculatedScheduleTimes = weeklyCycles > 0 ? weeklyCycles : 1;
        calculatedHours = 168;
        break;
      case 'Monthly':
        calculatedScheduleTimes = periodMonths > 0 ? periodMonths : 1;
        calculatedHours = 730;
        break;
      case 'Quarterly':
        int quarterlyCycles = (periodMonths / 3).ceil();
        calculatedScheduleTimes = quarterlyCycles > 0 ? quarterlyCycles : 1;
        calculatedHours = 2190;
        break;
      default:
        calculatedScheduleTimes = periodMonths > 0 ? periodMonths : 1;
        calculatedHours = 730;
    }

    sheduleForController.text = calculatedScheduleTimes.toString();
    afterController.text = calculatedHours.toString();
    update();
  }

  int _deriveInvestmentPeriodMonths(Plans plan) {
    final parsed = int.tryParse(plan.repeatTime ?? '');
    if (parsed != null && parsed > 0) {
      return parsed;
    }
    return 12;
  }

  void setInvestmentPeriod(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed <= 0) {
      return;
    }
    investmentPeriodMonths = parsed;
    calculateSipSchedule();
  }

  String getInvestmentPeriodLabel() {
    final months = investmentPeriodMonths;
    if (months <= 0) {
      return 'Flexible';
    }
    final years = months ~/ 12;
    final remainingMonths = months % 12;
    if (years > 0 && remainingMonths > 0) {
      return '${years} Year${years > 1 ? 's' : ''} ${remainingMonths} Month${remainingMonths > 1 ? 's' : ''}';
    } else if (years > 0) {
      return '${years} Year${years > 1 ? 's' : ''}';
    }
    return '${months} Month${months > 1 ? 's' : ''}';
  }

  void setTopupMode({required bool isTopup, int? investId}) {
    this.isTopup = isTopup;
    this.topupInvestId = investId;
    update();
  }

  // Convert hours to readable format
  String getReadableInterval() {
    if (calculatedHours < 24) {
      return calculatedHours == 1
          ? 'Every hour'
          : 'Every $calculatedHours hours';
    } else if (calculatedHours < 168) {
      int days = (calculatedHours / 24).round();
      return days == 1 ? 'Every day' : 'Every $days days';
    } else if (calculatedHours < 730) {
      int weeks = (calculatedHours / 168).round();
      return weeks == 1 ? 'Every week' : 'Every $weeks weeks';
    } else if (calculatedHours < 2190) {
      int months = (calculatedHours / 730).round();
      return months == 1 ? 'Every month' : 'Every $months months';
    } else {
      int quarters = (calculatedHours / 2190).round();
      return quarters == 1 ? 'Every quarter' : 'Every $quarters quarters';
    }
  }

  // Format plan interest validity text (e.g., "Per 2190 hours for lifetime" -> "Every 3 months for lifetime")
  String getFormattedInterestValidity() {
    String text = plan.interestValidity ?? '';
    if (text.isEmpty) return '';

    // Extract hours from text like "Per 2190 hours for lifetime" or "Per 730 hours for 12 Times"
    RegExp hourRegex = RegExp(r'(\d+)\s*hours?', caseSensitive: false);
    Match? match = hourRegex.firstMatch(text);

    if (match != null) {
      int hours = int.parse(match.group(1)!);
      String replacement = _formatHoursToReadable(hours);
      // Replace "Per X hours" with readable format
      return text.replaceAll(
          RegExp(r'Per\s+\d+\s*hours?', caseSensitive: false), replacement);
    }

    return text;
  }

  // Helper to convert hours to readable text
  String _formatHoursToReadable(int hours) {
    if (hours < 24) {
      return hours == 1 ? 'Per hour' : 'Per $hours hours';
    } else if (hours < 168) {
      int days = (hours / 24).round();
      return days == 1 ? 'Per day' : 'Per $days days';
    } else if (hours < 730) {
      int weeks = (hours / 168).round();
      return weeks == 1 ? 'Per week' : 'Per $weeks weeks';
    } else if (hours < 2190) {
      int months = (hours / 730).round();
      return months == 1 ? 'Per month' : 'Per $months months';
    } else {
      int quarters = (hours / 2190).round();
      return quarters == 1 ? 'Per quarter' : 'Per $quarters quarters';
    }
  }

  double rate = 1;
  double mainAmount = 0;
  setPaymentMethod(Methods? method) {
    String amt = amountController.text.toString();
    mainAmount = amt.isEmpty ? 0 : double.tryParse(amt) ?? 0;
    paymentMethod = method;
    if (method == null) {
      depositLimit = '';
      charge = '';
      payableText = '';
      conversionRate = '';
      inLocal = '';
      update();
      return;
    }
    depositLimit =
        '$curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding(method.minAmount ?? '0')} - $curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding(method.maxAmount ?? '0')}';
    changeInfoWidgetValue(mainAmount);
    update();
  }

  void changeInfoWidgetValue(double amount) {
    mainAmount = amount;
    double percent = double.tryParse(paymentMethod?.percentCharge ?? '0') ?? 0;
    double percentCharge = (amount * percent) / 100;
    double temCharge = double.tryParse(paymentMethod?.fixedCharge ?? '0') ?? 0;
    double totalCharge = percentCharge + temCharge;
    charge =
        '$curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding('$totalCharge')}';
    double payable = totalCharge + amount;
    payableText = '$curSymbol$payable';

    rate = double.tryParse(paymentMethod?.rate ?? '0') ?? 0;
    conversionRate = '${curSymbol}1 = ${paymentMethod?.symbol ?? ''}$rate';
    inLocal =
        Converter.twoDecimalPlaceFixedWithoutRounding('${payable * rate}');
    update();
    return;
  }

  Future<void> beforeInitLoadData() async {
    paymentMethodList.clear();
    currency = repo.apiClient.getCurrencyOrUsername();
    curSymbol = repo.apiClient.getCurrencyOrUsername(isSymbol: true);
    paymentMethod = null;

    ResponseModel response = await repo.getDepositMethod();
    if (response.statusCode == 200) {
      DepositMethodResponseModel model = DepositMethodResponseModel.fromJson(
          jsonDecode(response.responseJson));
      if (model.message?.success != null) {
        List<Methods>? tempList = model.data?.methods;
        if (tempList != null && tempList.isNotEmpty) {
          paymentMethodList.addAll(tempList);
          for (final m in tempList) {
            print(
                'Gateway option -> id: ${m.id}, method_code: ${m.methodCode}, name: ${m.name}, currency: ${m.currency}');
          }
        }
        paymentMethod =
            paymentMethodList.isNotEmpty ? paymentMethodList.first : null;
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> retrieveAndAddDepositWalletData() async {
    // No-op: wallet-based plan purchases are disabled by backend
    return;
  }

  bool submitLoading = false;
  void submitDeposit() async {
    int selectedGatewayId = paymentMethod?.id ?? -1;
    print(
        'Submitting invest with gateway -> id: $selectedGatewayId, method_code: ${paymentMethod?.methodCode}, name: ${paymentMethod?.name}');

    // Check if SIP is enabled
    final String sheduleTime = sheduleForController.text.toString();
    final String after = afterController.text.toString();
    final bool isSchedule = enableSip &&
        investMethod.toLowerCase() == 'schedule' &&
        sheduleTime.isNotEmpty &&
        after.isNotEmpty &&
        !isTopup; // SIP only for new investments, not top-ups

    if (!isSchedule && selectedGatewayId <= 0) {
      CustomSnackBar.error(errorList: [MyStrings.selectAWallet]);
      return;
    }

    String walletId = selectedGatewayId.toString();
    // Always use selected gateway id for deposit route
    final String walletForRequest = walletId;
    // Check agreement verification before proceeding with plan investment
    ResponseModel userResponse = await repo.getUserInfo();
    if (userResponse.statusCode == 200) {
      ProfileResponseModel model =
          ProfileResponseModel.fromJson(jsonDecode(userResponse.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        User? user = model.data?.user;
        if (!AgreementHelper.checkAndShowError(user, userEmail: user?.email)) {
          return;
        }
      }
    }

    String amount = amountController.text.toString();

    // Validate amount is in multiples of 100
    if (!isFixed && amount.isNotEmpty) {
      String? validationError =
          AmountValidator.validateHundredDenomination(amount);
      if (validationError != null) {
        CustomSnackBar.error(errorList: [validationError]);
        return;
      }
    }

    if (isFixed) {
      Map<String, dynamic> params = {
        'plan_id': plan.id.toString(),
        'amount': amount.toString(),
        'wallet': walletForRequest,
      };

      if (isTopup) {
        params['invest_time'] = 'invest_now';
        if (topupInvestId != null)
          params['invest_id'] = topupInvestId.toString();
      } else {
        if (isSchedule) {
          params['invest_time'] = 'schedule';
          params['sip_mode'] = '1';
          params['schedule_times'] = sheduleTime;
          params['hours'] = after;
        } else {
          params['invest_time'] = 'invest_now';
        }
      }

      submitInvestment(params);
    } else {
      if (amount.isEmpty) {
        return;
      }

      double mAmount = 0;
      try {
        mAmount = double.parse(amount);
      } catch (e) {
        return;
      }

      double maxAmount = double.tryParse(plan.maximum ?? '0') ?? 0;
      double minAmount = double.tryParse(plan.minimum ?? '0') ?? 0;

      if (mAmount > maxAmount || mAmount < minAmount) {
        CustomSnackBar.showCustomSnackBar(
            errorList: [MyStrings.investmentLimitMsg], msg: [], isError: true);
        return;
      }

      Map<String, dynamic> params = {
        'plan_id': plan.id.toString(),
        'amount': amount.toString(),
        'wallet': walletForRequest,
      };

      if (isTopup) {
        params['invest_time'] = 'invest_now';
        if (topupInvestId != null)
          params['invest_id'] = topupInvestId.toString();
      } else {
        if (isSchedule) {
          params['invest_time'] = 'schedule';
          params['sip_mode'] = '1';
          params['schedule_times'] = sheduleTime;
          params['hours'] = after;
        } else {
          params['invest_time'] = 'invest_now';
        }
      }

      submitInvestment(params);
    }
  }

  void submitInvestment(Map<String, dynamic> params) async {
    submitLoading = true;
    update();

    ResponseModel response = await repo.submitInvestment(params);

    if (response.statusCode == 200) {
      PlanResponseModel model =
          PlanResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == 'success') {
        // Check if this is a manual gateway with form fields (native flow)
        if (model.data?.isManual == true &&
            model.data?.formData != null &&
            model.data!.formData!.isNotEmpty) {
          // Manual payment gateway - show native form
          // Convert PlanResponseModel to DepositInsertResponseModel for the confirm screen
          var depositModel = DepositInsert.DepositInsertResponseModel(
              remark: model.remark,
              status: model.status,
              message: model.message,
              data: DepositInsert.Data(
                redirectUrl: model.data?.redirectUrl,
                track: model.data?.track,
                isManual: model.data?.isManual,
                formData: model.data?.formData,
                depositInstruction: model.data?.depositInstruction,
              ));
          final String gatewayLabel = (paymentMethod?.name != null &&
                  paymentMethod!.name!.toString().trim().isNotEmpty)
              ? paymentMethod!.name!.toString()
              : (paymentMethodList.isNotEmpty &&
                      (paymentMethodList.first.name ?? '').isNotEmpty)
                  ? paymentMethodList.first.name!
                  : 'Payment Gateway';
          Get.offAndToNamed(RouteHelper.confirmDepositRequest,
              arguments: [depositModel, gatewayLabel]);
        }
        // Otherwise use webview flow for automatic gateways
        else {
          String url = model.data?.redirectUrl ?? '';
          if (url.isNotEmpty) {
            loadWebView(url);
          } else {
            Get.back();
            CustomSnackBar.success(
                successList:
                    model.message?.success ?? [MyStrings.requestSuccess]);
          }
        }
      } else {
        final errors = model.message?.error ?? [MyStrings.requestFail];
        final remark = model.remark?.toLowerCase() ?? '';

        if (remark == 'plan_mismatch' || remark == 'not_available') {
          Get.defaultDialog(
            title: 'Plan Unavailable',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Text(
                  errors.first,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            textConfirm: 'Close',
            confirmTextColor: Colors.white,
            onConfirm: () => Get.back(),
          );
        } else {
          CustomSnackBar.error(errorList: errors);
        }
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    submitLoading = false;
    update();
  }

  void loadWebView(String url) {
    Get.offAndToNamed(RouteHelper.depositWebViewScreen, arguments: url);
  }

  void clearData() {
    depositLimit = '';
    charge = '';
    paymentMethodList.clear();
    amountController.text = '';
    sheduleForController.text = '';
    afterController.text = '';
    investmentPeriodMonths = _deriveInvestmentPeriodMonths(plan);
    investmentPeriodController.text =
        investmentPeriodMonths > 0 ? '$investmentPeriodMonths' : '';
    calculateSipSchedule();
    investMethod = MyStrings.selectOne;
    paymentMethod = null;
    isLoading = true;
    submitLoading = false;
    isFixed = false;
  }

  bool isShowRate() {
    if (rate > 1 &&
        currency.toLowerCase() != paymentMethod?.currency?.toLowerCase()) {
      return true;
    } else {
      return false;
    }
  }

  bool isShowPreview() {
    int id = paymentMethod?.id ?? -1;
    return mainAmount > 0 && id > 1
        ? true
        : false; // for deposit and interest you won't show preview widget
  }
}
