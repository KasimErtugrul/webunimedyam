
// ─── Switch List Tile ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/settings_sizes.dart';

class SettingsSwitchTile extends StatelessWidget {
  final SettingsSizes sizes;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String title;
  final String subtitle;

  const SettingsSwitchTile({
    super.key,
    required this.sizes,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        icon,
        color: AppTheme.textSec(context),
        size: sizes.switchIconSize,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: sizes.switchTitleFontSize,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: sizes.switchSubtitleFontSize,
        ),
      ),
      activeTrackColor: AppTheme.primaryColor,
      contentPadding: EdgeInsets.symmetric(
        horizontal: sizes.tileContentPaddingHorizontal,
      ),
    );
  }
}