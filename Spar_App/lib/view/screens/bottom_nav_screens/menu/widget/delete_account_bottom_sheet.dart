import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/style.dart';

import '../../../../../core/utils/dimensions.dart';
import '../../../../../core/utils/my_color.dart';
import '../../../../../core/utils/my_images.dart';
import '../../../../../core/utils/my_strings.dart';
import '../../../../components/show_custom_snackbar.dart';
import '../../../../components/text-field/custom_text_field.dart';
import 'package:hyip_lab/data/controller/menu/menu_controller.dart' as menu;

class DeleteAccountBottomsheetBody extends StatefulWidget {
  menu.MenuController controller;
  DeleteAccountBottomsheetBody({super.key, required this.controller});
  @override
  State<DeleteAccountBottomsheetBody> createState() =>
      _DeleteAccountBottomsheetBodyState();
}

class _DeleteAccountBottomsheetBodyState
    extends State<DeleteAccountBottomsheetBody> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<menu.MenuController>(builder: (menuController) {
      return LayoutBuilder(builder: (context, box) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            menuController.passwordDeleteController.clear();
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.clear,
                        size: 22, color: MyColor.getTextColor()),
                    padding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: Dimensions.space12),
                SvgPicture.asset(
                  MyImages.userDeleteImage,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  color: MyColor.redCancelTextColor,
                ),
                const SizedBox(height: Dimensions.space25),
                Text(
                  MyStrings.deleteYourAccount,
                  style: interRegularDefault.copyWith(
                      color: MyColor.getTextColor(),
                      fontSize: Dimensions.fontMediumLarge),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Dimensions.space25),
                Text(
                  MyStrings.deleteBottomSheetSubtitle,
                  style: interRegularDefault.copyWith(
                      color: MyColor.getTextColor1(),
                      fontSize: Dimensions.fontDefault),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                CustomTextField(
                  needOutlineBorder: true,
                  labelText: MyStrings.typeYourPassword.tr,
                  controller: menuController.passwordDeleteController,
                  onChanged: (value) {},
                  isShowSuffixIcon: true,
                  isPassword: true,
                  textInputType: TextInputType.text,
                  inputAction: TextInputAction.done,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return MyStrings.fieldErrorMsg.tr;
                    } else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: Dimensions.space40),
                GestureDetector(
                  onTap: () {
                    if (widget
                        .controller.passwordDeleteController.text.isNotEmpty) {
                      widget.controller.deleteAccount();
                    } else {
                      CustomSnackBar.error(
                          errorList: [MyStrings.enterYourPassword_]);
                    }
                  },
                  child: Container(
                    width: context.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 17),
                    decoration: BoxDecoration(
                      color: MyColor.delteBtnColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: menuController.isDeleteBtnLoading
                          ? const SizedBox(
                              width: Dimensions.fontExtraLarge + 3,
                              height: Dimensions.fontExtraLarge + 3,
                              child: CircularProgressIndicator(
                                  color: MyColor.delteBtnTextColor,
                                  strokeWidth: 2),
                            )
                          : Text(
                              MyStrings.deleteAccount,
                              style: interMediumDefault.copyWith(
                                  color: MyColor.delteBtnTextColor,
                                  fontSize: Dimensions.fontExtraLarge),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.space10),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    width: context.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 17),
                    decoration: BoxDecoration(
                      color: MyColor.getTextColor1().withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        MyStrings.cancel,
                        style: interMediumDefault.copyWith(
                            color: MyColor.getTextColor(),
                            fontSize: Dimensions.fontExtraLarge),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }
}
