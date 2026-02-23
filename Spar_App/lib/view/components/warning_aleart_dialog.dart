import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_images.dart';
import '../../../core/utils/my_strings.dart';

class WarningAlertDialog {
  const WarningAlertDialog();
  void warningAlertDialog(BuildContext context, VoidCallback press,
      {String titleMessage = MyStrings.areYourSure,
      String subtitleMessage = MyStrings.youWantToExitTheApp,
      bool isDelete = false}) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
              backgroundColor: MyColor.getCardBg(),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: Dimensions.space40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: Dimensions.space40,
                            bottom: Dimensions.space15,
                            left: Dimensions.space15,
                            right: Dimensions.space15),
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: MyColor.getCardBg(),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Text(
                                  titleMessage.tr,
                                  style: interSemiBoldLarge.copyWith(
                                      color: MyColor.colorRed),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subtitleMessage.tr,
                                  style: interRegularSmall.copyWith(
                                      color: MyColor.getTextColor()),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                ),
                              ],
                            ),
                            const SizedBox(height: Dimensions.space15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: RoundedButton(
                                    text: MyStrings.no.tr,
                                    press: () {
                                      Navigator.pop(context);
                                    },
                                    horizontalPadding: 3,
                                    verticalPadding: 3,
                                    color: MyColor.colorGrey,
                                    textColor: MyColor.colorWhite,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space10),
                                Expanded(
                                  child: RoundedButton(
                                      text: MyStrings.yes.tr,
                                      press: press,
                                      horizontalPadding: 3,
                                      verticalPadding: 3,
                                      color: MyColor.colorRed,
                                      textColor: MyColor.colorWhite),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: -30,
                        left: MediaQuery.of(context).padding.left,
                        right: MediaQuery.of(context).padding.right,
                        child: Image.asset(
                          MyImages.warning,
                          height: 60,
                          width: 60,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
