import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/account/profile_complete_controller.dart';
import 'package:hyip_lab/data/repo/account/profile_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_text_field.dart';
import 'package:hyip_lab/view/components/will_pop_widget.dart';
import 'package:hyip_lab/view/screens/auth/profile_complete/widget/country_bottom_sheet.dart';

import '../../../../core/utils/url.dart';
import '../../../../data/services/push_notification_service.dart';
import '../../../components/image/my_image_widget.dart';
import '../../../components/text-field/label_text_field.dart';


class ProfileCompleteScreen extends StatefulWidget {
  const ProfileCompleteScreen({Key? key}) : super(key: key);

  @override
  State<ProfileCompleteScreen> createState() => _ProfileCompleteScreenState();
}

class _ProfileCompleteScreenState extends State<ProfileCompleteScreen> {

  @override
  void initState() {

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find(), ));
    final controller = Get.put(ProfileCompleteController(profileRepo: Get.find()));
    Get.put(PushNotificationService(apiClient: Get.find()));

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.initData();
    });

    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }
  
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return WillPopWidget(
      nextRoute: '',
      child: SafeArea(
        child: Scaffold(
          backgroundColor: MyColor.getScreenBgColor(),
          appBar: CustomAppBar(
            title: MyStrings.profileComplete.tr,
            isShowBackBtn: true,
            fromAuth: false,
            isProfileCompleted: true,
            bgColor: MyColor.getAppbarBgColor(),
          ),
          body: GetBuilder<ProfileCompleteController>(
            builder: (controller) => SingleChildScrollView(
              padding: Dimensions.screenPaddingHV,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      labelText: MyStrings.username.tr,
                      hintText: MyStrings.enterUsername.tr,
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.userNameFocusNode,
                      controller: controller.userNameController,
                      nextFocus: controller.mobileNoFocusNode,
                      onChanged: (value){
                        controller.userNameController.text = value.toLowerCase();
                        controller.userNameController.selection = TextSelection.fromPosition(TextPosition(offset: controller.userNameController.text.length));
                      },
                      validator: (value){
                        if(value!=null && value.toString().isEmpty){
                          return MyStrings.enterUsername.tr;
                        } else{
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),

                    LabelTextField(
                      onChanged: (v) {},
                      needOutline: false,
                      hideLabel: true,
                      labelText: (MyStrings.phoneNo).replaceAll('.', '').tr,
                      hintText: MyStrings.enterYourPhoneNumber,
                      controller: controller.mobileNoController,
                      focusNode: controller.mobileNoFocusNode,
                      textInputType: TextInputType.phone,
                      inputAction: TextInputAction.next,
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(bottom: 14),
                        width: 100,
                        child: FittedBox(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  CountryBottomSheet.profileCompleteCountryBottomSheet(context, controller);
                                },
                                child: Container(
                                  padding: const EdgeInsetsDirectional.symmetric(horizontal: Dimensions.space12),
                                  decoration: BoxDecoration(
                                    color: MyColor.transparentColor,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      MyImageWidget(
                                        imageUrl: UrlContainer.countryFlagImageLink.replaceAll('{countryCode}', controller.countryCode.toString().toLowerCase()),
                                        height: Dimensions.space25,
                                        width: Dimensions.space40 + 2,
                                      ),
                                      const SizedBox(width: 6),
                                      Text("+${controller.mobileCode ?? ''}",style: interRegularLarge,),
                                      const SizedBox(width: 3),
                                      const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: MyColor.iconColor,
                                      ),
                                      Container(
                                        width: 2,
                                        height: Dimensions.space12,
                                        color: MyColor.borderColor,
                                      ),
                                      const SizedBox(width: 8)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.space25),


                    CustomTextField(
                      labelText: MyStrings.address,
                      hintText: "${MyStrings.enterYour.tr} ${MyStrings.address.toLowerCase().tr}",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.addressFocusNode,
                      controller: controller.addressController,
                      nextFocus: controller.stateFocusNode,
                      onChanged: (value){
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),

                    CustomTextField(
                      labelText: MyStrings.state,
                      hintText: "${MyStrings.enterYour.tr} ${MyStrings.state.toLowerCase().tr}",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.stateFocusNode,
                      controller: controller.stateController,
                      nextFocus: controller.cityFocusNode,
                      onChanged: (value){
                        return ;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),

                    CustomTextField(
                      labelText: MyStrings.city.tr,
                      hintText: "${MyStrings.enterYour.tr} ${MyStrings.city.toLowerCase().tr}",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.next,
                      focusNode: controller.cityFocusNode,
                      controller: controller.cityController,
                      nextFocus: controller.zipCodeFocusNode,
                      onChanged: (value){
                        return ;
                      },
                    ),
                    const SizedBox(height: Dimensions.space25),

                    CustomTextField(
                      labelText: MyStrings.zipCode.tr,
                      hintText: "${MyStrings.enterYour.tr} ${MyStrings.zipCode.toLowerCase().tr}",
                      textInputType: TextInputType.text,
                      inputAction: TextInputAction.done,
                      focusNode: controller.zipCodeFocusNode,
                      controller: controller.zipCodeController,
                      onChanged: (value){
                        return;
                      },
                    ),
                    const SizedBox(height: Dimensions.space35),

                    controller.submitLoading ? const RoundedLoadingBtn() : RoundedButton(
                      text: MyStrings.updateProfile.tr,
                      textColor: MyColor.getButtonTextColor(),
                      press: (){
                        if(formKey.currentState!.validate()){
                          controller.updateProfile();
                        }
                      },
                      color: MyColor.getButtonColor(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
