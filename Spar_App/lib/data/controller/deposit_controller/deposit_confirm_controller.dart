import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_insert_response_model.dart';
import 'package:hyip_lab/data/model/authorized/deposit/last_transaction_data.dart';
import 'package:hyip_lab/data/model/profile/profile_response_model.dart';
import 'package:hyip_lab/data/repo/account/profile_repo.dart';
import 'package:hyip_lab/data/repo/deposit_repo.dart';

import '../../../core/helper/date_converter.dart';
import '../../../view/components/show_custom_snackbar.dart';
import '../../model/authorization/authorization_response_model.dart';

class DepositConfirmController extends GetxController {

  DepositRepo repo;
  ProfileRepo profileRepo;
  DepositConfirmController({required this.repo,required this.profileRepo});

  bool isLoading = true;
  List<FormModel> formList = [];
  String selectOne = MyStrings.selectOne;
  String trxId='';
  String? depositInstruction;
  String? userData;
  String? gatewayCode;
  String? gatewayName;
  LastTransactionData? lastTransactionData;
  bool showAutofillSuggestion = false;

  String twoFactorCode = '';

  loadData(DepositInsertResponseModel model) async {
    isLoading = true;
    update();
    twoFactorCode = '';
    trxId=model.data?.track??'';
    depositInstruction = model.data?.depositInstruction ?? model.data?.userData;
    userData = model.data?.userData;
    gatewayCode = model.data?.deposit?.methodCode?.toString();
    gatewayName = model.data?.methodName;
    
    // Load last transaction data for autofill
    if (gatewayCode != null) {
      lastTransactionData = await repo.getLastTransactionData(gatewayCode!);
      if (lastTransactionData != null) {
        showAutofillSuggestion = true;
      }
    }
    
    List<FormModel>? tList = model.data?.formData;
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

    await checkTwoFactorStatus();

    isLoading = false;
    update();
  }

  clearData() {
    formList.clear();
  }

  bool submitLoading=false;
  Future<void>submitConfirmDepositRequest() async {

    List<String> list = hasError();
    if (list.isNotEmpty) {
      CustomSnackBar.error(errorList: list);
      return;
    }

    submitLoading=true;
    update();

    AuthorizationResponseModel model = await repo.confirmDepositRequest(trxId,formList,twoFactorCode);
    if(model.status?.toLowerCase() == MyStrings.success.toLowerCase()){
      // Save form data for next time autofill
      if (gatewayCode != null && gatewayName != null) {
        Map<String, dynamic> formDataMap = {};
        
        if (kDebugMode) {
          print('=== SAVING FORM DATA FOR AUTOFILL ===');
          print('Gateway Code: $gatewayCode');
          print('Gateway Name: $gatewayName');
        }
        
        for (var field in formList) {
          String? value;
          if (field.textEditingController != null && field.textEditingController!.text.isNotEmpty) {
            value = field.textEditingController!.text;
          } else if (field.selectedValue != null && field.selectedValue.toString().isNotEmpty) {
            value = field.selectedValue.toString();
          }
          if (value != null && value.isNotEmpty && field.type != 'file') {
            formDataMap[field.name ?? ''] = value;
            if (kDebugMode) {
              print('  ${field.name}: $value (${field.type})');
            }
          }
        }
        
        if (kDebugMode) {
          print('Total fields to save: ${formDataMap.length}');
        }
        
        await repo.saveLastTransactionData(gatewayCode!, gatewayName!, formDataMap);
      }
      
      CustomSnackBar.success(successList:model.message?.success??[MyStrings.requestSuccess]);
      Get.close(1);
      Get.offAndToNamed(RouteHelper.depositScreen);
    }else{
      CustomSnackBar.error(errorList: model.message?.error??[MyStrings.requestFail]);
    }

    submitLoading=false;
    update();
  }

  /// Autofill form with last transaction data
  void applyAutofill() {
    if (lastTransactionData == null) {
      if (kDebugMode) {
        print('❌ No last transaction data available');
      }
      return;
    }
    
    Map<String, dynamic> savedData = lastTransactionData!.formData;
    
    if (kDebugMode) {
      print('=== APPLYING AUTOFILL ===');
      print('Saved data keys: ${savedData.keys}');
      print('Form fields: ${formList.length}');
    }
    
    int filledCount = 0;
    
    for (var field in formList) {
      String fieldName = field.name ?? '';
      
      if (kDebugMode) {
        print('Checking field: $fieldName (type: ${field.type})');
      }
      
      if (savedData.containsKey(fieldName)) {
        String value = savedData[fieldName].toString();
        
        if (kDebugMode) {
          print('  Found saved value: $value');
        }
        
        if (field.type == 'text' || field.type == 'number' || 
            field.type == 'email' || field.type == 'textarea' || 
            field.type == 'url') {
          if (field.textEditingController != null) {
            field.textEditingController!.text = value;
            field.selectedValue = value; // ✅ ALSO UPDATE selectedValue for validation
            filledCount++;
            if (kDebugMode) {
              print('  ✅ Filled text field: $fieldName = $value');
              print('     Also set selectedValue for validation');
            }
          } else {
            if (kDebugMode) {
              print('  ⚠️ Text controller is null for field: $fieldName');
            }
          }
        } else if (field.type == 'select' || field.type == 'radio') {
          field.selectedValue = value;
          filledCount++;
          if (kDebugMode) {
            print('  ✅ Set selected value: $fieldName = $value');
          }
        }
        // Note: We don't autofill file fields or checkbox for security
      } else {
        if (kDebugMode) {
          print('  ⚠️ No saved data for field: $fieldName');
        }
      }
    }
    
    showAutofillSuggestion = false;
    update();
    
    if (kDebugMode) {
      print('=== AUTOFILL COMPLETE ===');
      print('Fields filled: $filledCount');
    }
    
    CustomSnackBar.success(successList: ['Autofilled $filledCount fields with previous details']);
  }

  /// Dismiss autofill suggestion
  void dismissAutofillSuggestion() {
    showAutofillSuggestion = false;
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
          } else if (element.cbSelected!.isEmpty) {
            errorList.add('${element.name} ${MyStrings.isRequired}');
          }
        } else if (element.type == 'file') {
          if (element.file == null) {
            errorList.add('${element.name} ${MyStrings.isRequired}');
          }
        } else {
          if (element.selectedValue == '' || element.selectedValue == selectOne) {
            errorList.add('${element.name} ${MyStrings.isRequired}');
          }
        }
      }
    }
    return errorList;
  }

  bool isTFAEnable = false;
  Future<void>checkTwoFactorStatus()async{
    ProfileResponseModel model = await profileRepo.loadProfileInfo();
    if(model.status?.toLowerCase()==MyStrings.success.toLowerCase()){
      isTFAEnable = model.data?.user?.ts=='1'?true:false;
    }
  }


  void changeSelectedValue(value, int index) {
    formList[index].selectedValue = value;
    update();
  }

  void changeSelectedRadioBtnValue(int listIndex, int selectedIndex) {
    formList[listIndex].selectedValue = formList[listIndex].options?[selectedIndex];
    update();
  }

  void changeSelectedCheckBoxValue(int listIndex, String value) {

    print("vvvvvvvvvvv ---- ${value}");

    List<String> list = value.split('_');
    print(list);
    int index = int.parse(list[0]);
    bool status = list[1] == 'true' ? true : false;

    List<String>? selectedValue = formList[listIndex].cbSelected;

    print(selectedValue);

    if (selectedValue != null) {

      String? value = formList[listIndex].options?[index];
      print(value);

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

  void changeSelectedFile(File file, int index) {
    formList[index].file = file;
    update();
  }

  void pickFile(int index) async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx']
    );

    if (result == null) return;

    formList[index].file = File(result.files.single.path!);
    String fileName = result.files.single.name;
    formList[index].selectedValue = fileName;
    update();
    return;
  }

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

        formList[index].selectedValue = DateConverter.estimatedDateTime(selectedDateTime);
        // formList[index].selectedValue = selectedDateTime.toIso8601String();
        formList[index].textEditingController?.text = DateConverter.estimatedDateTime(selectedDateTime);
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
      formList[index].selectedValue = DateConverter.estimatedDate(pickedDate);
      formList[index].textEditingController?.text = DateConverter.estimatedDate(pickedDate);
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

      formList[index].selectedValue = DateConverter.estimatedTime(selectedDateTime);
      formList[index].textEditingController?.text = DateConverter.estimatedTime(selectedDateTime);
      print(formList[index].textEditingController?.text);
      update();
    }

    update();
  }


}
