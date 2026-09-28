import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/university_stats_section_detail_sizes.dart';

class UniversityStatsSectionDetailErrorView extends StatelessWidget {
  const UniversityStatsSectionDetailErrorView({
    super.key,
    required this.sizes,
    required this.message,
    required this.onRetry,
  });

  final UniversityStatsSectionDetailSizes sizes;
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.textSec(context),
              size: sizes.errorIconSize,
            ),
            SizedBox(height: sizes.errorTextSpacing),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSec(context)),
            ),
            SizedBox(height: sizes.errorButtonSpacing),
            TextButton(
              onPressed: onRetry,
              child: const Text('Yeniden Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
