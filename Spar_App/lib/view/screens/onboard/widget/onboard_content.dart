import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/style.dart';

import '../../../../core/utils/dimensions.dart';
import '../../../../core/utils/my_color.dart';
import '../../../../core/utils/my_images.dart';
import '../../../../data/controller/onboard/onboard_controller.dart';

class OnboardContent extends StatelessWidget {
  final OnboardController controller;
  final int index;
  final String title;
  final String subTitle;
  final String? image;

  const OnboardContent({super.key, required this.controller, required this.index, required this.title, required this.subTitle, this.image});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Padding(
      padding: Dimensions.cardPaddingHV,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: size.height * .03),

              // CachedNetworkImage(
              //   imageUrl: image!,
              //   width: size.width*.65,
              //   placeholder: (context, url) => CustomLoader(loaderColor: MyColor.getPrimaryColor()),
              //   errorWidget: (context, url, error) => const Icon(Icons.error),
              // ),
              Image.asset(image ?? MyImages.onboardFirstImage,width: size.width *.85,),
              SizedBox(height: size.height * .04),
              Text(title.tr, textAlign: TextAlign.center, style: interBoldExtraLarge.copyWith(fontSize: 22, color: MyColor.getTextColor())),
              SizedBox(height: size.height * .03),
              Text(subTitle.tr, textAlign: TextAlign.center, style: interRegularDefault.copyWith(fontSize: 16, color: MyColor.getTextColor1()))
            ],
          ),
        ),
      ),
    );
  }
}
