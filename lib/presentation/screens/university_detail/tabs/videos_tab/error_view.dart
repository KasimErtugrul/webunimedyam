import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../utils/university_detail_sizes.dart';

class UniversityDetailVideosTabErrorView extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final String error;
  final VoidCallback onRetry;
  const UniversityDetailVideosTabErrorView({super.key, 
    required this.sizes,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(sizes.errorIconSize),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: sizes.errorIconSize,
              color: AppTheme.textSec(context),
            ),
            SizedBox(height: sizes.errorSpacingLarge),
            Text(
              error,
              style: TextStyle(
                fontSize: sizes.errorFontSize,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: sizes.errorSpacingSmall),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: sizes.errorIconSize * 0.4,
              ),
              label: Text(
                'Tekrar Dene',
                style: TextStyle(fontSize: sizes.errorFontSize - 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}