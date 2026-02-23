import 'package:flutter/material.dart';

import '../../../core/utils/dimensions.dart';
import '../../../core/utils/style.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  const StatusBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space10, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(Dimensions.badgeRadius),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: interRegularDefault.copyWith(
          color: color,
        ),
      ),
    );
  }
}
