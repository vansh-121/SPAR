import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/view/components/timer_widget.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
class CampaignCardWidget extends StatefulWidget {

  final DateTime deadline;

  const CampaignCardWidget({
    super.key,
    required this.deadline,
  });

  @override
  State<CampaignCardWidget> createState() => _CampaignCardWidgetState();
}

class _CampaignCardWidgetState extends State<CampaignCardWidget> {

  late Timer timer;
  Duration duration = const Duration();

  @override
  void initState() {
    calculateTimeLeft(widget.deadline);
    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => calculateTimeLeft(widget.deadline),
    );
    super.initState();
  }

  void calculateTimeLeft(DateTime deadline) {
    final seconds = deadline.difference(DateTime.now()).inSeconds;
    setState(() => duration = Duration(seconds: seconds));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    final days = duration.inDays.toString().padLeft(2,'0');
    final hours = duration.inHours.toString().padLeft(2,'0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    if(days == "00" && hours == '00' && minutes == '00' && seconds == '00'){
      Get.back();
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          // top: 10,
          // left: 10,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: EdgeInsets.only(left: size.width * .02,top: 4,bottom: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: MyColor.getScreenBgColor()
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                days != '00' ?
                TimerWidget(
                  value: days,
                  subtitle: MyStrings.days,
                ) : const SizedBox.shrink(),
                hours != '00' ?
                TimerWidget(
                  value: hours,
                  subtitle: MyStrings.hrs,
                ) : const SizedBox.shrink(),
                TimerWidget(
                  value: minutes,
                  subtitle: MyStrings.mins,
                ),
                TimerWidget(
                  value: seconds,
                  subtitle: MyStrings.secs,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}