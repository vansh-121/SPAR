import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';

class AutofillSuggestionBanner extends StatelessWidget {
  final String displaySummary;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  const AutofillSuggestionBanner({
    Key? key,
    required this.displaySummary,
    required this.onApply,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.getPrimaryColor().withOpacity(0.15),
            MyColor.getPrimaryColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: MyColor.getPrimaryColor().withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: MyColor.getPrimaryColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              color: MyColor.getScreenBgColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use Previous Details?',
                  style: TextStyle(
                    fontSize: Dimensions.fontDefault,
                    fontWeight: FontWeight.bold,
                    color: MyColor.getTextColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displaySummary,
                  style: TextStyle(
                    fontSize: Dimensions.fontSmall,
                    color: MyColor.getTextColor().withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Apply button
              InkWell(
                onTap: onApply,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: MyColor.getPrimaryColor(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      color: MyColor.getScreenBgColor(),
                      fontSize: Dimensions.fontSmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Dismiss button
              InkWell(
                onTap: onDismiss,
                borderRadius: BorderRadius.circular(20),
                child: Icon(
                  Icons.close,
                  color: MyColor.getTextColor().withOpacity(0.5),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
