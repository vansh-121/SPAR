import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/view/screens/onboard/widget/circular_button_with_indicator.dart';
import 'package:hyip_lab/view/screens/onboard/widget/onboard_content.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../../data/controller/onboard/onboard_controller.dart';
import '../../../data/services/api_service.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    // final controller = Get.put(OnboardController());
    Get.put(ApiClient(sharedPreferences: Get.find()));
    final controller = Get.put(OnboardController());
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GetBuilder<OnboardController>(
      builder: (controller) => SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: MyColor.getScreenBgColor(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              controller.currentIndex == MyStrings.onboardSubTitleList.length - 1
                  ? const SizedBox.shrink()
                  : SafeArea(
                      child: Container(
                        margin: EdgeInsets.only(top: size.height * .02, right: size.width * .06),
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            Get.toNamed(RouteHelper.loginScreen);
                          },
                          child: Text(MyStrings.skip.tr, style: interSemiBoldLarge.copyWith(color: MyColor.getTextColor())),
                        ),
                      ),
                    ),
              Expanded(
                child: PageView.builder(
                  controller: controller.controller,
                  itemCount: MyStrings.onboardTitleList.length,
                  onPageChanged: (int index) {
                    setState(() {
                      controller.currentIndex = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return OnboardContent(
                      controller: controller,
                      title: MyStrings.onboardTitleList[index].toString().toTitleCase(),
                      subTitle: MyStrings.onboardSubTitleList[index].toString().toTitleCase(),
                      index: index,
                      image: controller.onboardImageList[index],
                    );
                  },
                ),
              ),
              const SizedBox(height: Dimensions.space10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  MyStrings.onboardTitleList.length,
                  (index) => Container(
                    height: 10,
                    width: controller.currentIndex == index ? Dimensions.space20 : Dimensions.space10,
                    margin: const EdgeInsets.only(right: Dimensions.space5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: controller.currentIndex == index ? MyColor.primaryColor : MyColor.getTextColor3(),
                    ),
                  ),
                ),
              ),
              CircularButtonWithIndicator(controller: controller)
            ],
          ),
        ),
      ),
    );
  }
}
