import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/plan/plan_controller.dart';
import 'package:hyip_lab/data/repo/plan/plan_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/bottom_Nav/bottom_nav.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/will_pop_widget.dart';
import 'package:hyip_lab/view/screens/plan/widget/plan_card.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({Key? key}) : super(key: key);

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PlanRepo(apiClient: Get.find()));
    final controller = Get.put(PlanController(planRepo: Get.find()));

    super.initState();
    pageController = PageController(initialPage: 0, viewportFraction: .8);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.getAllPackageData();
      controller.planList.clear();
    });
  }

  late PageController pageController;

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlanController>(
        builder: (controller) => WillPopWidget(
              nextRoute: RouteHelper.homeScreen,
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: MyColor.getScreenBgColor(),
                  appBar: CustomAppBar(
                    isShowBackBtn: false,
                    title: MyStrings.investmentPlan.tr,
                    bgColor: MyColor.getAppbarBgColor(),
                  ),
                  body: controller.isLoading
                      ? const CustomLoader()
                      : SingleChildScrollView(
                          child: SingleChildScrollView(
                            padding: Dimensions.screenPaddingHV,
                            child: Column(
                              children: [
                                ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: controller.planList.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(
                                            height: Dimensions.space10),
                                    itemBuilder: (context, index) {
                                      return PlanCard(index: index);
                                    }),
                                // // Coming Soon Plans (Placeholders)
                                // const SizedBox(height: Dimensions.space10),
                                // _buildComingSoonPlan(
                                //     context, 'Plan 2 (Coming Soon)'),
                                // const SizedBox(height: Dimensions.space10),
                                // _buildComingSoonPlan(
                                //     context, 'Plan 3 (Coming Soon)'),
                              ],
                            ),
                          ),
                        ),
                  bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
                ),
              ),
            ));
  }

  Widget _buildComingSoonPlan(BuildContext context, String planName) {
    return GestureDetector(
      onTap: () {
        _showComingSoonDialog(context, planName);
      },
      child: Container(
        padding: const EdgeInsets.all(Dimensions.space15),
        decoration: BoxDecoration(
          color: MyColor.getCardBg(),
          borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
          border: Border.all(
            color: MyColor.getPrimaryColor().withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  planName,
                  style: TextStyle(
                    color: MyColor.getTextColor(),
                    fontSize: Dimensions.fontLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.space10,
                    vertical: Dimensions.space5,
                  ),
                  decoration: BoxDecoration(
                    color: MyColor.getPrimaryColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(Dimensions.space5),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: MyColor.getPrimaryColor(),
                      fontSize: Dimensions.fontSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.space10),
            Text(
              'Exciting new investment opportunities launching soon!',
              style: TextStyle(
                color: MyColor.getTextColor1(),
                fontSize: Dimensions.fontDefault,
              ),
            ),
            const SizedBox(height: Dimensions.space15),
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: MyColor.getPrimaryColor(),
                  size: 20,
                ),
                const SizedBox(width: Dimensions.space5),
                Text(
                  'Tap to learn more',
                  style: TextStyle(
                    color: MyColor.getPrimaryColor(),
                    fontSize: Dimensions.fontSmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String planName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: MyColor.getCardBg(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.space20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: Dimensions.space15),
                      Icon(
                        Icons.rocket_launch_rounded,
                        size: 60,
                        color: MyColor.getPrimaryColor(),
                      ),
                      const SizedBox(height: Dimensions.space20),
                      Text(
                        planName,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MyColor.getTextColor(),
                          fontSize: Dimensions.fontExtraLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space15),
                      Text(
                        'We\'re working hard to bring you this exciting new investment plan!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MyColor.getTextColor1(),
                          fontSize: Dimensions.fontDefault,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space10),
                      Text(
                        'Stay tuned for updates.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: MyColor.getTextColor1(),
                          fontSize: Dimensions.fontDefault,
                        ),
                      ),
                      const SizedBox(height: Dimensions.space25),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: MyColor.getPrimaryColor(),
                            padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.space12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.defaultRadius),
                            ),
                          ),
                          child: Text(
                            'Got It!',
                            style: TextStyle(
                              color: MyColor.getButtonTextColor(),
                              fontSize: Dimensions.fontDefault,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button (top right)
                Positioned(
                  top: Dimensions.space10,
                  right: Dimensions.space10,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(Dimensions.space5),
                      decoration: BoxDecoration(
                        color: MyColor.getTextColor1().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 20,
                        color: MyColor.getTextColor(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
