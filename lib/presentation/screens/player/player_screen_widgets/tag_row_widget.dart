// ═══════════════════════════════════════════════════════════════════════════
// Etiketler
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double spacing = 6;
  static const double runSpacing = 6;
  static const double paddingHorizontal = 10;
  static const double paddingVertical = 4;
  static const double borderRadius = 20;
  static const double fontSize = 11;
}

class _TabletSizes {
  static const double spacing = 8;
  static const double runSpacing = 8;
  static const double paddingHorizontal = 14;
  static const double paddingVertical = 6;
  static const double borderRadius = 24;
  static const double fontSize = 13;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class TagsRowWidget extends StatelessWidget {
  final List<String> tags;
  const TagsRowWidget({super.key, required this.tags});

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
    return Wrap(
      spacing: _PhoneSizes.spacing.w,
      runSpacing: _PhoneSizes.runSpacing.h,
      children: tags
          .take(8)
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.paddingHorizontal.w,
                vertical: _PhoneSizes.paddingVertical.h,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.fontSize.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Wrap(
      spacing: _TabletSizes.spacing,
      runSpacing: _TabletSizes.runSpacing,
      children: tags
          .take(8)
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.paddingHorizontal,
                vertical: _TabletSizes.paddingVertical,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.fontSize,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}