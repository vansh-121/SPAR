import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/shedule/shedule_controller.dart';
import 'package:hyip_lab/data/repo/shedule/shedule_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/bottom-sheet/shedule_bottom_sheet.dart';
import 'package:hyip_lab/view/components/column/card_column.dart';
import 'package:hyip_lab/view/components/custom_divider.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/no_data/no_data_widget.dart';
import 'package:hyip_lab/view/screens/schedule/widget/shedule_invest_bottom_sheet.dart';

import '../../../core/utils/util.dart';
import '../../../data/controller/common/theme_controller.dart';
import '../../components/dialog/delete_dialog.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      if (Get.find<SheduleController>().hasNext()) {
        Get.find<SheduleController>().getShedulePagenateData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SheduleRepo(apiClient: Get.find()));
    final controller = Get.put(SheduleController(sheduleRepo: Get.find()));

    ThemeController themeController = ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);

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
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(title: MyStrings.schedule),
      body: GetBuilder<SheduleController>(builder: (controller) {
        return controller.isLoading
          ? const CustomLoader()
          : controller.sheduleList.isEmpty
          ? const NoDataWidget()
          : Padding(
              padding: Dimensions.screenPaddingHV,
              child: ListView.builder(
                itemCount: controller.sheduleList.length + 1,
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index == controller.sheduleList.length) {
                    return controller.hasNext()
                      ? const CustomLoader(
                          isPagination: true,
                        )
                      : const SizedBox();
                  }
                  final shedule = controller.sheduleList[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      SheduleBottomSheet(
                        child: SheduleInvestBottomSheet(
                          shedule: shedule,
                          currency: controller.currency,
                          onButtonClick: () {
                            controller.changeScheduleStatus(shedule.id?.toInt() ?? 0,index);
                            Get.back();
                          },
                        ),
                      ).customBottomSheet(context);
                    },
                    child: Container(
                      // padding: Dimensions.cardPaddingHV,
                      margin: const EdgeInsetsDirectional.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      decoration: BoxDecoration(
                        color: MyColor.getCardBg(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CardColumn(
                                textColor: MyColor.primaryTextColor,
                                header: controller.sheduleList[index].plan?.name ?? "",
                                body: "${Converter.twoDecimalPlaceFixedWithoutRounding(controller.sheduleList[index].amount.toString())} ${controller.currency}",
                                space: 3,
                              ),
                              CardColumn(
                                textColor: MyColor.primaryTextColor,
                                alignmentEnd: true,
                                header: MyStrings.wallet,
                                body: Converter.replaceUnderscoreWithSpace(controller.sheduleList[index].wallet.toString()),
                                space: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.space15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CardColumn(
                                textColor: MyColor.primaryTextColor,
                                header: MyStrings.nextReturn,
                                body: DateConverter.nextReturnTime(controller.sheduleList[index].nextInvest.toString()),
                                space: 3,
                              ),
                              CardColumn(
                                textColor: MyColor.primaryTextColor,
                                alignmentEnd: true,
                                header: MyStrings.remainingTimes,
                                body: controller.sheduleList[index].remScheduleTimes.toString(),
                                space: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.space15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: CardColumn(
                                  textColor: MyColor.primaryTextColor,
                                  header: MyStrings.return_,
                                  body: controller.sheduleList[index].return_.toString()??'',
                                  space: 3,
                                ),
                              ),
                              const SizedBox(width: Dimensions.space10),
                              GestureDetector(
                                onTap: () {

                                  if(controller.isScheduleStatusLoading){
                                    return;
                                  }

                                  const WarningAlertDialog().actionAlertDialog(context, () {
                                    controller.changeScheduleStatus(shedule.id?.toInt() ?? 0,index);
                                  },shedule.status == "1"?MyStrings.pauseInvestMsg : MyStrings.continueInvestMsg);
                                },
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: MyColor.primaryColor,
                                  ),
                                  child: controller.isScheduleStatusLoading && controller.selectedScheduleIndex == index? const CustomLoader(indicatorColor:Colors.white,isPagination: true) :
                                  shedule.status == "1" ? const Icon(Icons.pause_sharp) : const Icon(Icons.play_arrow),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
      }),
    );
  }
}
