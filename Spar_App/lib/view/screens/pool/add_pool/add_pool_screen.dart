import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/pool/pool_contrroller.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_amount_text_field.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';
import '../../../../core/utils/util.dart';
import '../../../../data/controller/common/theme_controller.dart';

class AddPoolScreen extends StatefulWidget {
  const AddPoolScreen({super.key});

  @override
  State<AddPoolScreen> createState() => _AddPoolScreenState();
}

class _AddPoolScreenState extends State<AddPoolScreen> {
  String id = "-1";
  @override
  void initState() {
    String arg = Get.arguments.toString();
    id = arg;

    ThemeController themeController = ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.find<PoolController>().amountController.text = "";
      Get.find<PoolController>().planID = "-1";
      Get.find<PoolController>().changePlanID(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(title: MyStrings.pool),
      body: GetBuilder<PoolController>(builder: (controller) {
        return controller.isLoading? const CustomLoader() : SingleChildScrollView(
          child: Padding(
            padding: Dimensions.screenPaddingHV,
            child: Column(
              children: [
                const LabelText(text: MyStrings.wallet, required: true),
                const SizedBox(height: Dimensions.space5),
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

                const SizedBox(
                  height: Dimensions.space25,
                ),
                CustomAmountTextField(
                  labelText: MyStrings.amount,
                  hintText: "",
                  currency: controller.currency,
                  onChanged: (val) {},
                  controller: controller.amountController,
                  autoFocus: false,
                ),
                const SizedBox(
                  height: Dimensions.space50,
                ),
                controller.isSubmitLoading ?
                const RoundedLoadingBtn() :
                RoundedButton(
                  text: MyStrings.submit,
                  press: () {
                    controller.submitPool();
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
