class User {
  int? id;
  String? firstname;
  String? lastname;
  String? username;
  String? email;
  String? dialCode;
  String? wallet;
  String? message;
  String? countryCode;
  String? mobile;
  String? refBy;
  String? depositWallet;
  String? interestWallet;
  String? countryName;
  String? city;
  String? state;
  String? zip;
  String? address;
  String? totalInvests;
  String? teamInvests;
  String? userRankingId;
  String? status;
  String? isDeleted;
  String? kycRejectionReason;
  String? kv;
  String? ev;
  String? sv;
  String? agreementVerified;
  String? profileComplete;
  String? verCodeSendAt;
  String? ts;
  String? tv;
  String? tsc;
  String? banReason;
  String? provider;
  String? providerId;
  String? lastRankUpdate;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.dialCode,
    this.wallet,
    this.message,
    this.countryCode,
    this.mobile,
    this.refBy,
    this.depositWallet,
    this.interestWallet,
    this.countryName,
    this.city,
    this.state,
    this.zip,
    this.address,
    this.totalInvests,
    this.teamInvests,
    this.userRankingId,
    this.status,
    this.isDeleted,
    this.kycRejectionReason,
    this.kv,
    this.ev,
    this.sv,
    this.agreementVerified,
    this.profileComplete,
    this.verCodeSendAt,
    this.ts,
    this.tv,
    this.tsc,
    this.banReason,
    this.provider,
    this.providerId,
    this.lastRankUpdate,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstname: json["firstname"] != null ? json["firstname"].toString() : "",
    lastname: json["lastname"] != null ? json["lastname"].toString() : "",
    username: json["username"] != null ? json["username"].toString() : "",
    email: json["email"] != null ? json["email"].toString() : "",
    dialCode: json["dial_code"] != null ? json["dial_code"].toString() : "",
    wallet: json["wallet"] != null ? json["wallet"].toString() : "",
    message: json["message"] != null ? json["message"].toString() : "",
    countryCode: json["country_code"] != null ? json["country_code"].toString() : "",
    mobile: json["mobile"] != null ? json["mobile"].toString() : "",
    refBy: json["ref_by"] != null ? json["ref_by"].toString() : "",
    depositWallet: json["deposit_wallet"] != null ? json["deposit_wallet"].toString() : "",
    interestWallet: json["interest_wallet"] != null ? json["interest_wallet"].toString() : "",
    countryName: json["country_name"] != null ? json["country_name"]?.toString() : "",
    city: json["city"] != null ? json["city"].toString() : "",
    state: json["state"] != null ? json["state"].toString() : "",
    zip: json["zip"] != null ? json["zip"].toString() : "",
    address: json["address"] != null ? json["address"].toString() : "",
    totalInvests: json["total_invests"] != null ? json["total_invests"].toString() : "",
    teamInvests: json["team_invests"] != null ? json["team_invests"].toString() : "",
    userRankingId: json["user_ranking_id"] != null ? json["user_ranking_id"].toString() : "",
    status: json["status"] != null ? json["status"].toString() : "",
    isDeleted: json["is_deleted"] != null ? json["is_deleted"].toString() : "",
    kycRejectionReason: json["kyc_rejection_reason"] != null ? json["kyc_rejection_reason"].toString() : "",
    kv: json["kv"] != null ? json["kv"].toString() : "",
    ev: json["ev"] != null ? json["ev"].toString() : "",
    sv: json["sv"] != null ? json["sv"].toString() : "",
    agreementVerified: json["agreement_verified"] != null ? json["agreement_verified"].toString() : "0",
    profileComplete: json["profile_complete"] != null ? json["profile_complete"].toString() : "",
    verCodeSendAt: json["ver_code_send_at"] != null ? json["ver_code_send_at"].toString() : "",
    ts: json["ts"] != null ? json["ts"].toString() : "",
    tv: json["tv"] != null ? json["tv"].toString() : "",
    tsc: json["tsc"] != null ? json["tsc"].toString() : "",
    banReason: json["ban_reason"] != null ? json["ban_reason"].toString() : "",
    provider: json["provider"] != null ? json["provider"].toString() : "",
    providerId: json["provider_id"] != null ? json["provider_id"].toString() : "",
    lastRankUpdate: json["last_rank_update"] != null ? json["last_rank_update"].toString() : "",
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "email": email,
    "dial_code": dialCode,
    "wallet": wallet,
    "message": message,
    "country_code": countryCode,
    "mobile": mobile,
    "ref_by": refBy,
    "deposit_wallet": depositWallet,
    "interest_wallet": interestWallet,
    "country_name": countryName,
    "city": city,
    "state": state,
    "zip": zip,
    "address": address,
    "total_invests": totalInvests,
    "team_invests": teamInvests,
    "user_ranking_id": userRankingId,
    "status": status,
    "is_deleted": isDeleted,
    "kyc_rejection_reason": kycRejectionReason,
    "kv": kv,
    "ev": ev,
    "sv": sv,
    "agreement_verified": agreementVerified,
    "profile_complete": profileComplete,
    "ver_code_send_at": verCodeSendAt,
    "ts": ts,
    "tv": tv,
    "tsc": tsc,
    "ban_reason": banReason,
    "provider": provider,
    "provider_id": providerId,
    "last_rank_update": lastRankUpdate,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}