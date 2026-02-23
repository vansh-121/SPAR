import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_images.dart';


class OnboardController extends GetxController {
  int currentIndex = 0;
  PageController? controller = PageController();

  void setCurrentIndex(int index) {
    currentIndex = index;
    update();
  }


  List<String> onboardImageList = [
    MyImages.onboardFirstImage,
    MyImages.onboardSecondImage,
    MyImages.onboardThirdImage,
  ];

  bool isLoading = true;
}
