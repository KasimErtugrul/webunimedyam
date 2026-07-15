// lib/presentation/screens/home/widgets/tabs/home_tab/videos/video_horizontal_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/video_engagement_model.dart';

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
  static const double gradientHeight = 36;
  static const double durationBottom = 6;
  static const double durationRight = 6;
  static const double durationPaddingHorizontal = 5;
  static const double durationPaddingVertical = 2;
  static const double durationBorderRadius = 4;
  static const double durationFontSize = 9;
  
  // Content
  static const double contentPaddingHorizontal = 8;
  static const double contentPaddingVertical = 5;
  static const double titleFontSize = 10.5;
  static const double titleLineHeight = 1.25;
  static const double channelFontSize = 9;
  static const double statSpacing = 3;
  static const double statPaddingHorizontal = 5;
  static const double statPaddingVertical = 2;
  static const double statBorderRadius = 6;
  static const double statIconSize = 9;
  static const double statFontSize = 8.5;
  
  // Placeholder
  static const double placeholderIconSize = 32;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double cardWidth = 180;
  static const double cardHeight = 220;
  static const double cardMarginRight = 14;
  static const double cardBorderRadius = 16;
  
  // Thumbnail - tablet için daha büyük
  static const double gradientHeight = 40;
  static const double durationBottom = 8;
  static const double durationRight = 8;
  static const double durationPaddingHorizontal = 6;
  static const double durationPaddingVertical = 3;
  static const double durationBorderRadius = 5;
  static const double durationFontSize = 10;
  
  // Content - tablet için daha okunaklı
  static const double contentPaddingHorizontal = 10;
  static const double contentPaddingVertical = 6;
  static const double titleFontSize = 12;
  static const double titleLineHeight = 1.3;
  static const double channelFontSize = 10;
  static const double statSpacing = 4;
  static const double statPaddingHorizontal = 6;
  static const double statPaddingVertical = 3;
  static const double statBorderRadius = 7;
  static const double statIconSize = 10;
  static const double statFontSize = 9.5;
  
  // Placeholder - tablet için daha büyük
  static const double placeholderIconSize = 36;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class VideoHorizontalCard extends StatelessWidget {
  final VideoEngagementModel video;
  final String Function(VideoEngagementModel) statLabelBuilder;
  final IconData statIcon;

  const VideoHorizontalCard({
    super.key,
    required this.video,
    required this.statLabelBuilder,
    required this.statIcon,
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
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video.toVideoModel(),
        parameters: {'videoId': video.toVideoModel().videoId},
      ),
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
            // ── Thumbnail ─────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: video.fallbackThumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholderPhone(context),
                      placeholder: (_, _) => _shimmerBoxPhone(context),
                    ),
                    placeholder: (_, _) => _shimmerBoxPhone(context),
                  ),
                  // Gradient overlay
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
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Süre chip'i — sağ alt
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: _PhoneSizes.durationBottom.h,
                      right: _PhoneSizes.durationRight.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _PhoneSizes.durationPaddingHorizontal.w,
                          vertical: _PhoneSizes.durationPaddingVertical.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.durationBorderRadius.r,
                          ),
                        ),
                        child: Text(
                          _formatDuration(video.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.durationFontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Alt: Başlık + Kanal + Stat ───────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.contentPaddingHorizontal.w,
                  vertical: _PhoneSizes.contentPaddingVertical.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Video başlığı
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: _PhoneSizes.titleFontSize.sp,
                          fontWeight: FontWeight.w700,
                          height: _PhoneSizes.titleLineHeight,
                        ),
                      ),
                    ),
                    // Kanal adı
                    Text(
                      video.channelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _PhoneSizes.channelFontSize.sp,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.statSpacing.h),
                    // İstatistik chip
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
                              statLabelBuilder(video),
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

  Widget _placeholderPhone(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _PhoneSizes.placeholderIconSize.sp,
    ),
  );

  Widget _shimmerBoxPhone(BuildContext context) =>
      Container(color: AppTheme.surface(context));

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video.toVideoModel(),
        parameters: {'videoId': video.toVideoModel().videoId},
      ),
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
            // ── Thumbnail ─────────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: video.fallbackThumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholderTablet(context),
                      placeholder: (_, _) => _shimmerBoxTablet(context),
                    ),
                    placeholder: (_, _) => _shimmerBoxTablet(context),
                  ),
                  // Gradient overlay
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
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Süre chip'i — sağ alt
                  if (video.duration.isNotEmpty)
                    Positioned(
                      bottom: _TabletSizes.durationBottom,
                      right: _TabletSizes.durationRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _TabletSizes.durationPaddingHorizontal,
                          vertical: _TabletSizes.durationPaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.durationBorderRadius,
                          ),
                        ),
                        child: Text(
                          _formatDuration(video.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.durationFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Alt: Başlık + Kanal + Stat ───────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.contentPaddingHorizontal,
                  vertical: _TabletSizes.contentPaddingVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Video başlığı
                    Expanded(
                      child: Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: _TabletSizes.titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: _TabletSizes.titleLineHeight,
                        ),
                      ),
                    ),
                    // Kanal adı
                    Text(
                      video.channelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.channelFontSize,
                      ),
                    ),
                    SizedBox(height: _TabletSizes.statSpacing),
                    // İstatistik chip
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
                              statLabelBuilder(video),
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

  Widget _placeholderTablet(BuildContext context) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: _TabletSizes.placeholderIconSize,
    ),
  );

  Widget _shimmerBoxTablet(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}

// ─── ISO 8601 süreyi "MM:SS" formatına çevirir ───────────────────────────────

String _formatDuration(String iso) {
  // Örnek: PT1H20M30S, PT20M30S, PT45S
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final match = regex.firstMatch(iso);
  if (match == null) return '';

  final h = int.tryParse(match.group(1) ?? '') ?? 0;
  final m = int.tryParse(match.group(2) ?? '') ?? 0;
  final s = int.tryParse(match.group(3) ?? '') ?? 0;

  if (h > 0) {
    return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$m:${s.toString().padLeft(2, '0')}';
}