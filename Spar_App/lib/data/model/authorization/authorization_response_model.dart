import '../auth/login/login_response_model.dart';
import '../user/user.dart';

class AuthorizationResponseModel {
  AuthorizationResponseModel({
    String? remark,
    String? status,
    Message? message,
    Data? data}){
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  AuthorizationResponseModel.fromJson(dynamic json) {
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
    return map;
  }

}

class Data {
  Data({
    String? trx,
    String? otpId,
    String? verificationId,
    User? user
  }){
    _trx = trx;
    _otpId = otpId;
    _verificationId = verificationId;
    _user = user;
  }

  Data.fromJson(dynamic json) {
    _trx = json['trx'] != null ? json['trx'].toString() : '';
    _otpId = json['otpId'] != null ? json['otpId'].toString() : '';
    _verificationId = json['verificationId'] != null ? json['verificationId'].toString() : '';
    _user = json['user']!=null? User.fromJson(json['user']) : null;
  }

  String? _trx;
  String? _otpId;
  String? _verificationId;
  User? _user;

  String? get trx => _trx;
  String? get otpId => _otpId;
  String? get verificationId => _verificationId;
  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['trx'] = _trx;
    map['otpId'] = _otpId;
    map['verificationId'] = _verificationId;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    return map;
  }

}
