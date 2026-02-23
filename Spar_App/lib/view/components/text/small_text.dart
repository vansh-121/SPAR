import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/style.dart';

class SmallText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle textStyle;
  final int maxLine;
  const SmallText({
    Key? key,
    required this.text,
    this.textAlign,
    this.textStyle = interRegularSmall,
    this.maxLine = 1
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: textStyle,
      overflow: TextOverflow.ellipsis,
    );
  }
}
