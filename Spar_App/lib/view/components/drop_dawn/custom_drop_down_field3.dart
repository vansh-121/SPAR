import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/style.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';

class CustomDropDownTextField3 extends StatefulWidget {
  final dynamic selectedValue;
  final String? labelText;
  final String? hintText;
  final Function(dynamic)? onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final Color? fillColor;
  final Color? focusColor;
  final Color? dropDownColor;
  final Color? iconColor;
  final double radius;
  final bool needLabel;
  final bool isUnderLined;

  const CustomDropDownTextField3({
    Key? key,
    this.labelText,
    this.hintText,
    required this.selectedValue,
    required this.onChanged,
    required this.items,
    this.fillColor,
    this.focusColor,
    this.dropDownColor,
    this.iconColor,
    this.radius = Dimensions.defaultRadius,
    this.needLabel = true,
    this.isUnderLined = false,
  }) : super(key: key);

  @override
  State<CustomDropDownTextField3> createState() => _CustomDropDownTextField3State();
}

class _CustomDropDownTextField3State extends State<CustomDropDownTextField3> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.needLabel ? const SizedBox(height: Dimensions.textToTextSpace) : const SizedBox(),
        widget.isUnderLined ?
        SizedBox(
          height: 55,
          child: DropdownButtonFormField(
            value: widget.selectedValue,
            dropdownColor: widget.dropDownColor??MyColor.getCardBg(),
            focusColor: widget.focusColor??MyColor.getCardBg(),
            style: interRegularDefault.copyWith(color: MyColor.getTextColor()),
            alignment: Alignment.centerLeft,
            decoration: InputDecoration(
              hintText: widget.hintText.toString().tr,
              filled: true,
              fillColor: MyColor.colorWhite,
              hintStyle: interRegularDefault.copyWith(color: MyColor.getTextColor()),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: MyColor.primaryColor)),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: MyColor.borderColor)),
            ),
            isExpanded: true,
            onChanged: widget.onChanged,
            items: widget.items,
            icon: Icon(Icons.arrow_drop_down, color: widget.iconColor??MyColor.getTextColor()),
          ),
        )
        : SizedBox(
            height: 50,
            child: DropdownButtonFormField(
              alignment: Alignment.centerLeft,
              value: widget.selectedValue,
              dropdownColor: widget.dropDownColor??MyColor.getCardBg(),
              borderRadius: BorderRadius.circular(10),
              focusColor: widget.focusColor??MyColor.getCardBg(),
              style: interRegularDefault.copyWith(color: MyColor.getTextColor()),
              decoration: InputDecoration(
                hintText: widget.hintText.toString(),
                filled: true,
                fillColor: MyColor.transparentColor,
                hintStyle: interRegularDefault.copyWith(color: MyColor.getTextColor()),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                // contentPadding: EdgeInsets.only(bottom: 70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 243, 243, 243), width: .1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  borderSide: const BorderSide(color: Color.fromARGB(255, 236, 236, 236), width: .3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  borderSide: const BorderSide(color: MyColor.primaryColor, width: .1),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  borderSide: const BorderSide(color: MyColor.red, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  borderSide: const BorderSide(color: MyColor.borderColor, width: 1),
                ),
              ),
              isExpanded: true,
              onChanged: widget.onChanged,
              items: widget.items,
              icon: Icon(
                Icons.expand_more,
                color: widget.iconColor??MyColor.getTextColor(),
              ),
            ),
          )
      ],
    );
  }
}
