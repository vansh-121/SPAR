import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/controller/support/ticket_details_controller.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/style.dart';
import '../widget/ticket_list_item.dart';

class MessageListSection extends StatelessWidget {
  const MessageListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TicketDetailsController>(
      builder: (controller) => controller.messageList.isEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.space20, vertical: Dimensions.space20),
              decoration: BoxDecoration(
                color: MyColor.bodyTextColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    MyStrings.noMSgFound.tr,
                    style: interRegularDefault.copyWith(
                        color: MyColor.getGreyColor()),
                  ),
                ],
              ))
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.messageList.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => TicketListItem(
                  index: index,
                  messages: controller.messageList[index],
                ),
              ),
            ),
    );
  }
}
