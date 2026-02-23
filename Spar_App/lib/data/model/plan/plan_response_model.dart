import '../auth/sign_up_model/registration_response_model.dart';
import '../authorized/deposit/deposit_insert_response_model.dart' as deposit;

class PlanResponseModel {
  PlanResponseModel({
    String? remark,
    String? status,
    Message? message,
    Data? data,
  }) {
    _remark = remark;
    _status = status;
    _message = message;
    _data = data;
  }

  PlanResponseModel.fromJson(dynamic json) {
    _remark = json['remark'];
    _status = json['status'];
    _message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
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
    List<deposit.FormModel>? formData,
    String? depositInstruction,
  }) {
    _redirectUrl = redirectUrl;
    _track = track;
    _isManual = isManual;
    _formData = formData;
    _depositInstruction = depositInstruction;
  }

  Data.fromJson(dynamic json) {
    _redirectUrl = json['redirect_url'];
    _track = json['track'];
    _isManual = json['is_manual'];

    // Parse deposit instructions (can be at root level or nested)
    _depositInstruction = json['deposit_instruction'] ??
        json['instruction'] ??
        json['deposit']?['gateway']?['description'] ??
        json['deposit']?['gateway']?['user_data'] ??
        json['user_data'];

    // Parse form_data if present in various shapes
    if (json['form_data'] != null) {
      _formData = [];
      final fd = json['form_data'];
      if (fd is List) {
        for (final v in fd) {
          _formData?.add(deposit.FormModel(
            v['name'],
            v['label'],
            v['is_required'],
            v['instruction'],
            v['extensions'],
            v['options'] != null ? List<String>.from(v['options']) : [],
            v['type'],
            '',
          ));
        }
      } else if (fd is Map) {
        fd.forEach((key, v) {
          final String fieldName = key.toString();
          final String displayLabel = v['label'] ?? v['name'] ?? fieldName;
          _formData?.add(deposit.FormModel(
            fieldName,
            displayLabel,
            v['is_required'] ?? 'optional',
            v['instruction'] ?? '',
            v['extensions'] ?? '',
            v['options'] != null ? List<String>.from(v['options']) : [],
            v['type'] ?? 'text',
            '',
          ));
        });
      }
    } else if (json['deposit'] != null &&
        json['deposit']['gateway'] != null &&
        json['deposit']['gateway']['form'] != null &&
        json['deposit']['gateway']['form']['form_data'] != null) {
      // Fallback to nested structure
      final formData = json['deposit']['gateway']['form']['form_data'];
      _formData = [];
      if (_track == null || _track!.isEmpty) {
        _track = json['deposit']['trx'];
      }
      if (_isManual == null) {
        final methodCode =
            int.tryParse(json['deposit']['method_code'].toString());
        _isManual = methodCode != null ? methodCode >= 1000 : _isManual;
      }
      if (formData is Map) {
        formData.forEach((key, v) {
          final String fieldName = key.toString();
          final String displayLabel = v['label'] ?? v['name'] ?? fieldName;
          _formData?.add(deposit.FormModel(
            fieldName,
            displayLabel,
            v['is_required'] ?? 'optional',
            v['instruction'] ?? '',
            v['extensions'] ?? '',
            v['options'] != null ? List<String>.from(v['options']) : [],
            v['type'] ?? 'text',
            '',
          ));
        });
      } else if (formData is List) {
        for (final v in formData) {
          _formData?.add(deposit.FormModel(
            v['name'],
            v['label'],
            v['is_required'],
            v['instruction'],
            v['extensions'],
            v['options'] != null ? List<String>.from(v['options']) : [],
            v['type'],
            '',
          ));
        }
      }
    }
  }
  String? _redirectUrl;
  String? _track;
  bool? _isManual;
  List<deposit.FormModel>? _formData;
  String? _depositInstruction;

  String? get redirectUrl => _redirectUrl ?? '';
  String? get track => _track;
  bool? get isManual => _isManual;
  List<deposit.FormModel>? get formData => _formData;
  String? get depositInstruction => _depositInstruction;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['redirect_url'] = _redirectUrl;
    map['track'] = _track;
    map['is_manual'] = _isManual;
    if (_formData != null) {
      map['form_data'] = _formData?.map((v) => v.toJson()).toList();
    }
    map['deposit_instruction'] = _depositInstruction;
    return map;
  }
}
