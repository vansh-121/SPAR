import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hyip_lab/core/utils/my_color.dart';

class MyUtils {
  static dynamic getShadow() {
    return [
      BoxShadow(
          blurRadius: 15.0,
          offset: const Offset(0, 25),
          color: Colors.grey.shade500.withOpacity(0.6),
          spreadRadius: -35.0),
    ];
  }

  static dynamic getBottomSheetShadow() {
    return [
      BoxShadow(
        // color: MyColor.screenBgColor,
        color: Colors.grey.shade400.withOpacity(0.08),
        spreadRadius: 3,
        blurRadius: 4,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ];
  }

  static dynamic getCardShadow() {
    return [
      BoxShadow(
        color: Colors.grey.shade400.withOpacity(0.05),
        spreadRadius: 2,
        blurRadius: 2,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static void splashScreenUtils() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: MyColor.colorBlack,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: MyColor.colorBlack,
        systemNavigationBarIconBrightness: Brightness.dark));
  }

  static void allScreensUtils(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: MyColor.primaryColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: MyColor.getScreenBgColor(),
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark));
  }

  static bool isImage(String path) {
    if (path.contains('.jpg')) {
      return true;
    }
    if (path.contains('.png')) {
      return true;
    }
    if (path.contains('.jpeg')) {
      return true;
    }
    return false;
  }

  static bool isDoc(String path) {
    if (path.contains('.doc')) {
      return true;
    }
    if (path.contains('.docs')) {
      return true;
    }
    return false;
  }
}
