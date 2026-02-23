import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/account/profile_controller.dart';
import 'package:hyip_lab/data/controller/staking/staking_controller.dart';
import 'package:hyip_lab/data/repo/account/profile_repo.dart';
import 'package:hyip_lab/data/repo/staking/staking_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/no_data_found_screen.dart';
import 'package:hyip_lab/view/screens/staking/my_staking/widget/staking_card.dart';

import '../../../../core/utils/util.dart';
import '../../../../data/controller/common/theme_controller.dart';

class MystakingScreen extends StatefulWidget {
  const MystakingScreen({super.key});

  @override
  State<MystakingScreen> createState() => _MystakingScreenState();
}

class _MystakingScreenState extends State<MystakingScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (Get.find<StakingController>().hasNext()) {
        Get.find<StakingController>().getStakingPaginateData();
      }
    }
  }

  @override
  void initState() {
    ThemeController themeController =
        ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(StakingRepo(apiClient: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    Get.put(ProfileController(profileRepo: Get.find()));
    final controller = Get.put(StakingController(
        stakingRepo: Get.find(), profileController: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StakingController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.myStacking,
          bgColor: MyColor.getAppbarBgColor(),
          actionsList: [
            controller.isLoading
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: () {
                      Get.toNamed(RouteHelper.stakingScreen);
                    },
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColor.primaryColor.withOpacity(0.7),
                      ),
                      child: const Icon(Icons.add),
                    ),
                  ),
            const SizedBox(
              width: Dimensions.space10,
            )
          ],
        ),
        body: controller.isLoading
            ? const CustomLoader()
            : controller.myStakings.isEmpty
                ? const NoDataFoundScreen()
                : Padding(
                    padding: Dimensions.screenPaddingHV,
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        if (index == controller.myStakings.length) {
                          return controller.hasNext()
                              ? const CustomLoader(
                                  isPagination: true,
                                )
                              : const SizedBox();
                        }
                        return StakingCard(
                          myStaking: controller.myStakings[index],
                          currency: controller.currency,
                        );
                      },
                      itemCount: controller.myStakings.length + 1,
                    ),
                  ),
      ),
    );
  }
}
