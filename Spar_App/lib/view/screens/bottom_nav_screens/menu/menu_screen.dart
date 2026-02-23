import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/core/utils/util.dart';
import 'package:hyip_lab/data/controller/auth/login_controller.dart';
import 'package:hyip_lab/data/controller/common/theme_controller.dart';
import 'package:hyip_lab/data/controller/menu/menu_controller.dart' as menu;
import 'package:hyip_lab/data/repo/auth/general_setting_repo.dart';
import 'package:hyip_lab/data/repo/auth/login_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';
import 'package:hyip_lab/view/components/switch_button/custom_switch_button.dart';
import 'package:hyip_lab/view/components/text/default_text.dart';
import 'package:hyip_lab/view/components/text/header_text.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/menu/widget/delete_account_bottom_sheet.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/menu/widget/menu_row_widget.dart';
import 'package:hyip_lab/view/screens/transfer/balance_transfer/balance_transfer.dart';

import '../../../../data/controller/localization/localization_controller.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(GeneralSettingRepo(apiClient: Get.find()));
    final controller = Get.put(menu.MenuController(repo: Get.find()));
    ThemeController themeController = Get.put(ThemeController(sharedPreferences: Get.find()));
    Get.put(LocalizationController(sharedPreferences: Get.find()));
    MyUtils.allScreensUtils(themeController.darkTheme);
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    ThemeController themeController = Get.put(ThemeController(sharedPreferences: Get.find()));
    MyUtils.allScreensUtils(themeController.darkTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (theme) {
      return GetBuilder<LocalizationController>(builder: (localizationController) {
        return GetBuilder<menu.MenuController>(
          builder: (menuController) => SafeArea(
            child: Scaffold(
              backgroundColor: MyColor.getScreenBgColor(),
              appBar: CustomAppBar(title: MyStrings.menu.tr, isShowBackBtn: false, isShowActionBtn: false, bgColor: MyColor.getAppbarBgColor()),
              body: SingleChildScrollView(
                padding: Dimensions.screenPaddingHV,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(Dimensions.space15),
                      decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.space15),
                          MenuRowWidget(
                            isSvg: true,
                            image: MyImages.profileEdit,
                            label: MyStrings.account.tr,
                            onPressed: () => Get.toNamed(RouteHelper.userAccountScreen),
                          ),
                          const CustomDivider(space: Dimensions.space15),
                          MenuRowWidget(
                            isSvg: true,
                            image: MyImages.changePassword,
                            label: MyStrings.changePassword.tr,
                            onPressed: () => Get.toNamed(RouteHelper.changePasswordScreen),
                          ),

                          const CustomDivider(space: Dimensions.space15),
                          MenuRowWidget(
                            isSvg: true,
                            image: MyImages.twoFactorAuth,
                            label: MyStrings.twoFactorAuth.tr,
                            onPressed: () => Get.toNamed(RouteHelper.twoFactorSetupScreen),
                          ),

                          Visibility(
                            visible: menuController.balTransferEnable,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomDivider(space: Dimensions.space15),
                                MenuRowWidget(
                                  image: MyImages.transfer,
                                  isSvg: true,
                                  label: MyStrings.transfer.tr,
                                  onPressed: () {
                                    CustomBottomSheet(
                                      backgroundColor: MyColor.getCardBg(),
                                      voidCallback: () {},
                                      isNeedMargin: true,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          const BottomSheetBar(),
                                          const SizedBox(height: Dimensions.space15),
                                          HeaderText(text: MyStrings.balanceTransfer.tr, textAlign: TextAlign.center, textStyle: interRegularLarge),
                                          const SizedBox(height: Dimensions.space30),
                                          const BalanceTransfer(),
                                        ],
                                      )).customBottomSheet(context);
                                  },
                                ),
                              ],
                            )),
                        ],
                      ),
                    ),
                   Visibility(
                     visible: menuController.stackingInvestEnable || menuController.poolInvestEnable || menuController.scheduleInvestEnable || menuController.userRankEnable,
                     child: Column(
                     children: [
                       const SizedBox(height: Dimensions.space15),
                       Container(
                         width: MediaQuery.of(context).size.width,
                         padding: const EdgeInsets.all(Dimensions.space15),
                         decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Visibility(
                                 visible: menuController.stackingInvestEnable,
                                 child: Column(
                                   children: [
                                     MenuRowWidget(
                                       image: MyImages.userRank,
                                       isSvg: true,
                                       label: MyStrings.userRank.tr,
                                       onPressed: () => Get.toNamed(RouteHelper.userRankingScreen),
                                     ),
                                     const CustomDivider(space: Dimensions.space15),
                                   ],
                                 )
                             ),
                             Visibility(
                                 visible: menuController.stackingInvestEnable,
                                 child: Column(
                                   children: [
                                     MenuRowWidget(
                                       image: MyImages.myStacking,
                                       isSvg: true,
                                       label: MyStrings.myStacking.tr,
                                       onPressed: () => Get.toNamed(RouteHelper.mystakingScreen),
                                     ),
                                     const CustomDivider(space: Dimensions.space15),
                                   ],
                                 )
                             ),
                             Visibility(
                               visible: menuController.poolInvestEnable,
                               child: Column(
                                 children: [
                                   MenuRowWidget(
                                     image: MyImages.pool,
                                     isSvg: true,
                                     label: MyStrings.pool.tr,
                                     onPressed: () => Get.toNamed(RouteHelper.poolScreen),
                                   ),
                                   const CustomDivider(space: Dimensions.space15),
                                 ],
                               ),
                             ),
                             Visibility(
                               visible: menuController.scheduleInvestEnable,
                               child: Column(
                                 children: [
                                   MenuRowWidget(
                                     image: MyImages.schedule,
                                     isSvg: true,
                                     label: MyStrings.schedule.tr,
                                     onPressed: () => Get.toNamed(RouteHelper.sheduleScreen),
                                   ),
                                 ],
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   )),
                    const SizedBox(height: Dimensions.space15),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(Dimensions.space15),
                      decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MenuRowWidget(
                            image: MyImages.depositMenu,
                            isSvg: true,
                            label: MyStrings.deposit.tr,
                            onPressed: () => Get.toNamed(RouteHelper.depositScreen),
                          ),
                          const CustomDivider(space: Dimensions.space15),
                          MenuRowWidget(
                            image: MyImages.withdrawMenu,
                            isSvg: true,
                            label: MyStrings.withdraw.tr,
                            onPressed: () => Get.toNamed(RouteHelper.withdrawHistoryScreen),
                          ),
                          const CustomDivider(space: Dimensions.space15),
                          Visibility(
                              visible: menuController.langSwitchEnable,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MenuRowWidget(
                                    image: MyImages.language,
                                    isSvg: true,
                                    label: MyStrings.language.tr,
                                    onPressed: () {
                                      Get.toNamed(RouteHelper.languageScreen);
                                    },
                                  ),
                                  const CustomDivider(space: Dimensions.space15),
                                ],
                              )),

                          MenuRowWidget(
                            image: MyImages.support,
                            isSvg: true,
                            label: MyStrings.supportTicket.tr,
                            onPressed: () => Get.toNamed(RouteHelper.allTicketScreen),
                          ),

                          const CustomDivider(space: Dimensions.space15),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [SvgPicture.asset(MyImages.theme, color: MyColor.getSelectedIconColor(), height: 22, width: 22), const SizedBox(width: Dimensions.space15), DefaultText(text: MyStrings.theme.tr, textColor: MyColor.getTextColor())],
                              ),
                              CustomSwitch(
                                value: theme.darkTheme,
                                onChanged: (bool val) {
                                  theme.toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.space15),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(Dimensions.space15),
                      decoration: BoxDecoration(color: MyColor.getCardBg(), borderRadius: BorderRadius.circular(Dimensions.defaultRadius)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MenuRowWidget(
                            image: MyImages.terms,
                            isSvg: true,
                            label: MyStrings.terms.tr,
                            onPressed: () {
                              Get.toNamed(RouteHelper.privacyScreen);
                            },
                          ),
                          const CustomDivider(space: Dimensions.space15),
                          MenuRowWidget(
                            image: MyImages.faq,
                            isSvg: true,
                            label: MyStrings.faq.tr,
                            onPressed: () {
                              Get.toNamed(RouteHelper.faqScreen);
                            },
                          ),
                          Visibility(
                            visible: !menuController.isSocialSignIn,
                            child: Column(
                              children: [
                                const CustomDivider(space: Dimensions.space15),

                                MenuRowWidget(
                                  image: MyImages.delete,
                                  isSvg: true,
                                  label: MyStrings.deleteAccount.tr,
                                  onPressed: () {
                                   CustomBottomSheet(
                                     backgroundColor: MyColor.getScreenBgColor(),
                                     child: DeleteAccountBottomsheetBody(controller: menuController)
                                   ).customBottomSheet(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const CustomDivider(space: Dimensions.space15),
                          MenuRowWidget(
                            image: MyImages.logout,
                            isSvg: true,
                            label: MyStrings.signOut.tr,
                            onPressed: () {
                              Get.put(ApiClient(sharedPreferences: Get.find()));
                              Get.put(LoginRepo(apiClient: Get.find()));
                              final controller = Get.put(LoginController(loginRepo: Get.find()));

                              controller.loginRepo.apiClient.sharedPreferences.setBool(SharedPreferenceHelper.rememberMeKey, false);
                              controller.loginRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.accessTokenKey, "");

                              CustomSnackBar.showCustomSnackBar(errorList: [], msg: [MyStrings.logoutSuccessMsg], isError: false);
                              Get.offAllNamed(RouteHelper.loginScreen);
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
            ),
          ));
      });
    });
  }
}
