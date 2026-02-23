import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/auth/login/login_response_model.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/repo/auth/login_repo.dart';
import 'package:hyip_lab/view/components/dialog/delete_dialog.dart';
import 'package:hyip_lab/view/components/dialog/exit_dialog.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

import '../../model/user/user.dart';

class LoginController extends GetxController{


  LoginRepo loginRepo;

  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();



  List<String>errors=[];
  String? email;
  String? password;
  bool remember = false;

  LoginController({required this.loginRepo});


  void forgetPassword() {
    Get.toNamed(RouteHelper.forgetPasswordScreen);
  }

  bool isSubmitLoading = false;
  void loginUser() async {
    isSubmitLoading = true;
    update();

    ResponseModel model = await loginRepo.loginUser(emailController.text.toString(), passwordController.text.toString());

    if (model.statusCode == 200) {
      LoginResponseModel loginModel = LoginResponseModel.fromJson(jsonDecode(model.responseJson));
      if (loginModel.status.toString().toLowerCase() == MyStrings.success.toLowerCase()) {
        String accessToken = loginModel.data?.accessToken ?? "";
        String tokenType = loginModel.data?.tokenType ?? "";
        User? user = loginModel.data?.user;
        await RouteHelper.checkUserStatusAndGoToNextStep(user,accessToken: accessToken,tokenType: tokenType,isRemember: remember);
        if (remember) {
          changeRememberMe();
        }
      } else {
        CustomSnackBar.error(errorList: loginModel.message?.error ?? [MyStrings.loginFailedTryAgain]);
      }
    } else {
      CustomSnackBar.error(errorList: [model.message]);
    }

    isSubmitLoading = false;
    update();
  }

  changeRememberMe() {
    remember = !remember;
    update();
  }

  void clearTextField() {
    passwordController.text = '';
    emailController.text = '';
    if(remember){
      remember = false;
    }
    update();
  }

}
