// ─── Visibility Tile ─────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_settings_model.dart';
import '../utils/settings_sizes.dart';
import 'visibility_badge.dart';
import 'visibility_option_row.dart';

class SettingsVisibilityTile extends StatelessWidget {
  final SettingsSizes sizes;
  final IconData icon;
  final String title;
  final String subtitle;
  final VisibilityOption current;
  final VisibilityOption? ceiling;
  final Future<void> Function(VisibilityOption) onChanged;

  const SettingsVisibilityTile({
    super.key,
    required this.sizes,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.ceiling,
    required this.onChanged,
  });

  bool _isAllowed(VisibilityOption option) {
    if (ceiling == null) return true;
    const order = [VisibilityOption.private, VisibilityOption.public];
    return order.indexOf(option) <= order.indexOf(ceiling!);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: sizes.visIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: sizes.visTitleFontSize,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: sizes.visSubtitleFontSize,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SettingsVisibilityBadge(sizes: sizes, option: current),
          SizedBox(width: sizes.visTrailingSpacing),
          Icon(
            Icons.chevron_right,
            color: AppTheme.textSec(context),
            size: sizes.visTrailingChevronSize,
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: sizes.tileContentPaddingHorizontal,
      ),
      onTap: () => _showSheet(context),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(sizes.sheetBorderRadius),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: sizes.sheetHandleSpacing),
            Container(
              width: sizes.sheetHandleWidth,
              height: sizes.sheetHandleHeight,
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  sizes.sheetHandleBorderRadius,
                ),
              ),
            ),
            SizedBox(height: sizes.sheetHandleSpacing),
            Text(
              title,
              style: TextStyle(
                fontSize: sizes.sheetTitleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: sizes.sheetHandleSpacing),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: sizes.sheetSubtitleFontSize,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: sizes.sheetOptionSpacing),
            for (final option in VisibilityOption.values)
              SettingsVisibilityOptionRow(
                sizes: sizes,
                option: option,
                isCurrent: option == current,
                isAllowed: _isAllowed(option),
                ceiling: ceiling,
                onTap: () {
                  if (!_isAllowed(option)) return;
                  Get.back();
                  onChanged(option);
                },
              ),
            SizedBox(height: sizes.sheetBottomPadding),
          ],
        ),
      ),
    );
  }
}
