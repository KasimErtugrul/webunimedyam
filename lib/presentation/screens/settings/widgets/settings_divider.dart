// ─── Divider ──────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/settings_sizes.dart';

class SettingsDivider extends StatelessWidget {
  final SettingsSizes sizes;
  const SettingsDivider({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: sizes.dividerHeight,
      thickness: sizes.dividerThickness,
      color: AppTheme.surface(context),
    );
  }
}