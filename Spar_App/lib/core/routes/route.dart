import 'package:get/get.dart';
import 'package:hyip_lab/view/screens/about/privacy_policy_screen.dart';
import 'package:hyip_lab/view/screens/account/change-password/change_password_screen.dart';
import 'package:hyip_lab/view/screens/account/profile/edit-profile/edit_profile_screen.dart';
import 'package:hyip_lab/view/screens/auth/forget_password/reset_password/reset_password_screen.dart';
import 'package:hyip_lab/view/screens/auth/forget_password/verify_forget_password/verify_forget_password_screen.dart';
import 'package:hyip_lab/view/screens/auth/kyc/kyc.dart';
import 'package:hyip_lab/view/screens/auth/profile_complete/profile_complete_screen.dart';
import 'package:hyip_lab/view/screens/auth/email_verification_page/email_verification_screen.dart';
import 'package:hyip_lab/view/screens/auth/forget_password/forget_password/forget_password.dart';
import 'package:hyip_lab/view/screens/auth/login/login_screen.dart';
import 'package:hyip_lab/view/screens/auth/registration/registration_screen.dart';
import 'package:hyip_lab/view/screens/auth/sms_verification_page/sms_verification_screen.dart';
import 'package:hyip_lab/view/screens/auth/two_factor_screen/two_factor_verification_screen.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/home/home_screen.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/menu/menu_screen.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/user_account/user_account_screen.dart';
import 'package:hyip_lab/view/screens/deposit/deposit-history/deposit_history_screen.dart';
import 'package:hyip_lab/view/screens/deposit/deposit_confirm/confirm_deposit_screen.dart';
import 'package:hyip_lab/view/screens/deposit/deposit_webview/deposit_payment_webview.dart';
import 'package:hyip_lab/view/screens/faq/faq_screen.dart';
import 'package:hyip_lab/view/screens/investment/investment_screen.dart';
import 'package:hyip_lab/view/screens/language/language_screen.dart';
import 'package:hyip_lab/view/screens/onboard/onboard_screen.dart';
import 'package:hyip_lab/view/screens/plan/payment_method_screen/payment_method_screen.dart';
import 'package:hyip_lab/view/screens/plan/plan_screen.dart';
import 'package:hyip_lab/view/screens/plan/plan_detail_screen.dart';
import 'package:hyip_lab/view/screens/plan/investment_invoice_screen.dart';
import 'package:hyip_lab/view/screens/pool/add_pool/add_pool_screen.dart';
import 'package:hyip_lab/view/screens/pool/my_pool/my_pool_screen.dart';
import 'package:hyip_lab/view/screens/pool/pool/pool_screen.dart';
import 'package:hyip_lab/view/screens/ranking/ranking_screen.dart';
import 'package:hyip_lab/view/screens/referral/referral_screen.dart';
import 'package:hyip_lab/view/screens/schedule/schedule_screen.dart';
import 'package:hyip_lab/view/screens/splash_screen/splash_screen.dart';
import 'package:hyip_lab/view/screens/staking/my_staking/my_staking_screen.dart';
import 'package:hyip_lab/view/screens/staking/staking/staking_screen.dart';
import 'package:hyip_lab/view/screens/transaction-history/transaction_history_screen.dart';
import 'package:hyip_lab/view/screens/withdraw/withdraw_log/withdraw_history.dart';
import 'package:hyip_lab/view/screens/withdraw/withdraw_money/confirm_withdraw_screen/confirm_withdraw_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/user/user.dart';
import '../../data/services/push_notification_service.dart';
import '../../view/components/preview_image.dart';
import '../../view/screens/ticket/all_ticket_screen/all_ticket_screen.dart';
import '../../view/screens/ticket/new_ticket_screen/new_ticket_screen.dart';
import '../../view/screens/ticket/ticket_details_screen/ticket_details_screen.dart';
import '../../view/screens/two_factor_screen/two_factor_setup_screen.dart';
import '../helper/shared_preference_helper.dart';

class RouteHelper {
  static const String onboardScreen = '/onboard_screen';

  static const String splashScreen = '/splash_screen';
  static const String loginScreen = '/login_screen';
  static const String registrationScreen = '/registration_screen';
  static const String emailVerificationScreen = '/verify_email_screen';
  static const String smsVerificationScreen = '/verify_sms_screen';
  static const String forgetPasswordScreen = '/forget_password_screen';
  static const String verifyPassCodeScreen = '/verify_pass_code_screen';
  static const String resetPasswordScreen = '/reset_pass_screen';
  static const String homeScreen = '/home_screen';
  static const String profileCompleteScreen = '/profile_complete_screen';
  static const String depositScreen = '/deposit_screen';
  static const String investmentScreen = '/investment_screen';
  static const String confirmWithdrawRequest = '/confirm_withdraw_screen';
  static const String confirmDepositRequest = '/confirm_deposit_screen';
  static const String withdrawHistoryScreen = '/withdraw_history_screen';
  static const String privacyScreen = '/privacy_screen';
  static const String depositWebViewScreen = '/deposit_webView';
  static const String changePasswordScreen = '/change_password';
  static const String transactionHistoryScreen = '/transaction_log';
  static const String kycScreen = '/kyc_screen';
  static const String menuScreen = '/menu_screen';
  static const String planScreen = '/plan_screen';
  static const String referralScreen = "/referral_screen";
  static const String userAccountScreen = "/user_account_screen";
  static const String editProfileScreen = "/edit_profile_screen";
  static const String faqScreen = "/faq_screen";
  static const String notificationScreen = "/notification_screen";

  static const String paymentMethodScreen = "/payment-method-screen";
  static const String planDetailScreen = "/plan-detail-screen";
  static const String investmentInvoiceScreen = "/investment-invoice-screen";
  static const String twoFactorScreen = "/two-factor-screen";
  static const String languageScreen = "/language_screen";

  static const String stakingScreen = "/staking_screen";
  static const String mystakingScreen = "/mystaking_screen";
  static const String userRankingScreen = "/user-ranking-screen";

  static const String poolScreen = "/pool_screen";
  static const String addpoolScreen = "/add_pool_screen";
  static const String poolhistoryScreen = "/pool_history_screen";

  static const String sheduleScreen = "/shedule_screen";
  static const String twoFactorSetupScreen = "/two-factor-setup-screen";

  //support ticket
  static const String supportTicketMethodsList = '/all_ticket_methods';
  static const String allTicketScreen = '/all_ticket_screen';
  static const String ticketDetailsScreen = '/ticket_details_screen';
  static const String newTicketScreen = '/new_ticket_screen';
  static const String previewImageScreen = "/preview-image-screen";

  static List<GetPage> routes = [
    GetPage(name: onboardScreen, page: () => const OnBoardingScreen()),

    GetPage(name: splashScreen, page: () => const SplashScreen()),
    GetPage(name: loginScreen, page: () => const LoginScreen()),
    GetPage(name: registrationScreen, page: () => const RegistrationScreen()),
    GetPage(
        name: emailVerificationScreen,
        page: () => const EmailVerificationScreen()),
    GetPage(
        name: smsVerificationScreen, page: () => const SmsVerificationScreen()),

    //forget password
    GetPage(
        name: forgetPasswordScreen, page: () => const ForgetPasswordScreen()),
    GetPage(
        name: verifyPassCodeScreen, page: () => const VerifyForgetPassScreen()),
    GetPage(name: resetPasswordScreen, page: () => const ResetPasswordScreen()),
    GetPage(name: homeScreen, page: () => const HomeScreen()),
    GetPage(name: depositScreen, page: () => const DepositHistoryScreen()),
    GetPage(
        name: depositWebViewScreen,
        page: () => WebViewExample(redirectUrl: Get.arguments)),
    GetPage(
        name: confirmDepositRequest,
        page: () => ConfirmDepositScreen(model: Get.arguments[0])),

    //withdraw
    GetPage(
        name: confirmWithdrawRequest,
        page: () => ConfirmWithdrawScreen(model: Get.arguments[0])),
    GetPage(
        name: withdrawHistoryScreen, page: () => const WithdrawHistoryScreen()),

    GetPage(
        name: changePasswordScreen, page: () => const ChangePasswordScreen()),
    GetPage(
        name: profileCompleteScreen, page: () => const ProfileCompleteScreen()),
    GetPage(
        name: transactionHistoryScreen,
        page: () => const TransactionHistoryScreen()),
    GetPage(name: privacyScreen, page: () => const PrivacyScreen()),
    GetPage(name: menuScreen, page: () => const MenuScreen()),
    GetPage(name: investmentScreen, page: () => const InvestmentScreen()),
    GetPage(name: planScreen, page: () => const PlanScreen()),
    GetPage(name: planDetailScreen, page: () => const PlanDetailScreen()),
    GetPage(
        name: investmentInvoiceScreen,
        page: () => const InvestmentInvoiceScreen()),
    GetPage(name: referralScreen, page: () => const ReferralScreen()),
    GetPage(name: userAccountScreen, page: () => const UserAccountScreen()),
    GetPage(name: editProfileScreen, page: () => const EditProfileScreen()),
    GetPage(name: faqScreen, page: () => const FaqScreen()),
    GetPage(name: kycScreen, page: () => const KycScreen()),
    //
    GetPage(name: stakingScreen, page: () => const StakingScreen()),
    GetPage(name: mystakingScreen, page: () => const MystakingScreen()),

    GetPage(name: poolScreen, page: () => const PoolScreen()),
    GetPage(name: addpoolScreen, page: () => const AddPoolScreen()),
    GetPage(name: poolhistoryScreen, page: () => const MyPoolHistroyScreen()),

    GetPage(name: sheduleScreen, page: () => const ScheduleScreen()),
    GetPage(name: userRankingScreen, page: () => const RankingScreen()),

    GetPage(name: paymentMethodScreen, page: () => const PaymentMethodScreen()),
    GetPage(
        name: twoFactorScreen, page: () => const TwoFactorVerificationScreen()),
    GetPage(
        name: twoFactorSetupScreen, page: () => const TwoFactorSetupScreen()),
    GetPage(name: languageScreen, page: () => const LanguageScreen()),

    //support ticket
    GetPage(name: allTicketScreen, page: () => const AllTicketScreen()),
    GetPage(name: ticketDetailsScreen, page: () => const TicketDetailsScreen()),
    GetPage(name: newTicketScreen, page: () => const NewTicketScreen()),
    GetPage(
        name: previewImageScreen, page: () => PreviewImage(url: Get.arguments)),
  ];

  static Future<void> checkUserStatusAndGoToNextStep(User? user,
      {bool isRemember = false,
      String accessToken = "",
      String tokenType = ""}) async {
    bool needEmailVerification = user?.ev == "1" ? false : true;
    bool needSmsVerification = user?.sv == '1' ? false : true;
    bool isTwoFactorEnable = user?.tv == '1' ? false : true;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (isRemember) {
      await sharedPreferences.setBool(
          SharedPreferenceHelper.rememberMeKey, true);
    } else {
      await sharedPreferences.setBool(
          SharedPreferenceHelper.rememberMeKey, false);
    }

    await sharedPreferences.setString(
        SharedPreferenceHelper.userIdKey, user?.id.toString() ?? '-1');
    await sharedPreferences.setString(
        SharedPreferenceHelper.userEmailKey, user?.email ?? '');
    await sharedPreferences.setString(
        SharedPreferenceHelper.userPhoneNumberKey, user?.mobile ?? '');
    await sharedPreferences.setString(
        SharedPreferenceHelper.userNameKey, user?.username ?? '');

    if (accessToken.isNotEmpty) {
      await sharedPreferences.setString(
          SharedPreferenceHelper.accessTokenKey, accessToken);
      await sharedPreferences.setString(
          SharedPreferenceHelper.accessTokenType, tokenType);
    }

    bool isProfileCompleteEnable = user?.profileComplete == '0' ? true : false;

    if (isProfileCompleteEnable) {
      Get.offAndToNamed(RouteHelper.profileCompleteScreen);
    } else if (needEmailVerification) {
      Get.offAndToNamed(RouteHelper.emailVerificationScreen);
    } else if (needSmsVerification) {
      Get.offAndToNamed(RouteHelper.smsVerificationScreen);
    } else if (isTwoFactorEnable) {
      Get.offAndToNamed(RouteHelper.twoFactorScreen);
    } else {
      PushNotificationService(apiClient: Get.find()).sendUserToken();
      Get.offAndToNamed(RouteHelper.homeScreen, arguments: [true]);
    }
  }
}
