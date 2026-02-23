import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:get/get.dart';

class CustomDropDownWithTextField extends StatefulWidget {
  String? title, selectedValue;
  final List<String> list;
  final ValueChanged? onChanged;

  CustomDropDownWithTextField({
    Key? key,
    this.title,
    this.selectedValue,
    required this.list,
    this.onChanged,
  }) : super(key: key);

  @override
  State<CustomDropDownWithTextField> createState() => _CustomDropDownWithTextFieldState();
}

class _CustomDropDownWithTextFieldState extends State<CustomDropDownWithTextField> {
  @override
  void initState() {
    log(widget.list.first.toString());
    widget.selectedValue = widget.selectedValue;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  Widget build(BuildContext context) {
    widget.list.toList().removeWhere((element) => element.isEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 45,
          decoration: BoxDecoration(
            color: MyColor.transparentColor,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            border: Border.all(
              color: MyColor.getCardBg(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            child: DropdownButton<String>(
              isExpanded: true,
              underline: Container(),
              hint: Text(
                widget.selectedValue?.tr ?? '',
                style: interRegularDefault.copyWith(color: MyColor.getTextColor()),
              ), // Not necessary for Option 1
              value: widget.selectedValue,
              dropdownColor: MyColor.colorWhite,
              onChanged: widget.onChanged,
              items: widget.list.toList().map((value) {
                log(value);
                return DropdownMenuItem(
                  value: value,
                  child: Text(
                    value.tr,
                    style: interRegularDefault.copyWith(color: MyColor.getTextColor()),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
