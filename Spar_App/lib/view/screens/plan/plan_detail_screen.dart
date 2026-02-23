import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/plan_detail/plan_detail_controller.dart';
import 'package:hyip_lab/data/repo/deposit_repo.dart';
import 'package:hyip_lab/data/repo/account/transaction_log_repo.dart';
import 'package:hyip_lab/data/repo/investment_repo/investment_repo.dart';
import 'package:hyip_lab/data/repo/shedule/shedule_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/portfolio_charts.dart';
import 'package:hyip_lab/data/repo/portfolio/portfolio_analytics_repo.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class PlanDetailScreen extends StatefulWidget {
  const PlanDetailScreen({super.key});

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen> {
  late final Plans plan;
  bool _openTopupOnLoad = false;
  // Interest breakdown UI removed - calculations still logged to console
  // bool _showInterestBreakdown = false;

  @override
  void initState() {
    final args = Get.arguments;
    if (args is Map && args['plan'] is Plans) {
      plan = args['plan'] as Plans;
      _openTopupOnLoad = args['openTopup'] == true;
    } else {
      plan = args as Plans;
    }

    final apiClient = Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(InvestmentRepo(apiClient: apiClient));
    Get.put(SheduleRepo(apiClient: apiClient));
    Get.put(DepositRepo(apiClient: apiClient));
    Get.put(TransactionRepo(apiClient: apiClient));
    final portfolioAnalyticsRepo =
        Get.put(PortfolioAnalyticsRepo(apiClient: apiClient));
    final controller = Get.put(PlanDetailController(
      investmentRepo: Get.find(),
      sheduleRepo: Get.find(),
      depositRepo: Get.find(),
      transactionRepo: Get.find(),
      portfolioAnalyticsRepo: portfolioAnalyticsRepo,
    ));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadWithPlan(plan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlanDetailController>(builder: (controller) {
      if (_openTopupOnLoad && !controller.isLoading) {
        _openTopupOnLoad = false;
        Future.microtask(() => _navigateToTopup(controller));
      }
      final bool canTopup =
          controller.canTopup && controller.activeInvestId != null;

      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.planDetails.tr,
          isTitleCenter: true,
          isShowBackBtn: true,
          bgColor: MyColor.getAppbarBgColor(),
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : RefreshIndicator(
                onRefresh: () async => controller.loadWithPlan(plan),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: Dimensions.screenPaddingHV,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.space20),
                      _metricRow(
                        label: MyStrings.invested.tr,
                        value:
                            '${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.investedTotal.toString())}',
                      ),
                      const SizedBox(height: Dimensions.space15),
                      _metricRow(
                        label: 'Total Interest To Date',
                        value:
                            '${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.interestEarned.toString())}',
                      ),
                      const SizedBox(height: Dimensions.space15),
                      _metricRow(
                        label: 'Accrued This Period',
                        value:
                            '${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.accruedInterest.toString())}',
                      ),
                      // Detailed breakdown expandable
                      // Interest breakdown button removed from UI (still available in console logs)
                      const SizedBox(height: Dimensions.space15),
                      _metricRow(
                        label: 'Projected Next Payout',
                        value:
                            '${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.projectedInterest.toString())}',
                      ),
                      const SizedBox(height: Dimensions.space15),
                      _metricRow(
                        label: MyStrings.nextReturn.tr,
                        value: controller.nextDue == null
                            ? '-'
                            : DateConverter.isoStringToLocalDateOnly(
                                controller.nextDue!.toIso8601String()),
                      ),
                      // Next Scheduled Investment Date (SIP)
                      if (controller.nextInvestDate != null) ...[
                        const SizedBox(height: Dimensions.space15),
                        _metricRow(
                          label: 'Next Scheduled Investment',
                          value: DateConverter.isoStringToLocalDateOnly(
                              controller.nextInvestDate!.toIso8601String()),
                        ),
                      ],
                      const SizedBox(height: Dimensions.space15),
                      _metricRow(
                        label: MyStrings.investDate.tr,
                        value: controller.initiatedAt == null ||
                                controller.initiatedAt!.isEmpty
                            ? '-'
                            : DateConverter.isoStringToLocalDateOnly(
                                controller.initiatedAt!),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      // _metricRow(
                      //   label: MyStrings.remainingScheduleTimes.tr,
                      //   value: controller.remainingScheduleTimes ?? '-',
                      // ),
                      const SizedBox(height: Dimensions.space15),
                      // Interest payout behaviour (plan driven)
                      _buildInterestStrategyCard(controller),
                      const SizedBox(height: Dimensions.space30),

                      // Portfolio Analytics Charts
                      PortfolioChartsWidget(
                        analyticsData: controller.portfolioAnalytics,
                        isLoading: controller.isLoadingAnalytics,
                      ),
                      const SizedBox(height: Dimensions.space30),

                      Text('Installments',
                          style: interBoldDefault.copyWith(
                              color: MyColor.getTextColor())),
                      const SizedBox(height: Dimensions.space10),
                      ...controller.installments
                          .map((i) => _installmentRow(i, controller))
                          .toList(),
                      const SizedBox(height: Dimensions.space60),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: controller.isLoading
            ? null
            : SafeArea(
                minimum: const EdgeInsets.all(Dimensions.space15),
                child: RoundedButton(
                  press: () => _navigateToTopup(controller),
                  text: MyStrings.addMoney.tr,
                  color: canTopup
                      ? MyColor.getButtonColor()
                      : MyColor.getFieldDisableBorderColor(),
                  textColor: canTopup
                      ? MyColor.getButtonTextColor()
                      : MyColor.getHintTextColor(),
                  verticalPadding: 16,
                ),
              ),
      );
    });
  }

  void _navigateToTopup(PlanDetailController controller) {
    if (!controller.canTopup) {
      CustomSnackBar.error(errorList: ['Top-up is currently unavailable.']);
      return;
    }

    final investId = controller.activeInvestId;
    if (investId == null) {
      CustomSnackBar.error(
          errorList: ['No active investment found for this plan.']);
      return;
    }

    Get.toNamed(RouteHelper.paymentMethodScreen,
        arguments: [plan, investId, true]);
  }

  Widget _metricRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                interRegularDefault.copyWith(color: MyColor.getTextColor1())),
        Text(value,
            style: interBoldDefault.copyWith(color: MyColor.getTextColor())),
      ],
    );
  }

  Widget _installmentRow(InstallmentEntry i, PlanDetailController controller) {
    final ordinal = _ordinal(i.index);
    final date = i.dateIso.isEmpty
        ? '-'
        : DateConverter.isoStringToLocalDateOnly(i.dateIso);

    // Determine source display text
    String sourceText = '';
    Color sourceColor = MyColor.getTextColor1();
    switch (i.source) {
      case 'wire_transfer':
      case 'initial_investment':
        sourceText = 'Wire Transfer';
        sourceColor = MyColor.primaryColor;
        break;
      case 'manual_topup':
        sourceText = 'Manual Top-up';
        sourceColor = Colors.blue;
        break;
      case 'interest_gained':
      case 'auto_compound':
        sourceText = 'Interest Gained';
        sourceColor = MyColor.green;
        break;
      default:
        sourceText = i.source ?? 'Unknown';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.space10),
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.space10, horizontal: Dimensions.space10),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$ordinal installment • $date',
                    style: interRegularSmall.copyWith(
                        color: MyColor.getTextColor1())),
                const SizedBox(height: 4),
                Text(
                    'Amount: ${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(i.amount.toString())}',
                    style: interRegularSmall.copyWith(
                        color: MyColor.getTextColor())),
                const SizedBox(height: 4),
                Text('Source: $sourceText',
                    style: interRegularSmall.copyWith(
                        color: sourceColor, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                  'Total: ${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(i.runningTotal.toString())}',
                  style:
                      interBoldSmall.copyWith(color: MyColor.getTextColor())),
              const SizedBox(width: Dimensions.space10),
              IconButton(
                icon: Icon(
                  Icons.receipt_long,
                  color: MyColor.getPrimaryColor(),
                  size: 20,
                ),
                onPressed: () {
                  // Navigate to invoice screen
                  Get.toNamed(RouteHelper.investmentInvoiceScreen, arguments: {
                    'installment': i,
                    'plan': controller.plan,
                    'currencySymbol': controller.curSymbol,
                    'investId': controller.activeInvestId,
                  });
                },
                tooltip: 'View Invoice',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterestStrategyCard(PlanDetailController controller) {
    final isCompound = (controller.plan?.compoundInterest ?? '0') == '1';
    final title =
        isCompound ? 'Compound interest plan' : 'Simple interest plan';
    final description = isCompound
        ? 'Each payout is automatically reinvested into your principal. Your balance grows every cycle without manual action.'
        : 'Each payout is credited to your interest wallet. You can withdraw it or choose to top up manually whenever you like.';

    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
        border: Border.all(
          color: MyColor.getPrimaryColor().withOpacity(0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCompound ? Icons.auto_graph : Icons.payments_outlined,
            color: MyColor.getPrimaryColor(),
          ),
          const SizedBox(width: Dimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: interBoldSmall.copyWith(color: MyColor.getTextColor()),
                ),
                const SizedBox(height: Dimensions.space5),
                Text(
                  description,
                  style: interRegularExtraSmall.copyWith(
                      color: MyColor.getTextColor1()),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _ordinal(int n) {
    if (n % 100 >= 11 && n % 100 <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  // Interest breakdown UI removed - calculations still logged to console
  // Widget _buildInterestBreakdownButton(PlanDetailController controller) {
  //   return Column(
  //     children: [
  //       const SizedBox(height: Dimensions.space10),
  //       InkWell(
  //         onTap: () {
  //           print('=== INTEREST BREAKDOWN TOGGLE ===');
  //           print('Current state: $_showInterestBreakdown');
  //           setState(() {
  //             _showInterestBreakdown = !_showInterestBreakdown;
  //           });
  //           print('New state: $_showInterestBreakdown');
  //           if (_showInterestBreakdown) {
  //             print('Expanding interest breakdown...');
  //           }
  //         },
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(
  //               horizontal: Dimensions.space15, vertical: Dimensions.space10),
  //           decoration: BoxDecoration(
  //             color: MyColor.getCardBg(),
  //             borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
  //             border: Border.all(
  //               color: MyColor.getPrimaryColor().withOpacity(0.3),
  //             ),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 'View Interest Calculation Breakdown',
  //                 style: interRegularDefault.copyWith(
  //                   color: MyColor.getPrimaryColor(),
  //                 ),
  //               ),
  //               Icon(
  //                 _showInterestBreakdown
  //                     ? Icons.expand_less
  //                     : Icons.expand_more,
  //                 color: MyColor.getPrimaryColor(),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       if (_showInterestBreakdown) _buildDetailedBreakdown(controller),
  //     ],
  //   );
  // }

  // Interest breakdown UI removed - calculations still logged to console
  // Widget _buildDetailedBreakdown(PlanDetailController controller) {
  //   return const SizedBox.shrink();
  // }

  // Widget _buildSegmentCard(...) also removed
}

// Minimal object used to pass planId to existing payment flow without altering UI
// no extra helper classes
