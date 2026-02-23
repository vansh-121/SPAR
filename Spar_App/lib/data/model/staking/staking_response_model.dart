// To parse this JSON data, do
//
//     final stakingResponseModel = stakingResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:hyip_lab/data/model/auth/login/login_response_model.dart';

StakingResponseModel stakingResponseModelFromJson(String str) => StakingResponseModel.fromJson(json.decode(str));

String stakingResponseModelToJson(StakingResponseModel data) => json.encode(data.toJson());

class StakingResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  StakingResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory StakingResponseModel.fromJson(Map<String, dynamic> json) => StakingResponseModel(
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
  List<Staking>? staking;
  MyStakingsData? myStakings;

  Data({
    this.staking,
    this.myStakings,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        staking: json["staking"] == null ? [] : List<Staking>.from(json["staking"]!.map((x) => Staking.fromJson(x))),
        myStakings: json["my_stakings"] == null ? null : MyStakingsData.fromJson(json["my_stakings"]),
      );

  Map<String, dynamic> toJson() => {
        "staking": staking == null ? [] : List<dynamic>.from(staking!.map((x) => x.toJson())),
        "my_stakings": myStakings?.toJson(),
      };
}

class MyStakingsData {
  List<MyStakings>? data;
  dynamic nextPageUrl;

  MyStakingsData({
    this.data,
    this.nextPageUrl,
  });

  factory MyStakingsData.fromJson(Map<String, dynamic> json) => MyStakingsData(
        data: json["data"] == null ? [] : List<MyStakings>.from(json["data"]!.map((x) => MyStakings.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,

      };
}

class MyStakings {
  int? id;
  String? userId;
  String? stakingId;
  String? investAmount;
  String? interest;
  String? endAt;
  String? status;
  String? createdAt;
  String? updatedAt;

  MyStakings({
    this.id,
    this.userId,
    this.stakingId,
    this.investAmount,
    this.interest,
    this.endAt,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MyStakings.fromJson(Map<String, dynamic> json) => MyStakings(
        id: json["id"],
        userId: json["user_id"].toString(),
        stakingId: json["staking_id"].toString(),
        investAmount: json["invest_amount"].toString(),
        interest: json["interest"].toString(),
        endAt: json["end_at"].toString(),
        status: json["status"].toString(),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "staking_id": stakingId,
        "invest_amount": investAmount,
        "interest": interest,
        "status": status,
      };
}

class Staking {
  int? id;
  String? days;
  String? interestPercent;
  String? status;


  Staking({
    this.id,
    this.days,
    this.interestPercent,
    this.status,
  });

  factory Staking.fromJson(Map<String, dynamic> json) => Staking(
      id: json["id"],
      days: json["days"] != null ? json["days"].toString() : "",
      interestPercent: json["interest_percent"].toString(),
      status: json["status"].toString(),
    );

  Map<String, dynamic> toJson() => {
      "id": id,
      "days": days,
      "interest_percent": interestPercent,
      "status": status,
    };
}
