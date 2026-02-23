import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/user/user.dart';
import 'package:hyip_lab/view/components/agreement/agreement_required_popup.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class AgreementHelper {
  
  /// Check if user's KYC is verified
  static bool isKycVerified(User? user) {
    return user?.kv == '1';
  }

  /// Check if user's agreement is verified
  static bool isAgreementVerified(User? user) {
    return user?.agreementVerified == '1' || user?.agreementVerified == 'true';
  }

  /// Check if user needs to accept agreement (KYC verified but agreement not verified)
  static bool needsAgreementAcceptance(User? user) {
    return isKycVerified(user) && !isAgreementVerified(user);
  }

  /// Check if user can access protected features (both KYC and agreement verified)
  static bool canAccessProtectedFeatures(User? user) {
    return isKycVerified(user) && isAgreementVerified(user);
  }

  /// Show error message when trying to access protected feature without agreement
  static void showAgreementRequiredMessage({String? userEmail}) {
    BuildContext? context = Get.context;
    if (context != null) {
      AgreementRequiredPopup.show(context, userEmail: userEmail);
    } else {
      // Fallback to snackbar if context not available
      showAgreementRequiredSnackbar();
    }
  }

  /// Show error snackbar for agreement requirement
  static void showAgreementRequiredSnackbar() {
    CustomSnackBar.error(
      errorList: [MyStrings.agreementNeededShort],
    );
  }

  /// Check if user can proceed with action, show appropriate error if not
  /// Returns true if user can proceed, false otherwise
  static bool checkAndShowError(User? user, {String? userEmail}) {
    // First check KYC
    if (!isKycVerified(user)) {
      CustomSnackBar.error(
        errorList: ['Please complete KYC verification first'],
      );
      return false;
    }

    // Then check agreement
    if (!isAgreementVerified(user)) {
      showAgreementRequiredMessage(userEmail: userEmail);
      return false;
    }

    return true;
  }

  /// Get agreement status text for UI display
  static String getAgreementStatusText(User? user) {
    if (!isKycVerified(user)) {
      return 'KYC: Pending';
    }
    if (!isAgreementVerified(user)) {
      return MyStrings.agreementStatusPending;
    }
    return MyStrings.agreementStatusVerified;
  }

  /// Get agreement status icon
  static IconData getAgreementStatusIcon(User? user) {
    if (!isKycVerified(user)) {
      return Icons.pending_outlined;
    }
    if (!isAgreementVerified(user)) {
      return Icons.access_time_outlined;
    }
    return Icons.check_circle_outline;
  }

  /// Get agreement status color
  static Color getAgreementStatusColor(User? user) {
    if (!isKycVerified(user)) {
      return Colors.grey;
    }
    if (!isAgreementVerified(user)) {
      return Colors.orange;
    }
    return Colors.green;
  }
}
