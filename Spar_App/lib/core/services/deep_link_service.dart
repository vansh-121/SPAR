import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/data/repo/plan/plan_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class DeepLinkService {
  static final AppLinks _appLinks = AppLinks();
  static bool _isInitialized = false;

  /// Initialize deep link listener
  static void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    print('[DeepLinkService] Initializing deep link listeners');

    // Handle initial link (if app opened from link)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        print('[DeepLinkService] Initial link detected: $uri');
        _handleDeepLink(uri);
      } else {
        print('[DeepLinkService] No initial link');
      }
    });

    // Listen for incoming links while app is running
    _appLinks.uriLinkStream.listen((uri) {
      print('[DeepLinkService] Stream link received: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      print('[DeepLinkService] Deep link stream error: $err');
    });
  }

  /// Handle deep link navigation
  static Future<void> _handleDeepLink(Uri uri) async {
    try {
      print('[DeepLinkService] Processing URI: $uri');

      // Check if it's our custom scheme
      if (uri.scheme == 'app' || uri.scheme == 'hyiplab') {
        final path = uri.path;
        final host = uri.host;
        final target = (path.isNotEmpty && path != '/')
            ? path.replaceFirst('/', '')
            : host;
        final params = uri.queryParameters;

        print('[DeepLinkService] Normalized target: $target, params: $params');

        if (target == 'payment-method') {
          final planId = params['plan_id'];
          final investId = params['invest_id'];

          if (planId != null) {
            await _navigateToPaymentMethod(
              planId: planId,
              investId: investId != null ? int.tryParse(investId) : null,
            );
          } else {
            print('[DeepLinkService] Missing plan_id in URI');
            CustomSnackBar.showCustomSnackBar(
              errorList: ['Invalid deep link: plan_id is required'],
              msg: [],
              isError: true,
            );
          }
        } else {
          print('[DeepLinkService] Unknown deep link target: $target');
        }
      }
    } catch (e) {
      print('[DeepLinkService] Error handling deep link: $e');
      CustomSnackBar.showCustomSnackBar(
        errorList: ['Failed to open link: $e'],
        msg: [],
        isError: true,
      );
    }
  }

  /// Navigate to payment method screen with plan and invest_id
  static Future<void> _navigateToPaymentMethod({
    required String planId,
    int? investId,
  }) async {
    try {
      // Ensure dependencies are available
      if (!Get.isRegistered<ApiClient>()) {
        print('[DeepLinkService] ApiClient not registered');
        CustomSnackBar.showCustomSnackBar(
          errorList: ['App not initialized. Please try again.'],
          msg: [],
          isError: true,
        );
        return;
      }

      // Fetch plan data
      final apiClient = Get.find<ApiClient>();
      final planRepo = PlanRepo(apiClient: apiClient);

      print('[DeepLinkService] Fetching plan with ID: $planId, investId: $investId');
      final responseModel = await planRepo.getPackagesData();

      if (responseModel.statusCode == 200) {
        final planModel = PricingPlanModel.fromJson(
          jsonDecode(responseModel.responseJson),
        );

        if (planModel.status?.toString().toLowerCase() == 'success') {
          final plans = planModel.data?.plans ?? [];
          Plans? plan;
          try {
            plan = plans.firstWhere(
              (p) => p.id?.toString() == planId,
            );
          } catch (e) {
            plan = null;
          }

          if (plan != null) {
            print('[DeepLinkService] Plan found: ${plan.name}, navigating with investId=$investId');

            // Navigate to payment method screen
            // Arguments: [Plans plan, int? topupInvestId, bool isTopup]
            Get.toNamed(
              RouteHelper.paymentMethodScreen,
              arguments: [
                plan,
                investId,
                investId != null, // isTopup = true if invest_id exists
              ],
            );
          } else {
            print('[DeepLinkService] Plan $planId not found in API response');
            CustomSnackBar.showCustomSnackBar(
              errorList: ['Plan not found. Please try again.'],
              msg: [],
              isError: true,
            );
          }
        } else {
          CustomSnackBar.showCustomSnackBar(
            errorList: ['Failed to load plan data. Please try again.'],
            msg: [],
            isError: true,
          );
        }
      } else {
        print('[DeepLinkService] Plan API failed with status ${responseModel.statusCode}');
        CustomSnackBar.showCustomSnackBar(
          errorList: ['Failed to load plan data. Please try again.'],
          msg: [],
          isError: true,
        );
      }
    } catch (e) {
      print('[DeepLinkService] Error navigating to payment method: $e');
      CustomSnackBar.showCustomSnackBar(
        errorList: ['Failed to open payment screen: $e'],
        msg: [],
        isError: true,
      );
    }
  }
}
