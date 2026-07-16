// lib/presentation/screens/player/player_screen_widgets/engagement_bar/stat_badge_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Padding
  static const double verticalPadding = 4;
  static const double horizontalPadding = 2;

  // Icon / Loading
  static const double iconSize = 15;
  static const double loadingSize = 15;
  static const double loadingStrokeWidth = 1.5;

  // Spacing
  static const double iconTextSpacing = 4;

  // Loading skeleton
  static const double skeletonWidth = 24;
  static const double skeletonHeight = 8;
  static const double skeletonBorderRadius = 4;
  static const double skeletonOpacity = 0.15;

  // Text
  static const double textFontSize = 12;
  static const double textLineHeight = 1.2;
  static const double textDecorationThickness = 1.2;
  static const double textDecorationOpacity = 0.3;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 200);
}

class _TabletSizes {
  // Padding - tablet için daha büyük
  static const double verticalPadding = 6;
  static const double horizontalPadding = 3;

  // Icon / Loading - tablet için daha büyük
  static const double iconSize = 18;
  static const double loadingSize = 18;
  static const double loadingStrokeWidth = 2;

  // Spacing - tablet için daha büyük
  static const double iconTextSpacing = 5;

  // Loading skeleton - tablet için daha büyük
  static const double skeletonWidth = 30;
  static const double skeletonHeight = 10;
  static const double skeletonBorderRadius = 5;
  static const double skeletonOpacity = 0.15;

  // Text - tablet için daha büyük
  static const double textFontSize = 14;
  static const double textLineHeight = 1.2;
  static const double textDecorationThickness = 1.5;
  static const double textDecorationOpacity = 0.3;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 200);
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class StatBadgeWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool loading;
  final bool tappable;

  const StatBadgeWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.loading,
    this.tappable = false,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final Color iconColor = tappable
        ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
        : AppTheme.textSec(context);

    final Color textColor = tappable
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _PhoneSizes.verticalPadding.h,
        horizontal: _PhoneSizes.horizontalPadding.w,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: _PhoneSizes.loadingSize.sp,
              height: _PhoneSizes.loadingSize.sp,
              child: CircularProgressIndicator(
                strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
                color: AppTheme.textSec(context).withOpacity(0.5),
              ),
            )
          else
            Icon(
              icon,
              color: iconColor,
              size: _PhoneSizes.iconSize.sp,
            ),
          SizedBox(width: _PhoneSizes.iconTextSpacing.w),
          if (loading)
            Container(
              width: _PhoneSizes.skeletonWidth.w,
              height: _PhoneSizes.skeletonHeight.h,
              decoration: BoxDecoration(
                color: AppTheme.textSec(context).withOpacity(
                  _PhoneSizes.skeletonOpacity,
                ),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.skeletonBorderRadius.r,
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration: _PhoneSizes.animDuration,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _fmt(count),
                key: ValueKey(count),
                style: TextStyle(
                  color: textColor,
                  fontSize: _PhoneSizes.textFontSize.sp,
                  fontWeight: tappable ? FontWeight.w600 : FontWeight.normal,
                  height: _PhoneSizes.textLineHeight,
                  decoration: tappable
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(_PhoneSizes.textDecorationOpacity),
                  decorationThickness: _PhoneSizes.textDecorationThickness,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final Color iconColor = tappable
        ? Theme.of(context).colorScheme.primary.withOpacity(0.7)
        : AppTheme.textSec(context);

    final Color textColor = tappable
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _TabletSizes.verticalPadding,
        horizontal: _TabletSizes.horizontalPadding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: _TabletSizes.loadingSize,
              height: _TabletSizes.loadingSize,
              child: CircularProgressIndicator(
                strokeWidth: _TabletSizes.loadingStrokeWidth,
                color: AppTheme.textSec(context).withOpacity(0.5),
              ),
            )
          else
            Icon(
              icon,
              color: iconColor,
              size: _TabletSizes.iconSize,
            ),
          SizedBox(width: _TabletSizes.iconTextSpacing),
          if (loading)
            Container(
              width: _TabletSizes.skeletonWidth,
              height: _TabletSizes.skeletonHeight,
              decoration: BoxDecoration(
                color: AppTheme.textSec(context).withOpacity(
                  _TabletSizes.skeletonOpacity,
                ),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.skeletonBorderRadius,
                ),
              ),
            )
          else
            AnimatedSwitcher(
              duration: _TabletSizes.animDuration,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _fmt(count),
                key: ValueKey(count),
                style: TextStyle(
                  color: textColor,
                  fontSize: _TabletSizes.textFontSize,
                  fontWeight: tappable ? FontWeight.w600 : FontWeight.normal,
                  height: _TabletSizes.textLineHeight,
                  decoration: tappable
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(_TabletSizes.textDecorationOpacity),
                  decorationThickness: _TabletSizes.textDecorationThickness,
                ),
              ),
            ),
        ],
      ),
    );
  }
}