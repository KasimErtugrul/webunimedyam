import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../utils/university_detail_sizes.dart';

class UniversityDetailVideosTabEmptyView extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final IconData icon;
  final String title;
  final String subtitle;
  const UniversityDetailVideosTabEmptyView({super.key, 
    required this.sizes,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sizes.emptyIconSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: sizes.emptyIconContainerSize,
              height: sizes.emptyIconContainerSize,
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: sizes.emptyIconSize,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: sizes.emptySpacingLarge),
            Text(
              title,
              style: TextStyle(
                fontSize: sizes.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: sizes.emptySpacingSmall),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: sizes.emptySubtitleFontSize,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
