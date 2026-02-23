// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/shedule/shedule_response_model.dart';
import 'package:hyip_lab/data/repo/shedule/shedule_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class SheduleController extends GetxController {
  SheduleRepo sheduleRepo;
  SheduleController({required this.sheduleRepo});
  bool isLoading = false;

  String? nextPageUrl;
  int page = 0;

  String currency = '';
  String curSymbol = '';

  List<SheduleModel> sheduleList = [];

  Future<void> loadData() async {
    curSymbol = sheduleRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    currency = sheduleRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    page = 0;
    sheduleList.clear();
    isLoading = true;
    update();
    await getSheduleList();
    isLoading = false;
    update();
  }

  //
  Future<void> getSheduleList() async {
    page = page + 1;
    update();

    ResponseModel responseModel = await sheduleRepo.getSheduleData(page);
    if (responseModel.statusCode == 200) {
      SheduleResponseModel model = SheduleResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == MyStrings.success) {
        if (model.data != null) {
          List<SheduleModel> tempList = model.data?.scheduleInvests?.data?.toList() ?? [];
          if (tempList.isNotEmpty && tempList != null) {
            sheduleList.clear();
            sheduleList.addAll(tempList);
            update();
          }
        }
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  //
  Future<void> getShedulePagenateData() async {
    page = page + 1;
    update();

    ResponseModel responseModel = await sheduleRepo.getSheduleData(page);
    if (responseModel.statusCode == 200) {
      SheduleResponseModel model = SheduleResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == MyStrings.success) {
        if (model.data != null) {
          List<SheduleModel> tempList = model.data?.scheduleInvests?.data?.toList() ?? [];
          if (tempList.isNotEmpty && tempList != null) {
            sheduleList.addAll(tempList);
            update();
          }
        }
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  bool isScheduleStatusLoading =  false;
  int selectedScheduleIndex = -1;
  Future<void> changeScheduleStatus(int id,int index) async {
    page = 0;
    isScheduleStatusLoading = true;
    selectedScheduleIndex = index;
    update();

    Get.back();
    ResponseModel responseModel = await sheduleRepo.getSheduleStatus(id);
    if (responseModel.statusCode == 200) {
      SheduleResponseModel model = SheduleResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        await getSheduleList();
        CustomSnackBar.success(successList: model.message?.success ?? [],duration:3 );
      } else {
        await getSheduleList();
        CustomSnackBar.error(errorList: model.message?.error ?? []);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isScheduleStatusLoading = false;
    selectedScheduleIndex = -1;
    update();
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty ? true : false;
  }
}
