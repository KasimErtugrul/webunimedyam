// ─── Section Header ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/settings_sizes.dart';

class SettingsSectionHeader extends StatelessWidget {
  final SettingsSizes sizes;
  final String title;
  const SettingsSectionHeader({
    super.key,
    required this.sizes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.sectionHeaderPaddingLeft,
        sizes.sectionHeaderPaddingTop,
        sizes.sectionHeaderPaddingRight,
        sizes.sectionHeaderPaddingBottom,
      ),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: sizes.sectionHeaderFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: sizes.sectionHeaderLetterSpacing,
        ),
      ),
    );
  }
}