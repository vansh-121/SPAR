import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../core/utils/style.dart';
class TimerWidget extends StatelessWidget {

  final String value;
  final String subtitle;


  const TimerWidget({
    super.key,
    required this.value,
    required this.subtitle
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          margin: EdgeInsetsDirectional.only(end: size.width * .02),
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: MyColor.naturalDark,
          ),
          child: Text(value,style: interSemiBoldLarge.copyWith(color: MyColor.colorWhite),),
        ),
        const SizedBox(height: 2),
        Container(
          margin: EdgeInsetsDirectional.only(end: size.width * .02),
          child: Text(subtitle.tr,style: interRegularDefault.copyWith(color: MyColor.naturalDark)))
      ],
    );
  }
}
