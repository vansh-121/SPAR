import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/core/utils/util.dart';
import '../../../components/image/my_image_widget.dart';

class LanguageCard extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final bool isShowTopRight;
  final String langeName;
  final String imagePath;

  const LanguageCard(
      {super.key,
      required this.index,
      required this.selectedIndex,
      this.isShowTopRight = false,
      required this.langeName,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsetsDirectional.symmetric(
              vertical: Dimensions.space25),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: MyColor.getCardBg(),
              borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
              boxShadow: MyUtils.getCardShadow()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   height: 55,
              //   width: 55,
              //   alignment: Alignment.center,
              //   decoration: BoxDecoration(color: MyColor.getScreenBgColor(), shape: BoxShape.circle),
              //   child: const Icon(Icons.g_translate, color: MyColor.primaryColor, size: 22.5),
              // ),
              MyImageWidget(
                imageUrl: imagePath,
                width: 50,
                height: 50,
              ),
              const SizedBox(height: Dimensions.space10),
              Text(
                langeName.tr,
                style:
                    interSemiBoldSmall.copyWith(color: MyColor.getTextColor()),
              )
            ],
          ),
        ),
        index == selectedIndex
            ? isShowTopRight
                ? Positioned(
                    right: Dimensions.space12,
                    top: Dimensions.space10,
                    child: Container(
                      height: 20,
                      width: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: MyColor.getPrimaryColor(),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: MyColor.colorWhite, size: 10),
                    ),
                  )
                : Positioned(
                    left: 50,
                    right: 50,
                    top: 25,
                    child: Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: MyColor.getPrimaryColor().withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: MyColor.colorWhite, size: 22.5),
                    ),
                  )
            : const Positioned(
                top: Dimensions.space10,
                right: Dimensions.space12,
                child: SizedBox(),
              )
      ],
    );
  }
}
