

import '../user/user.dart';

class RankingResponseModel {
  RankingResponseModel({
    String? remark,
    String? status,
    Message? message,
    Data? data,}){
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  RankingResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'];
    _message = json['message'] != null ? Message.fromJson(json['message']) : null;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
  String? _remark;
  String? _status;
  Message? _message;
  Data? _data;

  String? get remark => _remark;
  String? get status => _status;
  Message? get message => _message;
  Data? get data => _data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['remark'] = _remark;
    map['status'] = _status;
    if (_message != null) {
      map['message'] = _message?.toJson();
    }
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }

}

class Data {
  Data({
    List<UserRankings>? userRankings,
    NextRanking? nextRanking,
    User? user,
    String? imagePath,}){
    _userRankings = userRankings;
    _nextRanking = nextRanking;
    _user = user;
    _imagePath = imagePath;
  }

  Data.fromJson(dynamic json) {
    if (json['user_rankings'] != null) {
      _userRankings = [];
      json['user_rankings'].forEach((v) {
        _userRankings?.add(UserRankings.fromJson(v));
      });
    }
    _nextRanking = json['next_ranking'] != null ? NextRanking.fromJson(json['next_ranking']) : null;
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _imagePath = json['image_path'];
  }
  List<UserRankings>? _userRankings;
  NextRanking? _nextRanking;
  User? _user;
  String? _imagePath;

  List<UserRankings>? get userRankings => _userRankings;
  NextRanking? get nextRanking => _nextRanking;
  User? get user => _user;
  String? get imagePath => _imagePath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_userRankings != null) {
      map['user_rankings'] = _userRankings?.map((v) => v.toJson()).toList();
    }
    if (_nextRanking != null) {
      map['next_ranking'] = _nextRanking?.toJson();
    }
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['image_path'] = _imagePath;
    return map;
  }

}

class Referrals {
  Referrals({
    int? id,
    String? firstname,
    String? lastname,
    String? username,
    String? email,
    dynamic wallet,
    dynamic message,
    String? countryCode,
    String? mobile,
    String? refBy,
    String? depositWallet,
    String? interestWallet,
    String? totalInvests,
    String? teamInvests,
    String? userRankingId,
    Address? address,
    String? status,
    String? isDeleted,
    String? kv,
    String? ev,
    String? sv,
    String? profileComplete,
    dynamic verCodeSendAt,
    String? ts,
    String? tv,
    dynamic tsc,
    dynamic banReason,
    dynamic lastRankUpdate,
    String? createdAt,
    String? updatedAt,}){
    _id = id;
    _firstname = firstname;
    _lastname = lastname;
    _username = username;
    _email = email;
    _wallet = wallet;
    _message = message;
    _countryCode = countryCode;
    _mobile = mobile;
    _refBy = refBy;
    _depositWallet = depositWallet;
    _interestWallet = interestWallet;
    _totalInvests = totalInvests;
    _teamInvests = teamInvests;
    _userRankingId = userRankingId;
    _address = address;
    _status = status;
    _isDeleted = isDeleted;
    _kv = kv;
    _ev = ev;
    _sv = sv;
    _profileComplete = profileComplete;
    _verCodeSendAt = verCodeSendAt;
    _ts = ts;
    _tv = tv;
    _tsc = tsc;
    _banReason = banReason;
    _lastRankUpdate = lastRankUpdate;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Referrals.fromJson(dynamic json) {
    _id = json['id'];
    _firstname = json['firstname'];
    _lastname = json['lastname'];
    _username = json['username'];
    _email = json['email'].toString();
    _wallet = json['wallet'].toString();
    _message = json['message'].toString();
    _countryCode = json['country_code'].toString();
    _mobile = json['mobile'].toString();
    _depositWallet = json['deposit_wallet'].toString();
    _interestWallet = json['interest_wallet'].toString();
    _totalInvests = json['total_invests'].toString();
    _teamInvests = json['team_invests'].toString();
    _userRankingId = json['user_ranking_id'].toString();
    _address = json['address'] != null ? Address.fromJson(json['address']) : null;
    _status = json['status'].toString();
    _isDeleted = json['is_deleted'].toString();
    _kv = json['kv'].toString();
    _ev = json['ev'].toString();
    _sv = json['sv'].toString();
    _profileComplete = json['profile_complete'].toString();
    _verCodeSendAt = json['ver_code_send_at'].toString();
    _ts = json['ts'].toString();
    _tv = json['tv'].toString();
    _tsc = json['tsc'].toString();
    _banReason = json['ban_reason'].toString();
    _lastRankUpdate = json['last_rank_update'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }

  int? _id;
  String? _firstname;
  String? _lastname;
  String? _username;
  String? _email;
  dynamic _wallet;
  dynamic _message;
  String? _countryCode;
  String? _mobile;
  String? _refBy;
  String? _depositWallet;
  String? _interestWallet;
  String? _totalInvests;
  String? _teamInvests;
  String? _userRankingId;
  Address? _address;
  String? _status;
  String? _isDeleted;
  String? _kv;
  String? _ev;
  String? _sv;
  String? _profileComplete;
  dynamic _verCodeSendAt;
  String? _ts;
  String? _tv;
  dynamic _tsc;
  dynamic _banReason;
  dynamic _lastRankUpdate;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get username => _username;
  String? get email => _email;
  dynamic get wallet => _wallet;
  dynamic get message => _message;
  String? get countryCode => _countryCode;
  String? get mobile => _mobile;
  String? get refBy => _refBy;
  String? get depositWallet => _depositWallet;
  String? get interestWallet => _interestWallet;
  String? get totalInvests => _totalInvests;
  String? get teamInvests => _teamInvests;
  String? get userRankingId => _userRankingId;
  Address? get address => _address;
  String? get status => _status;
  String? get isDeleted => _isDeleted;
  String? get kv => _kv;
  String? get ev => _ev;
  String? get sv => _sv;
  String? get profileComplete => _profileComplete;
  dynamic get verCodeSendAt => _verCodeSendAt;
  String? get ts => _ts;
  String? get tv => _tv;
  dynamic get tsc => _tsc;
  dynamic get banReason => _banReason;
  dynamic get lastRankUpdate => _lastRankUpdate;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['firstname'] = _firstname;
    map['lastname'] = _lastname;
    map['username'] = _username;
    map['email'] = _email;
    map['wallet'] = _wallet;
    map['message'] = _message;
    map['country_code'] = _countryCode;
    map['mobile'] = _mobile;
    map['ref_by'] = _refBy;
    map['deposit_wallet'] = _depositWallet;
    map['interest_wallet'] = _interestWallet;
    map['total_invests'] = _totalInvests;
    map['team_invests'] = _teamInvests;
    map['user_ranking_id'] = _userRankingId;
    if (_address != null) {
      map['address'] = _address?.toJson();
    }
    map['status'] = _status;
    map['is_deleted'] = _isDeleted;
    map['kv'] = _kv;
    map['ev'] = _ev;
    map['sv'] = _sv;
    map['profile_complete'] = _profileComplete;
    map['ver_code_send_at'] = _verCodeSendAt;
    map['ts'] = _ts;
    map['tv'] = _tv;
    map['tsc'] = _tsc;
    map['ban_reason'] = _banReason;
    map['last_rank_update'] = _lastRankUpdate;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}

class Address {
  Address({
    String? country,
    String? address,
    String? state,
    String? zip,
    String? city,}){
    _country = country;
    _address = address;
    _state = state;
    _zip = zip;
    _city = city;
  }

  Address.fromJson(dynamic json) {
    _country = json['country'];
    _address = json['address'];
    _state = json['state'];
    _zip = json['zip'];
    _city = json['city'];
  }
  String? _country;
  String? _address;
  String? _state;
  String? _zip;
  String? _city;

  String? get country => _country;
  String? get address => _address;
  String? get state => _state;
  String? get zip => _zip;
  String? get city => _city;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['country'] = _country;
    map['address'] = _address;
    map['state'] = _state;
    map['zip'] = _zip;
    map['city'] = _city;
    return map;
  }

}


class NextRanking {
  NextRanking({
    int? id,
    String? icon,
    String? level,
    String? name,
    String? minimumInvest,
    String? minReferralInvest,
    String? minReferral,
    String? bonus,
    String? status,
    String? createdAt,
    String? updatedAt,}){
    _id = id;
    _icon = icon;
    _level = level;
    _name = name;
    _minimumInvest = minimumInvest;
    _minReferralInvest = minReferralInvest;
    _minReferral = minReferral;
    _bonus = bonus;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  NextRanking.fromJson(dynamic json) {
    _id = json['id'];
    _icon = json['icon'].toString();
    _level = json['level'].toString();
    _name = json['name'].toString();
    _minimumInvest = json['minimum_invest'].toString();
    _minReferralInvest = json['min_referral_invest'].toString();
    _minReferral = json['min_referral'].toString();
    _bonus = json['bonus'].toString();
    _status = json['status'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  int? _id;
  String? _icon;
  String? _level;
  String? _name;
  String? _minimumInvest;
  String? _minReferralInvest;
  String? _minReferral;
  String? _bonus;
  String? _status;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get icon => _icon;
  String? get level => _level;
  String? get name => _name;
  String? get minimumInvest => _minimumInvest;
  String? get minReferralInvest => _minReferralInvest;
  String? get minReferral => _minReferral;
  String? get bonus => _bonus;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['icon'] = _icon;
    map['level'] = _level;
    map['name'] = _name;
    map['minimum_invest'] = _minimumInvest;
    map['min_referral_invest'] = _minReferralInvest;
    map['min_referral'] = _minReferral;
    map['bonus'] = _bonus;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }

}

class UserRankings {
  UserRankings({
    int? id,
    String? icon,
    String? level,
    String? name,
    String? minimumInvest,
    String? minReferralInvest,
    String? minReferral,
    String? bonus,
    String? status,
    String? createdAt,
    String? updatedAt,
    String? progressPercent,}){
    _id = id;
    _icon = icon;
    _level = level;
    _name = name;
    _minimumInvest = minimumInvest;
    _minReferralInvest = minReferralInvest;
    _minReferral = minReferral;
    _bonus = bonus;
    _status = status;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _progressPercent = progressPercent;
  }

  UserRankings.fromJson(dynamic json) {
    _id = json['id'];
    _icon = json['icon'].toString();
    _level = json['level'].toString();
    _name = json['name'].toString();
    _minimumInvest = json['minimum_invest'].toString();
    _minReferralInvest = json['min_referral_invest'].toString();
    _minReferral = json['min_referral'].toString();
    _bonus = json['bonus'].toString();
    _status = json['status'].toString();
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _progressPercent = json['progress_percent'].toString();
  }
  int? _id;
  String? _icon;
  String? _level;
  String? _name;
  String? _minimumInvest;
  String? _minReferralInvest;
  String? _minReferral;
  String? _bonus;
  String? _status;
  String? _createdAt;
  String? _updatedAt;
  String? _progressPercent;

  int? get id => _id;
  String? get icon => _icon;
  String? get level => _level;
  String? get name => _name;
  String? get minimumInvest => _minimumInvest;
  String? get minReferralInvest => _minReferralInvest;
  String? get minReferral => _minReferral;
  String? get bonus => _bonus;
  String? get status => _status;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get progressPercent => _progressPercent;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['icon'] = _icon;
    map['level'] = _level;
    map['name'] = _name;
    map['minimum_invest'] = _minimumInvest;
    map['min_referral_invest'] = _minReferralInvest;
    map['min_referral'] = _minReferral;
    map['bonus'] = _bonus;
    map['status'] = _status;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    map['progress_percent'] = _progressPercent;
    return map;
  }

}


class Message {
  Message({
    List<String>? success,
    List<String>? error,
  }){
    _success = success;
    _error=error;
  }

  Message.fromJson(dynamic json) {
    _success = json['success'] != null ?[json['success'].toString()]:null;
    _error = json['error'] != null ? [json['error'].toString()] :null;
  }
  List<String>? _success;
  List<String>? _error;

  List<String>? get success => _success;
  List<String>? get error => _error;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = _success;
    map['error'] = _error;
    return map;
  }

}