import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/pool/pool_contrroller.dart';
import 'package:hyip_lab/view/components/animated_widget/expanded_widget.dart';
import 'package:hyip_lab/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/buttons/status_button.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text/default_text.dart';
import 'package:hyip_lab/view/components/text/header_text.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class PoolCardWidget extends StatefulWidget {
  final int index;

  const PoolCardWidget({Key? key, required this.index}) : super(key: key);

  @override
  State<PoolCardWidget> createState() => _PoolCardWidgetState();
}

class _PoolCardWidgetState extends State<PoolCardWidget> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PoolController>(
      builder: (controller) => GestureDetector(
        onTap: () {
          if (controller.selectedIndex == widget.index) {
            controller.changeSelectedIndex(-1);
          } else {
            controller.changeSelectedIndex(widget.index);
          }
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(bottom: Dimensions.space12),
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.space10, horizontal: Dimensions.space15),
          decoration: BoxDecoration(
            color: MyColor.getCardBg(),
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultText(
                        text: (controller.poolList[widget.index].name ?? '').tr,
                        textAlign: TextAlign.left,
                        textStyle: interSemiBoldLarge.copyWith(
                          fontSize: Dimensions.fontMediumLarge,
                          color: MyColor.getTextColor(),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space10),
                      Text(
                          "${Converter.twoDecimalPlaceFixedWithoutRounding(
                            controller.poolList[widget.index].amount.toString(),
                          )} ${controller.currency}",
                          textAlign: TextAlign.center,
                          style: interRegularLarge.copyWith(
                              color: MyColor.getTextColor1(),
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      if (controller.selectedIndex == widget.index) {
                        controller.changeSelectedIndex(-1);
                      } else {
                        controller.changeSelectedIndex(widget.index);
                      }
                    },
                    child: Icon(
                        widget.index == controller.selectedIndex
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: MyColor.getSelectedIconColor().withOpacity(.7),
                        size: 25),
                  )
                ],
              ),
              ExpandedSection(
                expand: widget.index == controller.selectedIndex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomDivider(space: Dimensions.space15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${MyStrings.investTill.tr} ",
                            style: interSemiBoldDefault.copyWith(
                                color: MyColor.getTextColor())),
                        const SizedBox(width: Dimensions.space10),
                        Text(
                            DateConverter.nextReturnTime(controller
                                .poolList[widget.index].startDate
                                .toString()),
                            style: interRegularDefault.copyWith(
                                color: MyColor.getTextColor())),
                      ],
                    ),
                    const CustomDivider(space: Dimensions.space15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${MyStrings.returnDate.tr} ",
                            style: interSemiBoldDefault.copyWith(
                                color: MyColor.getTextColor())),
                        const SizedBox(width: Dimensions.space10),
                        Text(
                            DateConverter.nextReturnTime(controller
                                .poolList[widget.index].endDate
                                .toString()),
                            style: interRegularDefault.copyWith(
                                color: MyColor.getTextColor())),
                      ],
                    ),
                    const CustomDivider(space: Dimensions.space15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "${MyStrings.investedAmount.tr} ",
                                    style: interSemiBoldDefault.copyWith(
                                        color: MyColor.getTextColor())),
                                TextSpan(
                                  text:
                                      "  ${controller.curSymbol}${Converter.roundDoubleAndRemoveTrailingZero(controller.poolList[widget.index].investedAmount ?? "0")}/ ${controller.curSymbol}${Converter.roundDoubleAndRemoveTrailingZero(controller.poolList[widget.index].amount ?? "0")}",
                                  style: interRegularDefault.copyWith(
                                      color: MyColor.getTextColor()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.space10),
                        CircularPercentIndicator(
                          radius: 18.0,
                          lineWidth: 4.0,
                          percent: controller.getPercent(widget.index),
                          backgroundColor: MyColor.getTextColor(),
                          progressColor: MyColor.greenSuccessColor,
                        ),
                      ],
                    ),
                    const CustomDivider(space: Dimensions.space15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${MyStrings.interestRange.tr} ",
                            style: interSemiBoldDefault.copyWith(
                                color: MyColor.getTextColor())),
                        const SizedBox(width: Dimensions.space10),
                        Text(
                            (controller.poolList[widget.index].interestRange ??
                                ""),
                            style: interSemiBoldDefault.copyWith(
                                color: MyColor.getPrimaryColor())),
                      ],
                    ),
                    // const CustomDivider(space: Dimensions.space15),
                    const SizedBox(height: Dimensions.space25),
                    RoundedButton(
                      press: () {
                        Get.toNamed(RouteHelper.addpoolScreen,
                            arguments: controller.poolList[widget.index].id);
                      },
                      color: MyColor.getButtonColor(),
                      textColor: MyColor.getButtonTextColor(),
                      text: MyStrings.investNow,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
