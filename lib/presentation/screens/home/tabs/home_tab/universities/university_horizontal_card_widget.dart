// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/university_horizontal_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_stats_model.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Kart
  static const double cardWidth = 160;
  static const double cardHeight = 200;
  static const double cardMarginRight = 12;
  static const double cardBorderRadius = 14;
  
  // Thumbnail
  static const double gradientHeight = 40;
  static const double logoSize = 80;
  static const double placeholderIconSize = 32;
  
  // Content
  static const double contentPaddingHorizontal = 8;
  static const double contentPaddingVertical = 6;
  static const double titleFontSize = 11;
  static const double titleLineHeight = 1.3;
  static const double statPaddingHorizontal = 6;
  static const double statPaddingVertical = 3;
  static const double statBorderRadius = 6;
  static const double statIconSize = 10;
  static const double statFontSize = 9.5;
  static const double statSpacing = 3;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double cardWidth = 180;
  static const double cardHeight = 220;
  static const double cardMarginRight = 14;
  static const double cardBorderRadius = 16;
  
  // Thumbnail - tablet için daha büyük
  static const double gradientHeight = 44;
  static const double logoSize = 90;
  static const double placeholderIconSize = 36;
  
  // Content - tablet için daha okunaklı
  static const double contentPaddingHorizontal = 10;
  static const double contentPaddingVertical = 8;
  static const double titleFontSize = 13;
  static const double titleLineHeight = 1.35;
  static const double statPaddingHorizontal = 8;
  static const double statPaddingVertical = 4;
  static const double statBorderRadius = 7;
  static const double statIconSize = 12;
  static const double statFontSize = 11;
  static const double statSpacing = 4;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversityHorizontalCard extends StatelessWidget {
  final UniversityStatsModel stats;
  final String? imageUrl;
  final String statLabel;
  final IconData statIcon;
  final bool showLogoLarge;

  const UniversityHorizontalCard({
    super.key,
    required this.stats,
    required this.imageUrl,
    required this.statLabel,
    required this.statIcon,
    this.showLogoLarge = false,
  });

  void _navigateToDetail() {
    Get.toNamed(AppRoutes.universityDetail, arguments: stats.universityId);
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
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        width: _PhoneSizes.cardWidth.w,
        height: _PhoneSizes.cardHeight.h,
        margin: EdgeInsets.only(right: _PhoneSizes.cardMarginRight.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImagePhone(context),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: _PhoneSizes.gradientHeight.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.card(context).withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.contentPaddingHorizontal.w,
                  vertical: _PhoneSizes.contentPaddingVertical.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stats.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.titleFontSize.sp,
                        fontWeight: FontWeight.w600,
                        height: _PhoneSizes.titleLineHeight,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _PhoneSizes.statPaddingHorizontal.w,
                        vertical: _PhoneSizes.statPaddingVertical.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          _PhoneSizes.statBorderRadius.r,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statIcon,
                            size: _PhoneSizes.statIconSize.sp,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: _PhoneSizes.statSpacing.w),
                          Flexible(
                            child: Text(
                              statLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: _PhoneSizes.statFontSize.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePhone(BuildContext context) {
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _placeholderPhone(context);
    }

    if (showLogoLarge) {
      return Container(
        color: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F0F0),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            width: _PhoneSizes.logoSize.w,
            height: _PhoneSizes.logoSize.w,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => _placeholderPhone(context),
            placeholder: (_, _) => _shimmerBoxPhone(context),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => _placeholderPhone(context),
      placeholder: (_, _) => _shimmerBoxPhone(context),
    );
  }

  Widget _placeholderPhone(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.school_rounded,
      color: AppTheme.textSec(context),
      size: _PhoneSizes.placeholderIconSize.sp,
    ),
  );

  Widget _shimmerBoxPhone(BuildContext context) => Container(
    color: AppTheme.surface(context),
  );

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetail,
      child: Container(
        width: _TabletSizes.cardWidth,
        height: _TabletSizes.cardHeight,
        margin: EdgeInsets.only(right: _TabletSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageTablet(context),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: _TabletSizes.gradientHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.card(context).withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.contentPaddingHorizontal,
                  vertical: _TabletSizes.contentPaddingVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      stats.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.titleFontSize,
                        fontWeight: FontWeight.w600,
                        height: _TabletSizes.titleLineHeight,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _TabletSizes.statPaddingHorizontal,
                        vertical: _TabletSizes.statPaddingVertical,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.statBorderRadius,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statIcon,
                            size: _TabletSizes.statIconSize,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(width: _TabletSizes.statSpacing),
                          Flexible(
                            child: Text(
                              statLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: _TabletSizes.statFontSize,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageTablet(BuildContext context) {
    final url = imageUrl;

    if (url == null || url.isEmpty) {
      return _placeholderTablet(context);
    }

    if (showLogoLarge) {
      return Container(
        color: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F0F0),
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            width: _TabletSizes.logoSize,
            height: _TabletSizes.logoSize,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => _placeholderTablet(context),
            placeholder: (_, _) => _shimmerBoxTablet(context),
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      errorWidget: (_, _, _) => _placeholderTablet(context),
      placeholder: (_, _) => _shimmerBoxTablet(context),
    );
  }

  Widget _placeholderTablet(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.school_rounded,
      color: AppTheme.textSec(context),
      size: _TabletSizes.placeholderIconSize,
    ),
  );

  Widget _shimmerBoxTablet(BuildContext context) => Container(
    color: AppTheme.surface(context),
  );
}