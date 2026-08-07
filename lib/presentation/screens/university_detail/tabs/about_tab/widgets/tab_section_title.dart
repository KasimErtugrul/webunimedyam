import 'package:flutter/material.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../utils/university_detail_sizes.dart';

class UniversityDetailAboutTabSectionTitle extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final String title;
  const UniversityDetailAboutTabSectionTitle({super.key, required this.sizes, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: sizes.sectionTitleFontSize,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPri(context),
      ),
    );
  }
}