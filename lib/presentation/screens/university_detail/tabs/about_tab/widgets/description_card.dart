import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../utils/university_detail_sizes.dart';

class UniversityDetailAboutTabDescriptionCard extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final dynamic uni;
  const UniversityDetailAboutTabDescriptionCard({super.key, required this.sizes, required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizes.aboutCardPadding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.aboutCardBorderRadius),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ReadMoreText(
        (uni.description != null && uni.description!.isNotEmpty)
            ? uni.description!
            : 'Bu üniversite için açıklama bulunmuyor.',
        trimMode: TrimMode.Line,
        trimLines: 5,
        trimCollapsedText: ' Daha fazla',
        trimExpandedText: ' Daha az',
        style: TextStyle(
          fontSize: sizes.aboutDescriptionFontSize,
          color: AppTheme.textSec(context),
          height: sizes.aboutDescriptionLineHeight,
          fontStyle: (uni.description != null && uni.description!.isNotEmpty)
              ? FontStyle.normal
              : FontStyle.italic,
        ),
        moreStyle: TextStyle(
          fontSize: sizes.aboutDescriptionFontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
        lessStyle: TextStyle(
          fontSize: sizes.aboutDescriptionFontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}