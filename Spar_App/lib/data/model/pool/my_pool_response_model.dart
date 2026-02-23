// To parse this JSON data, do
//
//     final mypoolResponseModel = mypoolResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:hyip_lab/data/model/auth/sign_up_model/registration_response_model.dart';
import 'package:hyip_lab/data/model/pool/pool_response_model.dart';

MypoolResponseModel mypoolResponseModelFromJson(String str) => MypoolResponseModel.fromJson(json.decode(str));

String mypoolResponseModelToJson(MypoolResponseModel data) => json.encode(data.toJson());

class MypoolResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  MypoolResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory MypoolResponseModel.fromJson(Map<String, dynamic> json) => MypoolResponseModel(
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
  PoolInvests? poolInvests;

  Data({
    this.poolInvests,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        poolInvests: json["pool_invests"] == null ? null : PoolInvests.fromJson(json["pool_invests"]),
      );

  Map<String, dynamic> toJson() => {
        "pool_invests": poolInvests?.toJson(),
      };
}

class PoolInvests {
  List<Invest>? data;
  dynamic nextPageUrl;

  PoolInvests({
    this.data,
    this.nextPageUrl,
  });

  factory PoolInvests.fromJson(Map<String, dynamic> json) => PoolInvests(
        data: json["data"] == null ? [] : List<Invest>.from(json["data"]!.map((x) => Invest.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class Invest {
  int? id;
  String? userId;
  String? poolId;
  String? investAmount;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? totalReturn;
  Pool? pool;

  Invest({
    this.id,
    this.userId,
    this.poolId,
    this.investAmount,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.totalReturn,
    this.pool,
  });

  factory Invest.fromJson(Map<String, dynamic> json) => Invest(
        id: json["id"],
        userId: json["user_id"].toString(),
        poolId: json["pool_id"].toString(),
        investAmount: json["invest_amount"].toString(),
        status: json["status"].toString(),
        totalReturn: json["total_return"]!= null? json["total_return"].toString() : '',
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        pool: json["pool"] == null ? null : Pool.fromJson(json["pool"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "pool_id": poolId,
        "invest_amount": investAmount,
        "status": status,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "pool": pool?.toJson(),
      };
}

