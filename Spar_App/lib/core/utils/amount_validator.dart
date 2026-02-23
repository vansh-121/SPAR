/// Utility class for validating amount inputs
class AmountValidator {
  /// Validates that the amount is a multiple of 100
  /// Returns error message if invalid, null if valid
  static String? validateHundredDenomination(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    if (amount % 100 != 0) {
      return 'Amount must be in multiples of 100 (e.g., 100, 200, 4700, 4800)';
    }

    return null;
  }

  /// Checks if an amount is a valid multiple of 100
  static bool isValidHundredDenomination(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }

    final amount = double.tryParse(value);
    
    if (amount == null || amount <= 0) {
      return false;
    }

    return amount % 100 == 0;
  }
}
