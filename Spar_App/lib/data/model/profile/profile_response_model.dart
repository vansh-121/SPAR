import 'package:hyip_lab/data/model/user/user.dart';

import '../auth/sign_up_model/registration_response_model.dart';

class ProfileResponseModel {
  ProfileResponseModel({
      String? remark, 
      String? status, 
      Message? message, 
      Data? data,}){
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
}

  ProfileResponseModel.fromJson(dynamic json) {
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
      User? user,}){
    _user = user;
}

  Data.fromJson(dynamic json) {
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
  }
  User? _user;

  User? get user => _user;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
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
    _country  =   json['country'];
    _address  =   json['address'];
    _state    =   json['state'] !=null ? json['state'].toString():'';
    _zip      =   json['zip'] !=null? json['zip'].toString() : '';
    _city     =   json['city'] !=null ? json['city'].toString():'';
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
