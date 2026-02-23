// To parse this JSON data, do
//
//     final poolResponseModel = poolResponseModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

import 'package:hyip_lab/data/model/auth/login/login_response_model.dart';

PoolResponseModel poolResponseModelFromJson(String str) => PoolResponseModel.fromJson(json.decode(str));

String poolResponseModelToJson(PoolResponseModel data) => json.encode(data.toJson());

class PoolResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  PoolResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory PoolResponseModel.fromJson(Map<String, dynamic> json) => PoolResponseModel(
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
  List<Pool>? pools;

  Data({
    this.pools,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        pools: json["pools"] == null ? [] : List<Pool>.from(json["pools"]!.map((x) => Pool.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "pools": pools == null ? [] : List<dynamic>.from(pools!.map((x) => x.toJson())),
      };
}

class Pool {
  int? id;
  String? name;
  String? amount;
  String? investedAmount;
  String? startDate;
  String? endDate;
  String? interestRange;
  String? shareInterest;
  String? interest;
  String? status;
  String? createdAt;
  String? updatedAt;

  Pool({
    this.id,
    this.name,
    this.amount,
    this.investedAmount,
    this.startDate,
    this.endDate,
    this.interestRange,
    this.shareInterest,
    this.interest,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Pool.fromJson(Map<String, dynamic> json) => Pool(
        id: json["id"],
        name: json["name"],
        amount: json["amount"].toString(),
        investedAmount: json["invested_amount"].toString(),
        startDate: json["start_date"] == null ? null : json["start_date"].toString(),
        endDate: json["end_date"] == null ? null : json["end_date"].toString(),
        interestRange: json["interest_range"].toString(),
        shareInterest: json["share_interest"].toString(),
        interest: json["interest"].toString(),
        status: json["status"].toString(),
        createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "amount": amount,
        "invested_amount": investedAmount,
        "start_date": startDate?.toString(),
        "end_date": endDate?.toString(),
        "interest_range": interestRange,
        "share_interest": shareInterest,
        "interest": interest,
        "status": status,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
      };
}
