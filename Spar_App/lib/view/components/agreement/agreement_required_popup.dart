import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementRequiredPopup {
  static void show(BuildContext context, {String? userEmail}) {
    CustomBottomSheet(
      backgroundColor: MyColor.getCardBg(),
      isNeedMargin: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const BottomSheetBar(),
          const SizedBox(height: Dimensions.space20),
          
          // Icon
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_outlined,
              size: 40,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: Dimensions.space20),
          
          // Title
          Text(
            MyStrings.agreementPopupTitle.tr,
            style: interSemiBoldExtraLarge.copyWith(
              color: MyColor.getTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.space12),
          
          // Message
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.space10),
            child: Text(
              MyStrings.agreementPopupMessage.tr,
              style: interRegularDefault.copyWith(
                color: MyColor.getLabelTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          if (userEmail != null && userEmail.isNotEmpty) ...[
            const SizedBox(height: Dimensions.space20),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.space15,
                vertical: Dimensions.space12,
              ),
              decoration: BoxDecoration(
                color: MyColor.getPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                border: Border.all(
                  color: MyColor.getPrimaryColor().withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: MyColor.getPrimaryColor(),
                  ),
                  const SizedBox(width: Dimensions.space10),
                  Flexible(
                    child: Text(
                      userEmail,
                      style: interMediumDefault.copyWith(
                        color: MyColor.getPrimaryColor(),
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: Dimensions.space30),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: RoundedButton(
                  text: MyStrings.checkEmail,
                  press: () {
                    _openEmailApp(context);
                  },
                  color: MyColor.getPrimaryColor(),
                  textColor: MyColor.colorWhite,
                  verticalPadding: 14,
                  horizontalPadding: 20,
                ),
              ),
              const SizedBox(width: Dimensions.space12),
              Expanded(
                child: RoundedButton(
                  text: MyStrings.contactSupport,
                  press: () {
                    Get.back();
                    Get.toNamed(RouteHelper.allTicketScreen);
                  },
                  color: MyColor.getScreenBgColor(),
                  textColor: MyColor.getTextColor(),
                  isOutlined: true,
                  borderColor: MyColor.getBorderColor(),
                  verticalPadding: 14,
                  horizontalPadding: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: Dimensions.space15),
          
          // Close button
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              MyStrings.close.tr,
              style: interRegularDefault.copyWith(
                color: MyColor.getLabelTextColor(),
              ),
            ),
          ),
          
          const SizedBox(height: Dimensions.space5),
        ],
      ),
    ).customBottomSheet(context);
  }

  static void _openEmailApp(BuildContext context) async {
    // Try to open email app with mailto scheme
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: '',
    );
    
    try {
      Get.back(); // Close bottom sheet first
      
      bool launched = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
      
      if (!launched) {
        // Show snackbar if email app can't be opened
        Get.snackbar(
          MyStrings.error.tr,
          'Could not open email app. Please check your email manually.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: MyColor.getTextColor(),
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(Dimensions.space15),
        );
      }
    } catch (e) {
      // Show snackbar on error
      Get.snackbar(
        MyStrings.error.tr,
        'Could not open email app. Please check your email manually.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: MyColor.getTextColor(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(Dimensions.space15),
      );
    }
  }
}
