import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/ranking_controller/ranking_controller.dart';
import 'package:hyip_lab/data/repo/ranking/ranking_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/bottom_sheet_bar.dart';
import 'package:hyip_lab/view/components/bottom-sheet/custom_bottom_sheet.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/divider/custom_divider.dart';
import 'package:hyip_lab/view/components/no_data_found_screen.dart';

import '../../../core/utils/util.dart';
import '../../../data/controller/common/theme_controller.dart';
import '../../../data/model/ranking/ranking_response_model.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (Get.find<RankingController>().hasNext()) {
        Get.find<RankingController>().loadPaginationData();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(RankingRepo(apiClient: Get.find()));
    final controller = Get.put(RankingController(rankingRepo: Get.find()));

    ThemeController themeController =
        ThemeController(sharedPreferences: Get.find());
    MyUtils.allScreensUtils(themeController.darkTheme);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.page = 0;
      controller.initData();
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
    return GetBuilder<RankingController>(
        builder: (controller) => SafeArea(
              child: Scaffold(
                backgroundColor: MyColor.getScreenBgColor(),
                appBar: CustomAppBar(title: MyStrings.userRanking),
                body: controller.isLoading
                    ? const CustomLoader()
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: Dimensions.space20,
                              horizontal: Dimensions.space15),
                          child: controller.allRankList.isEmpty
                              ? const NoDataFoundScreen()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      visible: controller.nextRanking != null &&
                                          controller.nextRanking?.name != null,
                                      child: Container(
                                        padding: const EdgeInsets.all(
                                            Dimensions.space12),
                                        decoration: BoxDecoration(
                                          color: MyColor.getCardBg(),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                          controller.getImageUrl(
                                                              controller
                                                                      .nextRanking
                                                                      ?.icon ??
                                                                  ''),
                                                          height: 45,
                                                          width: 45,
                                                          errorBuilder:
                                                              (context, v1,
                                                                  v2) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }),
                                                      const SizedBox(
                                                          width: Dimensions
                                                              .space15),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            MyStrings
                                                                .myInvest.tr,
                                                            style: interSemiBoldDefault
                                                                .copyWith(
                                                                    color: MyColor
                                                                        .getTextColor1()),
                                                          ),
                                                          const SizedBox(
                                                              height: 1),
                                                          Text(
                                                            "${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.user?.totalInvests ?? '0')} / ${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.nextRanking?.minimumInvest ?? "0")}",
                                                            style: interRegularDefault.copyWith(
                                                                color: MyColor
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          const SizedBox(
                                                              height: 3),
                                                          Text(
                                                            '${controller.curSymbol}${controller.getUnlockAmount(controller.nextRanking?.minimumInvest ?? '', controller.user?.totalInvests ?? '')} ${MyStrings.toUnlock.tr}',
                                                            style: interRegularDefault
                                                                .copyWith(
                                                                    color: MyColor
                                                                        .getSecondaryTextColor()),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const CustomDivider(
                                                space: Dimensions.space12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(MyStrings.teamInvest.tr,
                                                    style: interRegularDefault
                                                        .copyWith(
                                                            color: MyColor
                                                                .getSecondaryTextColor())),
                                                Expanded(
                                                    child: Text(
                                                        "${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.user?.teamInvests ?? '0')} / ${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.nextRanking?.minReferralInvest ?? '0')}",
                                                        textAlign:
                                                            TextAlign.end,
                                                        style: interRegularDefault
                                                            .copyWith(
                                                                color: MyColor
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))),
                                              ],
                                            ),
                                            const CustomDivider(
                                                space: Dimensions.space12),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(MyStrings.bonus.tr,
                                                        style: interRegularDefault
                                                            .copyWith(
                                                                color: MyColor
                                                                    .getSecondaryTextColor())),
                                                    Text(
                                                        "${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(controller.nextRanking?.bonus ?? '')}",
                                                        style: interRegularDefault
                                                            .copyWith(
                                                                color: MyColor
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                  ],
                                                )),
                                                Expanded(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                        MyStrings
                                                            .directReferral.tr,
                                                        style: interRegularDefault
                                                            .copyWith(
                                                                color: MyColor
                                                                    .getSecondaryTextColor())),
                                                    Text(
                                                        "${controller.totalReffered}/${controller.nextRanking?.minReferral}",
                                                        style: interRegularDefault
                                                            .copyWith(
                                                                color: MyColor
                                                                    .primaryColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                  ],
                                                ))
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.space15),
                                    SizedBox(
                                      child: GridView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  childAspectRatio: 1.10),
                                          itemCount:
                                              controller.allRankList.length,
                                          itemBuilder: (context, index) {
                                            UserRankings model =
                                                controller.allRankList[index];
                                            return IntrinsicHeight(
                                              child: GestureDetector(
                                                onTap: () {
                                                  CustomBottomSheet(
                                                          backgroundColor:
                                                              MyColor.getCardBg(),
                                                          child: Container(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left: Dimensions
                                                                    .space12,
                                                                right: Dimensions
                                                                    .space12),
                                                            child: Column(
                                                              children: [
                                                                Center(
                                                                  child:
                                                                      Container(
                                                                    height: 5,
                                                                    width: 50,
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            1),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      color: MyColor
                                                                          .colorGrey
                                                                          .withOpacity(
                                                                              0.4),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height:
                                                                      Dimensions
                                                                          .space20,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            MyStrings
                                                                                .level.tr,
                                                                            style:
                                                                                interRegularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w600))),
                                                                    Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            model.level ??
                                                                                '',
                                                                            textAlign: TextAlign
                                                                                .end,
                                                                            style: interRegularDefault.copyWith(
                                                                                fontSize: Dimensions.fontLarge,
                                                                                color: MyColor.getTextColor(),
                                                                                fontWeight: FontWeight.w300))),
                                                                  ],
                                                                ),
                                                                const CustomDivider(
                                                                    space: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            MyStrings
                                                                                .minimumInvest.tr,
                                                                            style:
                                                                                interRegularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w600))),
                                                                    Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            "${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(model.minimumInvest ?? '')}",
                                                                            textAlign: TextAlign
                                                                                .end,
                                                                            style: interRegularDefault.copyWith(
                                                                                fontSize: Dimensions.fontLarge,
                                                                                color: MyColor.getTextColor(),
                                                                                fontWeight: FontWeight.w400))),
                                                                  ],
                                                                ),
                                                                const CustomDivider(
                                                                    space: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            MyStrings
                                                                                .directReferral.tr,
                                                                            style:
                                                                                interRegularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w600))),
                                                                    Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            model.minReferral ??
                                                                                '',
                                                                            textAlign: TextAlign
                                                                                .end,
                                                                            style: interRegularDefault.copyWith(
                                                                                fontSize: Dimensions.fontLarge,
                                                                                color: MyColor.getTextColor(),
                                                                                fontWeight: FontWeight.w400))),
                                                                  ],
                                                                ),
                                                                const CustomDivider(
                                                                    space: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            MyStrings
                                                                                .referralInvest.tr,
                                                                            style:
                                                                                interRegularDefault.copyWith(color: MyColor.getTextColor(), fontWeight: FontWeight.w600))),
                                                                    Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            "${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(model.minReferralInvest ?? '')}",
                                                                            textAlign: TextAlign
                                                                                .end,
                                                                            style: interRegularDefault.copyWith(
                                                                                fontSize: Dimensions.fontLarge,
                                                                                color: MyColor.getTextColor(),
                                                                                fontWeight: FontWeight.w300))),
                                                                  ],
                                                                ),
                                                                const CustomDivider(
                                                                    space: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child:
                                                                            Text(
                                                                          MyStrings
                                                                              .bonus
                                                                              .tr,
                                                                          style: interRegularDefault.copyWith(
                                                                              color: MyColor.getTextColor(),
                                                                              fontWeight: FontWeight.w600),
                                                                        )),
                                                                    Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            "${controller.curSymbol}${Converter.twoDecimalPlaceFixedWithoutRounding(model.bonus ?? '')}",
                                                                            textAlign: TextAlign
                                                                                .end,
                                                                            style: interRegularDefault.copyWith(
                                                                                fontSize: Dimensions.fontLarge,
                                                                                color: MyColor.getTextColor(),
                                                                                fontWeight: FontWeight.w300))),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ))
                                                      .customBottomSheet(
                                                          context);
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  alignment: Alignment.center,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  padding: const EdgeInsets.all(
                                                      Dimensions.space10),
                                                  decoration: BoxDecoration(
                                                      color: controller
                                                              .isCross(index)
                                                          ? MyColor
                                                              .getActiveBadgeBGColor()
                                                          : MyColor.getCardBg(),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  12))),
                                                  child: Center(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        controller
                                                                .isCross(index)
                                                            ? Image.network(
                                                                controller
                                                                    .getImageUrl(
                                                                        model.icon ??
                                                                            ''),
                                                                colorBlendMode:
                                                                    BlendMode
                                                                        .darken,
                                                                height: 65,
                                                                width: 65,
                                                              )
                                                            : Stack(
                                                                children: [
                                                                  ColorFiltered(
                                                                      colorFilter: ColorFilter.mode(
                                                                          MyColor
                                                                              .getCardBg(),
                                                                          BlendMode
                                                                              .color),
                                                                      child: Image.network(
                                                                          controller.getImageUrl(model.icon ??
                                                                              ''),
                                                                          height:
                                                                              65)),
                                                                ],
                                                              ),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .space5),
                                                        Text(
                                                          model.name?.tr ?? '',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: interRegularDefault
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSmall,
                                                                  color: MyColor
                                                                      .getTextColor(),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        ),
                                                        Text(
                                                          '${MyStrings.bonus.tr} - ${controller.curSymbol}${Converter.roundDoubleAndRemoveTrailingZero(model.bonus ?? '')}',
                                                          style: interRegularDefault
                                                              .copyWith(
                                                                  color: MyColor
                                                                      .getTextColor(),
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSmall,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300),
                                                        ),
                                                        Visibility(
                                                            visible: controller
                                                                    .nextRanking
                                                                    ?.id
                                                                    .toString() ==
                                                                model.id
                                                                    .toString(),
                                                            child: Column(
                                                              children: [
                                                                const SizedBox(
                                                                    height: Dimensions
                                                                        .space5),
                                                                LinearProgressIndicator(
                                                                  value: Converter
                                                                      .getPercent(
                                                                          model
                                                                              .progressPercent),
                                                                  backgroundColor: MyColor
                                                                          .getScreenBgColor()
                                                                      .withOpacity(
                                                                          .08),
                                                                  color: MyColor
                                                                      .greenSuccessColor,
                                                                  minHeight: 7,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4),
                                                                ),
                                                              ],
                                                            ))
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    )
                                  ],
                                ),
                        ),
                      ),
              ),
            ));
  }
}
