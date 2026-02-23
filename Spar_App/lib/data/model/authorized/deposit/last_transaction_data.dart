import 'dart:convert';

/// Model to store last transaction form data for autofill
class LastTransactionData {
  final String gatewayCode;
  final String gatewayName;
  final Map<String, dynamic> formData;
  final DateTime lastUsed;
  final String? displaySummary; // e.g., "HDFC Bank - Account ending 9012"

  LastTransactionData({
    required this.gatewayCode,
    required this.gatewayName,
    required this.formData,
    required this.lastUsed,
    this.displaySummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'gatewayCode': gatewayCode,
      'gatewayName': gatewayName,
      'formData': formData,
      'lastUsed': lastUsed.toIso8601String(),
      'displaySummary': displaySummary,
    };
  }

  factory LastTransactionData.fromJson(Map<String, dynamic> json) {
    return LastTransactionData(
      gatewayCode: json['gatewayCode'],
      gatewayName: json['gatewayName'],
      formData: Map<String, dynamic>.from(json['formData']),
      lastUsed: DateTime.parse(json['lastUsed']),
      displaySummary: json['displaySummary'],
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory LastTransactionData.fromJsonString(String jsonString) {
    return LastTransactionData.fromJson(jsonDecode(jsonString));
  }

  /// Generate a display summary from form data
  static String generateSummary(Map<String, dynamic> formData) {
    List<String> parts = [];
    
    // Look for common bank field names
    final bankNameFields = ['bank_name', 'bankname', 'bank', 'gateway'];
    final accountFields = ['account_number', 'account', 'acc_number', 'account_no'];
    
    String? bankName;
    String? accountNumber;
    
    // Find bank name
    for (var field in bankNameFields) {
      if (formData.containsKey(field) && formData[field] != null && formData[field].toString().isNotEmpty) {
        bankName = formData[field].toString();
        break;
      }
    }
    
    // Find account number
    for (var field in accountFields) {
      if (formData.containsKey(field) && formData[field] != null && formData[field].toString().isNotEmpty) {
        accountNumber = formData[field].toString();
        break;
      }
    }
    
    // Build summary
    if (bankName != null) {
      parts.add(bankName);
    }
    
    if (accountNumber != null && accountNumber.length > 4) {
      // Show last 4 digits
      String lastFour = accountNumber.substring(accountNumber.length - 4);
      parts.add('Account ending $lastFour');
    }
    
    return parts.isNotEmpty ? parts.join(' - ') : 'Last used details';
  }
}
