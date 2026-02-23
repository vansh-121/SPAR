import 'dart:convert';
import 'dart:math';

import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/data/repo/plan/plan_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';
import 'package:hyip_lab/data/model/my_investment/my_investment_response_model.dart'
    as inv;
import 'package:hyip_lab/core/utils/url.dart';

class PlanController extends GetxController {
  PlanRepo planRepo;
  PlanController({required this.planRepo});

  bool isLoading = true;
  List<Plans> planList = [];
  String currency = '';
  String curSymbol = '';

  // Track which plans user already owns
  Set<String> ownedPlanIds = {};

  Future<void> getAllPackageData() async {
    selectedIndex = -1;
    isLoading = true;
    update();
    currency = planRepo.apiClient.getCurrencyOrUsername();
    curSymbol = planRepo.apiClient.getCurrencyOrUsername(isSymbol: true);

    // Fetch owned plans first
    await _loadOwnedPlans();

    ResponseModel responseModel = await planRepo.getPackagesData();
    if (responseModel.statusCode == 200) {
      PricingPlanModel planModel =
          PricingPlanModel.fromJson(jsonDecode(responseModel.responseJson));
      if (planModel.status.toString().toLowerCase() == "success") {
        List<Plans>? tempPackageList = planModel.data?.plans;
        if (tempPackageList != null && tempPackageList.isNotEmpty) {
          planList.addAll(tempPackageList);
        }
      } else {
        CustomSnackBar.showCustomSnackBar(
            errorList:
                planModel.message?.error ?? [MyStrings.somethingWentWrong],
            msg: [],
            isError: true);
      }
    } else {
      CustomSnackBar.showCustomSnackBar(
          errorList: [], msg: [responseModel.message], isError: true);
    }

    isLoading = false;
    update();
  }

  int selectedIndex = 0;
  void changeSelectedIndex(int index) {
    selectedIndex = index;
    update();
  }

  String getAmount(int index) {
    double fixedAmt = double.tryParse(planList[index].fixedAmount ?? '') ?? 0.0;
    if (fixedAmt > 0) {
      String formatedAmt =
          Converter.roundDoubleAndRemoveTrailingZero('$fixedAmt');
      return '$formatedAmt $currency';
    } else {
      String minimum = Converter.twoDecimalPlaceFixedWithoutRounding(
          planList[index].minimum ?? '0');
      String maximum = Converter.twoDecimalPlaceFixedWithoutRounding(
          planList[index].maximum ?? '0');
      return '$minimum - $maximum $currency';
    }
  }

  String getTotalReturn(int index) {
    String totalReturn = planList[index].totalReturn ?? '';
    String value = totalReturn;
    try {
      List<String> tempList = totalReturn.split('+');
      value = tempList.first;
      if (tempList.length == 2) {
        value = '$value+ ';
      }
    } catch (e) {
      value = totalReturn;
    }
    return value;
  }

  String getPlanDescription(int index) {
    final plan = planList[index];
    final bool isCompound = plan.compoundInterest == '1';
    final double? monthlyPercent = _extractMonthlyPercentage(plan);

    if (monthlyPercent != null && _isMonthlyPlan(plan)) {
      final double annualPercent = isCompound
          ? _calculateCompoundAnnual(monthlyPercent)
          : _calculateSimpleAnnual(monthlyPercent);

      final String formattedAnnual =
          Converter.twoDecimalPlaceFixedWithoutRounding(
              annualPercent.toString());
      return 'Earn returns of upto $formattedAnnual% annually.';
    }

    final return_ = plan.return_ ?? '';
    final duration = plan.interestDuration ?? '';

    String description = 'Earn $return_ returns $duration with ';

    List<String> features = [];
    if (plan.compoundInterest == '1') {
      features.add('compound interest');
    }
    if (plan.holdCapital == '1') {
      features.add('capital reinvestment');
    }

    if (features.isNotEmpty) {
      description += features.join(' and ');
    } else {
      description += 'flexible investment options';
    }

    return description + '.';
  }

  double? _extractMonthlyPercentage(Plans plan) {
    final rate = plan.return_ ?? '';
    if (rate.isEmpty) return null;

    final String sanitized = rate.replaceAll(RegExp(r'[^0-9\.\-]'), '');
    if (sanitized.isEmpty) return null;

    return double.tryParse(sanitized);
  }

  bool _isMonthlyPlan(Plans plan) {
    final duration = (plan.interestDuration ?? '').toLowerCase();
    final repeat = (plan.repeatTime ?? '').toLowerCase();
    return duration.contains('month') || repeat.contains('month');
  }

  double _calculateSimpleAnnual(double monthlyPercent) {
    return monthlyPercent * 12;
  }

  double _calculateCompoundAnnual(double monthlyPercent) {
    final monthlyDecimal = monthlyPercent / 100;
    final effective = pow(1 + monthlyDecimal, 12) - 1;
    return effective * 100;
  }

  Future<void> _loadOwnedPlans() async {
    ownedPlanIds.clear();
    try {
      final response = await planRepo.apiClient.request(
          '${UrlContainer.baseUrl}${UrlContainer.investUrl}?type=active&page=1',
          'GET',
          null,
          passHeader: true);

      if (response.statusCode == 200) {
        final model = inv.MyInvestmentResponseModel.fromJson(
            jsonDecode(response.responseJson));
        final invests = model.data?.invests?.data ?? [];
        for (final invest in invests) {
          if (invest.planId != null) {
            ownedPlanIds.add(invest.planId.toString());
          }
        }
      }
    } catch (e) {
      // Silent fail - user can still try to invest
    }
  }

  bool isPlanOwned(int index) {
    if (index < 0 || index >= planList.length) return false;
    final planId = planList[index].id?.toString() ?? '';
    return ownedPlanIds.contains(planId);
  }
}
