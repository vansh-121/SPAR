import 'package:flutter/material.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/model/staking/staking_response_model.dart';
import 'package:hyip_lab/view/components/column/card_column.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StakingCard extends StatelessWidget {
  MyStakings myStaking;
  String currency;
  StakingCard({super.key, required this.myStaking, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10, vertical: Dimensions.space10),
      margin: const EdgeInsets.only(bottom: Dimensions.space10),
      decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                header: MyStrings.investDate,
                textColor: MyColor.primaryTextColor,
                space: 5,
                body: DateConverter.isoStringToLocalDateOnly(myStaking.createdAt??''),
              ),
              const SizedBox(
                height: Dimensions.space10,
              ),
              CardColumn(
                alignmentEnd: true,
                header: MyStrings.investAmount,
                textColor: MyColor.primaryTextColor,
                space: 5,
                body: "${Converter.twoDecimalPlaceFixedWithoutRounding(myStaking.investAmount.toString())} $currency",
              ),

            ],
          ),
          const CustomDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                header: MyStrings.totalReturn,
                space: 5,
                textColor: MyColor.primaryTextColor,
                body: "${Converter.sum(myStaking.investAmount??'0.0',myStaking.interest??'0.0')} $currency",
              ),
              const SizedBox(
                height: Dimensions.space10,
              ),
              CardColumn(
                alignmentEnd: true,
                header: MyStrings.interest,
                space: 5,
                textColor: MyColor.primaryTextColor,
                body: "${Converter.twoDecimalPlaceFixedWithoutRounding(myStaking.interest.toString())} $currency",
              ),
            ],
          ),
          const CustomDivider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CardColumn(
                header: MyStrings.endAt,
                space: 5,
                textColor: MyColor.primaryTextColor,
                body: DateConverter.nextReturnTime(myStaking.endAt??''),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
