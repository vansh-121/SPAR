import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/style.dart';

import '../../core/utils/dimensions.dart';
import '../../core/utils/my_color.dart';

class CustomRadioButton extends StatefulWidget {
  final String? title, selectedValue;
  final int selectedIndex;
  final List<String> list;
  final ValueChanged? onChanged;
  const CustomRadioButton({Key? key,
    this.title,
    this.selectedIndex=0,
    this.selectedValue,
    required this.list,
    this.onChanged, }) : super(key: key);

  @override
  _CustomRadioButtonState createState() => _CustomRadioButtonState();
}

class _CustomRadioButtonState extends State<CustomRadioButton> {


  @override
  Widget build(BuildContext context) {

    if(widget.list.isEmpty){
      return Container();
    }
    return Column(
      children: [
        widget.title!=null?const SizedBox():Text(widget.title??''),
        Column(
          children: List<RadioListTile<int>>.generate(
              widget.list.length,
                  (int index){
                bool isSelected = index == widget.selectedIndex;
                return RadioListTile<int>(
                  value: index,
                  groupValue: widget.selectedIndex,
                  fillColor:
                  MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                        return (isSelected)
                            ? MyColor.primaryColor
                            : MyColor.getBorderColor();
                      }),
                  activeColor: MyColor.getPrimaryColor(),
                  selectedTileColor: MyColor.getPrimaryColor(),
                  title: Text(widget.list[index].tr,style: interRegularDefault.copyWith(color: MyColor.getTextColor()),),
                  selected: index==widget.selectedIndex,
                  onChanged: (int? value) {
                    setState((){
                      if(value!=null){
                        widget.onChanged!(index);
                      }

                    });
                  },
                );
              }
          )
        ),
      ],
    );
  }
}
