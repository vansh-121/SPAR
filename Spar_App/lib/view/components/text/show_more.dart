import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/view/components/text/read_more_text.dart';

import '../../../core/utils/my_strings.dart';

class ShowMore extends StatelessWidget {
  final String showMoreText;
  final int trimLines;
  final String trimCollapsedText;
  final String trimExpandedText;
  final TextStyle textStyle;
  const ShowMore(this.showMoreText,{
    Key? key,
    this.trimLines = 1,
    this.trimCollapsedText = 'Show more',
    this.trimExpandedText = 'Show less',
    this.textStyle = interRegularDefault,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReadMoreText(
      showMoreText.tr,
      trimLines: trimLines,
      colorClickableText: MyColor.primaryColor,
      trimMode: TrimMode.Line,
      trimCollapsedText: trimCollapsedText,
      trimExpandedText: trimExpandedText,
      style: textStyle,
      moreStyle:  const TextStyle(fontSize: Dimensions.fontDefault, fontWeight: FontWeight.bold,color: MyColor.primaryColor),
    );
  }
}
