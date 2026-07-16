// lib/presentation/screens/radio/widgets/radio_dot_indicator_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double activeWidth = 18;
  static const double inactiveWidth = 6;
  static const double height = 6;
  static const double horizontalMargin = 2;
  static const double borderRadius = 3;
  static const double inactiveAlpha = 0.25;
}

class _TabletSizes {
  static const double activeWidth = 24;
  static const double inactiveWidth = 8;
  static const double height = 8;
  static const double horizontalMargin = 3;
  static const double borderRadius = 4;
  static const double inactiveAlpha = 0.25;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioDotIndicatorWidget extends StatelessWidget {
  final int count;
  final int current;

  const RadioDotIndicatorWidget({
    super.key,
    required this.count,
    required this.current,
  });

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
    final start = (current - 3).clamp(0, (count - 7).clamp(0, count));
    final end = (start + 7).clamp(0, count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? _PhoneSizes.activeWidth.w : _PhoneSizes.inactiveWidth.w,
          height: _PhoneSizes.height.h,
          margin: EdgeInsets.symmetric(horizontal: _PhoneSizes.horizontalMargin.w),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: _PhoneSizes.inactiveAlpha),
            borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final start = (current - 3).clamp(0, (count - 7).clamp(0, count));
    final end = (start + 7).clamp(0, count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? _TabletSizes.activeWidth : _TabletSizes.inactiveWidth,
          height: _TabletSizes.height,
          margin: EdgeInsets.symmetric(horizontal: _TabletSizes.horizontalMargin),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: _TabletSizes.inactiveAlpha),
            borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
          ),
        );
      }),
    );
  }
}