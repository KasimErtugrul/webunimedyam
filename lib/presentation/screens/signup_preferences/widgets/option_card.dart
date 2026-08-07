// ═══════════════════════════════════════════════════════════════════════
// Ortak "seçilebilir kart" bileşeni
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/singup_preferences_sizes.dart';

class OptionCard extends StatelessWidget {
  final SignupPreferencesSizes sizes;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const OptionCard({super.key, 
    required this.sizes,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(sizes.optionRadius),
      child: Container(
        padding: EdgeInsets.all(sizes.optionPadding),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.12)
              : AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.optionRadius),
          border: Border.all(
            color: selected
                ? primary
                : AppTheme.textSec(context).withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? primary : AppTheme.textSec(context),
              size: sizes.optionIconSize,
            ),
            SizedBox(width: sizes.isTablet ? 20 : 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: sizes.optionTitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: sizes.isTablet ? 4 : 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: sizes.optionSubtitleFontSize,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: primary,
                size: sizes.optionCheckIconSize,
              ),
          ],
        ),
      ),
    );
  }
}
