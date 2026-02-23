import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/agreement_helper.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/dashboard/dashboard_response_model.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/my_investment/my_investment_response_model.dart'
    as investment;
import 'package:hyip_lab/data/model/user/user.dart';
import 'package:hyip_lab/data/model/portfolio/portfolio_analytics_model.dart';
import 'package:hyip_lab/data/repo/portfolio/portfolio_analytics_repo.dart';
import 'package:hyip_lab/view/components/agreement/agreement_required_popup.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

import '../../repo/dashboard_repo.dart';

class DashBoardController extends GetxController {
  bool dashBoardLoading = true;

  DashboardRepo dashboardRepo;
  PortfolioAnalyticsRepo? portfolioAnalyticsRepo;
  int notificationListSize = 0;

  DashBoardController({
    required this.dashboardRepo,
    this.portfolioAnalyticsRepo,
  });

  String currency = '';
  String curSymbol = '';

  bool hasNext = false;
  String depositWalletBal = '';
  String interestWalletBal = '';
  String totalInvest = '';
  String totalDeposit = '';
  String totalWithdraw = '';
  String referralEarnings = '';
  String withdrawPending = '';
  String unrealizedReturns = '';

  String username = '';
  String email = '';
  String kycStatus = '';

  User? currentUser; // Store user data for agreement check
  bool agreementPopupShown = false; // Flag to show popup only once

  List<investment.Data> activePlanList = [];
  // Derived, de-duplicated by plan_id for UI
  List<investment.Data> uniqueActivePlans = [];

  // Portfolio Analytics
  PortfolioAnalyticsModel? portfolioAnalytics;
  bool isLoadingAnalytics = false;

  bool isLoading = true;
  Future<void> loadData() async {
    currency = dashboardRepo.apiClient.getCurrencyOrUsername();
    curSymbol = dashboardRepo.apiClient
        .getCurrencyOrUsername(isCurrency: true, isSymbol: true);
    isLoading = true;
    update();

    await loadDashboard();
    await loadActivePlan();
    await _loadPortfolioAnalytics();

    isLoading = false;
    update();
  }

  Future<void> loadDashboard() async {
    ResponseModel response = await dashboardRepo.getDashboardData();

    if (response.statusCode == 200) {
      DashboardResponseModel model =
          DashboardResponseModel.fromJson(jsonDecode(response.responseJson));

      if (model.status == 'success') {
        // Store user data for agreement check
        currentUser = model.data?.user;
        final sharedPrefs = dashboardRepo.apiClient.sharedPreferences;
        kycStatus =
            sharedPrefs.getString(SharedPreferenceHelper.kycStatusKey) ?? '';
        if ((currentUser?.kv ?? '') == '1') {
          sharedPrefs.remove(SharedPreferenceHelper.kycStatusKey);
          kycStatus = '';
        } else {
          if (kycStatus.isEmpty) {
            kycStatus = SharedPreferenceHelper.kycStatusPending;
            sharedPrefs.setString(
                SharedPreferenceHelper.kycStatusKey, kycStatus);
          }
        }

        totalInvest =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.totalInvest ?? '0')} $currency';
        totalDeposit =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.totalDeposit ?? '0')} $currency';
        totalWithdraw =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.totalWithdrawal ?? '0')} $currency';
        referralEarnings =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.referralEarnings ?? '0')} $currency';
        // Calculate unrealized returns from accrued interest (will be updated after loadActivePlan)
        unrealizedReturns =
            '${Converter.twoDecimalPlaceFixedWithoutRounding('0')} $currency';
        withdrawPending =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.pendingWithdraw ?? '0')} $currency';
        depositWalletBal =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.user?.depositWallet ?? '0')} $currency';
        interestWalletBal =
            '${Converter.twoDecimalPlaceFixedWithoutRounding(model.data?.user?.interestWallet ?? '0')} $currency';

        username = model.data?.user?.username ?? '';
        email = model.data?.user?.email ?? '';

        // Check agreement status and show popup if needed
        _checkAndShowAgreementPopup();
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  Future<void> loadActivePlan() async {
    ResponseModel response = await dashboardRepo.getInvestmentData('active', 1);
    activePlanList.clear();
    uniqueActivePlans.clear();

    if (response.statusCode == 200) {
      investment.MyInvestmentResponseModel model =
          investment.MyInvestmentResponseModel.fromJson(
              jsonDecode(response.responseJson));

      if (model.status == 'success') {
        List<investment.Data>? tempList = model.data?.invests?.data;
        if (tempList != null && tempList.isNotEmpty) {
          activePlanList.addAll(tempList);
          // Build unique list by plan_id
          final Map<String, String> seenPlanIds = {};
          for (final item in activePlanList) {
            final String pid = (item.planId ?? '').toString();
            if (pid.isEmpty) continue;
            if (!seenPlanIds.containsKey(pid)) {
              uniqueActivePlans.add(item);
              seenPlanIds[pid] = pid;
            }
          }
        }

        // Calculate total unrealized returns (accrued interest not yet credited)
        _calculateUnrealizedReturns();
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }
  }

  /// Calculate unrealized returns from accrued interest across all active investments
  void _calculateUnrealizedReturns() {
    double totalAccruedInterest = 0.0;

    for (final invest in activePlanList) {
      // Get the accrued/unpaid interest for each active investment
      // nextTimePercent represents accrued interest till now
      final accrued = double.tryParse(invest.nextTimePercent ?? '0') ?? 0.0;
      totalAccruedInterest += accrued;
    }

    unrealizedReturns =
        '${Converter.twoDecimalPlaceFixedWithoutRounding(totalAccruedInterest.toString())} $currency';
    update();
  }

  bool isExpand = false;
  void changeVisibility() {
    isExpand = !isExpand;
    update();
  }

  bool renewLoading = false;
  Future<bool> renewPackage() async {
    renewLoading = true;
    update();
    renewLoading = false;
    update();

    return true;
  }

  String getMessage(int index) {
    String period = uniqueActivePlans[index].period == '-1'
        ? MyStrings.lifeTime
        : '${uniqueActivePlans[index].period ?? ''} ${uniqueActivePlans[index].timeName}';
    String message =
        '${Converter.twoDecimalPlaceFixedWithoutRounding(uniqueActivePlans[index].interest ?? '0')} $currency ${MyStrings.every.toLowerCase()} ${uniqueActivePlans[index].timeName}\nfor $period ';
    return message;
  }

  double getPercent(int index) {
    double percent = 0;
    try {
      percent =
          (double.tryParse(uniqueActivePlans[index].nextTimePercent ?? '0') ??
                  0) /
              (double.tryParse(activePlanList[index].nextTimePercent ?? '0') ??
                  0) /
              100;
    } catch (e) {
      percent = 0;
    }
    return percent;
  }

  /// Check if user needs to accept agreement and show popup
  void _checkAndShowAgreementPopup() {
    // Only show popup once per session and if agreement is needed
    if (!agreementPopupShown &&
        AgreementHelper.needsAgreementAcceptance(currentUser)) {
      agreementPopupShown = true;

      // Show popup after a short delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () {
        BuildContext? context = Get.context;
        if (context != null) {
          AgreementRequiredPopup.show(context, userEmail: email);
        }
      });
    }
  }

  Future<void> _loadPortfolioAnalytics() async {
    if (portfolioAnalyticsRepo == null) {
      print('PortfolioAnalyticsRepo not available for dashboard');
      return;
    }

    isLoadingAnalytics = true;
    update();

    try {
      print('🔄 Loading real-time portfolio analytics...');

      // Clear any cached data first
      portfolioAnalytics = null;

      // Load analytics - real-time endpoint ignores date parameters
      portfolioAnalytics =
          await portfolioAnalyticsRepo!.getPortfolioAnalytics();

      print('✅ Portfolio analytics loaded successfully');
      if (portfolioAnalytics?.equityCurve != null) {
        print(
            '📊 Equity curve has ${portfolioAnalytics!.equityCurve!.length} data points');
      }

      isLoadingAnalytics = false;
      update();
    } catch (e) {
      print('❌ Error loading dashboard portfolio analytics: $e');
      portfolioAnalytics = null;
      isLoadingAnalytics = false;
      update();
    }
  }

  // Method to manually refresh real-time data
  Future<void> refreshPortfolioAnalytics() async {
    await _loadPortfolioAnalytics();
  }
}
