import 'package:hyip_lab/data/model/language/language_model.dart';

class MyStrings {
  //app name
  static const String appName = "SPAR";

  static List<String> onboardTitleList = [
    'CLARITY Through Real-Time Intelligence',
    'Manage Your Portfolio with Precision',
    ' Grow Your Wealth with Purpose-Built Products',
  ];

  //onboard text
  static List<String> onboardSubTitleList = [
    'Stay ahead with live market insights, continuous performance tracking, and transparent data flows. SPAR transforms raw financial information into clear, actionable intelligence so you always know where you stand.',
    'Monitor allocations, assess risk exposure, and optimize your holdings using institution-grade financial frameworks. SPAR equips you with engineering-driven tools to manage your portfolio efficiently and strategically.',
    'Unlock access to H&S investment solutions designed to match your goals, risk tolerance, and financial horizon. With SPAR, your capital grows through products engineered for stability, performance, and long-term value creation.',
  ];

  static const String skip = "Skip";
  static const String rank = "Rank";
  static const String userRanking = "User Ranking";
  static const String selectALanguage = 'Select Language';
  static const String investmentLimitMsg = "Please check investment limit";
  static const String confirmToInvestOn = "Confirm to invest on";
  static const String invest = 'Invest';
  static const String interestRange = 'Interest Range';
  static const String investTill = 'Invest Till';
  static const String returnDate = 'Return Date';
  static const String interest = 'Interest';
  static const String phone = 'Phone';
  static const String typeYourPassword = 'Type your password';
  static const String deleteYourAccount = 'Delete your Account';
  static const String nextWorkingDay = 'Next Working Day';
  static const String workingDayMessage =
      'Withdrawal request is disable for today. Please wait for next working day.';
  static const String deleteBottomSheetSubtitle =
      'You will lose all of your data by deleting your account. This action cannot be undone.';

  static const String bonus = "Bonus";
  static const String selectMaxFiveItems = "Please select maximum 5 items";
  static const String myInvest = "MyInvest";
  static const String minimumInvest = "Minimum Investment";
  static const String toUnlock = "To unlock";
  static const String teamInvest = "Team Invest";
  static const String commissionEarned = "Commission Earned";
  static const String teamInvestment = "Team Investment";
  static const String directReferral = "Direct Referral";
  static const String referralInvest = "Referral Invest";
  static const String loading = "Loading...";

  static const String kyc = 'KYC';

  static const String isRequired = 'is required';

  // Agreement Verification
  static const String agreementRequired = 'Agreement Required';
  static const String agreementVerificationPending =
      'Agreement Verification Pending';
  static const String agreementAcceptanceRequired =
      'Agreement Acceptance Required';
  static const String agreementPopupTitle = 'Agreement Required';
  static const String agreementPopupMessage =
      'Congratulations! Your KYC has been approved.\n\n'
      'Before you can access investment and withdrawal services, please review the agreement details that have been sent to your registered email address.\n\n'
      'Once you have reviewed the agreement, please contact our support team or reply to the email to confirm your acceptance.\n\n'
      'Your account will be fully activated once we receive your confirmation.';
  static const String agreementBannerMessage =
      '⚠️ Action Required - Agreement details sent to your email. Please review and confirm to unlock all features.';
  static const String agreementFeatureLockMessage =
      'Agreement Acceptance Required\n\n'
      'Your KYC verification is approved! However, you need to accept our user agreement to access this feature.\n\n'
      'Agreement details have been sent to your email.\n\n'
      'Please check your email and contact support to confirm your acceptance.';
  static const String agreementStatusPending = 'Agreement: Pending';
  static const String agreementStatusVerified = 'Agreement: Accepted';
  static const String checkEmail = 'Check Email';
  static const String contactSupport = 'Contact Support';
  static const String agreementNeededShort =
      'Please accept agreement to proceed';

  static const String gogoleAuthenticatorCode = 'Google Authenticator Code';
  static const String twoFactorAuth = 'Two Factor Authentication';
  static const String twoFactorMsg =
      'Enter 6-digit code from your two factor authenticator APP.';
  // staking
  static const String myStacking = "My Stacking";
  static const String userRank = "User Rank";
  static const String stacking = "Staking";

  static const String manageInvestCapital = "Manage Invest Capital";
  static const String reInvest = "Reinvest";
  static const String capitalBackType = "Capital Back";
  static const String investmentCapital = "Investment Capital";
  //pool
  static const String pool = "Pool";
  static const String poolHistory = "Pool History";

  //exit dialog
  static const String exitTitle = "Do you want to exit\n the app?";
  static const String accountDeleteTitle =
      "Are you sure you want to delete you account?";
  static const String accountDeletedSuccessfully =
      "Account deleted successfully";
  static const String no = "No";
  static const String yes = "Yes";

  static const String hasUpperLetter = "Has uppercase letter";
  static const String hasLowerLetter = "Has lowercase letter";
  static const String hasDigit = "Has digit";
  static const String hasSpecialChar = "Has special character";
  static const String minSixChar = "Min of 6 characters";

  static const String scheduleInvestText =
      "You can set your investment as a scheduler or invest instant.";
  static const String scheduleForText = "Set how many times you want to invest";
  static const String afterText =
      "Set a frequency at which you prefer to make investments.";

  static const String payable = 'Payable';
  static const String receivable = 'Receivable';
  static const String conversionRate = 'Conversion Rate';
  static const String in_ = 'In';

  static const String chargeMsg2 = "will cut from your selected wallet";
  static const String selectWallet = 'Select Wallet';
  static const String payVia = 'Pay Via';
  static const String usernameEmptyMsg = "Username can't be empty";

  static const String approved = "Approved";
  static const String succeed = "Succeed";
  static const String pending = "Pending";
  static const String rejected = "Rejected";
  static const String initiated = 'Initiated';

  static const String days = 'days';
  static const String hrs = 'hrs';
  static const String mins = 'mins';
  static const String secs = 'secs';

  /// login
  static const String account = "Account";
  static const String welcomeBack = "Welcome Back";
  static const String recoverAccount = "Recover Account";
  static const String subTittle =
      "to your personalized interface for structured portfolio intelligence";
  static const String usernameOrEmail = "Username or Email";
  static const String usernameOrEmailHint = "Enter your username or email";
  static const String password = "Password";
  static const String passwordHint = "Enter your password";
  static const String rememberMe = "Remember Me";
  static const String forgotPassword = "Forgot Password?";
  static const String signIn = "Sign In";
  static const String notRegistered = "Not registered yet?";
  static const String noAccount = "Don't have an account?";
  static const String createAccount = "Create an account";
  static const String fieldErrorMsg = "Please fill out this field";
  static const String resetPassContent =
      "To secure your account please provide a secure password";

  /// forget password
  static const String forgetPasswordSubText =
      "Enter your email or username below to receive a password reset verification code";
  static const String verifyPasswordSubText =
      "A 6 digits verification code sent to your email address";
  static const String viewHistory = "View History";

  /// registration
  static const String createAnAccount = "Engineer Your Financial Future";
  static const String username = "Username";
  static const String confirmPassword = "Confirm Password";
  static const String email = "Email";
  static const String country = "Country";
  static const String phoneNo = "Phone No.";
  static const String alreadyAccount = "Already have an account?";
  static const String signUp = "Sign Up";
  static const String passwordResetEmailSentTo = 'Password reset email sent to';
  static const String passwordEmptyMsg = "Please enter your password";
  static const String enterYourLastName = "Enter your lastname";
  static const String enterYourFirstName = "Enter your firstname";
  static const String agreePolicyMessage =
      "You must agree with our privacy & policies";
  static const String enterValidPhoneNumber = "Enter a valid phone number";
  static const String enterDigitsOnly = "Only digits are allowed";

  /// email verify
  static const String emailVerification = "Email Verification";
  static const String viaEmailVerify =
      "We've sent you an access code via email for email verification";
  static const String verify = "Verify";
  static const String didNotReceiveCode = "Didn't Receive Code?";
  static const String resend = "Resend";

  /// sms verify
  static const String smsVerification = "Sms Verification";

  /// profile complete
  static const String profileComplete = "Profile Complete";
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String address = "Address";
  static const String state = "State";
  static const String city = "City";
  static const String zipCode = "Zip Code";
  static const String updateProfile = "Update Profile";
  static const String enterYour = "Enter your";
  static const String enter = "Enter";
  static const String searchCountry = "Search Country";

  /// home
  static const String paymentCaptureMsg = "Payment captured successfully";
  static const String interestWalletBalance = "Realized Return";
  static const String totalInvest = "Total Invested";
  static const String totalDeposit = "Total Deposit";
  static const String totalWithdraw = "Total Withdraw";
  static const String referralEarnings = "Referral Earnings";
  static const String withdrawalPending = "Withdrawal Pending";
  static const String unrealizedReturns = "Unrealized Return";
  static const String deposit = "Deposit";
  static const String withdraw = "Withdraw";
  static const String transfer = "Transfer";
  static const String investment = "Investment";
  static const String referral = "Referral";
  static const String transactions = "Transactions";
  static const String history = "History";
  static const String plan = "Plan";
  static const String activePlan = "Active Investment";
  static const String viewAll = "View All";
  static const String all = "All";
  static const String plus = "Plus";
  static const String minus = "Minus";
  static const String invested = "Invested";
  static const String nextReturn = "Next Return";
  static const String remainingTimes = "Remaining Times";
  static const String totalReturn = "Total Return";
  static const String every = "every";

  /// deposit
  static const String depositMoney = "Deposit Money";
  static const String submit = "Submit";
  static const String depositHistory = 'Plan History';

  /// withdraw
  static const String withdrawMoney = "Withdraw Money";
  static const String withdrawHistory = 'Withdraw History';

  /// transaction
  static const String pauseInvestMsg =
      'Are you sure to pause this schedule invest?';
  static const String continueInvestMsg =
      'Are you sure to continue this schedule invest?';
  static const String transaction = 'Transactions';
  static const String transactionHistory = 'Transaction History';
  static const String trx = 'TRX';
  static const String date = 'Date';
  static const String investDate = 'Invest Date';
  static const String capitalBack = 'capital will be back';
  static const String amount = 'Amount';
  static const String postBalance = 'Post Balance';
  static const String details = 'Details';
  static const String and = '&';
  static const String any = 'Any';

  /// transfer
  static const String balanceTransfer = "Balance Transfer";

  /// investment
  static const String completePlan = "Completed Investment";

  /// referral
  static const String referralLink = "Referral Link";

  /// plan
  static const String total = "Total";
  static const String maxEarn = "Max Earn";
  static const String investNow = "INVEST NOW";
  static const String investNow_ = "Invest Now";
  static const String everyWeek = "Every week for";
  static const String week = "week";
  static const String investmentPlan = "Investment Plan";
  static const String copyLink = "Copied Referral Link";
  static const String walletType = "Wallet Type";
  static const String wallet = "Wallet";
  static const String type = "Type";
  static const String remark = "Remark";

  static const String withdrawVia = "Withdraw Via";
  static const String depositVia = "Deposit Via";
  static const String depositInstruction = "Payment Instructions";
  static const String profile = "Profile";

  static const String editProfile = "Edit Profile";
  static const String theme = "Theme";
  static const String setting = "Settings";
  static const String helpAndSetting = "Help & Settings";
  static const String language = "Language";
  static const String help = "Help";
  static const String faq = "FAQ";
  static const String terms = "Terms & Conditions";
  static const String signOut = "Sign Out";
  static const String deleteAccount = "Delete Account";
  static const String light = "Light";
  static const String lifeTime = "Lifetime";
  static const String dark = "Dark";
  static const String selectGateway = "Select Gateway";
  static const String conversion = "Conversion";
  static const String transactionNo = "Transaction No.";

  /// privacy-policy screen title
  static const String ourPrivacyPolicy = "Our Privacy Policy";
  static const String howLongWeRetain = "How Long We Retain";
  static const String yourData = "What we don't do with your data";
  static const String protectionActCompliance = "Protection Act Compliance";
  static const String refundPolicy = "Payment/Refund Policy";
  static const String paymentPolicy = "Payment Policy";

  static const String weHaveSent = "We've sent a verification code to";
  static const String resetLabelText =
      "Your account is verified successfully. Now you can change your password.";

  static const String toRecover =
      "To recover your account please provide your email or username to find your account";
  static const String yourEmailAddress = "your email address";
  static const String resetYourPassword = "Reset Your Password";
  static const String forgetPassword = "Forget Password";
  static const String for_ = "for";
  static const String capital = "Capital";
  static const String doNotHaveAccount = "Don't have an account?";
  static const String enterEmailOrUserName = 'Enter username or email';
  static const String policies = 'Policies';
  static const String verificationFailed = 'Verification Failed';
  static const String emailVerificationFailed = 'Email Verification Failed';
  static const String emailVerificationSuccess = 'Email Verification Success';

  static const String login = 'Login';
  static const String registration = 'Registration';
  static const String enterYourPassword_ = 'Enter your password';

  //menu
  static const String kycVerification = 'KYC Verification';
  static const String notification = 'Notifications';

  //kyc
  static const String kycData = 'KYC Data';
  static const String noDataFound = 'No Data Found';
  static const String noActiveInvestmentFound = 'No active investment found';
  static const String chooseOption = 'Choose option';
  static const String chooseFile = 'Choose File';
  static const String gallery = "Gallery";
  static const String camera = "Camera";
  static const String completeYourKyc = 'Complete your KYC';
  static const String kycUnderReviewMsg = 'Your KYC is under review';
  static const String kycAlreadyVerifiedMsg = 'You are already verified';

  static const String gateway = 'Gateway';
  static const String paymentMethod = 'Payment Method';
  static const String iAgreeWith = "I agree with the";

  //profile complete
  static const String emailAddress = 'E-mail Address';

  /// change password
  static const String currentPassword = 'Current Password';
  static const String createNewPassword = "Create new password";

  static const String createPasswordSubText =
      "Please provide a strong password to protect your account";
  static const String newPassword = 'New password';
  static const String enterCurrentPassword = 'Enter current password';
  static const String enterNewPassword = 'Enter new password';
  static const String enterConfirmPassword = 'Enter confirm password';

  //withdraw
  static const String changePassword = "Change Password";
  static const String addWithdraw = "Add Withdraw";
  static const String enterAmount = "Enter Amount";
  //static const String investAmount = "Invest Amount";
  static const String hint = "0.0";
  static const String withdrawMethod = "Withdraw Method";
  static const String searchByTrxId = "Search by trx id";
  static const String noTrxFound = "No Transaction Found";
  static const String status = "Status";
  static const String trxId = "Trx Id";
  static const String complete = "Completed";
  static const String cancel = "Cancel";
  static const String time = "Time";
  static const String times = "Times";

  static const String bankName = "Bank Name";
  static const String accountName = "Account Name";
  static const String accountNumber = "Account Number";
  static const String routingNumber = "Routing Number";
  static const String payNow = "PAY NOW";

  //deposit
  static const String noDepositFound = "No Deposit Found";
  static const String noWithdrawFound = "No Withdraw Found";

  static const String otpVerification = "OTP Verification";

  static const String showMore = "Show More";
  static const String more = "More";
  static const String success = 'success';
  static const String version = 'version';

  //
  static const String logoutSuccessMsg = 'Sign Out Successfully';

  static RegExp emailValidatorRegExp =
      RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  static const String invalidEmailMsg = "Enter valid email";
  static const String enterCurrentPass = "Enter your current password";
  static const String enterNewPass = "Enter your new password";
  static const String invalidPassMsg =
      "Password must be contain 1 special character and number";
  static const String kMatchPassError = "Password doesn't match";
  static const String kFirstNameNullError = "Enter first name";
  static const String kLastNameNullError = "Enter last name";
  static const String kShortUserNameError = "Username must be 6 character";
  static const String phoneNumber = "Phone Number";
  static const String passVerification = 'Password Verification';

  static const String successfullyCodeResend = 'Resend the code successfully';
  static const String resendCodeFail = 'Failed to resend code';
  static const String somethingWentWrong = 'Something went wrong';
  static const String noRedirectUrlFound = 'No redirect url found';
  static const String invalidAmount = 'Invalid amount';
  static const String searchResult = 'Search Result';
  static const String resetPassword = 'Reset Password';
  static const String resetPassMsg =
      "Enter your email or username below to receive a password reset verification code";

  static const String verificationSuccess = 'Verification Success';
  static const String enterYourUsername = 'Enter your username';
  static const String enterUsername = 'Enter username';
  static const String enterYourEmail = 'Enter your email';
  static const String enterYourPhoneNumber = "Enter your phone number";
  static const String confirmYourPassword = 'Confirm your password';

  static const String compoundInterestAvailable = 'Compound interest available';
  static const String holdCapitalReinvest = 'Hold capital & reinvest';

  static const String registerMsg =
      "Create your account to unlock intelligent asset models, automated performance tracking, and a fully engineered approach to personal finance.";
  static const String noCodeReceive = "Didn't receive the code?";
  static const String smsVerificationMsg =
      "We've sent you an access code to your phone number for SMS verification";

  //login
  static const String wellComeBack = 'Wellcome back';
  static const String loginMsg =
      'Log in with the data that you entered during your registration';
  static const String register = 'Register';
  static const String selectACountry = "Select a country";
  static const String requestFail = "Request Failed";
  static const String requestSuccess = "Request Success";
  static const String loginFailedTryAgain = 'Login failed,please try again';

  static const String selectOne = "Select One";
  static const String sms = 'SMS';

  //no internet
  static const String noInternet = 'No internet connection';
  static const String retry = "Retry";
  static const String return_ = 'Return';

  static const String otpFieldEmptyMsg = "Otp field can't be empty";
  static const String goBackLogMsg =
      'Sorry something went wrong here, go back and retry after sometimes';

  static const String secondAgo = 'second ago';
  static const String minutesAgo = 'minutes ago';
  static const String hourAgo = 'hour ago';
  static const String daysAgo = 'days ago';
  static const String justNow = 'just now';

  static const String level = "Level";
  static const String logout = "logout";
  static const String menu = "Menu";
  static const String home = "Home";

  static const String writeSomething = "Write something...";
  static const String badResponseMsg = 'Bad Response Format!';
  static const String serverError = 'Server Error';
  static const String unAuthorized = 'Unauthorized';
  static const String yourEmail = 'your email';
  static const String passResetMailSendTo = "Password reset email sent to ";
  static const String passwordChanged = "Password change successfully";
  static const String charge = "Charge";
  static const String depositLimit = "Deposit Limit";
  static const String limit = "Limit";

  //transfer
  static const String selectDuration = "Select Duration";
  static const String selectAWallet = "Select a wallet";
  static const String please = "Please";
  static const String depositWallet = "";
  static const String interestWallet = "Interest Wallet";

  //TODO : Add all other strings

  static const String error = 'Error';
  static const String trxType = 'Trx Type';
  //
  static const String investAmount = "Investment Amount";
  static const String investedAmount = "Invested Amount";
  static const String endAt = "End AT";
  static const String duration = "Duration";
  static const String stackingSuccessMsg =
      "Staking investment added successfully";
  static const String totalamount = "Total amount";

  static const String schedule = "Schedule";
  static const String scheduleTimes = "Schedule Times";
  static const String planDetails = "Plan Details";
  static const String addMoney = "Add money";
  static const String topupWindowInfo =
      "Top-up is enabled 1 day before to 1 day after the scheduled date";
  static const String remainingScheduleTimes = "Remaining Schedule Times";

  static const String planName = "Plan Name";

  static const String interval = "Interval";

  static const String hours = "Hours";

  static const String nextInvest = "Next Invest";

  static const String autoSheduleInvest = " Auto Schedule Invest";

  static const String compoundInterest = "Compound Interest";

  static const String scheduleFor = "Schedule For";

  static const String after = "After";
  static const String confirm = "Confirm";

  static const String investTime = "Invested Time";
  static const String selectInvestTime = "Select Invested Time";

  //2fa
  static const String setupKey = "Setup Key";
  static const String copiedToClipBoard = "Copied to your clipboard!";
  static const String download = "Download";
  static const String useQRCODETips2 =
      "Google Authenticator is a multifactor app for mobile devices. It generates timed codes used during the 2-step verification process. To use Google Authenticator, install the Google Authenticator application on your mobile device.";
  static const String disable2Fa = "Disable 2FA Security";
  static const String useQRCODETips =
      "Use the QR code or setup key on your Google Authenticator app to add your account.";
  static const String twoFaIconMsg = "Manage your 2FA security";
  static const String addYourAccount = "Add Your Account";
  static const String enable2Fa = "Enable 2FA Security";

  static const String areYourSure = "Are you sure";
  static const String youWantToExitTheApp = "You want to exit the app?";

  //support ticket
  static const String subjectRequired = 'Subject is required';
  static const String noFileChosen = 'No file chosen';
  static const String high = 'High';
  static const String medium = 'Medium';
  static const String low = 'Low';
  static const String enterYourMessage = 'Enter your message';
  static const String messageRequired = 'Message is required';
  static const String ticketCreateSuccessfully = 'Ticket created successfully';
  static const String replyTicketEmptyMsg = "Reply ticket can't be empty";
  static const String cancelTicketMessage =
      'Are you sure you want to close the ticket';
  static const String repliedSuccessfully = "Replied successfully";
  static const String permissionDenied = "Permission denied";
  static const String downloadDirNotFound = "Download directory not found";
  static const String noDocOpenerApp = "No doc openner apps";
  static const String fileNotFound = 'file Not Found';
  static const String noSupportTicketToShow =
      'Sorry! there are no ticket to show';
  static const String supportTicket = 'Support Ticket';
  static const String noSupportTicket = 'No support ticket found';
  static const String answered = 'Answered';
  static const String open = 'Open';
  static const String replied = 'Replied';
  static const String closed = 'Closed';
  static const String close = 'Close';
  static const String ticket = 'Ticket';
  static const String addNewTicket = 'Create Ticket';
  static const String enterYourSubject = 'Enter your subject';
  static const String priority = 'Priority';
  static const String subject = 'Subject';
  static const String message = 'Message';
  static const String chooseAFile = "Choose a file";
  static const String supportedFileType = "Supported File Type:";
  static const String ext = ".jpg, .jpeg, .png, .pdf, .doc, .docx";
  static const String upload = "Upload";
  static const String replyTicket = "Ticket Details";
  static const String admin = "Admin";
  static const String you = "You";
  static const String noMSgFound = "No Message Found";
  static const String reply = "Reply";
  static const String google = "google";
  static const String attachment = "Attachment";
  static const String youWantToCloseThisTicket =
      "You want to close this ticket?";

  static const String referralCode = "Referral code";
  static const String optional = "optional";

  //social
  static const String or = "Or";
  static const String signInWithGoogle = "Sign In with Google";
  static const String signInWithFacebook = "Sign In with Facebook";
  static const String signInWithLinkedin = "Sign In with Linkedin";

  //meta mask
  static const String metaMask = "Metamask";
  static const String verifyMetamaskLogin = "Verify Metamask Login";
  static const String donNotHave = "Don't have";
  static const String connectMetamask = "Connect to Metamask";

  static List<MyLanguageModel> myLanguages = [
    MyLanguageModel(
        languageName: 'English', countryCode: 'US', languageCode: 'en'),
    MyLanguageModel(
        languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
  ];
}
