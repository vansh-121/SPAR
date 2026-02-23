import 'package:flutter/material.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/support/support_controller.dart';
import 'package:hyip_lab/data/repo/support/support_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/screens/ticket/all_ticket_screen/widget/all_ticket_list_item.dart';
import 'package:get/get.dart';

import '../../../../core/routes/route.dart';
import '../../../../core/utils/ticket_helper.dart';
import '../../../components/appbar/custom_appbar.dart';
import '../../../components/floating_action_button/fab.dart';
import '../../../components/no_support_ticket_screen.dart';

class AllTicketScreen extends StatefulWidget {
  const AllTicketScreen({super.key});

  @override
  State<AllTicketScreen> createState() => _AllTicketScreenState();
}

class _AllTicketScreenState extends State<AllTicketScreen> {
  ScrollController scrollController = ScrollController();

  void scrollListener() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (Get.find<SupportController>().hasNext()) {
        Get.find<SupportController>().getSupportTicket();
      }
    }
  }

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    final controller = Get.put(SupportController(repo: Get.find()));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
      scrollController.addListener(scrollListener);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupportController>(builder: (controller) {
      return Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(title: MyStrings.supportTicket),
        body: controller.isLoading ? const CustomLoader() : RefreshIndicator(
            onRefresh: () async {
              controller.loadData();
            },
            color: MyColor.primaryColor,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: Dimensions.defaultPaddingHV,
              child: controller.ticketList.isEmpty ?
              const Center(child: NoSupportTicketScreen()) :
              ListView.separated(
                controller: scrollController,
                itemCount: controller.ticketList.length + 1,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                separatorBuilder: (context, index) => const SizedBox(height: Dimensions.space10),
                itemBuilder: (context, index) {
                  if (controller.ticketList.length == index) {
                    return controller.hasNext()
                        ? const CustomLoader(isPagination: true)
                        : const SizedBox();
                  }
                  return GestureDetector(
                      onTap: () {
                        String id = controller.ticketList[index].ticket ?? '-1';
                        String subject = controller.ticketList[index].subject ?? '';
                        Get.toNamed(RouteHelper.ticketDetailsScreen, arguments: [id, subject])?.then((value) {
                          if(value != null && value == 'updated'){
                            // controller.getSupportTicket(),
                            controller.loadData();
                          }
                        },);
                      },
                      child: AllTicketListItem(
                          ticketNumber: controller.ticketList[index].ticket ?? '',
                          subject: controller.ticketList[index].subject ?? '',
                          status: TicketHelper.getStatusText(controller.ticketList[index].status ?? '0'),
                          priority: TicketHelper.getPriorityText(controller.ticketList[index].priority ?? '0'),
                          statusColor: TicketHelper.getStatusColor(controller.ticketList[index].status ?? '0'),
                          priorityColor: TicketHelper.getPriorityColor(controller.ticketList[index].priority ?? '0'),
                          time: DateConverter.getFormatedSubtractTime(controller.ticketList[index].createdAt ?? '')
                      )
                  );
                },
              ),
            )),
        floatingActionButton: FAB(
          callback: () {
            Get.toNamed(RouteHelper.newTicketScreen)?.then(
                    (value) => {
                  if(value != null && value == 'updated'){
                    // controller.getSupportTicket(),
                    controller.loadData()
                  }
                });
          },
        ),
      );
    });
  }
}