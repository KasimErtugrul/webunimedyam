
// ─── Settings Tile ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/settings_sizes.dart';

class SettingsTile extends StatelessWidget {
  final SettingsSizes sizes;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.sizes,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: sizes.tileIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.textPri(context),
          fontSize: sizes.tileTitleFontSize,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.tileSubtitleFontSize,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSec(context),
        size: sizes.tileTrailingIconSize,
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: sizes.tileContentPaddingHorizontal,
      ),
    );
  }
}