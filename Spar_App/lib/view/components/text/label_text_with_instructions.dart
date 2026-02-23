import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/style.dart';

class LabelTextInstruction extends StatelessWidget {
  final bool isRequired;
  final String text;
  final String? instructions;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  const LabelTextInstruction({
    super.key,
    required this.text,
    this.textAlign,
    this.textStyle,
    this.isRequired = false,
    this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> _tooltipKey = GlobalKey<TooltipState>();

    return isRequired
        ? Row(
            children: [
              Text(text.tr,
                  textAlign: textAlign,
                  style: textStyle ??
                      interSemiBoldDefault.copyWith(
                          color: MyColor.getPrimaryTextColor())),
              const SizedBox(
                width: 2,
              ),
              if (instructions != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 2, end: Dimensions.space10),
                  child: Tooltip(
                      key: _tooltipKey,
                      message: "$instructions",
                      child: GestureDetector(
                        onTap: () {
                          _tooltipKey.currentState?.ensureTooltipVisible();
                        },
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: Dimensions.space15,
                          color: MyColor.primaryColor.withOpacity(.5),
                        ),
                      )),
                ),
              ],
              Text(
                '*',
                style: interSemiBoldDefault.copyWith(color: MyColor.colorRed),
              ),
            ],
          )
        : Row(
            children: [
              Text(
                text.tr,
                textAlign: textAlign,
                style: textStyle ??
                    interSemiBoldDefault.copyWith(
                        color: MyColor.getPrimaryTextColor()),
              ),
              if (instructions != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 2, end: Dimensions.space10),
                  child: Tooltip(
                      key: _tooltipKey,
                      message: "$instructions",
                      child: GestureDetector(
                        onTap: () {
                          _tooltipKey.currentState?.ensureTooltipVisible();
                        },
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: Dimensions.space15,
                          color: MyColor.getLabelTextColor().withOpacity(0.8),
                        ),
                      )),
                ),
              ],
            ],
          );
  }
}
