import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/plan/plan_controller.dart';
import 'package:hyip_lab/view/components/animated_widget/expanded_widget.dart';
import 'package:hyip_lab/view/components/buttons/status_button.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text/default_text.dart';

class PlanCard extends StatefulWidget {
  final int index;

  const PlanCard({Key? key, required this.index}) : super(key: key);

  @override
  State<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<PlanCard> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlanController>(
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
          padding: const EdgeInsets.symmetric(
              vertical: Dimensions.space10, horizontal: Dimensions.space15),
          decoration: BoxDecoration(
            color: MyColor.getCardBg(),
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
            border: Border.all(
              color: MyColor.getPrimaryColor().withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DefaultText(
                            text: (controller.planList[widget.index].name ?? '')
                                .tr,
                            textAlign: TextAlign.left,
                            textStyle: interSemiBoldLarge.copyWith(
                                fontSize: Dimensions.fontMediumLarge,
                                color: MyColor.getTextColor())),
                        const SizedBox(height: Dimensions.space10),
                        Text(controller.getAmount(widget.index),
                            textAlign: TextAlign.left,
                            style: interRegularLarge.copyWith(
                                color: MyColor.getTextColor1(),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
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
              const SizedBox(height: Dimensions.space10),
              Text(
                controller.getPlanDescription(widget.index),
                style: interRegularDefault.copyWith(
                  color: MyColor.getTextColor1(),
                  fontSize: Dimensions.fontDefault,
                ),
              ),
              ExpandedSection(
                expand: widget.index == controller.selectedIndex,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomDivider(space: Dimensions.space15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(children: [
                        TextSpan(
                            text: "${MyStrings.return_.tr} ",
                            style: interRegularDefault.copyWith(
                                color: MyColor.getTextColor())),
                        TextSpan(
                            text:
                                controller.planList[widget.index].return_ ?? "",
                            style: interRegularDefault.copyWith(
                                color: MyColor.getTextColor()))
                      ]),
                    ),
                    const CustomDivider(space: Dimensions.space15),
                    Text(
                        (controller.planList[widget.index].interestDuration ??
                                "")
                            .tr,
                        style: interRegularDefault.copyWith(
                            color: MyColor.getTextColor())),
                    const CustomDivider(space: Dimensions.space15),
                    Text(
                        (controller.planList[widget.index].repeatTime ?? "").tr,
                        style: interRegularDefault.copyWith(
                            color: MyColor.getTextColor())),
                    const CustomDivider(space: Dimensions.space15),
                    Row(
                      children: [
                        Text(controller.getTotalReturn(widget.index),
                            style: interRegularDefault.copyWith(
                                color: MyColor.getTextColor())),
                        controller.planList[widget.index].totalReturn
                                    ?.split('+')
                                    .length ==
                                2
                            ? StatusButton(
                                text: MyStrings.capital.tr,
                                bgColor: MyColor.greenSuccessColor,
                                isCircle: true)
                            : const SizedBox()
                      ],
                    ),
                    Visibility(
                        visible: controller
                                .planList[widget.index].compoundInterest ==
                            '1',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomDivider(space: Dimensions.space15),
                            Text(MyStrings.compoundInterestAvailable.tr,
                                style: interRegularDefault.copyWith(
                                    color: MyColor.getTextColor())),
                          ],
                        )),
                    Visibility(
                        visible:
                            controller.planList[widget.index].holdCapital ==
                                '1',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomDivider(space: Dimensions.space15),
                            Text(MyStrings.holdCapitalReinvest.tr,
                                style: interRegularDefault.copyWith(
                                    color: MyColor.getTextColor())),
                          ],
                        )),
                    const SizedBox(height: Dimensions.space25),
                    Row(
                      children: [
                        Expanded(
                          child: RoundedButton(
                            press: () {
                              final plan = controller.planList[widget.index];
                              if (controller.isPlanOwned(widget.index)) {
                                Get.toNamed(RouteHelper.planDetailScreen,
                                    arguments: {
                                      'plan': plan,
                                      'openTopup': true,
                                    });
                              } else {
                                // Navigate to payment for new investment
                                Get.toNamed(RouteHelper.paymentMethodScreen,
                                    arguments: plan);
                              }
                            },
                            color: MyColor.getButtonColor(),
                            textColor: MyColor.getButtonTextColor(),
                            text: controller.isPlanOwned(widget.index)
                                ? MyStrings.addMoney.tr
                                : MyStrings.investNow,
                          ),
                        ),
                        const SizedBox(width: Dimensions.space10),
                        Expanded(
                          child: RoundedButton(
                            press: () {
                              final plan = controller.planList[widget.index];
                              Get.toNamed(RouteHelper.planDetailScreen,
                                  arguments: plan);
                            },
                            color: MyColor.getCardBg(),
                            textColor: MyColor.getPrimaryColor(),
                            text: MyStrings.planDetails,
                            isOutlined: true,
                            borderColor: MyColor.getPrimaryColor(),
                          ),
                        )
                      ],
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
