import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/dashboard/dashboard_controller.dart';
import 'package:hyip_lab/data/model/my_investment/my_investment_response_model.dart'
    as investment;
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/card/clickable_card.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/text/default_text.dart';
import 'package:hyip_lab/view/components/text/header_text.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/history/history_bottom_sheet_items.dart';
import 'package:hyip_lab/view/screens/deposit/deposit_method/add_deposit_method.dart';
import 'package:hyip_lab/view/screens/investment/widget/active_plan_card.dart';
import 'package:hyip_lab/view/screens/withdraw/withdraw_money/add_withdraw_method.dart';

class HomeBottomSection extends StatelessWidget {
  const HomeBottomSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
        builder: (controller) => Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.space20, horizontal: Dimensions.space15),
              decoration: BoxDecoration(
                  color: MyColor.getScreenBgColor(),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ClickableCard(
                          backgroundColor: MyColor.getCardBg(),
                          onPressed: () {
                            CustomBottomSheet(
                                backgroundColor: MyColor.getCardBg(),
                                isNeedMargin: true,
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    BottomSheetBar(),
                                    SizedBox(height: Dimensions.space15),
                                    HeaderText(
                                        text: MyStrings.depositMoney,
                                        textAlign: TextAlign.center,
                                        textStyle: interRegularLarge),
                                    SizedBox(height: Dimensions.space30),
                                    AddDepositMethod(),
                                  ],
                                )).customBottomSheet(context);
                          },
                          image: MyImages.deposit,
                          label: MyStrings.deposit.tr,
                        ),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ClickableCard(
                            backgroundColor: MyColor.getCardBg(),
                            onPressed: () {
                              CustomBottomSheet(
                                  backgroundColor: MyColor.getCardBg(),
                                  isNeedMargin: true,
                                  child: const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      BottomSheetBar(),
                                      SizedBox(height: Dimensions.space15),
                                      HeaderText(
                                          text: MyStrings.withdrawMoney,
                                          textAlign: TextAlign.center,
                                          textStyle: interRegularLarge),
                                      SizedBox(height: Dimensions.space30),
                                      AddWithdrawMethod(),
                                    ],
                                  )).customBottomSheet(context);
                            },
                            image: MyImages.withdraw,
                            label: MyStrings.withdraw.tr),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ClickableCard(
                            backgroundColor: MyColor.getCardBg(),
                            onPressed: () {
                              Get.toNamed(RouteHelper.investmentScreen);
                            },
                            image: MyImages.investment,
                            label: MyStrings.investment.tr),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ClickableCard(
                            backgroundColor: MyColor.getCardBg(),
                            onPressed: () {
                              Get.offAndToNamed(RouteHelper.planScreen);
                            },
                            image: MyImages.plan,
                            label: MyStrings.plan.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // DISABLED: Referral button
                      // Expanded(
                      //   child: ClickableCard(
                      //       backgroundColor: MyColor.getCardBg(),
                      //       onPressed: () {
                      //         Get.toNamed(RouteHelper.referralScreen);
                      //       },
                      //       image: MyImages.referral,
                      //       label: MyStrings.referral.tr),
                      // ),
                      // const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ClickableCard(
                            backgroundColor: MyColor.getCardBg(),
                            onPressed: () {
                              Get.toNamed(RouteHelper.transactionHistoryScreen);
                            },
                            image: MyImages.transaction,
                            label: MyStrings.transactions.tr),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ClickableCard(
                            backgroundColor: MyColor.getCardBg(),
                            onPressed: () {
                              CustomBottomSheet(
                                      isNeedMargin: true,
                                      backgroundColor: MyColor.getCardBg(),
                                      child: const HistoryBottomSheetItems())
                                  .customBottomSheet(context);
                            },
                            image: MyImages.history,
                            label: MyStrings.history.tr),
                      ),
                      const SizedBox(width: Dimensions.space10),
                      Expanded(
                        child: ClickableCard(
                            backgroundColor: MyColor.getCardBg(),
                            onPressed: () {
                              Get.toNamed(RouteHelper.userAccountScreen);
                            },
                            image: MyImages.accountBold,
                            label: MyStrings.account.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.space20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DefaultText(
                          text: MyStrings.activePlan.tr,
                          textStyle: interSemiBoldDefault,
                          textColor: MyColor.getTextColor()),
                      TextButton(
                        onPressed: () {
                          Get.toNamed(RouteHelper.investmentScreen);
                        },
                        child: DefaultText(
                            text: MyStrings.viewAll.tr,
                            textStyle: interRegularDefault.copyWith(
                                color: MyColor.getPrimaryColor())),
                      )
                    ],
                  ),
                  const SizedBox(height: Dimensions.space15),
                  controller.isLoading
                      ? const CustomLoader()
                      : controller.uniqueActivePlans.isEmpty
                          ? Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.space15,
                                  vertical: Dimensions.space30),
                              decoration: BoxDecoration(
                                color: MyColor.getCardBg(),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimensions.defaultRadius)),
                              ),
                              child: Text(
                                MyStrings.noActiveInvestmentFound.tr,
                                style: interRegularDefault.copyWith(
                                    fontSize: Dimensions.fontLarge,
                                    color: MyColor.getTextColor()),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: controller.uniqueActivePlans.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: Dimensions.space10),
                              itemBuilder: (context, index) {
                                investment.Data model =
                                    controller.uniqueActivePlans[index];
                                final investmentPlan =
                                    model.plan; // Plan from investment

                                // Convert investment.Plan to Plans model for navigation
                                Plans? plansModel;
                                if (investmentPlan != null) {
                                  plansModel = Plans(
                                    id: investmentPlan.id,
                                    name: investmentPlan.name,
                                    minimum: investmentPlan.minimum,
                                    maximum: investmentPlan.maximum,
                                    fixedAmount: investmentPlan.fixedAmount,
                                    return_: investmentPlan
                                        .interest, // Use interest as return
                                    interestDuration:
                                        'Every ${investmentPlan.timeName}',
                                    repeatTime: investmentPlan.repeatTime,
                                    totalReturn:
                                        '', // Not available in investment plan
                                    interestValidity:
                                        '', // Not available in investment plan
                                  );
                                }

                                return Column(
                                  children: [
                                    ActivePlanCard(
                                      investmentId: model.id.toString(),
                                      hasCapital: model.plan?.capitalBack == '1'
                                          ? true
                                          : false,
                                      percent: controller.getPercent(index),
                                      name: (model.plan?.name ?? '').tr,
                                      nextReturn: DateConverter.nextReturnTime(
                                          model.nextTime ?? ''),
                                      totalReturn:
                                          '${Converter.twoDecimalPlaceFixedWithoutRounding(model.interest ?? '0')} X ${Converter.twoDecimalPlaceFixedWithoutRounding(model.returnRecTime ?? '0', precision: 0)} = ${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(model.paid ?? '0')}',
                                      invested:
                                          '${Converter.twoDecimalPlaceFixedWithoutRounding(model.amount ?? '')} ${controller.currency}',
                                      isActive: true,
                                      message: controller.getMessage(index),
                                    ),
                                    const SizedBox(height: Dimensions.space10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (plansModel != null) {
                                                Get.toNamed(
                                                    RouteHelper
                                                        .planDetailScreen,
                                                    arguments: plansModel);
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  MyColor.getCardBg(),
                                            ),
                                            child: Text(MyStrings.planDetails,
                                                style: interRegularDefault
                                                    .copyWith(
                                                        color: MyColor
                                                            .getTextColor())),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: Dimensions.space10),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (plansModel != null) {
                                                // Already owned, show plan details with Add Money button
                                                Get.toNamed(
                                                    RouteHelper
                                                        .planDetailScreen,
                                                    arguments: {
                                                      'plan': plansModel,
                                                      'openTopup': true,
                                                    });
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  MyColor.getButtonColor(),
                                            ),
                                            child: Text(MyStrings.addMoney.tr,
                                                style: interRegularDefault.copyWith(
                                                    color: MyColor
                                                        .getButtonTextColor())),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            )
                ],
              ),
            ));
  }
}
