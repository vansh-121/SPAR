import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/model/shedule/shedule_response_model.dart';
import 'package:hyip_lab/data/model/staking/staking_response_model.dart';
import 'package:hyip_lab/view/components/custom_divider.dart';

class SheduleInvestBottomSheet extends StatelessWidget {
  SheduleModel shedule;
  String currency;
  VoidCallback onButtonClick;
  SheduleInvestBottomSheet(
      {super.key,
      required this.shedule,
      required this.currency,
      required this.onButtonClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Container(
                height: 5,
                width: 50,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: MyColor.colorGrey.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.planName, style: interRegularDefault),
                Text(
                  shedule.plan?.name ?? "",
                  style: interBoldDefault,
                ),
              ],
            ),
            const CustomDivider(
              space: Dimensions.space15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.investAmount, style: interRegularDefault),
                Text(
                  "${Converter.twoDecimalPlaceFixedWithoutRounding(shedule.amount.toString())} $currency",
                  style: interBoldDefault,
                ),
              ],
            ),
            const CustomDivider(
              space: Dimensions.space15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.interest, style: interRegularDefault),
                Text(
                  "${Converter.twoDecimalPlaceFixedWithoutRounding(shedule.plan?.interest ?? "")} $currency",
                  style: interBoldDefault,
                ),
              ],
            ),
            const CustomDivider(
              space: Dimensions.space15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.scheduleTimes, style: interRegularDefault),
                Text(
                  shedule.scheduleTimes ?? "",
                  style: interBoldDefault,
                ),
              ],
            ),
            const CustomDivider(
              space: Dimensions.space15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.remainingScheduleTimes,
                    style: interRegularDefault),
                Text(
                  shedule.remScheduleTimes ?? "",
                  style: interBoldDefault,
                ),
              ],
            ),
            const CustomDivider(
              space: Dimensions.space15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.interval, style: interRegularDefault),
                Text(
                  "${shedule.intervalHours} ${MyStrings.hours}",
                  style: interBoldDefault,
                ),
              ],
            ),
            const CustomDivider(
              space: Dimensions.space15,
            ),
            Visibility(
                visible: shedule.plan?.compoundInterest.toString() == '1',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(MyStrings.compoundInterest,
                            style: interRegularDefault),
                        Text(
                          "${shedule.compoundTimes} ${MyStrings.times.tr}",
                          style: interBoldDefault,
                        ),
                      ],
                    ),
                    const CustomDivider(
                      space: Dimensions.space15,
                    ),
                  ],
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(MyStrings.nextInvest, style: interRegularDefault),
                Text(
                  DateConverter.nextReturnTime(shedule.nextInvest.toString()),
                  style: interBoldDefault,
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
