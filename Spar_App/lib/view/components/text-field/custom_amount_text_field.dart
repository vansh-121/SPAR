import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/core/utils/amount_validator.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';

class CustomAmountTextField extends StatefulWidget {
  const CustomAmountTextField(
      {Key? key,
      required this.labelText,
      required this.hintText,
      this.controller,
      this.chargeText = '',
      required this.currency,
      required this.onChanged,
      this.autoFocus = false,
      this.isRequired = true,
      this.inputAction,
      this.readOnly = false,
      this.validator,
      this.enforceHundredMultiples = true})
      : super(key: key);

  final String chargeText;
  final String labelText;
  final String hintText;
  final String currency;
  final bool autoFocus;
  final bool readOnly;
  final bool isRequired;
  final Function(String) onChanged;
  final TextEditingController? controller;
  final TextInputAction? inputAction;
  final FormFieldValidator<String>? validator;
  final bool enforceHundredMultiples;

  @override
  State<CustomAmountTextField> createState() => _CustomAmountTextFieldState();
}

class _CustomAmountTextFieldState extends State<CustomAmountTextField> {
  bool isFocus = false;
  String? errorText;

  void _validateAmount(String value) {
    if (!widget.enforceHundredMultiples) {
      setState(() {
        errorText = null;
      });
      return;
    }

    if (value.isEmpty) {
      setState(() {
        errorText = null;
      });
      return;
    }

    final validationError = AmountValidator.validateHundredDenomination(value);
    setState(() {
      errorText = validationError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(text: widget.labelText.tr, required: widget.isRequired),
        const SizedBox(height: 8),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.space15, vertical: 8),
          decoration: BoxDecoration(
              color: MyColor.transparentColor,
              border: Border.all(
                  color: errorText != null
                      ? MyColor.redCancelTextColor
                      : isFocus
                          ? MyColor.getFieldEnableBorderColor()
                          : MyColor.getFieldDisableBorderColor(),
                  width: 0.5),
              borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: FocusScope(
                  child: Focus(
                    onFocusChange: (focus) {
                      setState(() {
                        isFocus = focus;
                      });
                      if (!focus && widget.controller != null) {
                        _validateAmount(widget.controller!.text);
                      }
                    },
                    child: TextField(
                      cursorColor: MyColor.getTextColor(),
                      readOnly: widget.readOnly,
                      controller: widget.controller,
                      autofocus: widget.autoFocus,
                      style: interRegularDefault.copyWith(
                          color: MyColor.getTextColor()),
                      textAlign: TextAlign.left,
                      keyboardType: TextInputType.number,
                      textInputAction: widget.inputAction,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (widget.enforceHundredMultiples) {
                          _validateAmount(value);
                        }
                        widget.onChanged(value);
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(bottom: 16),
                          hintText: widget.hintText,
                          hintStyle: interRegularSmall.copyWith(
                              color: MyColor.hintTextColor, height: 1.452),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          errorBorder: InputBorder.none),
                    ),
                  ),
                ),
              ),
              Container(
                width: 48,
                padding: const EdgeInsets.all(Dimensions.space5),
                decoration: BoxDecoration(
                    color: MyColor.getTextColor().withOpacity(0.04),
                    borderRadius: BorderRadius.circular(5)),
                alignment: Alignment.center,
                child: Text(widget.currency,
                    textAlign: TextAlign.center,
                    style: interRegularDefault.copyWith(
                        color: MyColor.getTextColor(),
                        fontWeight: FontWeight.w500)),
              )
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Text(
            errorText!,
            style: interRegularSmall.copyWith(
              color: MyColor.redCancelTextColor,
              fontSize: Dimensions.fontSmall,
            ),
          ),
        ],
      ],
    );
  }
}
