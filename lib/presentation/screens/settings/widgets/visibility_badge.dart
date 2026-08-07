
// ─── Visibility Badge ───────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../data/models/user_settings_model.dart';
import '../utils/settings_sizes.dart';

class SettingsVisibilityBadge extends StatelessWidget {
  final SettingsSizes sizes;
  final VisibilityOption option;
  const SettingsVisibilityBadge({
    super.key,
    required this.sizes,
    required this.option,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (option) {
      VisibilityOption.public => (
        Icons.public_outlined,
        Colors.green,
        'Herkese',
      ),
      VisibilityOption.private => (Icons.lock_outline, Colors.orange, 'Gizli'),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.visBadgePaddingHorizontal,
        vertical: sizes.visBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(sizes.visBadgeBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: sizes.visBadgeBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: sizes.visBadgeIconSize, color: color),
          SizedBox(width: sizes.visTrailingSpacing),
          Text(
            label,
            style: TextStyle(
              fontSize: sizes.visBadgeFontSize,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
