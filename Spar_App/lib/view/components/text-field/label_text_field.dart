// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/style.dart';
import '../text/label_text.dart';

class LabelTextField extends StatefulWidget {
  final bool needOutline;
  final String labelText;
  final String? hintText;
  final Function? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final FormFieldValidator? validator;
  final TextInputType? textInputType;
  final bool isEnable;
  final bool isPassword;
  final TextInputAction inputAction;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool readOnly;
  final int maxLines;
  final bool isRequired;
  final bool isAttachment;
  final bool hideLabel;
  final double radius;
  final EdgeInsetsGeometry contentPadding;
  final Color fillColor;
  final Color labelTextColor;
  final Color hintTextColor;
  final TextStyle? labelTextStyle;
  final TextStyle? inputTextStyle;

  const LabelTextField({
    super.key,
    this.needOutline = true,
    required this.labelText,
    this.readOnly = false,
    required this.onChanged,
    this.hintText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.validator,
    this.textInputType,
    this.isEnable = true,
    this.isPassword = false,
    this.isAttachment = false,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.isRequired = false,
    this.hideLabel = false,
    this.radius = Dimensions.largeRadius,
    this.suffixIcon,
    this.prefixIcon,
    this.contentPadding =
        const EdgeInsets.only(top: 5, left: 15, right: 15, bottom: 5),
    this.fillColor = Colors.transparent,
    this.hintTextColor = MyColor.hintTextColor,
    this.labelTextColor = MyColor.labelTextColor,
    this.labelTextStyle,
    this.inputTextStyle,
  });

  @override
  State<LabelTextField> createState() => _LabelTextFieldState();
}

class _LabelTextFieldState extends State<LabelTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return widget.needOutline
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.hideLabel != true) ...[
                LabelText(
                  text: widget.labelText.toString(),
                  required: widget.isRequired,
                ),
                const SizedBox(height: Dimensions.textToTextSpace),
              ],
              TextFormField(
                maxLines: widget.maxLines,
                readOnly: widget.readOnly,
                style: widget.inputTextStyle ??
                    interRegularDefault.copyWith(color: MyColor.getTextColor()),
                cursorColor: MyColor.getTextColor(),
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                decoration: InputDecoration(
                  contentPadding: widget.contentPadding,
                  hintText: widget.hintText?.tr ?? '',
                  hintStyle:
                      interRegularDefault.copyWith(color: widget.hintTextColor),
                  fillColor: widget.fillColor,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.5,
                          color: MyColor.getTextFieldDisableBorder()),
                      borderRadius: BorderRadius.circular(widget.radius)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 0.5,
                          color: MyColor.textFieldDisableBorderColor),
                      borderRadius: BorderRadius.circular(widget.radius)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 0.5, color: MyColor.getTextFieldDisableBorder()),
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.isPassword
                      ? UnconstrainedBox(
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              focusColor: MyColor.colorGrey.withOpacity(0.01),
                              autofocus: false,
                              canRequestFocus: false,
                              onTap: _toggle,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(Dimensions.space5),
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                height: 25,
                                width: 25,
                                child: SvgPicture.asset(
                                  obscureText
                                      ? MyImages.eyeInvisibleIcon
                                      : MyImages.eyeVisibleIcon,
                                  color: MyColor.getHintTextColor(),
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                            ),
                          ),
                        )
                      : widget.suffixIcon,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null
                    ? FocusScope.of(context).requestFocus(widget.nextFocus)
                    : null,
                onChanged: (text) => widget.onChanged!(text),
              ),
            ],
          )
        : widget.isAttachment
            ? TextFormField(
                maxLines: widget.maxLines,
                readOnly: widget.readOnly,
                style: widget.inputTextStyle ??
                    interRegularDefault.copyWith(color: MyColor.getTextColor()),
                cursorColor: MyColor.getTextColor(),
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                decoration: InputDecoration(
                  contentPadding: widget.contentPadding,
                  hintText: widget.hintText?.tr ?? '',
                  hintStyle:
                      interRegularDefault.copyWith(color: widget.hintTextColor),
                  fillColor: widget.fillColor,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.5,
                          color: MyColor.getTextFieldDisableBorder()),
                      borderRadius: BorderRadius.circular(widget.radius)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.5,
                          color: MyColor.getTextFieldDisableBorder()),
                      borderRadius: BorderRadius.circular(widget.radius)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        width: 0.5, color: MyColor.getTextFieldDisableBorder()),
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.isPassword
                      ? UnconstrainedBox(
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              focusColor: MyColor.colorGrey.withOpacity(0.01),
                              autofocus: false,
                              canRequestFocus: false,
                              onTap: _toggle,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(Dimensions.space5),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: MyColor.primaryColor),
                                height: 25,
                                width: 25,
                              ),
                            ),
                          ),
                        )
                      : widget.suffixIcon,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null
                    ? FocusScope.of(context).requestFocus(widget.nextFocus)
                    : null,
                onChanged: (text) => widget.onChanged!(text),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.hideLabel != true) ...[
                    LabelText(
                      text: widget.labelText.toString(),
                      required: widget.isRequired,
                      // textStyle: widget.labelTextStyle ?? Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: Dimensions.textToTextSpace),
                  ],
                  TextFormField(
                    maxLines: widget.maxLines,
                    readOnly: widget.readOnly,
                    style: widget.inputTextStyle ??
                        interRegularDefault.copyWith(
                            color: MyColor.getTextColor()),
                    cursorColor: MyColor.getTextColor(),
                    controller: widget.controller,
                    autofocus: false,
                    textInputAction: widget.inputAction,
                    enabled: widget.isEnable,
                    focusNode: widget.focusNode,
                    validator: widget.validator,
                    keyboardType: widget.textInputType,
                    obscureText: widget.isPassword ? obscureText : false,
                    decoration: InputDecoration(
                      contentPadding: widget.contentPadding,
                      hintText: widget.hintText?.tr ?? '',
                      hintStyle: interRegularDefault.copyWith(
                          color: widget.hintTextColor),
                      fillColor: widget.fillColor,
                      filled: true,
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: MyColor.getFieldDisableBorderColor()),
                          borderRadius:
                              BorderRadius.circular(Dimensions.defaultRadius)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: MyColor.getFieldEnableBorderColor()),
                          borderRadius:
                              BorderRadius.circular(Dimensions.defaultRadius)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: MyColor.getFieldDisableBorderColor()),
                          borderRadius:
                              BorderRadius.circular(Dimensions.defaultRadius)),
                      prefixIcon: widget.prefixIcon,
                      suffixIcon: widget.isPassword
                          ? UnconstrainedBox(
                              child: Material(
                                color: Colors.transparent,
                                shape: const CircleBorder(),
                                child: InkWell(
                                  splashColor: MyColor.getPrimaryColor()
                                      .withOpacity(0.1),
                                  onTap: _toggle,
                                  child: Container(
                                      padding: const EdgeInsets.all(
                                          Dimensions.space5),
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle),
                                      height: 25,
                                      width: 25,
                                      child: SvgPicture.asset(
                                        obscureText
                                            ? MyImages.eyeInvisibleIcon
                                            : MyImages.eyeVisibleIcon,
                                        color: MyColor.getHintTextColor(),
                                        height: 18,
                                        width: 18,
                                      )),
                                ),
                              ),
                            )
                          : widget.suffixIcon,
                    ),
                    onFieldSubmitted: (text) => widget.nextFocus != null
                        ? FocusScope.of(context).requestFocus(widget.nextFocus)
                        : null,
                    onChanged: (text) => widget.onChanged!(text),
                  ),
                ],
              );
  }

  void _toggle() {
    setState(() {
      obscureText = !obscureText;
    });
  }
}
