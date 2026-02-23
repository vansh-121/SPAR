import 'package:flutter/material.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/util.dart';

class BottomSheetCard extends StatelessWidget {
  final Widget child;
  final double bottomSpace;
  final double padding;
  const BottomSheetCard(
      {Key? key,
      required this.child,
      this.bottomSpace = 7,
      this.padding = Dimensions.space15})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(padding),
        margin: EdgeInsets.only(top: bottomSpace),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
            color: MyColor.getScreenBgColor(),
            border: Border.all(
                width: .5, color: MyColor.colorWhite.withOpacity(.3))),
        child: child);
  }
}
