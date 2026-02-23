import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/account/profile_controller.dart';
import 'package:hyip_lab/data/controller/pool/pool_contrroller.dart';
import 'package:hyip_lab/data/repo/account/profile_repo.dart';
import 'package:hyip_lab/data/repo/pool/pool_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/screens/bottom_nav_screens/home/widgets/plan_card.dart';
import 'package:hyip_lab/view/screens/pool/my_pool/widget/pool_history_card.dart';
import 'package:hyip_lab/view/screens/pool/pool/widget/pool_card_widget.dart';

import '../../../../core/utils/util.dart';
import '../../../../data/controller/common/theme_controller.dart';

class PoolScreen extends StatefulWidget {
  const PoolScreen({super.key});

  @override
  State<PoolScreen> createState() => _PoolScreenState();
}

class _PoolScreenState extends State<PoolScreen> {
  @override
  void initState() {
    ThemeController themeController =
        ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PoolRepo(apiClient: Get.find()));
    Get.put(ProfileRepo(apiClient: Get.find()));
    Get.put(ProfileController(profileRepo: Get.find()));

    final controller = Get.put(
        PoolController(poolRepo: Get.find(), profileController: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(
        title: MyStrings.pool,
        actionsList: [
          GestureDetector(
            onTap: () {
              Get.offNamed(RouteHelper.poolhistoryScreen);
            },
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MyColor.primaryColor.withOpacity(0.7),
              ),
              child: const Icon(Icons.history),
            ),
          ),
          const SizedBox(
            width: Dimensions.space10,
          )
        ],
      ),
      body: GetBuilder<PoolController>(builder: (controller) {
        return controller.isLoading
            ? const CustomLoader()
            : Padding(
                padding: Dimensions.screenPaddingHV,
                child: ListView.builder(
                  itemCount: controller.poolList.length,
                  itemBuilder: (context, index) {
                    return PoolCardWidget(index: index);
                  },
                ),
              );
      }),
    );
  }
}
