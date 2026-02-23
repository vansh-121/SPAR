import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/controller/auth/auth/registration_controller.dart';
import 'package:hyip_lab/environment.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/image/my_image_widget.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_text_field.dart';
import 'package:hyip_lab/view/screens/auth/registration/widget/country_code_bottom_sheet.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key}) : super(key: key);

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegistrationController>(
      builder: (controller) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                labelText: MyStrings.firstName.tr,
                hintText: MyStrings.firstName.tr,
                controller: controller.fNameController,
                focusNode: controller.firstNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: controller.lastNameFocusNode,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourFirstName.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: 25),
              CustomTextField(
                labelText: MyStrings.lastName.tr,
                hintText: MyStrings.lastName.tr,
                controller: controller.lNameController,
                focusNode: controller.lastNameFocusNode,
                textInputType: TextInputType.text,
                nextFocus: controller.userNameFocusNode,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourLastName.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  return;
                },
              ),
              const SizedBox(height: 25),
              // Username field - hidden but still functional
              Visibility(
                visible: false,
                maintainState: true,
                child: CustomTextField(
                  labelText: MyStrings.username.tr,
                  hintText: MyStrings.enterUsername.tr,
                  controller: controller.userNameController,
                  focusNode: controller.userNameFocusNode,
                  textInputType: TextInputType.text,
                  nextFocus: controller.mobileFocusNode,
                  validator: (value) {
                    if (value != null && value.isEmpty) {
                      return MyStrings.enterUsername.tr;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.userNameController.text = value.toLowerCase();
                    controller.userNameController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: controller.userNameController.text.length));
                  },
                ),
              ),
              CustomTextField(
                labelText: (MyStrings.phoneNo).replaceAll('.', '').tr,
                hintText: MyStrings.enterYourPhoneNumber.tr,
                controller: controller.mobileController,
                focusNode: controller.mobileFocusNode,
                textInputType: TextInputType.phone,
                nextFocus: controller.emailFocusNode,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourPhoneNumber.tr;
                  }
                  if (value != null && value.isNotEmpty) {
                    final trimmed = value.replaceAll(RegExp(r'\s'), '');
                    final digitsOnly =
                        trimmed.replaceAll(RegExp(r'[^0-9]'), '');
                    if (digitsOnly.isEmpty) {
                      return MyStrings.enterValidPhoneNumber.tr;
                    }
                    if (digitsOnly.length != trimmed.length) {
                      return MyStrings.enterDigitsOnly.tr;
                    }
                  }
                  return null;
                },
                onChanged: (value) {
                  return;
                },
                prefixWidget: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 6),
                  child: controller.countryLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            RegistrationCountryBottomSheet.show(
                                context, controller);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  MyColor.getPrimaryColor().withOpacity(0.08),
                              borderRadius:
                                  BorderRadius.circular(Dimensions.space10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if ((controller.countryCode ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: MyImageWidget(
                                      imageUrl: UrlContainer
                                          .countryFlagImageLink
                                          .replaceAll(
                                        '{countryCode}',
                                        (controller.countryCode ??
                                                Environment.defaultCountryCode)
                                            .toLowerCase(),
                                      ),
                                      height: Dimensions.space20,
                                      width: 20,
                                    ),
                                  ),
                                Text(
                                  '+${controller.mobileCode ?? Environment.defaultPhoneCode}',
                                  style: interRegularDefault.copyWith(
                                    color: MyColor.getPrimaryColor(),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: MyColor.getPrimaryColor(),
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 25),
              CustomTextField(
                labelText: MyStrings.email.tr,
                hintText: MyStrings.enterYourEmail.tr,
                controller: controller.emailController,
                focusNode: controller.emailFocusNode,
                textInputType: TextInputType.emailAddress,
                inputAction: TextInputAction.next,
                validator: (value) {
                  if (value != null && value.isEmpty) {
                    return MyStrings.enterYourEmail.tr;
                  } else if (!MyStrings.emailValidatorRegExp
                      .hasMatch(value ?? '')) {
                    return MyStrings.invalidEmailMsg.tr;
                  } else {
                    return null;
                  }
                },
                onChanged: (value) {
                  // Auto-fill username from email
                  if (value.isNotEmpty) {
                    // Extract username part from email (before @)
                    String username = value.split('@').first.toLowerCase();
                    controller.userNameController.text = username;
                    controller.userNameController.selection =
                        TextSelection.fromPosition(TextPosition(
                            offset: controller.userNameController.text.length));
                  }
                  return;
                },
              ),
              const SizedBox(height: 25),
              Focus(
                  onFocusChange: (hasFocus) {
                    controller.changePasswordFocus(hasFocus);
                  },
                  child: CustomTextField(
                    isShowSuffixIcon: true,
                    isPassword: true,
                    labelText: MyStrings.password.tr,
                    controller: controller.passwordController,
                    focusNode: controller.passwordFocusNode,
                    nextFocus: controller.confirmPasswordFocusNode,
                    hintText: MyStrings.enterYourPassword_.tr,
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      if (controller.checkPasswordStrength) {
                        controller.updateValidationList(value);
                      }
                    },
                    validator: (value) {
                      return controller.validatePassword(value ?? '');
                    },
                  )),
              const SizedBox(height: 25),
              CustomTextField(
                labelText: MyStrings.confirmPassword.tr,
                hintText: MyStrings.confirmYourPassword.tr,
                controller: controller.cPasswordController,
                focusNode: controller.confirmPasswordFocusNode,
                inputAction: TextInputAction.done,
                isShowSuffixIcon: true,
                isPassword: true,
                onChanged: (value) {},
                validator: (value) {
                  if (controller.passwordController.text.toLowerCase() !=
                      controller.cPasswordController.text.toLowerCase()) {
                    return MyStrings.kMatchPassError.tr;
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 25),
              CustomTextField(
                labelText:
                    "${MyStrings.referralCode.tr} (${MyStrings.optional.tr})",
                hintText:
                    "${MyStrings.referralCode.tr} (${MyStrings.optional.tr})",
                controller: controller.referralCodeController,
                focusNode: controller.referralCodeFocusNode,
                inputAction: TextInputAction.done,
                onChanged: (value) {},
              ),
              const SizedBox(height: 25),
              Visibility(
                  visible: controller.needAgree,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                        height: 25,
                        child: Checkbox(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.defaultRadius)),
                          activeColor: MyColor.transparentColor,
                          checkColor: MyColor.getPrimaryColor(),
                          value: controller.agreeTC,
                          fillColor: const MaterialStatePropertyAll<Color>(
                              MyColor.transparentColor),
                          side: MaterialStateBorderSide.resolveWith(
                            (states) => BorderSide(
                                width: 1.0,
                                color: controller.agreeTC
                                    ? MyColor.getFieldEnableBorderColor()
                                    : MyColor.getFieldDisableBorderColor()),
                          ),
                          onChanged: (bool? value) {
                            controller.updateAgreeTC();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Row(
                        children: [
                          Text(MyStrings.iAgreeWith.tr,
                              style: interRegularDefault.copyWith(
                                  color: MyColor.getTextColor2())),
                          const SizedBox(width: 3),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteHelper.privacyScreen);
                            },
                            child: Text(MyStrings.policies.tr.toLowerCase(),
                                style: GoogleFonts.inter(
                                    color: MyColor.getPrimaryColor(),
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        MyColor.getPrimaryColor())),
                          ),
                          const SizedBox(width: 3),
                        ],
                      ),
                    ],
                  )),
              const SizedBox(height: 35),
              controller.submitLoading
                  ? const RoundedLoadingBtn()
                  : RoundedButton(
                      text: MyStrings.signUp.toUpperCase().tr,
                      textColor: MyColor.getButtonTextColor(),
                      color: MyColor.getButtonColor(),
                      press: () {
                        if (formKey.currentState!.validate()) {
                          controller.signUpUser();
                        }
                      }),
              const SizedBox(height: Dimensions.space35),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(MyStrings.alreadyAccount.tr,
                      style: interRegularLarge.copyWith(
                          color: MyColor.getTextColor2(),
                          fontWeight: FontWeight.w500)),
                  const SizedBox(width: Dimensions.space5),
                  TextButton(
                    onPressed: () {
                      controller.clearAllData();
                      Get.offAndToNamed(RouteHelper.loginScreen);
                    },
                    child: Text(MyStrings.signIn.tr,
                        style: interRegularLarge.copyWith(
                            color: MyColor.getPrimaryColor())),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
