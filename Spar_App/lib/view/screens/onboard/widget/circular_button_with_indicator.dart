import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/onboard/onboard_controller.dart';
import 'package:hyip_lab/data/services/api_service.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import 'indicator.dart';

class CircularButtonWithIndicator extends StatelessWidget {
  final OnboardController controller;

  const CircularButtonWithIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * .05),
      child: Stack(alignment: Alignment.center, children: [
        AnimatedIndicator(
          duration: const Duration(seconds: 10),
          size: Dimensions.indicatorSize,
          callback: () {},
          indicatorValue: 100 / MyStrings.onboardTitleList.length * (controller.currentIndex.toDouble() + 1),
        ),
        GestureDetector(
          child: Container(
            alignment: Alignment.bottomCenter,
            height: Dimensions.space60,
            width: Dimensions.space60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: MyColor.primaryColor),
            child: Center(
              child: Icon(
                controller.currentIndex == MyStrings.onboardTitleList.length - 1 ? Icons.check : Icons.arrow_forward_ios_rounded,
                color: MyColor.colorWhite,
              ),
            ),
          ),
          onTap: () {
            if (controller.currentIndex < MyStrings.onboardTitleList.length - 1) {
              controller.controller?.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Get.find<ApiClient>().sharedPreferences.setBool(SharedPreferenceHelper.firstTimeAppOpeningStatus, false);
              Get.toNamed(RouteHelper.loginScreen);
            }
          },
        )
      ]),
    );
  }
}
