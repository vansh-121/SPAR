import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';

import '../../../../view/components/show_custom_snackbar.dart';
import '../../../model/authorization/authorization_response_model.dart';
import '../../../repo/auth/sms_email_verification_repo.dart';
import '../../../services/push_notification_service.dart';

class SmsVerificationController extends GetxController {
  SmsEmailVerificationRepo repo;
  SmsVerificationController({required this.repo});

  bool hasError = false;
  bool isLoading = true;
  String currentText = '';
  bool isProfileCompleteEnable = false;

  Future<void> intData() async {
    isLoading = true;
    update();
    await repo.sendAuthorizationRequest();
    isLoading = false;
    update();
    return;
  }

  bool submitLoading = false;
  verifyYourSms(String currentText) async {
    if (currentText.isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.otpFieldEmptyMsg.tr]);
      return;
    }

    submitLoading = true;
    update();

    ResponseModel responseModel =
        await repo.verify(currentText, isEmail: false);

    if (responseModel.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(
          jsonDecode(responseModel.responseJson));

      bool is2FAEnable = model.data?.user?.tv == "0" ? true : false;

      if (model.status == MyStrings.success) {
        CustomSnackBar.success(
            successList: model.message?.success ??
                ['${MyStrings.sms.tr} ${MyStrings.verificationSuccess.tr}']);

        if (is2FAEnable) {
          Get.offAndToNamed(RouteHelper.twoFactorScreen);
        } else {
          PushNotificationService(apiClient: Get.find()).sendUserToken();
          Get.offAndToNamed(RouteHelper.homeScreen);
        }
      } else {
        CustomSnackBar.error(
            errorList: model.message?.error ??
                ['${MyStrings.sms.tr} ${MyStrings.verificationFailed}']);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    submitLoading = false;
    update();
  }

  bool resendLoading = false;
  Future<void> sendCodeAgain() async {
    resendLoading = true;
    update();
    await repo.resendVerifyCode(isEmail: false);
    resendLoading = false;
    update();
  }
}
