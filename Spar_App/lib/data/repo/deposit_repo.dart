import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:hyip_lab/core/utils/method.dart' as method;
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/auth/login/login_response_model.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_history_response_model.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_insert_method.dart';
import 'package:hyip_lab/data/model/authorized/deposit/deposit_insert_response_model.dart';
import 'package:hyip_lab/data/model/authorized/deposit/last_transaction_data.dart';
import 'package:hyip_lab/data/model/authorization/authorization_response_model.dart';
import 'package:hyip_lab/data/repo/kyc/kyc_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../view/components/show_custom_snackbar.dart';
import '../model/global/response_model/response_model.dart';
import '../services/api_service.dart';

class DepositRepo {
  ApiClient apiClient;
  DepositRepo({required this.apiClient});
  Future<dynamic> getDepositHistory(
      {int page = -1, bool isSearch = false, String? trx = '-1'}) async {
    Map<String, dynamic> params = isSearch ? {'search': trx} : {'page': page};

    String url =
        '${UrlContainer.baseUrl}${UrlContainer.depositHistoryUrl}${isSearch ? '?search=$trx' : '?page=$page'}';
    ResponseModel response = await apiClient
        .request(url, method.Method.getMethod, params, passHeader: true);

    if (kDebugMode) {
      print(response.responseJson);
      print(response.statusCode);
    }

    if (response.statusCode == 200) {
      DepositHistoryResponseModel model = DepositHistoryResponseModel.fromJson(
          jsonDecode(response.responseJson));
      if (!(model.status == 'error')) {
        return model;
      } else {
        CustomSnackBar.showCustomSnackBar(
            errorList: model.message?.error ?? ['Unknown Validation Error'],
            msg: [],
            isError: true);
        return model;
      }
    } else {
      return DepositHistoryResponseModel();
    }
  }

  Future<dynamic> getDepositMethod() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.depositMethodUrl}';
    ResponseModel response = await apiClient
        .request(url, method.Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<dynamic> insertDeposit(DepositInsertModel model) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.depositInsertUrl}';

    Map<String, dynamic> param = {
      'method_code': model.methodCode.toString(),
      'amount': model.amount.toString(),
      'currency': model.currency
    };

    if (kDebugMode) {
      print('=== DEPOSIT INSERT REQUEST ===');
      print('URL: $url');
      print('Params: $param');
      print('==============================');
    }

    ResponseModel response = await apiClient
        .request(url, method.Method.postMethod, param, passHeader: true);

    if (kDebugMode) {
      print('=== DEPOSIT INSERT API RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Message: ${response.message}');
      print('Response JSON: ${response.responseJson}');
      print('===================================');
    }

    if (response.statusCode == 200) {
      // Debug: Print raw JSON response
      if (kDebugMode) {
        print('=== RAW DEPOSIT INSERT RESPONSE ===');
        print(response.responseJson);
        print('===================================');
      }

      DepositInsertResponseModel model = DepositInsertResponseModel.fromJson(
          jsonDecode(response.responseJson));

      if (model.message?.success != null) {
        return model;
      } else {
        CustomSnackBar.showCustomSnackBar(
            errorList:
                model.message?.error ?? [MyStrings.somethingWentWrong.tr],
            msg: [],
            isError: true);
        return model;
      }
    } else {
      // Show error message from API response
      if (kDebugMode) {
        print('❌ API Error: Status ${response.statusCode}');
      }
      CustomSnackBar.error(errorList: [response.message]);
      return DepositInsertResponseModel();
    }
  }

  Future<dynamic> getUserInfo() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}';
    ResponseModel response = await apiClient
        .request(url, method.Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> submitInvestment(Map<String, dynamic> params) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.investStoreUrl}';
    ResponseModel model = await apiClient
        .request(url, method.Method.postMethod, params, passHeader: true);
    return model;
  }

  List<Map<String, String>> fieldList = [];
  List<ModelDynamicValue> filesList = [];

  Future<dynamic> confirmDepositRequest(
      String trx, List<FormModel> list, String twoFactorCode) async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.depositRequestConfirm}';

    if (kDebugMode) {
      print('=== CONFIRM DEPOSIT REQUEST ===');
      print('URL: $url');
      print('Track/Trx: $trx');
      print('Form fields count: ${list.length}');
    }

    apiClient.initToken();
    await modelToMap(list);

    var request = http.MultipartRequest('POST', Uri.parse(url));

    Map<String, String> finalMap = {};

    for (var element in fieldList) {
      finalMap.addAll(element);
    }

    request.headers
        .addAll(<String, String>{'Authorization': 'Bearer ${apiClient.token}'});

    // Add files using proper async method with explicit content type
    for (var file in filesList) {
      if (kDebugMode) {
        print('Adding file: ${file.key}');
        print('File path: ${file.value.path}');
        print('File exists: ${file.value.existsSync()}');
        print('File size: ${file.value.lengthSync()} bytes');
      }

      try {
        // Detect content type from file extension
        String? contentType;
        String filePath = file.value.path.toLowerCase();
        if (filePath.endsWith('.jpg') || filePath.endsWith('.jpeg')) {
          contentType = 'image/jpeg';
        } else if (filePath.endsWith('.png')) {
          contentType = 'image/png';
        } else if (filePath.endsWith('.gif')) {
          contentType = 'image/gif';
        } else if (filePath.endsWith('.pdf')) {
          contentType = 'application/pdf';
        } else if (filePath.endsWith('.doc')) {
          contentType = 'application/msword';
        } else if (filePath.endsWith('.docx')) {
          contentType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        }

        var multipartFile = await http.MultipartFile.fromPath(
          file.key ?? 'file',
          file.value.path,
          contentType: contentType != null
              ? http_parser.MediaType.parse(contentType)
              : null,
        );
        request.files.add(multipartFile);

        if (kDebugMode) {
          print('✅ File added successfully: ${file.key}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error adding file ${file.key}: $e');
        }
      }
    }

    // Use 'track' as parameter name (backend expects 'track', not 'trx')
    request.fields.addAll({'track': trx});

    if (twoFactorCode.isNotEmpty) {
      request.fields.addAll({'authenticator_code': twoFactorCode});
    }

    request.fields.addAll(finalMap);

    if (kDebugMode) {
      print('Request fields: ${request.fields}');
      print('Request files: ${request.files.length}');
      for (var file in request.files) {
        print(
            '  - ${file.field}: ${file.filename} (${file.length} bytes, ${file.contentType})');
      }
      print('Request headers: ${request.headers}');
      print('================================');
    }

    http.StreamedResponse response = await request.send();
    String jsonResponse = await response.stream.bytesToString();

    if (kDebugMode) {
      print('=== CONFIRM DEPOSIT RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Response: $jsonResponse');
      print('================================');
    }

    // Handle error responses (non-200 status codes)
    if (response.statusCode != 200) {
      var errorData = jsonDecode(jsonResponse);
      List<String> errorList = [];

      // Handle validation errors (422 status)
      if (response.statusCode == 422 && errorData['errors'] != null) {
        // Laravel validation errors format
        Map<String, dynamic> errors = errorData['errors'];
        errors.forEach((key, value) {
          if (value is List) {
            errorList.addAll(value.cast<String>());
          }
        });
      }
      // Handle general errors (500, 400, etc.)
      else if (errorData['message'] != null) {
        errorList.add(errorData['message'].toString());
      } else {
        errorList.add('Server error occurred. Please try again.');
      }

      return AuthorizationResponseModel(
        remark: 'error',
        status: 'error',
        message: Message(error: errorList),
      );
    }

    AuthorizationResponseModel model =
        AuthorizationResponseModel.fromJson(jsonDecode(jsonResponse));

    return model;
  }

  Future<dynamic> modelToMap(List<FormModel> list) async {
    // Clear previous data
    fieldList.clear();
    filesList.clear();

    for (var e in list) {
      if (kDebugMode) {
        print('Processing field: ${e.name} (${e.type})');
      }

      if (e.type == 'checkbox') {
        if (e.cbSelected != null && e.cbSelected!.isNotEmpty) {
          for (int i = 0; i < e.cbSelected!.length; i++) {
            fieldList.add({'${e.name}[$i]': e.cbSelected![i]});
          }
        }
      } else if (e.type == 'file') {
        if (e.file != null) {
          filesList.add(ModelDynamicValue(e.name, e.file!));
          if (kDebugMode) {
            print('Added file: ${e.name}');
          }
        }
      } else {
        // Use textEditingController.text for text fields, selectedValue for others
        String? value;
        if (e.textEditingController != null &&
            e.textEditingController!.text.isNotEmpty) {
          value = e.textEditingController!.text;
        } else if (e.selectedValue != null &&
            e.selectedValue.toString().isNotEmpty) {
          value = e.selectedValue.toString();
        }

        if (value != null && value.isNotEmpty) {
          fieldList.add({e.name ?? '': value});
          if (kDebugMode) {
            print('Added field: ${e.name} = $value');
          }
        }
      }
    }

    if (kDebugMode) {
      print('Total fields: ${fieldList.length}');
      print('Total files: ${filesList.length}');
    }
  }

  // ==================== AUTOFILL FEATURE ====================
  
  /// Save last transaction data for autofill
  Future<void> saveLastTransactionData(
    String gatewayCode,
    String gatewayName,
    Map<String, dynamic> formData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTransaction = LastTransactionData(
        gatewayCode: gatewayCode,
        gatewayName: gatewayName,
        formData: formData,
        lastUsed: DateTime.now(),
        displaySummary: LastTransactionData.generateSummary(formData),
      );
      
      String key = 'last_transaction_$gatewayCode';
      await prefs.setString(key, lastTransaction.toJsonString());
      
      if (kDebugMode) {
        print('✅ Saved last transaction data for $gatewayName');
        print('Summary: ${lastTransaction.displaySummary}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving last transaction: $e');
      }
    }
  }

  /// Get last transaction data for autofill
  Future<LastTransactionData?> getLastTransactionData(String gatewayCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String key = 'last_transaction_$gatewayCode';
      String? jsonString = prefs.getString(key);
      
      if (jsonString != null) {
        LastTransactionData data = LastTransactionData.fromJsonString(jsonString);
        if (kDebugMode) {
          print('✅ Found last transaction data for gateway $gatewayCode');
          print('Summary: ${data.displaySummary}');
          print('Last used: ${data.lastUsed}');
        }
        return data;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading last transaction: $e');
      }
    }
    return null;
  }

  /// Clear last transaction data
  Future<void> clearLastTransactionData(String gatewayCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String key = 'last_transaction_$gatewayCode';
      await prefs.remove(key);
      if (kDebugMode) {
        print('✅ Cleared last transaction data for gateway $gatewayCode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing last transaction: $e');
      }
    }
  }
}
