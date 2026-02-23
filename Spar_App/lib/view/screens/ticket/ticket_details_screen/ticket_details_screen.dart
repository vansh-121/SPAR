import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/support/ticket_details_controller.dart';
import 'package:hyip_lab/data/repo/support/support_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/warning_aleart_dialog.dart';
import 'package:hyip_lab/view/screens/ticket/ticket_details_screen/sections/message_list_section.dart';
import 'package:hyip_lab/view/screens/ticket/ticket_details_screen/sections/reply_section.dart';
import 'package:hyip_lab/view/screens/ticket/ticket_details_screen/widget/ticket_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketDetailsScreen extends StatefulWidget {
  const TicketDetailsScreen({super.key});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  String title = "";
  @override
  void initState() {
    String ticketId = Get.arguments[0];
    title = Get.arguments[1];
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(SupportRepo(apiClient: Get.find()));
    var controller = Get.put(TicketDetailsController(repo: Get.find(), ticketId: ticketId));

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketDetailsController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: const Text(MyStrings.replyTicket),
          actions: [
            if (controller.model.data?.myTickets?.status != '3')
              Padding(
                padding: const EdgeInsets.only(right: Dimensions.space20),
                child: TextButton(
                  onPressed: () {

                    const WarningAlertDialog().warningAlertDialog(subtitleMessage: MyStrings.youWantToCloseThisTicket.tr, context, () {
                      Navigator.pop(context);
                      controller.closeTicket(controller.model.data?.myTickets?.id.toString() ?? '-1');
                    });

                  },
                  child: controller.closeLoading? Text(MyStrings.loading, style: interRegularMediumLarge.copyWith(color: MyColor.colorWhite)) : controller.isLoading ? const SizedBox.shrink() : Text(MyStrings.close, style: interRegularMediumLarge.copyWith(color: MyColor.colorWhite))
                ),
              )
          ],
        ),
        body: controller.isLoading ?
        const CustomLoader(isFullScreen: true) :
        SingleChildScrollView(
          padding: Dimensions.screenPadding,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                TicketStatusWidget(controller: controller),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: MyColor.getCardBg(),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReplySection(),
                      MessageListSection()
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}

