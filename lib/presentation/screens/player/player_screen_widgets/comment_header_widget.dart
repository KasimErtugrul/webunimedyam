// ═══════════════════════════════════════════════════════════════════════════
// Yorum başlığı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Başlık
  static const double titleFontSize = 16;
  static const FontWeight titleFontWeight = FontWeight.bold;  // ✅ FontWeight olarak düzeltildi

  // Badge
  static const double badgeHorizontalPadding = 8;
  static const double badgeVerticalPadding = 3;
  static const double badgeBorderRadius = 12;
  static const double badgeFontSize = 12;
  static const double badgeSpacing = 8;
  static const double badgeOpacity = 0.15;

  // Boş durum mesajı
  static const double emptyTopPadding = 4;
  static const double emptyFontSize = 12;

  // Divider
  static const double dividerHeight = 1;
  static const double dividerThickness = 1;
  static const double dividerOpacity = 0.08;
  static const double dividerTopSpacing = 12;
}

class _TabletSizes {
  // Başlık - tablet için daha büyük
  static const double titleFontSize = 20;
  static const FontWeight titleFontWeight = FontWeight.bold;  // ✅ FontWeight olarak düzeltildi

  // Badge - tablet için daha büyük
  static const double badgeHorizontalPadding = 10;
  static const double badgeVerticalPadding = 4;
  static const double badgeBorderRadius = 14;
  static const double badgeFontSize = 14;
  static const double badgeSpacing = 10;
  static const double badgeOpacity = 0.15;

  // Boş durum mesajı - tablet için daha büyük
  static const double emptyTopPadding = 6;
  static const double emptyFontSize = 14;

  // Divider - tablet için
  static const double dividerHeight = 1;
  static const double dividerThickness = 1;
  static const double dividerOpacity = 0.08;
  static const double dividerTopSpacing = 16;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class CommentsHeaderWidget extends StatelessWidget {
  final int count;
  const CommentsHeaderWidget({super.key, required this.count});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Yorumlar',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.titleFontSize.sp,
                fontWeight: _PhoneSizes.titleFontWeight,  // ✅ FontWeight doğru tip
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: _PhoneSizes.badgeSpacing.w),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.badgeHorizontalPadding.w,
                  vertical: _PhoneSizes.badgeVerticalPadding.h,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(_PhoneSizes.badgeOpacity),
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.badgeBorderRadius.r,
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: _PhoneSizes.badgeFontSize.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (count == 0)
          Padding(
            padding: EdgeInsets.only(top: _PhoneSizes.emptyTopPadding.h),
            child: Text(
              'Henüz yorum yapılmamış. İlk sen yaz!',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.emptyFontSize.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: _PhoneSizes.dividerTopSpacing.h),
        Divider(
          height: _PhoneSizes.dividerHeight,
          thickness: _PhoneSizes.dividerThickness,
          color: AppTheme.textSec(context).withOpacity(_PhoneSizes.dividerOpacity),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Yorumlar',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.titleFontSize,
                fontWeight: _TabletSizes.titleFontWeight,  // ✅ FontWeight doğru tip
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: _TabletSizes.badgeSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.badgeHorizontalPadding,
                  vertical: _TabletSizes.badgeVerticalPadding,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(_TabletSizes.badgeOpacity),
                  borderRadius: BorderRadius.circular(
                    _TabletSizes.badgeBorderRadius,
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: _TabletSizes.badgeFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (count == 0)
          Padding(
            padding: EdgeInsets.only(top: _TabletSizes.emptyTopPadding),
            child: Text(
              'Henüz yorum yapılmamış. İlk sen yaz!',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.emptyFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: _TabletSizes.dividerTopSpacing),
        Divider(
          height: _TabletSizes.dividerHeight,
          thickness: _TabletSizes.dividerThickness,
          color: AppTheme.textSec(context).withOpacity(_TabletSizes.dividerOpacity),
        ),
      ],
    );
  }
}