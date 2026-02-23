import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';

import '../../../core/utils/my_images.dart';

class WarningAlertDialog {
  const WarningAlertDialog();

  void deleteAlertDialog(BuildContext context, VoidCallback press) {
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
                            Text(
                              MyStrings.accountDeleteTitle.tr,
                              style: interSemiBoldDefault.copyWith(
                                  color: MyColor.red),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: Dimensions.space10),
                            Text(
                              MyStrings.accountDeleteTitle.tr,
                              style: interRegularDefault.copyWith(
                                  color: MyColor.getTextColor()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
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
                                    color: MyColor.getScreenBgColor(),
                                    textColor: MyColor.getTextColor(),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space10),
                                Expanded(
                                  child: RoundedButton(
                                      text: MyStrings.yes.tr,
                                      press: press,
                                      horizontalPadding: 3,
                                      verticalPadding: 3,
                                      color: MyColor.getPrimaryColor(),
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
                          MyImages.warningImage,
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

  void actionAlertDialog(
      BuildContext context, VoidCallback press, String title) {
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
                            const SizedBox(height: Dimensions.space5),
                            Text(
                              title,
                              style: interRegularDefault.copyWith(
                                  color: MyColor.getTextColor()),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
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
                                    color: MyColor.getScreenBgColor(),
                                    textColor: MyColor.getTextColor(),
                                  ),
                                ),
                                const SizedBox(width: Dimensions.space10),
                                Expanded(
                                  child: RoundedButton(
                                      text: MyStrings.yes.tr,
                                      press: press,
                                      horizontalPadding: 3,
                                      verticalPadding: 3,
                                      color: MyColor.getPrimaryColor(),
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
                          MyImages.warningImage,
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
