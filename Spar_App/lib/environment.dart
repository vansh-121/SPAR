class Environment {
/* ATTENTION Please update your desired data. */

  static const String appName = 'SPAR';
  static const String appSubTitle = 'Advanced investment mobile application';
  static const String version = '1.0.0';
  static const String appWebUrl = 'https://url8.viserlab.com/api_test/hyiylab';

  static String defaultLangCode = "en";
  static String defaultLanguageName = "English";

  static const bool DEV_MODE = false;

  static String defaultPhoneCode = "1"; //don't put + here
  static String defaultCountryCode = "US";
  static int otpTime = 60;
  List<String> mobileRechargeQuickAmount = [
    "10",
    "20",
    "30",
    "40",
    "50",
    "60",
    "100",
    "500"
  ]; // it's a static amount you can change its for yourself

  static const String walletConnectProjectID =
      '26278d601a2d2716fd4379c7a7666d98'; //Insert your wallet connect Project ID Here
  static const bool enableLoginWithMetamask = true;
}
