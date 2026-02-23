import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/authorization/authorization_response_model.dart';

import '../../../core/helper/date_converter.dart';
import '../../../core/helper/shared_preference_helper.dart';
import '../../../core/routes/route.dart';
import '../../../view/components/show_custom_snackbar.dart';
import '../../model/kyc/kyc_response_model.dart';
import '../../repo/kyc/kyc_repo.dart';

class KycController extends GetxController {
  KycRepo repo;
  KycController({required this.repo});
  File? imageFile;

  bool isLoading = true;
  List<KycFormModel> formList = [];
  String selectOne = MyStrings.selectOne;

  KycResponseModel model = KycResponseModel();
  bool isNoDataFound = false;
  bool isAlreadyVerified = false;
  bool isAlreadyPending = false;

  beforeInitLoadKycData() async {
    setStatusTrue();
    try {
      model = await repo.getKycData();
      if (model.data != null &&
          model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        List<KycFormModel>? tList = model.data?.form?.list;
        if (tList != null && tList.isNotEmpty) {
          formList.clear();
          for (var element in tList) {
            if (element.type == 'select') {
              bool? isEmpty = element.options?.isEmpty;
              bool empty = isEmpty ?? true;
              if (element.options != null && empty != true) {
                element.options?.insert(0, selectOne);
                element.selectedValue = element.options?.first;
                formList.add(element);
              }
            } else {
              formList.add(element);
            }
          }
        }

        isNoDataFound = false;
      } else {
        if (model.remark?.toLowerCase() == 'already_verified') {
          isAlreadyVerified = true;
          await repo.apiClient.sharedPreferences
              .remove(SharedPreferenceHelper.kycStatusKey);
        } else if (model.remark?.toLowerCase() == 'under_review') {
          isAlreadyPending = true;
        } else {
          isNoDataFound = true;
        }
      }
    } finally {
      setStatusFalse();
    }
    setStatusFalse();
  }

  setStatusTrue() {
    isLoading = true;
    update();
  }

  setStatusFalse() {
    isLoading = false;
    update();
  }

  bool submitLoading = false;
  submitKycData() async {
    List<String> list = hasError();

    if (list.isNotEmpty) {
      CustomSnackBar.showCustomSnackBar(
          errorList: list, msg: [], isError: true);
      return;
    }
    submitLoading = true;
    update();

    AuthorizationResponseModel response = await repo.submitKycData(formList);

    if (response.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
      isAlreadyPending = true;
      CustomSnackBar.showCustomSnackBar(
          errorList: [],
          msg: response.message?.success ?? [MyStrings.success.tr],
          isError: false);
      await repo.apiClient.sharedPreferences.setString(
          SharedPreferenceHelper.kycStatusKey,
          SharedPreferenceHelper.kycStatusUnderReview);
      Future.delayed(const Duration(milliseconds: 600), () {
        Get.offAllNamed(RouteHelper.homeScreen);
      });
    } else {
      CustomSnackBar.showCustomSnackBar(
          errorList: response.message?.error ?? [MyStrings.requestFail.tr],
          msg: [],
          isError: true);
    }

    submitLoading = false;
    update();
  }

  List<String> hasError() {
    List<String> errorList = [];
    errorList.clear();
    for (var element in formList) {
      if (element.isRequired == 'required') {
        if (element.type == 'checkbox') {
          if (element.cbSelected == null) {
            errorList.add('${element.name} ${MyStrings.isRequired}');
          }
        } else if (element.type == 'file') {
          if (element.imageFile == null) {
            errorList.add('${element.name} ${MyStrings.isRequired}');
          }
        } else {
          if (element.selectedValue == '' ||
              element.selectedValue == selectOne) {
            errorList.add('${element.name} ${MyStrings.isRequired}');
          }
        }
      }
    }
    return errorList;
  }

  void changeSelectedValue(value, int index) {
    formList[index].selectedValue = value;
    update();
  }

  void changeSelectedRadioBtnValue(int listIndex, int selectedIndex) {
    formList[listIndex].selectedValue =
        formList[listIndex].options?[selectedIndex];
    update();
  }

  void changeSelectedCheckBoxValue(int listIndex, String value) {
    List<String> list = value.split('_');
    print(list.toString());
    print(value);
    int index = int.parse(list[0]);
    bool status = list[1] == 'true' ? true : false;

    List<String>? selectedValue = formList[listIndex].cbSelected;

    if (selectedValue != null) {
      String? value = formList[listIndex].options?[index];
      if (status) {
        if (!selectedValue.contains(value)) {
          selectedValue.add(value!);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      } else {
        if (selectedValue.contains(value)) {
          selectedValue.removeWhere((element) => element == value);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      }
    } else {
      selectedValue = [];
      String? value = formList[listIndex].options?[index];
      if (status) {
        if (!selectedValue.contains(value)) {
          selectedValue.add(value!);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      } else {
        if (selectedValue.contains(value)) {
          selectedValue.removeWhere((element) => element == value);
          formList[listIndex].cbSelected = selectedValue;
          update();
        }
      }
    }
  }

  void pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx']);

    if (result == null) return;

    formList[index].imageFile = File(result.files.single.path!);
    String fileName = result.files.single.name;
    formList[index].selectedValue = fileName;
    update();
    return;
  }

  //NEW DATE TIME
  void changeSelectedDateTimeValue(int index, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        formList[index].selectedValue =
            DateConverter.estimatedDateTime(selectedDateTime);
        // formList[index].selectedValue = selectedDateTime.toIso8601String();
        formList[index].textEditingController?.text =
            DateConverter.estimatedDateTime(selectedDateTime);
        print(formList[index].textEditingController?.text);
        print(formList[index].selectedValue);
        update();
      }
    }

    update();
  }

  void changeSelectedDateOnlyValue(int index, BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final DateTime selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );

      formList[index].selectedValue =
          DateConverter.estimatedDate(selectedDateTime);
      formList[index].textEditingController?.text =
          DateConverter.estimatedDate(selectedDateTime);
      print(formList[index].textEditingController?.text);
      print(formList[index].selectedValue);
      update();
    }

    update();
  }

  void changeSelectedTimeOnlyValue(int index, BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final DateTime selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        pickedTime.hour,
        pickedTime.minute,
      );

      formList[index].selectedValue =
          DateConverter.estimatedTime(selectedDateTime);
      formList[index].textEditingController?.text =
          DateConverter.estimatedTime(selectedDateTime);
      print(formList[index].textEditingController?.text);
      print(formList[index].selectedValue);
      update();
    }

    update();
  }
}
