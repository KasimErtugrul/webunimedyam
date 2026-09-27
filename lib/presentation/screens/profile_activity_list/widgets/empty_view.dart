// ─── Boş Durum ──────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/profile_activity_list_controller.dart';
import '../utils/sizes.dart';

class ProfileActivityListEmptyView extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final String emptyText;
  final String emptySubtext;
  final ProfileActivityType activityType;

  const ProfileActivityListEmptyView({
    super.key,
    required this.sizes,
    required this.emptyText,
    required this.emptySubtext,
    required this.activityType,
  });

  IconData get _icon {
    switch (activityType) {
      case ProfileActivityType.favorites:
        return Icons.favorite_outline_rounded;
      case ProfileActivityType.viewed:
        return Icons.play_circle_outline_rounded;
      case ProfileActivityType.commented:
        return Icons.chat_bubble_outline_rounded;
      case ProfileActivityType.shared:
        return Icons.share_outlined;
      case ProfileActivityType.liked:
        return Icons.thumb_up_alt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sizes.emptyPaddingHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: AppTheme.textSec(context),
              size: sizes.emptyIconSize,
            ),
            SizedBox(height: sizes.emptySpacingLarge),
            Text(
              emptyText,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: sizes.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sizes.emptySpacingSmall),
            Text(
              emptySubtext,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.emptySubtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}