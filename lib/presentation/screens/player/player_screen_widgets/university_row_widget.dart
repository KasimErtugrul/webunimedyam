// ═══════════════════════════════════════════════════════════════════════════
// Üniversite Satırı  (logo · üniversite adı)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double borderRadius = 10;
  static const double verticalPadding = 4;
  static const double fontSize = 13;
  static const double lineHeight = 1.3;
  static const double chevronSize = 18;
}

class _TabletSizes {
  static const double borderRadius = 12;
  static const double verticalPadding = 6;
  static const double fontSize = 16;
  static const double lineHeight = 1.35;
  static const double chevronSize = 22;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversityRowWidget extends StatelessWidget {
  final String universityName;
  final String? logoUrl;
  final VoidCallback? onTap;

  const UniversityRowWidget({
    super.key,
    required this.universityName,
    this.logoUrl,
    this.onTap,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: _PhoneSizes.verticalPadding.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                universityName,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _PhoneSizes.fontSize.sp,
                  fontWeight: FontWeight.w600,
                  height: _PhoneSizes.lineHeight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: _PhoneSizes.chevronSize.sp,
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: _TabletSizes.verticalPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                universityName,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _TabletSizes.fontSize,
                  fontWeight: FontWeight.w600,
                  height: _TabletSizes.lineHeight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: _TabletSizes.chevronSize,
              ),
          ],
        ),
      ),
    );
  }
}