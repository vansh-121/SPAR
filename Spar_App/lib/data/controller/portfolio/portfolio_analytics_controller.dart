import 'package:get/get.dart';
import 'package:hyip_lab/data/model/portfolio/portfolio_analytics_model.dart';
import 'package:hyip_lab/data/repo/portfolio/portfolio_analytics_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class PortfolioAnalyticsController extends GetxController {
  PortfolioAnalyticsRepo repo;
  PortfolioAnalyticsController({required this.repo});

  bool isLoading = false;
  PortfolioAnalyticsModel? analyticsData;

  String selectedPeriod = '12M'; // 1M, 3M, 6M, 12M, ALL

  @override
  void onInit() {
    super.onInit();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    isLoading = true;
    update();

    try {
      // Calculate date range based on selected period
      DateTime endDate = DateTime.now();
      DateTime startDate;
      
      switch (selectedPeriod) {
        case '1M':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case '3M':
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        case '6M':
          startDate = endDate.subtract(const Duration(days: 180));
          break;
        case '12M':
          startDate = endDate.subtract(const Duration(days: 365));
          break;
        case 'ALL':
        default:
          startDate = endDate.subtract(const Duration(days: 3650)); // 10 years
      }

      analyticsData = await repo.getPortfolioAnalytics(
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
      );

      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      CustomSnackBar.showCustomSnackBar(
        errorList: ['Failed to load analytics: $e'],
        msg: [],
        isError: true,
      );
    }
  }

  void changePeriod(String period) {
    if (selectedPeriod != period) {
      selectedPeriod = period;
      loadAnalytics();
    }
  }
}


