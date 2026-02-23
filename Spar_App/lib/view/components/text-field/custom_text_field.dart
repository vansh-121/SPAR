import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';

import '../text/label_text_with_instructions.dart';

class CustomTextField extends StatefulWidget {
  final String? instructions;
  final bool isShowInstructionWidget;
  final bool isRequired;
  final String? labelText;
  final String? hintText;
  final Function? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final FormFieldValidator? validator;
  final TextInputType? textInputType;
  final bool isEnable;
  final bool isPassword;
  final bool isShowSuffixIcon;
  final bool isIcon;
  final VoidCallback? onSuffixTap;
  final bool isSearch;
  final bool isCountryPicker;
  final TextInputAction inputAction;
  final bool needOutlineBorder;
  final bool needLabel;
  final bool readOnly;
  final bool needRequiredSign;
  final Color? disableColor;
  final int? maxLines;
  final VoidCallback? onTap;
  final Widget? prefixWidget;

  const CustomTextField({
    Key? key,
    this.labelText,
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
    this.isShowSuffixIcon = false,
    this.isIcon = false,
    this.onSuffixTap,
    this.isSearch = false,
    this.isCountryPicker = false,
    this.inputAction = TextInputAction.next,
    this.needOutlineBorder = false,
    this.needLabel = true,
    this.needRequiredSign = false,
    this.disableColor,
    this.instructions,
    this.isShowInstructionWidget = false,
    this.isRequired = false,
    this.maxLines,
    this.onTap,
    this.prefixWidget,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return widget.needOutlineBorder
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.isShowInstructionWidget
                  ? LabelTextInstruction(
                      text: widget.labelText.toString(),
                      isRequired: widget.isRequired,
                      instructions: widget.instructions,
                    )
                  : const SizedBox(),
              widget.isShowInstructionWidget
                  ? const SizedBox(height: Dimensions.textToTextSpace)
                  : const SizedBox(),
              TextFormField(
                readOnly: widget.readOnly,
                maxLines: widget.maxLines ?? 1,
                style:
                    interRegularDefault.copyWith(color: MyColor.getTextColor()),
                textAlign: TextAlign.left,
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
                  errorMaxLines: 2,
                  contentPadding: const EdgeInsets.only(
                      top: 5, left: 15, right: 15, bottom: 5),
                  hintText: widget.hintText != null ? widget.hintText!.tr : '',
                  hintStyle: interRegularSmall.copyWith(
                      color: MyColor.getHintTextColor()),
                  fillColor: MyColor.transparentColor,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: MyColor.getFieldDisableBorderColor()),
                      borderRadius:
                          BorderRadius.circular(Dimensions.defaultRadius)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: MyColor.getFieldEnableBorderColor()),
                      borderRadius:
                          BorderRadius.circular(Dimensions.defaultRadius)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: MyColor.getFieldDisableBorderColor()),
                      borderRadius:
                          BorderRadius.circular(Dimensions.defaultRadius)),
                  prefixIcon: widget.prefixWidget,
                  suffixIcon: widget.isShowSuffixIcon
                      ? widget.isPassword
                          ? IconButton(
                              icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: MyColor.hintTextColor,
                                  size: 20),
                              onPressed: _toggle)
                          : widget.isIcon
                              ? IconButton(
                                  onPressed: widget.onSuffixTap,
                                  icon: Icon(
                                    widget.isSearch
                                        ? Icons.search_outlined
                                        : widget.isCountryPicker
                                            ? Icons.arrow_drop_down_outlined
                                            : Icons.camera_alt_outlined,
                                    size: 25,
                                    color: MyColor.getPrimaryColor(),
                                  ),
                                )
                              : null
                      : null,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null
                    ? FocusScope.of(context).requestFocus(widget.nextFocus)
                    : null,
                onChanged: (text) => widget.onChanged!(text),
                onTap: widget.onTap,
              )
            ],
          )
        : Column(
            children: [
              widget.isShowInstructionWidget
                  ? LabelTextInstruction(
                      text: widget.labelText.toString(),
                      isRequired: widget.isRequired,
                      instructions: widget.instructions,
                    )
                  : const SizedBox.shrink(),
              TextFormField(
                maxLines: widget.maxLines ?? 1,
                readOnly: widget.readOnly,
                style: interRegularDefault.copyWith(
                    color: MyColor.getInputTextColor()),
                textAlign: TextAlign.left,
                cursorColor: MyColor.getHintTextColor(),
                controller: widget.controller,
                autofocus: false,
                textInputAction: widget.inputAction,
                enabled: widget.isEnable,
                focusNode: widget.focusNode,
                validator: widget.validator,
                keyboardType: widget.textInputType,
                obscureText: widget.isPassword ? obscureText : false,
                decoration: InputDecoration(
                  errorMaxLines: 2,
                  contentPadding: const EdgeInsets.only(
                      top: 5, left: 0, right: 0, bottom: 5),
                  labelText: widget.labelText?.tr,
                  labelStyle: interRegularDefault.copyWith(
                      color: MyColor.getLabelTextColor()),
                  fillColor: MyColor.transparentColor,
                  filled: true,
                  disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: widget.disableColor ??
                              MyColor.getFieldDisableBorderColor())),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: MyColor.getFieldDisableBorderColor())),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: MyColor.getFieldEnableBorderColor())),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: MyColor.getFieldDisableBorderColor())),
                  prefixIcon: widget.prefixWidget,
                  suffixIcon: widget.isShowSuffixIcon
                      ? widget.isPassword
                          ? IconButton(
                              icon: Icon(
                                  obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: MyColor.hintTextColor,
                                  size: 20),
                              onPressed: _toggle)
                          : widget.isIcon
                              ? IconButton(
                                  onPressed: widget.onSuffixTap,
                                  icon: Icon(
                                    widget.isSearch
                                        ? Icons.search_outlined
                                        : widget.isCountryPicker
                                            ? Icons.arrow_drop_down_outlined
                                            : Icons.camera_alt_outlined,
                                    size: 25,
                                    color: MyColor.getPrimaryColor(),
                                  ),
                                )
                              : null
                      : null,
                ),
                onFieldSubmitted: (text) => widget.nextFocus != null
                    ? FocusScope.of(context).requestFocus(widget.nextFocus)
                    : null,
                onChanged: (text) => widget.onChanged!(text),
                onTap: widget.onTap,
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
