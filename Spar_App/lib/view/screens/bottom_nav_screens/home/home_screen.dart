import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/agreement_helper.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_images.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/util.dart';
import 'package:hyip_lab/data/controller/common/theme_controller.dart';
import 'package:hyip_lab/data/repo/dashboard_repo.dart';
import 'package:hyip_lab/data/repo/portfolio/portfolio_analytics_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/agreement/agreement_pending_banner.dart';
import 'package:hyip_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:hyip_lab/view/components/card/card_with_round_icon.dart';
import 'package:hyip_lab/view/components/will_pop_widget.dart';
import 'package:hyip_lab/view/components/kyc/kyc_pending_banner.dart';
import 'package:hyip_lab/view/components/portfolio_charts.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/home/widgets/home_bottom_section.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/home/widgets/home_top_section.dart';

import '../../../../data/controller/dashboard/dashboard_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(DashboardRepo(apiClient: Get.find()));

    // Initialize PortfolioAnalyticsRepo if not already registered
    if (!Get.isRegistered<PortfolioAnalyticsRepo>()) {
      Get.put(PortfolioAnalyticsRepo(apiClient: Get.find()));
    }

    // Get the portfolio analytics repo, or null if not available
    PortfolioAnalyticsRepo? portfolioRepo;
    try {
      portfolioRepo = Get.find<PortfolioAnalyticsRepo>();
    } catch (e) {
      portfolioRepo = null;
    }

    final controller = Get.put(DashBoardController(
      dashboardRepo: Get.find(),
      portfolioAnalyticsRepo: portfolioRepo,
    ));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    ThemeController themeController =
        ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopWidget(
      nextRoute: '',
      child: SafeArea(
          child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        body: GetBuilder<DashBoardController>(
          builder: (controller) => RefreshIndicator(
            onRefresh: () async {
              await controller.loadData();
            },
            color: MyColor.getPrimaryColor(),
            backgroundColor: MyColor.getCardBg(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const HomeTopSection(),

                  if ((controller.currentUser?.kv ?? '1') != '1')
                    Padding(
                      padding: const EdgeInsets.only(
                        left: Dimensions.space15,
                        right: Dimensions.space15,
                        top: Dimensions.space15,
                      ),
                      child: KycPendingBanner(
                        message: controller.kycStatus ==
                                SharedPreferenceHelper.kycStatusUnderReview
                            ? MyStrings.kycUnderReviewMsg.tr
                            : MyStrings.completeYourKyc.tr,
                        isUnderReview: controller.kycStatus ==
                            SharedPreferenceHelper.kycStatusUnderReview,
                        onTap: () => Get.toNamed(RouteHelper.kycScreen),
                      ),
                    ),

                  // Agreement Pending Banner
                  if (AgreementHelper.needsAgreementAcceptance(
                      controller.currentUser))
                    const Padding(
                      padding: EdgeInsets.only(
                        left: Dimensions.space15,
                        right: Dimensions.space15,
                        top: Dimensions.space15,
                      ),
                      child: AgreementPendingBanner(),
                    ),

                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: MyColor.getCardBg(),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20))),
                    child: Column(
                      children: [
                        const SizedBox(height: Dimensions.space20),
                        // Portfolio Analytics Charts
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space15),
                          child: PortfolioChartsWidget(
                            analyticsData: controller.portfolioAnalytics,
                            isLoading: controller.isLoadingAnalytics,
                          ),
                        ),
                        const SizedBox(height: Dimensions.space20),
                        // 2x2 Grid Layout for cards
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.space15),
                          child: Column(
                            children: [
                              // Row 1: Interest Wallet + Plan Deposit Pending
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CardWithRoundIcon(
                                        backgroundColor:
                                            MyColor.getScreenBgColor(),
                                        titleText:
                                            MyStrings.interestWalletBalance.tr,
                                        titleColor: MyColor.getTextColor(),
                                        trailColor: MyColor.getPrimaryColor(),
                                        trailText: controller.interestWalletBal,
                                        icon: MyImages.depositWallet,
                                        onPressed: () {
                                          Get.toNamed(
                                              RouteHelper
                                                  .transactionHistoryScreen,
                                              arguments:
                                                  MyStrings.interestWallet);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space12),
                                    Expanded(
                                      child: CardWithRoundIcon(
                                        backgroundColor:
                                            MyColor.getScreenBgColor(),
                                        titleText:
                                            MyStrings.unrealizedReturns.tr,
                                        titleColor: MyColor.getTextColor(),
                                        trailColor: MyColor.getPrimaryColor(),
                                        trailText: controller.unrealizedReturns,
                                        icon: MyImages.pending,
                                        onPressed: () {
                                          Get.toNamed(
                                              RouteHelper.depositScreen);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: Dimensions.space12),
                              // Row 2: Withdrawal Pending + Total Invest
                              IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: CardWithRoundIcon(
                                        backgroundColor:
                                            MyColor.getScreenBgColor(),
                                        titleText:
                                            MyStrings.withdrawalPending.tr,
                                        icon: MyImages.pending,
                                        titleColor: MyColor.getTextColor(),
                                        trailText: controller.withdrawPending,
                                        onPressed: () => Get.toNamed(
                                            RouteHelper.withdrawHistoryScreen),
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.space12),
                                    Expanded(
                                      child: CardWithRoundIcon(
                                        backgroundColor:
                                            MyColor.getScreenBgColor(),
                                        titleText: MyStrings.totalInvest.tr,
                                        titleColor: MyColor.getTextColor(),
                                        trailColor: MyColor.getPrimaryColor(),
                                        trailText: controller.totalInvest,
                                        icon: MyImages.totalInvest,
                                        onPressed: () {
                                          Get.toNamed(
                                              RouteHelper.investmentScreen);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: Dimensions.space20),
                        const HomeBottomSection()
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
      )),
    );
  }
}
