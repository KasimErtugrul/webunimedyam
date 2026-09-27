// ─── Section Title ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class StatsSectionTitle extends StatelessWidget {
  final StatsSizes sizes;
  final String title;
  const StatsSectionTitle({super.key, required this.sizes, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: sizes.sectionTitleFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: sizes.sectionTitleLetterSpacing,
      ),
    );
  }
}