import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';

class KycPendingBanner extends StatelessWidget {
  final VoidCallback? onTap;
  final String message;
  final bool isUnderReview;

  const KycPendingBanner({
    super.key,
    this.onTap,
    required this.message,
    this.isUnderReview = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.space15,
          vertical: Dimensions.space15,
        ),
        decoration: BoxDecoration(
          color: MyColor.getPrimaryColor()
              .withOpacity(isUnderReview ? 0.08 : 0.12),
          borderRadius: BorderRadius.circular(Dimensions.space12),
          border: Border.all(
            color: MyColor.getPrimaryColor()
                .withOpacity(isUnderReview ? 0.2 : 0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isUnderReview
                  ? Icons.info_outline
                  : Icons.assignment_turned_in_outlined,
              color: MyColor.getPrimaryColor(),
              size: 24,
            ),
            const SizedBox(width: Dimensions.space12),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.start,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MyColor.getTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: Dimensions.space12),
              Icon(
                Icons.chevron_right,
                color: MyColor.getPrimaryColor(),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
