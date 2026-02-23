class UrlContainer {
  static const String domainUrl = 'https://rise.nutribasket.in';
  // static const String domainUrl = 'https://url8.viserlab.com/api_test/hyiylab';
  static const String baseUrl = '$domainUrl/api/';

  static const String registrationEndPoint = 'register';
  static const String loginEndPoint = 'login';
  static const String userDashboardEndPoint = 'user/home';
  static const String userLogoutEndPoint = 'logout';
  static const String forgetPasswordEndPoint = 'password/email';
  static const String passwordVerifyEndPoint = 'password/verify-code';
  static const String resetPasswordEndPoint = 'password/reset';
  static const String referralEndPoint = "my-referrals";
  static const String verify2FAUrl = 'verify-g2fa';

  static const String verifyEmailEndPoint = 'verify-email';
  static const String verifySmsEndPoint = 'verify-mobile';
  static const String resendVerifyCodeEndPoint = 'resend-verify/';
  static const String authorizationCodeEndPoint = 'authorization';

  static const String dashBoardUrl = 'dashboard';
  static const String depositHistoryUrl = 'deposit/history';
  static const String depositMethodUrl = 'deposit/methods';
  static const String depositInsertUrl = 'deposit/insert';
  static const String depositRequestConfirm = 'manual/confirm';
  static const String transactionEndpoint = 'transactions';

  static const String rankingEndpoint = 'ranking';
  //withdraw
  static const String addWithdrawRequestUrl = 'withdraw-request';
  static const String withdrawMethodUrl = 'withdraw-method';
  static const String withdrawRequestConfirm = 'withdraw-request/confirm';
  static const String withdrawHistoryUrl = 'withdraw/history';

  static const String planEndPoint = "invest/plans";

  static const String twoFactor = "twofactor";
  static const String twoFactorEnable = "twofactor/enable";
  static const String twoFactorDisable = "twofactor/disable";

  //kyc
  static const String kycFormUrl = 'kyc-form';
  static const String kycSubmitUrl = 'kyc-submit';

  static const String generalSettingEndPoint = 'general-setting';
  static const String accountDelete = 'account-delete';

  //plan
  static const String investUrl = 'invest';
  static const String investStoreUrl = 'invest/store';
  static const String manageCapital = 'invest/manage-capital';

  //privacy policy
  static const String privacyPolicyEndPoint = 'policies';
  static const String faqEndPoint = 'faq';

  //profile
  static const String getProfileEndPoint = 'user-info';
  static const String updateProfileEndPoint = 'profile-setting';
  static const String profileCompleteEndPoint = 'user-data-submit';

  //change password
  static const String changePasswordEndPoint = 'change-password';
  static const String countryEndPoint = 'get-countries';

  static const String deviceTokenEndPoint = 'add-device-token';
  static const String languageUrl = 'language/';
  static const String balanceTransfer = 'balance-transfer';

  static const String pool = 'pool';
  static const String pools = 'pools';
  static const String poolPlan = 'pool/plans';
  static const String staking = 'staking';
  static const String save = 'save';

  //support ticket
  static const String communityGroupsEndPoint = 'community-groups';
  static const String supportMethodsEndPoint = 'support/method';
  static const String supportListEndPoint = 'ticket';
  static const String storeSupportEndPoint = 'ticket/create';
  static const String supportViewEndPoint = 'ticket/view';
  static const String supportReplyEndPoint = 'ticket/reply';
  static const String supportCloseEndPoint = 'ticket/close';
  static const String supportDownloadEndPoint = 'ticket/download';
  static const String supportImagePath = '$domainUrl/assets/support/';

  static const String socialLoginEndPoint = 'social-login';

  static const String metamaskGetMessageEndPoint =
      'web3/metamask-login/message';
  static const String metamaskMessageVerifyEndPoint =
      'web3/metamask-login/verify';

  static const String sheduleEndPoint = 'invest/schedules';
  static const String sheduleStatusEndPoint = 'invest/schedule/status';
  static const String countryFlagImageLink =
      'https://flagpedia.net/data/flags/h24/{countryCode}.webp';

  //portfolio analytics
  static const String portfolioAnalyticsEndPoint = 'portfolio/analytics';
}
