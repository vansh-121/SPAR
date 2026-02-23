import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../auth/sign_up_model/registration_response_model.dart';

class DepositInsertResponseModel {
  DepositInsertResponseModel({
      String? remark, 
      String? status, 
      Message? message, 
      Data? data,}){
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
}

  DepositInsertResponseModel.fromJson(dynamic json) {
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
      String? redirectUrl,
      String? track,
      bool? isManual,
      List<FormModel>? formData,
      DepositData? deposit,
      String? methodName,
      String? methodCurrency,
      String? amount,
      String? charge,
      String? payable,
      String? finalAmount,
      String? rate,
      String? depositInstruction,
      String? userData,
  }){
    _redirectUrl = redirectUrl;
    _track = track;
    _isManual = isManual;
    _formData = formData;
    _deposit = deposit;
    _methodName = methodName;
    _methodCurrency = methodCurrency;
    _amount = amount;
    _charge = charge;
    _payable = payable;
    _finalAmount = finalAmount;
    _rate = rate;
    _depositInstruction = depositInstruction;
    _userData = userData;
}

  Data.fromJson(dynamic json) {
    if (kDebugMode) {
      print('🔍 Parsing Data.fromJson...');
      print('JSON keys: ${json.keys}');
      print('Has form_data at root: ${json['form_data'] != null}');
      print('Has deposit: ${json['deposit'] != null}');
      print('Has is_manual: ${json['is_manual'] != null}');
      print('Has track: ${json['track'] != null}');
    }
    
    _redirectUrl = json['redirect_url'];
    _track = json['track'];
    _isManual = json['is_manual'];
    
    // NEW BACKEND: Parse form_data array if present at root level (must be a List, not nested in deposit)
    if (json['form_data'] != null && json['form_data'] is List && json['is_manual'] == true) {
      if (kDebugMode) {
        print('✅ Found NEW backend structure (form_data array at root)');
      }
      _formData = [];
      (json['form_data'] as List).forEach((v) {
        _formData?.add(FormModel(
          v['name'],
          v['label'],
          v['is_required'],
          v['instruction'],
          v['extensions'],
          v['options'] != null ? List<String>.from(v['options']) : [],
          v['type'],
          '',
        ));
      });
    }
    // OLD BACKEND: Parse form_data from nested structure deposit.gateway.form.form_data
    else if (json['deposit'] != null && 
             json['deposit']['gateway'] != null && 
             json['deposit']['gateway']['form'] != null && 
             json['deposit']['gateway']['form']['form_data'] != null) {
      
      if (kDebugMode) {
        print('✅ Found OLD backend structure (nested form_data)');
      }
      
      var formData = json['deposit']['gateway']['form']['form_data'];
      _formData = [];
      _track = json['deposit']['trx']; // Use trx as track
      _isManual = json['deposit']['method_code'] >= 1000; // Detect manual gateway
      
      if (kDebugMode) {
        print('Track: $_track');
        print('IsManual: $_isManual (method_code: ${json['deposit']['method_code']})');
        print('FormData type: ${formData.runtimeType}');
      }
      
      if (formData is Map) {
        try {
          // Convert Map to entries and iterate
          (formData as Map<String, dynamic>).forEach((String key, dynamic v) {
            if (kDebugMode) {
              print('Parsing field key: $key');
              print('Field data: $v');
            }
            if (v is Map) {
              // The key in the Map IS the field name to use for submission
              // Use key as name, and v['name'] or v['label'] as display label
              String fieldName = key; // This is the actual field name for backend
              String displayLabel = v['label'] ?? v['name'] ?? key;
              
              if (kDebugMode) {
                print('Created field: name=$fieldName, label=$displayLabel, type=${v['type']}');
              }
              
              _formData?.add(FormModel(
                fieldName,  // Use the map key as the field name
                displayLabel,  // Use label for display
                v['is_required'] ?? 'optional',
                v['instruction'] ?? '',
                v['extensions'] ?? '',
                v['options'] != null ? List<String>.from(v['options']) : [],
                v['type'] ?? 'text',
                '',
              ));
            }
          });
          if (kDebugMode) {
            print('✅ Parsed ${_formData?.length ?? 0} form fields');
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing form fields: $e');
          }
        }
      }
    } else {
      if (kDebugMode) {
        print('⚠️ No form data found in response');
      }
    }
    
    _deposit = json['deposit'] != null ? DepositData.fromJson(json['deposit']) : null;
    _methodName = json['method_name'] ?? json['deposit']?['gateway']?['name'];
    _methodCurrency = json['method_currency'] ?? json['deposit']?['method_currency'];
    _amount = json['amount']?.toString() ?? json['deposit']?['amount']?.toString();
    _charge = json['charge']?.toString() ?? json['deposit']?['charge']?.toString();
    _payable = json['payable']?.toString() ?? json['deposit']?['final_amount']?.toString();
    _finalAmount = json['final_amount']?.toString() ?? json['deposit']?['final_amount']?.toString();
    _rate = json['rate']?.toString() ?? json['deposit']?['rate']?.toString();
    
    // Parse deposit instructions (can be at root level or in deposit.gateway)
    _depositInstruction = json['deposit_instruction'] ?? 
                         json['instruction'] ?? 
                         json['deposit']?['gateway']?['description'] ?? 
                         json['deposit']?['gateway']?['user_data'] ??
                         json['user_data'];
    _userData = json['user_data'] ?? json['deposit']?['gateway']?['user_data'];
    
    if (kDebugMode) {
      print('📝 Deposit Instruction: $_depositInstruction');
      print('👤 User Data: $_userData');
    }
  }
  
  String? _redirectUrl;
  String? _track;
  bool? _isManual;
  List<FormModel>? _formData;
  DepositData? _deposit;
  String? _methodName;
  String? _methodCurrency;
  String? _amount;
  String? _charge;
  String? _payable;
  String? _finalAmount;
  String? _rate;
  String? _depositInstruction;
  String? _userData;

  String? get redirectUrl => _redirectUrl;
  String? get track => _track;
  bool? get isManual => _isManual;
  List<FormModel>? get formData => _formData;
  DepositData? get deposit => _deposit;
  String? get methodName => _methodName;
  String? get methodCurrency => _methodCurrency;
  String? get amount => _amount;
  String? get charge => _charge;
  String? get payable => _payable;
  String? get finalAmount => _finalAmount;
  String? get rate => _rate;
  String? get depositInstruction => _depositInstruction;
  String? get userData => _userData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['redirect_url'] = _redirectUrl;
    map['track'] = _track;
    map['is_manual'] = _isManual;
    if (_formData != null) {
      map['form_data'] = _formData?.map((v) => v.toJson()).toList();
    }
    if (_deposit != null) {
      map['deposit'] = _deposit?.toJson();
    }
    map['method_name'] = _methodName;
    map['method_currency'] = _methodCurrency;
    map['amount'] = _amount;
    map['charge'] = _charge;
    map['payable'] = _payable;
    map['final_amount'] = _finalAmount;
    map['rate'] = _rate;
    map['deposit_instruction'] = _depositInstruction;
    map['user_data'] = _userData;
    return map;
  }

}

class Form {
  Form({List<FormModel>? list}) {
    _list = list;
  }

  List<FormModel>? _list=[];

  List<FormModel>? get list => _list;

  Form.fromJson(dynamic json) {
    try {
      _list = [];
      if(json is List<dynamic>){
        for (var e in json) {
          _list?.add(FormModel(
              e.value['name'],
              e.value['label'],
              e.value['is_required'],
              e.value['extensions'],
              e.value['instruction'],
              (e.value['options'] as List).map((e) => e as String).toList(),
              e.value['type'],
              ''
          ));
        }
        _list;
      } else{
        var map = Map.from(json).map((k, v) => MapEntry<String, dynamic>(k, v));
        List<FormModel>? list = map.entries
            .map((e) => FormModel(
            e.value['name'],
            e.value['label'],
            e.value['is_required'],
            e.value['instruction'],
            e.value['extensions'],
            (e.value['options'] as List).map((e) => e as String).toList(),
            e.value['type'],
            ''
        ),).toList();
        if (list.isNotEmpty) {
          list.removeWhere((element) => element.toString().isEmpty);
          _list?.addAll(list);
        }
        _list;
      }
    }catch(e){
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_list != null) {
      map['list'] = _list;
    }
    return map;
  }
}


class FormModel {
  String? name;
  String? label;
  String? isRequired;
  String? instruction;
  String? extensions;
  List<String>? options;
  String? type;
  dynamic selectedValue;
  TextEditingController? textEditingController;
  File? file;
  List<String>?cbSelected;

  FormModel(this.name, this.label, this.isRequired, this.instruction,  this.extensions,
      this.options, this.type,this.selectedValue,{this.cbSelected,this.file}){
    textEditingController ??= TextEditingController();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['label'] = label;
    map['is_required'] = isRequired;
    map['instruction'] = instruction;
    map['extensions'] = extensions;
    map['options'] = options;
    map['type'] = type;
    return map;
  }
}


class DepositData {
  DepositData({
    String? methodId,
    int? methodCode,
    String? userId,
    String? amount,
    String? methodCurrency,
    String? charge,
    String? rate,
    String? finalAmo,
    String? trx,
    String? updatedAt,
    String? createdAt,
    int? id,
  }) {
    _methodId     = methodId;
    _methodCode   = methodCode;
    _userId       = userId;
    _amount       = amount;
    _methodCurrency = methodCurrency;
    _charge       = charge;
    _rate         = rate;
    _finalAmo     = finalAmo;
    _trx          = trx;
    _updatedAt    = updatedAt;
    _createdAt    = createdAt;
    _id           = id;
  }

  DepositData.fromJson(dynamic json) {
    _methodId       = json['method_id']?.toString();
    _methodCode     = int.tryParse(json['method_code']?.toString() ?? '0') ?? 0;
    _userId         = json['user_id']?.toString();
    _amount         = json['amount']?.toString();
    _methodCurrency = json['method_currency']?.toString();
    _charge         = json['charge']?.toString();
    _rate           = json['rate']?.toString();
    _finalAmo       = json['final_amo']?.toString() ?? json['final_amount']?.toString();
    _trx            = json['trx']?.toString();
    _updatedAt      = json['updated_at'];
    _createdAt      = json['created_at'];
    _id             = json['id'];
  }

  String? _methodId;
  int? _methodCode;
  String? _userId;
  String? _amount;
  String? _methodCurrency;
  String? _charge;
  String? _rate;
  String? _finalAmo;
  String? _trx;
  String? _updatedAt;
  String? _createdAt;
  int? _id;

  String? get methodId => _methodId;
  int? get methodCode => _methodCode;
  String? get userId => _userId;
  String? get amount => _amount;
  String? get methodCurrency => _methodCurrency;
  String? get charge => _charge;
  String? get rate => _rate;
  String? get finalAmo => _finalAmo;
  String? get trx => _trx;
  String? get updatedAt => _updatedAt;
  String? get createdAt => _createdAt;
  int? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['method_id'] = _methodId;
    map['method_code'] = _methodCode;
    map['user_id'] = _userId;
    map['amount'] = _amount;
    map['method_currency'] = _methodCurrency;
    map['charge'] = _charge;
    map['rate'] = _rate;
    map['final_amo'] = _finalAmo;
    map['trx'] = _trx;
    map['updated_at'] = _updatedAt;
    map['created_at'] = _createdAt;
    map['id'] = _id;
    return map;
  }
}

