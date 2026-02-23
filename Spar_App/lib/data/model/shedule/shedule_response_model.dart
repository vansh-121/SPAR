// To parse this JSON data, do
//
//     final sheduleResponseModel = sheduleResponseModelFromJson(jsonString);

// ignore_for_file: prefer_null_aware_operators

import 'dart:convert';

import 'package:hyip_lab/data/model/auth/login/login_response_model.dart';

SheduleResponseModel sheduleResponseModelFromJson(String str) => SheduleResponseModel.fromJson(json.decode(str));

String sheduleResponseModelToJson(SheduleResponseModel data) => json.encode(data.toJson());

class SheduleResponseModel {
  String? remark;
  String? status;
  Message? message;
  Data? data;

  SheduleResponseModel({
    this.remark,
    this.status,
    this.message,
    this.data,
  });

  factory SheduleResponseModel.fromJson(Map<String, dynamic> json) => SheduleResponseModel(
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
  ScheduleInvests? scheduleInvests;

  Data({
    this.scheduleInvests,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        scheduleInvests: json["schedule_invests"] == null ? null : ScheduleInvests.fromJson(json["schedule_invests"]),
      );

  Map<String, dynamic> toJson() => {
        "schedule_invests": scheduleInvests?.toJson(),
      };
}

class ScheduleInvests {
  List<SheduleModel>? data;
  dynamic nextPageUrl;

  ScheduleInvests({
    this.data,
    this.nextPageUrl,
  });

  factory ScheduleInvests.fromJson(Map<String, dynamic> json) => ScheduleInvests(
        data: json["data"] == null ? [] : List<SheduleModel>.from(json["data"]!.map((x) => SheduleModel.fromJson(x))),
        nextPageUrl: json["next_page_url"],
      );

  Map<String, dynamic> toJson() => {
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "next_page_url": nextPageUrl,
      };
}

class SheduleModel {
  int? id;
  String? userId;
  String? planId;
  String? wallet;
  String? amount;
  String? scheduleTimes;
  String? remScheduleTimes;
  String? intervalHours;
  String? compoundTimes;
  String? nextInvest;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? return_;
  Plan? plan;

  SheduleModel({
    this.id,
    this.userId,
    this.planId,
    this.wallet,
    this.amount,
    this.scheduleTimes,
    this.remScheduleTimes,
    this.intervalHours,
    this.compoundTimes,
    this.nextInvest,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.return_,
    this.plan,
  });

  factory SheduleModel.fromJson(Map<String, dynamic> json) => SheduleModel(
        id: json["id"],
        userId: json["user_id"].toString(),
        planId: json["plan_id"].toString(),
        wallet: json["wallet"] != null? json["wallet"].toString() : "",
        amount: json["amount"] != null? json["amount"].toString() : "",
        scheduleTimes: json["schedule_times"].toString(),
        remScheduleTimes: json["rem_schedule_times"].toString(),
        intervalHours: json["interval_hours"].toString(),
        compoundTimes: json["compound_times"].toString(),
        nextInvest: json["next_invest"] == null ? "" : json["next_invest"].toString(),
        status: json["status"].toString(),
        createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
        return_: json["return"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "plan_id": planId,
        "wallet": wallet,
        "amount": amount,
        "schedule_times": scheduleTimes,
        "rem_schedule_times": remScheduleTimes,
        "interval_hours": intervalHours,
        "compound_times": compoundTimes,
        "next_invest": nextInvest?.toString(),
        "status": status,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
        "plan": plan?.toJson(),
      };
}

class Plan {
  int? id;
  String? timeSettingId;
  String? name;
  String? minimum;
  String? maximum;
  String? fixedAmount;
  String? interest;
  String? interestType;
  String? repeatTime;
  String? lifetime;
  String? capitalBack;
  String? compoundInterest;
  String? holdCapital;
  String? featured;
  String? status;
  String? createdAt;
  String? updatedAt;
  TimeSetting? timeSetting;

  Plan({
    this.id,
    this.timeSettingId,
    this.name,
    this.minimum,
    this.maximum,
    this.fixedAmount,
    this.interest,
    this.interestType,
    this.repeatTime,
    this.lifetime,
    this.capitalBack,
    this.compoundInterest,
    this.holdCapital,
    this.featured,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.timeSetting,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: json["id"],
        timeSettingId: json["time_setting_id"].toString(),
        name: json["name"],
        minimum: json["minimum"].toString(),
        maximum: json["maximum"].toString(),
        fixedAmount: json["fixed_amount"].toString(),
        interest: json["interest"].toString(),
        interestType: json["interest_type"].toString(),
        repeatTime: json["repeat_time"].toString(),
        lifetime: json["lifetime"].toString(),
        capitalBack: json["capital_back"].toString(),
        compoundInterest: json["compound_interest"].toString(),
        holdCapital: json["hold_capital"].toString(),
        featured: json["featured"].toString(),
        status: json["status"].toString(),
        createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
        timeSetting: json["time_setting"] == null ? null : TimeSetting.fromJson(json["time_setting"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "time_setting_id": timeSettingId,
        "name": name,
        "minimum": minimum,
        "maximum": maximum,
        "fixed_amount": fixedAmount,
        "interest": interest,
        "interest_type": interestType,
        "repeat_time": repeatTime,
        "lifetime": lifetime,
        "capital_back": capitalBack,
        "compound_interest": compoundInterest,
        "hold_capital": holdCapital,
        "featured": featured,
        "status": status,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
        "time_setting": timeSetting?.toJson(),
      };
}

class TimeSetting {
  int? id;
  String? name;
  String? time;
  String? status;
  String? createdAt;
  String? updatedAt;

  TimeSetting({
    this.id,
    this.name,
    this.time,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeSetting.fromJson(Map<String, dynamic> json) => TimeSetting(
        id: json["id"],
        name: json["name"],
        time: json["time"],
        status: json["status"].toString(),
        createdAt: json["created_at"] == null ? null : json["created_at"].toString(),
        updatedAt: json["updated_at"] == null ? null : json["updated_at"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "time": time,
        "status": status,
        "created_at": createdAt?.toString(),
        "updated_at": updatedAt?.toString(),
      };
}


