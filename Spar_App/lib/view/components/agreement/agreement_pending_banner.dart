import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';

class AgreementPendingBanner extends StatelessWidget {
  final VoidCallback? onTap;

  const AgreementPendingBanner({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15,
          vertical: Dimensions.space10,
        ),
        padding: const EdgeInsets.all(Dimensions.space15),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: Dimensions.space12),
            
            // Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    MyStrings.agreementRequired,
                    style: interSemiBoldDefault.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: Dimensions.space5),
                  Text(
                    'Check your email and contact support to unlock all features',
                    style: interRegularSmall.copyWith(
                      color: MyColor.getTextColor().withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            GestureDetector(
              onTap: () {
                Get.toNamed(RouteHelper.allTicketScreen);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space12,
                  vertical: Dimensions.space5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                ),
                child: Text(
                  MyStrings.contactSupport,
                  style: interMediumSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
