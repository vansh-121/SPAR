# Interest Calculation Documentation

## Overview

The Rise App calculates interest in two ways depending on the investment plan type:
1. **Simple Interest** - Linear return calculation
2. **Compound Interest** - Exponential return calculation

---

## 1. Simple Interest Calculation

### Formula
```
Total Amount = Principal + (Principal × Rate × Time / 100)
```

Or for quick reference:
```
Interest Amount = (Principal × Interest Rate) / 100
Total Return = Principal + Interest Amount
```

### Implementation
**File**: `lib/data/controller/staking/staking_controller.dart` (Line 203)

```dart
void calculateReturnAmount(String value) {
  double userInputAmount = double.tryParse(value) ?? 0.0;
  double interest = double.tryParse(selectedStak?.interestPercent ?? "0.0") ?? 0.0;
  
  // Calculate interest amount
  double amount = (userInputAmount * interest) / 100;
  
  // Total = Principal + Interest
  returnAmount = Converter.twoDecimalPlaceFixedWithoutRounding("${amount + userInputAmount}");
  update();
}
```

### Example
- **Principal**: $1,000
- **Interest Rate**: 10%
- **Interest Earned**: (1,000 × 10) / 100 = $100
- **Total Return**: $1,000 + $100 = **$1,100**

---

## 2. Compound Interest Calculation

### Formula
```
Annual Rate (Compound) = (1 + monthlyRate)^12 - 1
```

In percentage:
```
Annual Percent = [(1 + (monthlyRate/100))^12 - 1] × 100
```

### Implementation
**File**: `lib/data/controller/plan/plan_controller.dart` (Lines 100-127)

```dart
double _calculateCompoundAnnual(double monthlyPercent) {
  // Convert percentage to decimal (e.g., 2% → 0.02)
  final monthlyDecimal = monthlyPercent / 100;
  
  // Apply compound interest formula: (1 + rate)^12 - 1
  final effective = pow(1 + monthlyDecimal, 12) - 1;
  
  // Convert back to percentage
  return effective * 100;
}
```

### Step-by-Step Example
- **Monthly Rate**: 2%
- **Step 1**: Convert to decimal: 0.02
- **Step 2**: Calculate compound: (1.02)^12 = 1.26824
- **Step 3**: Subtract 1: 1.26824 - 1 = 0.26824
- **Step 4**: Convert to percentage: 0.26824 × 100 = **26.82% annually**

### Comparison: Simple vs Compound
For a 2% monthly rate:
- **Simple Interest**: 2% × 12 = **24% annually**
- **Compound Interest**: **26.82% annually** (difference: +2.82%)

---

## 3. Data Structure

### Staking Model
**File**: `lib/data/model/staking/staking_response_model.dart`

```dart
class Staking {
  int? id;                    // Staking plan ID
  String? days;              // Duration in days
  String? interestPercent;   // Interest rate (e.g., "10.5")
  String? status;            // Plan status (active/inactive)
}
```

### User's Active Staking
**File**: `lib/data/model/staking/staking_response_model.dart`

```dart
class MyStakings {
  int? id;                  // Staking record ID
  String? investAmount;     // Principal invested
  String? interest;         // Earned interest (already calculated by backend)
  String? endAt;           // Maturity date
  String? status;          // Status (active/completed)
}
```

### Plan Model
**File**: `lib/data/model/plan/plan_model.dart`

```dart
class Plans {
  String? return_;           // Interest rate (e.g., "5%", "0.5%")
  String? interestDuration;  // Duration type ("Monthly", "Daily", etc.)
  String? repeatTime;        // Repeat frequency
  String? compoundInterest;  // "1" for compound, "0" for simple
  String? holdCapital;       // "1" if capital is reinvested
}
```

---

## 4. Interest Calculation by Plan Type

### Monthly Plans with Compound Interest

**File**: `lib/data/controller/plan/plan_controller.dart` (Line 100-120)

```dart
String getPlanDescription(int index) {
  final plan = planList[index];
  final bool isCompound = plan.compoundInterest == '1';
  final double? monthlyPercent = _extractMonthlyPercentage(plan);

  if (monthlyPercent != null && _isMonthlyPlan(plan)) {
    final double annualPercent = isCompound
        ? _calculateCompoundAnnual(monthlyPercent)  // Compound
        : _calculateSimpleAnnual(monthlyPercent);   // Simple (12 × monthly)

    return 'Earn returns of upto $formattedAnnual% annually.';
  }
}
```

### Logic Flow
1. **Extract Rate**: Parse interest rate from plan (e.g., "2%" → 2.0)
2. **Check Plan Type**:
   - If `compoundInterest == "1"`: Use compound formula
   - If `compoundInterest == "0"`: Use simple formula (monthly × 12)
3. **Calculate Annual**: Convert to annualized percentage
4. **Display**: Show as "Earn returns of upto X% annually"

---

## 5. Real-World Scenarios

### Scenario 1: Fixed Staking (Simple Interest)
```
Investment: $10,000
Rate: 10% per annum
Duration: 1 year

Interest Earned: (10,000 × 10) / 100 = $1,000
Total Amount: $10,000 + $1,000 = $11,000
```

**UI Display**:
- Invested Amount: $10,000
- Interest Earned: $1,000
- Total: $11,000

---

### Scenario 2: Monthly Plan (Compound Interest)
```
Investment: $10,000
Monthly Rate: 2%
Duration: 1 year (compounded monthly)

Annual Rate: (1.02)^12 - 1 = 26.82%
Interest Earned: $10,000 × 0.2682 = $2,682
Total Amount: $10,000 + $2,682 = $12,682
```

**UI Display**:
- Monthly Rate: 2%
- "Earn returns of upto 26.82% annually"
- After 1 year total: $12,682

---

### Scenario 3: Capital Reinvestment
```
When holdCapital == "1":
Interest is automatically reinvested as principal
Each period earns interest on (original principal + accumulated interest)

Month 1: $10,000 × 2% = $200
Month 2: ($10,000 + $200) × 2% = $204
Month 3: ($10,200 + $204) × 2% = $208.08
... and so on
```

---

## 6. Backend vs Frontend Calculation

### Backend Responsibility
- **Stores**: Pre-calculated interest amount for each user staking
- **File**: API returns `myStakings.interest` already calculated

```dart
class MyStakings {
  String? investAmount;  // e.g., "10000"
  String? interest;      // e.g., "1000" (already calculated by backend)
}
```

### Frontend Responsibility
- **Displays**: User's earned interest + invested amount
- **Calculates**: Projected returns for hypothetical investments
- **Shows**: Plan descriptions with annual percentages

```dart
// Display actual staking
String totalAmount = Converter.sum(
  myStaking.investAmount ?? '0.0',
  myStaking.interest ?? '0.0'
);  // Shows: $11,000

// Calculate hypothetical return for new investment
void calculateReturnAmount(String value) {
  // ... calculates what user would earn for input amount
}
```

---

## 7. File Reference Guide

| File | Purpose | Key Method |
|------|---------|-----------|
| `staking_controller.dart` | Staking calculations | `calculateReturnAmount()` |
| `plan_controller.dart` | Plan interest rates | `_calculateCompoundAnnual()` |
| `staking_response_model.dart` | Data structures | `MyStakings` class |
| `plan_model.dart` | Plan details | `Plans` class |
| `shedule_response_model.dart` | Scheduled investments | `SheduleResponse` class |

---

## 8. Utility Functions

### Amount Formatting
**File**: `lib/core/utils/converter.dart`

```dart
// Prevents rounding issues
Converter.twoDecimalPlaceFixedWithoutRounding(amount.toString())

// Adds amounts together
Converter.sum(amount1, amount2)
```

---

## 9. Common Formulas Reference

| Type | Formula | Result |
|------|---------|--------|
| Simple Interest | `(Principal × Rate) / 100` | Interest amount |
| Simple Annual | `monthlyRate × 12` | Annual % |
| Compound Annual | `(1 + rate)^12 - 1` | Annual % |
| Total Amount | `Principal + Interest` | Final amount |
| Effective Rate | `pow(1 + periodicRate, periods) - 1` | Effective rate |

---

## 10. Debugging Tips

### Check Interest Calculation
```dart
// In staking_controller.dart
print("Principal: $userInputAmount");
print("Rate: $interest%");
print("Interest Earned: ${(userInputAmount * interest) / 100}");
print("Total: $returnAmount");
```

### Verify Plan Type
```dart
// Check if plan has compound interest
print("Compound: ${plan.compoundInterest == '1' ? 'Yes' : 'No'}");
print("Monthly Rate: $monthlyPercent%");
print("Annual Rate: ${_calculateCompoundAnnual(monthlyPercent)}%");
```

---

## 11. Edge Cases

### Zero Values
- If interest rate = 0%, interest earned = 0
- Calculation handles gracefully with default "0.0"

### Missing Data
- If `interestPercent` is null, defaults to 0.0
- If `investAmount` is null, defaults to 0.0

### Very Large Numbers
- Uses `double` for precision
- Formatted to 2 decimal places for display
- `Converter.twoDecimalPlaceFixedWithoutRounding` prevents rounding errors

---

## Summary

- **Simple Interest**: Linear calculation (Principal × Rate / 100)
- **Compound Interest**: Exponential calculation ((1 + rate)^periods - 1)
- **Frontend**: Handles display and hypothetical calculations
- **Backend**: Stores pre-calculated interest for active stakings
- **Key Files**: `staking_controller.dart`, `plan_controller.dart`

Interest is calculated based on the plan type and whether compound interest is enabled, providing users with clear visualization of their returns.
