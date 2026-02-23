import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/investment/investment_controller.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/drop_dawn/custom_drop_down_field3.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';
import 'package:hyip_lab/view/components/text/small_text.dart';
import 'package:percent_indicator/percent_indicator.dart';

class ActivePlanCard extends StatelessWidget {
  const ActivePlanCard(
      {Key? key,
      this.eligibleForCapitalBack = false,
      required this.investmentId,
      required this.name,
      required this.nextReturn,
      required this.totalReturn,
      required this.invested,
      required this.message,
      required this.percent,
      this.isActive = true,
      this.hasCapital = false})
      : super(key: key);

  final String name;
  final String nextReturn;
  final String totalReturn;
  final String invested;
  final String message;
  final bool isActive;
  final double percent;
  final bool hasCapital;
  final String investmentId;
  final bool eligibleForCapitalBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(
          vertical: Dimensions.space10 + 2, horizontal: Dimensions.space15),
      decoration: BoxDecoration(
          color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "$name - $message",
                        style: interSemiBoldDefault.copyWith(
                            color: MyColor.getTextColor()),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isActive)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: Dimensions.space10),
                        child: CircularPercentIndicator(
                          radius: 18.0,
                          lineWidth: 4.0,
                          percent: percent,
                          backgroundColor: MyColor.getTextColor(),
                          progressColor: MyColor.greenSuccessColor,
                        ),
                      )
                    else if (eligibleForCapitalBack)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: Dimensions.space10),
                        child: InkWell(
                            onTap: () {
                                    CustomBottomSheet(
                                        backgroundColor: MyColor.getCardBg(),
                                        child: GetBuilder<InvestmentController>(
                                            builder: (controller) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    MyStrings
                                                        .manageInvestCapital,
                                                    style: interSemiBoldDefault
                                                        .copyWith(
                                                            color: MyColor
                                                                .getTextColor()),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.back();
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: MyColor
                                                                  .getCardBg()
                                                              .withOpacity(.4)),
                                                      child: Icon(
                                                        Icons.clear,
                                                        size: 17,
                                                        color: MyColor
                                                            .getTextColor(),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const CustomDivider(
                                                space: Dimensions.space20,
                                              ),
                                              const LabelText(
                                                  text: MyStrings
                                                      .investmentCapital),
                                              CustomDropDownTextField3(
                                                  fillColor: MyColor.getCardBg()
                                                      .withOpacity(.2),
                                                  selectedValue: controller
                                                      .selectedInvestmentCapital,
                                                  onChanged: (value) {
                                                    controller
                                                        .changeInvestmentCapitalType(
                                                            value);
                                                  },
                                                  items: controller
                                                      .investmentCapitalType
                                                      .map<
                                                          DropdownMenuItem<
                                                              String>>((value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(
                                                        value,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                            fontSize: Dimensions
                                                                .fontDefault,
                                                            color: MyColor
                                                                .getTextColor()),
                                                      ),
                                                    );
                                                  }).toList()),
                                              const SizedBox(
                                                  height: Dimensions.space40 +
                                                      Dimensions.space30),
                                              controller
                                                      .isSubmitInvestmentLoading
                                                  ? const RoundedLoadingBtn()
                                                  : RoundedButton(
                                                      text: MyStrings.submit,
                                                      press: () {
                                                        controller
                                                            .submitInvestmentData(
                                                                investmentId);
                                                      }),
                                              const SizedBox(
                                                  height: Dimensions.space20),
                                            ],
                                          );
                                        })).customBottomSheet(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(
                                        Dimensions.space10),
                                    decoration: const BoxDecoration(
                                        color: MyColor.primaryColor,
                                        shape: BoxShape.circle),
                                    child: Image.asset(
                                      MyImages.deposit,
                                      height: 17,
                                      width: 17,
                                      color: MyColor.colorWhite,
                                    ),
                                  ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Dimensions.space5),
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "${MyStrings.invested.tr}: ",
                        style: interRegularExtraSmall.copyWith(
                            color: MyColor.getTextColor())),
                    TextSpan(
                        text: invested,
                        style: interRegularExtraSmall.copyWith(
                            color: MyColor.getPrimaryColor())),
                    TextSpan(
                        text: hasCapital ? " (${MyStrings.capitalBack})" : '',
                        style: interRegularExtraSmall.copyWith(
                            color: MyColor.getTextColor())),
                  ]),
                ),
                const SizedBox(height: Dimensions.space15),
                SizedBox(
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SmallText(
                                  text: MyStrings.nextReturn,
                                  textStyle: interRegularExtraSmall.copyWith(
                                      color: MyColor.getTextColor3())),
                              const SizedBox(height: Dimensions.space5),
                              SmallText(
                                  text: nextReturn,
                                  textStyle: interRegularSmall.copyWith(
                                      color: MyColor.getTextColor()))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
