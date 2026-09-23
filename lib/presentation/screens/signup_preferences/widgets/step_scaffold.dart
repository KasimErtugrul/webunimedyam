/* // ═══════════════════════════════════════════════════════════════════════
// Ortak adım iskeleti
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/singup_preferences_sizes.dart';

class StepScaffold extends StatelessWidget {
  final SignupPreferencesSizes sizes;
  final IconData headerIcon;
  final String title;
  final String description;
  final List<Widget> options;

  const StepScaffold({super.key, 
    required this.sizes,
    required this.headerIcon,
    required this.title,
    required this.description,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(sizes.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: sizes.isTablet ? 20 : 12.h),
          Center(
            child: Container(
              width: sizes.iconContainerSize,
              height: sizes.iconContainerSize,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                headerIcon,
                color: Theme.of(context).colorScheme.primary,
                size: sizes.iconSize,
              ),
            ),
          ),
          SizedBox(height: sizes.iconSpacing),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: sizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: sizes.titleSpacing),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: sizes.descriptionFontSize,
            ),
          ),
          SizedBox(height: sizes.descriptionSpacing),
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(height: sizes.optionSpacing),
            options[i],
          ],
        ],
      ),
    );
  }
}
 */