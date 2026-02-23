// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/pool/my_pool_controller.dart';
import 'package:hyip_lab/data/model/pool/my_pool_response_model.dart';
import 'package:hyip_lab/view/components/column/card_column.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/text/small_text.dart';
import 'package:percent_indicator/percent_indicator.dart';

class PoolHistoryCard extends StatelessWidget {
  Invest invest;
  PoolHistoryCard({super.key, required this.invest});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MypoolController>(builder: (controller) {
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: Dimensions.space12),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.space10 + 2, horizontal: Dimensions.space15),
        decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(8)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: CardColumn(header: MyStrings.plan, body: invest.pool?.name.toString() ?? "")),
                      const SizedBox(width: Dimensions.space5),
                      CardColumn(alignmentEnd:true,header: MyStrings.investTill, body: DateConverter.nextReturnTime(invest.pool?.startDate??'')),

                    ],
                  ),
                  const CustomDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CardColumn(header: MyStrings.investAmount, body: "${Converter.twoDecimalPlaceFixedWithoutRounding(
                          invest.investAmount.toString() ?? "",
                        )} ${controller.currency}",),
                      ),
                      const SizedBox(width: Dimensions.space5),
                      CardColumn(alignmentEnd:true,header: MyStrings.returnDate, body: DateConverter.nextReturnTime(invest.pool?.endDate??'')),
                    ],
                  ),
                  const CustomDivider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: CardColumn(
                            header: MyStrings.totalReturn,
                            body: "${Converter.twoDecimalPlaceFixedWithoutRounding(invest.totalReturn.toString() ?? " ")} ${double.tryParse(invest.totalReturn.toString()) != null?controller.currency:""}"
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}
