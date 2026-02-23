import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/pool/my_pool_controller.dart';
import 'package:hyip_lab/data/controller/pool/pool_contrroller.dart';
import 'package:hyip_lab/data/repo/pool/pool_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/no_data_found_screen.dart';
import 'package:hyip_lab/view/screens/pool/my_pool/widget/pool_history_card.dart';

import '../../../../core/utils/util.dart';
import '../../../../data/controller/common/theme_controller.dart';

class MyPoolHistroyScreen extends StatefulWidget {
  const MyPoolHistroyScreen({super.key});

  @override
  State<MyPoolHistroyScreen> createState() => _MyPoolHistroyScreenState();
}

class _MyPoolHistroyScreenState extends State<MyPoolHistroyScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<MypoolController>().hasNext()) {
        Get.find<MypoolController>().mypoolHistroyPaginateData();
      }
    }
  }

  @override
  void initState() {


    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(PoolRepo(apiClient: Get.find()));
    final controller = Get.put(MypoolController(poolRepo: Get.find()));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(title: MyStrings.poolHistory),
      body: GetBuilder<MypoolController>(builder: (controller) {
        return controller.isLoading
          ? const CustomLoader()
          : controller.myInvests.isEmpty?
        const NoDataFoundScreen() :
        Padding(
          padding: Dimensions.screenPaddingHV,
          child: ListView.builder(
            controller: scrollController,
            itemCount: controller.myInvests.length + 1,
            itemBuilder: (context, index) {
              if (controller.myInvests.length == index) {
                return controller.hasNext()
                  ? const CustomLoader(isPagination: true)
                  : const SizedBox();
              }
              return PoolHistoryCard(invest: controller.myInvests[index]);
            },
          ),
        );
      }),
    );
  }
}
