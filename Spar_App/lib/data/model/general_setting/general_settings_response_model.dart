import 'dart:convert';

import '../auth/login/login_response_model.dart';

GeneralSettingResponseModel generalSettingResponseModelFromJson(String str) => GeneralSettingResponseModel.fromJson(json.decode(str));

String generalSettingResponseModelToJson(GeneralSettingResponseModel data) => json.encode(data.toJson());

class GeneralSettingResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  GeneralSettingResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory GeneralSettingResponseModel.fromJson(Map<String, dynamic> json) => GeneralSettingResponseModel(
    remark: json["remark"],
    status: json["status"],
    message: json["message"] == null ? null : Message.fromJson(json["message"]),
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "remark": remark,
    "status": status,
    "message": message?.toJson(),
    "data": data?.toJson(),
  };
}

class Data {
  GeneralSetting? generalSetting;
  String? socialLoginRedirect;

  Data({
    this.generalSetting,
    this.socialLoginRedirect,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    generalSetting: json["general_setting"] == null ? null : GeneralSetting.fromJson(json["general_setting"]),
    socialLoginRedirect: json["social_login_redirect"],
  );

  Map<String, dynamic> toJson() => {
    "general_setting": generalSetting?.toJson(),
    "social_login_redirect": socialLoginRedirect,
  };
}

class GeneralSetting {
  int? id;
  String? siteName;
  String? curText;
  String? curSym;
  String? emailFrom;
  dynamic emailFromName;
  String? smsTemplate;
  String? smsFrom;
  dynamic pushTitle;
  dynamic pushTemplate;
  String? baseColor;
  String? secondaryColor;
  GlobalShortcodes? globalShortcodes;
  String? kv;
  String? ev;
  String? en;
  String? sv;
  String? sn;
  String? pn;
  String? forceSsl;
  String? maintenanceMode;
  String? securePassword;
  String? agree;
  String? registration;
  String? metamaskLogin;
  String? activeTemplate;
  SocialiteCredentials? socialiteCredentials;
  String? systemCustomized;
  String? paginateNumber;
  String? currencyFormat;
  String? depositCommission;
  String? investCommission;
  String? investReturnCommission;
  String? signupBonusAmount;
  String? signupBonusControl;
  String? promotionalTool;
  dynamic firebaseConfig;
  dynamic firebaseTemplate;
  String? pushNotify;
  dynamic offDay;
  String? lastCron;
  String? availableVersion;
  String? bTransfer;
  String? fCharge;
  String? pCharge;
  String? userRanking;
  String? scheduleInvest;
  String? holidayWithdraw;
  String? stakingOption;
  String? stakingMinAmount;
  String? stakingMaxAmount;
  String? poolOption;
  String? multiLanguage;
  dynamic createdAt;
  String? updatedAt;

  GeneralSetting({
    this.id,
    this.siteName,
    this.curText,
    this.curSym,
    this.emailFrom,
    this.emailFromName,
    this.smsTemplate,
    this.smsFrom,
    this.pushTitle,
    this.pushTemplate,
    this.baseColor,
    this.secondaryColor,
    this.globalShortcodes,
    this.kv,
    this.ev,
    this.en,
    this.sv,
    this.sn,
    this.pn,
    this.forceSsl,
    this.maintenanceMode,
    this.securePassword,
    this.agree,
    this.registration,
    this.metamaskLogin,
    this.activeTemplate,
    this.socialiteCredentials,
    this.systemCustomized,
    this.paginateNumber,
    this.currencyFormat,
    this.depositCommission,
    this.investCommission,
    this.investReturnCommission,
    this.signupBonusAmount,
    this.signupBonusControl,
    this.promotionalTool,
    this.firebaseConfig,
    this.firebaseTemplate,
    this.pushNotify,
    this.offDay,
    this.lastCron,
    this.availableVersion,
    this.bTransfer,
    this.fCharge,
    this.pCharge,
    this.userRanking,
    this.scheduleInvest,
    this.holidayWithdraw,
    this.stakingOption,
    this.stakingMinAmount,
    this.stakingMaxAmount,
    this.poolOption,
    this.multiLanguage,
    this.createdAt,
    this.updatedAt,
  });

  factory GeneralSetting.fromJson(Map<String, dynamic> json) => GeneralSetting(
    id: json["id"],
    siteName: json["site_name"].toString(),
    curText: json["cur_text"].toString(),
    curSym: json["cur_sym"].toString(),
    emailFrom: json["email_from"].toString(),
    emailFromName: json["email_from_name"].toString(),
    smsTemplate: json["sms_template"].toString(),
    smsFrom: json["sms_from"].toString(),
    pushTitle: json["push_title"].toString(),
    pushTemplate: json["push_template"].toString(),
    baseColor: json["base_color"].toString(),
    secondaryColor: json["secondary_color"].toString(),
    globalShortcodes: json["global_shortcodes"] == null ? null : GlobalShortcodes.fromJson(json["global_shortcodes"]),
    kv: json["kv"].toString(),
    ev: json["ev"].toString(),
    en: json["en"].toString(),
    sv: json["sv"].toString(),
    sn: json["sn"].toString(),
    pn: json["pn"].toString(),
    forceSsl: json["force_ssl"].toString(),
    maintenanceMode: json["maintenance_mode"].toString(),
    securePassword: json["secure_password"].toString(),
    agree: json["agree"].toString(),
    registration: json["registration"].toString(),
    metamaskLogin: json["metamask_login"].toString(),
    activeTemplate: json["active_template"].toString(),
    socialiteCredentials: json["socialite_credentials"] == null ? null : SocialiteCredentials.fromJson(json["socialite_credentials"]),
    systemCustomized: json["system_customized"].toString(),
    paginateNumber: json["paginate_number"].toString(),
    currencyFormat: json["currency_format"].toString(),
    depositCommission: json["deposit_commission"].toString(),
    investCommission: json["invest_commission"].toString(),
    investReturnCommission: json["invest_return_commission"].toString(),
    signupBonusAmount: json["signup_bonus_amount"].toString(),
    signupBonusControl: json["signup_bonus_control"].toString(),
    promotionalTool: json["promotional_tool"].toString(),
    firebaseConfig: json["firebase_config"].toString(),
    firebaseTemplate: json["firebase_template"].toString(),
    pushNotify: json["push_notify"].toString(),
    offDay: json['off_day'].toString(),
    lastCron: json["last_cron"].toString(),
    availableVersion: json["available_version"].toString(),
    bTransfer: json["b_transfer"].toString(),
    fCharge: json["f_charge"].toString(),
    pCharge: json["p_charge"].toString(),
    userRanking: json["user_ranking"].toString(),
    scheduleInvest: json["schedule_invest"].toString(),
    holidayWithdraw: json["holiday_withdraw"].toString(),
    stakingOption: json["staking_option"].toString(),
    stakingMinAmount: json["staking_min_amount"].toString(),
    stakingMaxAmount: json["staking_max_amount"].toString(),
    poolOption: json["pool_option"].toString(),
    multiLanguage: json["multi_language"].toString(),
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "site_name": siteName,
    "cur_text": curText,
    "cur_sym": curSym,
    "email_from": emailFrom,
    "email_from_name": emailFromName,
    "sms_template": smsTemplate,
    "sms_from": smsFrom,
    "push_title": pushTitle,
    "push_template": pushTemplate,
    "base_color": baseColor,
    "secondary_color": secondaryColor,
    "global_shortcodes": globalShortcodes?.toJson(),
    "kv": kv,
    "ev": ev,
    "en": en,
    "sv": sv,
    "sn": sn,
    "pn": pn,
    "force_ssl": forceSsl,
    "maintenance_mode": maintenanceMode,
    "secure_password": securePassword,
    "agree": agree,
    "registration": registration,
    "metamask_login": metamaskLogin,
    "active_template": activeTemplate,
    "socialite_credentials": socialiteCredentials?.toJson(),
    "system_customized": systemCustomized,
    "paginate_number": paginateNumber,
    "currency_format": currencyFormat,
    "deposit_commission": depositCommission,
    "invest_commission": investCommission,
    "invest_return_commission": investReturnCommission,
    "signup_bonus_amount": signupBonusAmount,
    "signup_bonus_control": signupBonusControl,
    "promotional_tool": promotionalTool,
    "firebase_config": firebaseConfig,
    "firebase_template": firebaseTemplate,
    "push_notify": pushNotify,
    "off_day": offDay,
    "last_cron": lastCron,
    "available_version": availableVersion,
    "b_transfer": bTransfer,
    "f_charge": fCharge,
    "p_charge": pCharge,
    "user_ranking": userRanking,
    "schedule_invest": scheduleInvest,
    "holiday_withdraw": holidayWithdraw,
    "staking_option": stakingOption,
    "staking_min_amount": stakingMinAmount,
    "staking_max_amount": stakingMaxAmount,
    "pool_option": poolOption,
    "multi_language": multiLanguage,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}

class GlobalShortcodes {
  String? siteName;
  String? siteCurrency;
  String? currencySymbol;

  GlobalShortcodes({
    this.siteName,
    this.siteCurrency,
    this.currencySymbol,
  });

  factory GlobalShortcodes.fromJson(Map<String, dynamic> json) => GlobalShortcodes(
    siteName: json["site_name"].toString(),
    siteCurrency: json["site_currency"].toString(),
    currencySymbol: json["currency_symbol"].toString(),
  );

  Map<String, dynamic> toJson() => {
    "site_name": siteName,
    "site_currency": siteCurrency,
    "currency_symbol": currencySymbol,
  };
}

class SocialiteCredentials {
  Facebook? google;
  Facebook? facebook;
  Facebook? linkedin;

  SocialiteCredentials({
    this.google,
    this.facebook,
    this.linkedin,
  });

  factory SocialiteCredentials.fromJson(Map<String, dynamic> json) => SocialiteCredentials(
    google: json["google"] == null ? null : Facebook.fromJson(json["google"]),
    facebook: json["facebook"] == null ? null : Facebook.fromJson(json["facebook"]),
    linkedin: json["linkedin"] == null ? null : Facebook.fromJson(json["linkedin"]),
  );

  Map<String, dynamic> toJson() => {
    "google": google?.toJson(),
    "facebook": facebook?.toJson(),
    "linkedin": linkedin?.toJson(),
  };
}

class Facebook {
  String? clientId;
  String? clientSecret;
  String? status;

  Facebook({
    this.clientId,
    this.clientSecret,
    this.status,
  });

  factory Facebook.fromJson(Map<String, dynamic> json) => Facebook(
    clientId: json["client_id"],
    clientSecret: json["client_secret"],
    status: json["status"] != null ? json["status"].toString() : "",
  );

  Map<String, dynamic> toJson() => {
    "client_id": clientId,
    "client_secret": clientSecret,
    "status": status,
  };
}
