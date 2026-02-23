// ignore_for_file: unrelated_type_equality_checks

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/core/utils/util.dart';
import 'package:hyip_lab/data/controller/staking/staking_controller.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/data/model/staking/staking_response_model.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_amount_text_field.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';

import '../../../../data/controller/common/theme_controller.dart';
import '../../../components/drop_dawn/custom_drop_down_field3.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {

  @override
  void initState() {
    ThemeController themeController = ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);
    super.initState();
  }

  bool isBottomSheetOpen = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(title: MyStrings.stacking),
      body: GetBuilder<StakingController>(builder: (controller) {
        return SingleChildScrollView(
          child: Padding(
            padding: Dimensions.screenPaddingHV,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LabelText(text: MyStrings.duration, required: true),
                const SizedBox(
                  height: Dimensions.space5,
                ),
                Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                  decoration: BoxDecoration(
                      color: MyColor.transparentColor,
                      borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                      border: Border.all(color:
                      MyColor.getFieldDisableBorderColor(), width: 0.5)
                  ),
                  child: DropdownButton<Staking>(
                    dropdownColor: MyColor.getScreenBgColor(),
                    value: controller.selectedStak,
                    elevation: 8,
                    icon: Icon(Icons.keyboard_arrow_down, color:  MyColor.getFieldDisableBorderColor()),
                    iconDisabledColor: Colors.red,
                    iconEnabledColor : MyColor.getPrimaryColor(),
                    isExpanded: true,
                    underline: Container(height: 0, color: MyColor.getAppbarBgColor()),
                    onChanged: (Staking? newValue) {
                      controller.selectStak(newValue);
                      // selected = newValue ?? "Select one";
                    },
                    items: controller.staking.map((Staking value) {
                      return DropdownMenuItem<Staking>(
                        value: value,
                        child:value.id == -1 ? Text(MyStrings.selectOne,style: interRegularDefault.copyWith(color: MyColor.getTextColor())) : Text("${value.days} ${MyStrings.days}- ${MyStrings.interest} ${value.interestPercent}%",
                        // child: Text("${value.days}",
                            style: interRegularDefault.copyWith(color: MyColor.getTextColor())
                        ),
                      );
                    }).toList(),
                  ),
                ),



                // controller.selectedStak?.id == -1 ? const SizedBox.shrink() :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: Dimensions.space25),
                    const LabelText(text: MyStrings.wallet, required: true),
                    const SizedBox(height: Dimensions.space5,),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.space15, vertical: Dimensions.space10),
                      decoration: BoxDecoration(
                          color: MyColor.transparentColor,
                          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                          border: Border.all(color:
                          MyColor.getFieldDisableBorderColor(), width: 0.5)
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: MyColor.getScreenBgColor(),
                        value: controller.selectedWallet,
                        elevation: 8,
                        icon: Icon(Icons.keyboard_arrow_down, color:  MyColor.getFieldDisableBorderColor()),
                        iconDisabledColor: Colors.red,
                        iconEnabledColor : MyColor.getPrimaryColor(),
                        isExpanded: true,
                        underline: Container(height: 0, color: MyColor.getAppbarBgColor()),
                        onChanged: (String? newValue) {
                          controller.selectwallet(newValue ?? MyStrings.selectOne);
                          // selected = newValue ?? "Select one";
                        },
                        items: controller.walletList.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child:value == MyStrings.selectOne ? Text(MyStrings.selectOne,style: interRegularDefault.copyWith(color: MyColor.getTextColor())) : Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                                style:  interRegularDefault.copyWith(color: MyColor.getTextColor())
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: Dimensions.space25),
                CustomAmountTextField(
                  labelText: "${MyStrings.amount} ${controller.stackingLimit}",
                  hintText: "0.0",
                  currency: controller.currency,
                  onChanged: (value) {
                    controller.calculateReturnAmount(value);
                  },
                  controller: controller.amountController,
                  autoFocus: false,
                ),
               Visibility(
                 visible: controller.amountController.text.isNotEmpty,
                 child: Column(
                 children: [
                   const SizedBox(height: Dimensions.space5+2),
                   Text("${MyStrings.totalReturn.tr} : ${controller.returnAmount} ${controller.currency}",style: interRegularDefault.copyWith(color: MyColor.primaryColor,fontSize: Dimensions.fontSmall),),
                 ],
               )),
                const SizedBox(
                  height: Dimensions.space50,
                ),
                controller.isSubmitLoading
                  ? const RoundedLoadingBtn()
                  : RoundedButton(
                      text: MyStrings.submit,
                      press: () {
                        controller.submiStaking();
                      },
                    ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
