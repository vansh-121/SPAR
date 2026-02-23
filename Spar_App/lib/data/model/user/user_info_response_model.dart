// To parse this JSON data, do
//
//     final userInfoResponseModel = userInfoResponseModelFromJson(jsonString);

import 'dart:convert';

import '../auth/login/login_response_model.dart';

UserInfoResponseModel userInfoResponseModelFromJson(String str) => UserInfoResponseModel.fromJson(json.decode(str));

String userInfoResponseModelToJson(UserInfoResponseModel data) => json.encode(data.toJson());

class UserInfoResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  UserInfoResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory UserInfoResponseModel.fromJson(Map<String, dynamic> json) => UserInfoResponseModel(
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
  User? user;

  Data({
    this.user,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
  };
}

class User {
  int? id;
  String? provider;
  String? providerId;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
    this.provider,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    provider: json["provider"] != null ? json["provider"].toString() : "",
    providerId: json["provider_id"] != null ? json["provider_id"].toString() : "",
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "provider": provider,
    "provider_id": providerId,
    "created_at": createdAt,
    "updated_at": updatedAt,
  };
}
