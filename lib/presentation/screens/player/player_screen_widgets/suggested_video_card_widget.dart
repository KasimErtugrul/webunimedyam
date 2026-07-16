// lib/presentation/screens/player/player_screen_widgets/suggested_video_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/video_model.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Kart
  static const double cardWidth = 160;
  static const double cardMarginRight = 12;
  static const double cardBorderRadius = 14;
  static const double cardShadowBlur = 4;
  static const double cardShadowOffsetY = 1;

  // Thumbnail
  static const double gradientHeight = 32;
  static const double durationBadgeBottom = 5;
  static const double durationBadgeRight = 5;
  static const double durationBadgePaddingHorizontal = 5;
  static const double durationBadgePaddingVertical = 2;
  static const double durationBadgeBorderRadius = 4;
  static const double durationBadgeFontSize = 9;
  static const double hdBadgeTop = 5;
  static const double hdBadgeRight = 5;
  static const double hdBadgePaddingHorizontal = 4;
  static const double hdBadgePaddingVertical = 2;
  static const double hdBadgeBorderRadius = 4;
  static const double hdBadgeFontSize = 8;
  static const double errorIconSize = 32;

  // Content
  static const double contentPaddingLeft = 8;
  static const double contentPaddingTop = 7;
  static const double contentPaddingRight = 8;
  static const double contentPaddingBottom = 8;
  static const double titleFontSize = 10.5;
  static const double titleLineHeight = 1.25;
  static const double titleSpacing = 4;
  static const double channelFontSize = 9;
  static const double channelSpacing = 4;
  static const double statSpacing = 6;
  static const double statRunSpacing = 4;
  static const double statPaddingHorizontal = 5;
  static const double statPaddingVertical = 2;
  static const double statBorderRadius = 6;
  static const double statIconSize = 9;
  static const double statFontSize = 8.5;
  static const double statSpacingSmall = 3;
  static const double statLikeIconSize = 8;
  static const double statLikeFontSize = 8;
  static const double statUniversityIconSize = 8;
  static const double statUniversityFontSize = 7.5;
  static const double statUniversitySpacing = 2;
  static const double timeFontSize = 7.5;
  static const double timeSpacing = 4;
  static const double schoolIconSize = 10;
  static const double schoolIconSpacing = 4;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double cardWidth = 200;
  static const double cardMarginRight = 14;
  static const double cardBorderRadius = 16;
  static const double cardShadowBlur = 6;
  static const double cardShadowOffsetY = 2;

  // Thumbnail - tablet için daha büyük
  static const double gradientHeight = 36;
  static const double durationBadgeBottom = 6;
  static const double durationBadgeRight = 6;
  static const double durationBadgePaddingHorizontal = 6;
  static const double durationBadgePaddingVertical = 3;
  static const double durationBadgeBorderRadius = 5;
  static const double durationBadgeFontSize = 11;
  static const double hdBadgeTop = 6;
  static const double hdBadgeRight = 6;
  static const double hdBadgePaddingHorizontal = 5;
  static const double hdBadgePaddingVertical = 3;
  static const double hdBadgeBorderRadius = 5;
  static const double hdBadgeFontSize = 9;
  static const double errorIconSize = 40;

  // Content - tablet için daha büyük
  static const double contentPaddingLeft = 10;
  static const double contentPaddingTop = 8;
  static const double contentPaddingRight = 10;
  static const double contentPaddingBottom = 10;
  static const double titleFontSize = 13;
  static const double titleLineHeight = 1.3;
  static const double titleSpacing = 6;
  static const double channelFontSize = 11;
  static const double channelSpacing = 5;
  static const double statSpacing = 8;
  static const double statRunSpacing = 5;
  static const double statPaddingHorizontal = 6;
  static const double statPaddingVertical = 3;
  static const double statBorderRadius = 7;
  static const double statIconSize = 11;
  static const double statFontSize = 10;
  static const double statSpacingSmall = 4;
  static const double statLikeIconSize = 10;
  static const double statLikeFontSize = 9;
  static const double statUniversityIconSize = 10;
  static const double statUniversityFontSize = 9;
  static const double statUniversitySpacing = 3;
  static const double timeFontSize = 9;
  static const double timeSpacing = 5;
  static const double schoolIconSize = 12;
  static const double schoolIconSpacing = 5;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class SuggestedVideoCard extends StatelessWidget {
  final VideoModel video;

  const SuggestedVideoCard({super.key, required this.video});

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
      onTap: () => Get.offNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: _PhoneSizes.cardWidth.w,
        margin: EdgeInsets.only(right: _PhoneSizes.cardMarginRight.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: _PhoneSizes.cardShadowBlur.r,
              offset: Offset(0, _PhoneSizes.cardShadowOffsetY.h),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, _, _) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _PhoneSizes.errorIconSize.sp,
                      ),
                    ),
                  ),
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
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: _PhoneSizes.durationBadgeBottom.h,
                      right: _PhoneSizes.durationBadgeRight.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _PhoneSizes.durationBadgePaddingHorizontal.w,
                          vertical: _PhoneSizes.durationBadgePaddingVertical.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.durationBadgeBorderRadius.r,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.durationBadgeFontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (video.isHd)
                    Positioned(
                      top: _PhoneSizes.hdBadgeTop.h,
                      right: _PhoneSizes.hdBadgeRight.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _PhoneSizes.hdBadgePaddingHorizontal.w,
                          vertical: _PhoneSizes.hdBadgePaddingVertical.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.hdBadgeBorderRadius.r,
                          ),
                        ),
                        child: Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.hdBadgeFontSize.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Alt: Başlık + Kanal + Görüntülenme ──────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                _PhoneSizes.contentPaddingLeft.w,
                _PhoneSizes.contentPaddingTop.h,
                _PhoneSizes.contentPaddingRight.w,
                _PhoneSizes.contentPaddingBottom.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  SizedBox(height: _PhoneSizes.titleSpacing.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _PhoneSizes.channelFontSize.sp,
                          ),
                        ),
                      ),
                      if (video.universityId != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: _PhoneSizes.schoolIconSpacing.w,
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: _PhoneSizes.schoolIconSize.sp,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _PhoneSizes.channelSpacing.h),
                  Wrap(
                    spacing: _PhoneSizes.statSpacing.w,
                    runSpacing: _PhoneSizes.statRunSpacing.h,
                    children: [
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
                              Icons.remove_red_eye_outlined,
                              size: _PhoneSizes.statIconSize.sp,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: _PhoneSizes.statSpacingSmall.w),
                            Flexible(
                              child: Text(
                                video.formattedViewCount,
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
                      if (video.likeCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _PhoneSizes.statPaddingHorizontal.w,
                            vertical: _PhoneSizes.statPaddingVertical.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textSec(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              _PhoneSizes.statBorderRadius.r,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: _PhoneSizes.statLikeIconSize.sp,
                                color: AppTheme.textSec(context),
                              ),
                              SizedBox(width: _PhoneSizes.statSpacingSmall.w),
                              Text(
                                _formatCompact(video.likeCount),
                                style: TextStyle(
                                  color: AppTheme.textSec(context),
                                  fontSize: _PhoneSizes.statLikeFontSize.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (video.universityName != null &&
                          video.universityName!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _PhoneSizes.statPaddingHorizontal.w,
                            vertical: _PhoneSizes.statPaddingVertical.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              _PhoneSizes.statBorderRadius.r,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: _PhoneSizes.statUniversityIconSize.sp,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: _PhoneSizes.statUniversitySpacing.w),
                              Flexible(
                                child: Text(
                                  video.universityName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: _PhoneSizes.statUniversityFontSize.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _PhoneSizes.timeSpacing.h),
                  Text(
                    _relativeTime(video.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.8),
                      fontSize: _PhoneSizes.timeFontSize.sp,
                    ),
                  ),
                ],
              ),
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
    return GestureDetector(
      onTap: () => Get.offNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: _TabletSizes.cardWidth,
        margin: EdgeInsets.only(right: _TabletSizes.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: _TabletSizes.cardShadowBlur,
              offset: Offset(0, _TabletSizes.cardShadowOffsetY),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, _, _) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.errorIconSize,
                      ),
                    ),
                  ),
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
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: _TabletSizes.durationBadgeBottom,
                      right: _TabletSizes.durationBadgeRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _TabletSizes.durationBadgePaddingHorizontal,
                          vertical: _TabletSizes.durationBadgePaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.durationBadgeBorderRadius,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.durationBadgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (video.isHd)
                    Positioned(
                      top: _TabletSizes.hdBadgeTop,
                      right: _TabletSizes.hdBadgeRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _TabletSizes.hdBadgePaddingHorizontal,
                          vertical: _TabletSizes.hdBadgePaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.hdBadgeBorderRadius,
                          ),
                        ),
                        child: Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.hdBadgeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Alt: Başlık + Kanal + Görüntülenme ──────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.contentPaddingLeft,
                _TabletSizes.contentPaddingTop,
                _TabletSizes.contentPaddingRight,
                _TabletSizes.contentPaddingBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  SizedBox(height: _TabletSizes.titleSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _TabletSizes.channelFontSize,
                          ),
                        ),
                      ),
                      if (video.universityId != null)
                        Padding(
                          padding: EdgeInsets.only(
                            left: _TabletSizes.schoolIconSpacing,
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: _TabletSizes.schoolIconSize,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _TabletSizes.channelSpacing),
                  Wrap(
                    spacing: _TabletSizes.statSpacing,
                    runSpacing: _TabletSizes.statRunSpacing,
                    children: [
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
                              Icons.remove_red_eye_outlined,
                              size: _TabletSizes.statIconSize,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: _TabletSizes.statSpacingSmall),
                            Flexible(
                              child: Text(
                                video.formattedViewCount,
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
                      if (video.likeCount > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _TabletSizes.statPaddingHorizontal,
                            vertical: _TabletSizes.statPaddingVertical,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textSec(context).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              _TabletSizes.statBorderRadius,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                size: _TabletSizes.statLikeIconSize,
                                color: AppTheme.textSec(context),
                              ),
                              SizedBox(width: _TabletSizes.statSpacingSmall),
                              Text(
                                _formatCompact(video.likeCount),
                                style: TextStyle(
                                  color: AppTheme.textSec(context),
                                  fontSize: _TabletSizes.statLikeFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (video.universityName != null &&
                          video.universityName!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: _TabletSizes.statPaddingHorizontal,
                            vertical: _TabletSizes.statPaddingVertical,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              _TabletSizes.statBorderRadius,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.school_rounded,
                                size: _TabletSizes.statUniversityIconSize,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: _TabletSizes.statUniversitySpacing),
                              Flexible(
                                child: Text(
                                  video.universityName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontSize: _TabletSizes.statUniversityFontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: _TabletSizes.timeSpacing),
                  Text(
                    _relativeTime(video.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.8),
                      fontSize: _TabletSizes.timeFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ORTAK YARDIMCI METODLAR
  // ═══════════════════════════════════════════════════════════════════════

  String _formatCompact(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
    return count.toString();
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Şimdi';
        return '${diff.inMinutes} dk önce';
      }
      return '${diff.inHours} sa önce';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} g önce';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} hf önce';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} ay önce';
    } else {
      return '${(diff.inDays / 365).floor()} y önce';
    }
  }
}