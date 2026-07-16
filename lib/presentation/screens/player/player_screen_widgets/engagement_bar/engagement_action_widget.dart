import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Buton
  static const double borderRadius = 20;
  static const double horizontalPadding = 12;
  static const double verticalPadding = 8;
  static const double iconSize = 20;
  static const double loadingIndicatorSize = 20;
  static const double loadingStrokeWidth = 2.0;
  static const double textFontSize = 13;
  static const double textSpacing = 6;
}

class _TabletSizes {
  // Buton - tablet için biraz daha büyük ama kompakt
  static const double borderRadius = 22;
  static const double horizontalPadding = 14;
  static const double verticalPadding = 10;
  static const double iconSize = 22;
  static const double loadingIndicatorSize = 22;
  static const double loadingStrokeWidth = 2.5;
  static const double textFontSize = 14;
  static const double textSpacing = 7;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

/// Tıklanabilir aksiyon butonu — ikon + sayı (MD3 Tinted ve Animasyonlu)
class EngagementActionWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool loading;
  final VoidCallback onTap;

  const EngagementActionWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.active,
    required this.loading,
    required this.onTap,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    if (n == 0) return '';
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
    final color = active
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);

    final bgColor = active
        ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.horizontalPadding.w,
          vertical: _PhoneSizes.verticalPadding.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: _PhoneSizes.loadingIndicatorSize.sp,
                height: _PhoneSizes.loadingIndicatorSize.sp,
                child: CircularProgressIndicator(
                  strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
                  color: color,
                ),
              )
            else
              AnimatedScale(
                scale: active ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  color: color,
                  size: _PhoneSizes.iconSize.sp,
                ),
              ),
            if (_fmt(count).isNotEmpty) ...[
              SizedBox(width: _PhoneSizes.textSpacing.w),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _fmt(count),
                  key: ValueKey(count),
                  style: TextStyle(
                    color: color,
                    fontSize: _PhoneSizes.textFontSize.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final color = active
        ? Theme.of(context).colorScheme.primary
        : AppTheme.textSec(context);

    final bgColor = active
        ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
        : Colors.transparent;

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
      splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.horizontalPadding,
          vertical: _TabletSizes.verticalPadding,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: _TabletSizes.loadingIndicatorSize,
                height: _TabletSizes.loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: _TabletSizes.loadingStrokeWidth,
                  color: color,
                ),
              )
            else
              AnimatedScale(
                scale: active ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(
                  icon,
                  color: color,
                  size: _TabletSizes.iconSize,
                ),
              ),
            if (_fmt(count).isNotEmpty) ...[
              SizedBox(width: _TabletSizes.textSpacing),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  _fmt(count),
                  key: ValueKey(count),
                  style: TextStyle(
                    color: color,
                    fontSize: _TabletSizes.textFontSize,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}