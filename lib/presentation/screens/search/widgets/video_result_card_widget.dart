// lib/presentation/screens/search/widgets/video_result_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/video_model.dart';
import 'highlight_text_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Kart
  static const double bottomMargin = 12;
  static const double borderRadius = 12;
  static const double thumbnailWidth = 120;
  static const double thumbnailHeight = 80;
  static const double thumbnailSpacing = 12;
  static const double verticalPadding = 10;
  static const double titleFontSize = 13;
  static const double uniFontSize = 11;
  static const double viewFontSize = 11;
  static const double spacingSmall = 4;
  static const double spacingMedium = 2;
  static const double thumbnailRadiusTopLeft = 12;
  static const double thumbnailRadiusBottomLeft = 12;
  static const double placeholderIconSize = 32;
  static const double trailingSpacing = 8;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double bottomMargin = 16;
  static const double borderRadius = 14;
  static const double thumbnailWidth = 160;
  static const double thumbnailHeight = 100;
  static const double thumbnailSpacing = 16;
  static const double verticalPadding = 14;
  static const double titleFontSize = 16;
  static const double uniFontSize = 13;
  static const double viewFontSize = 13;
  static const double spacingSmall = 6;
  static const double spacingMedium = 3;
  static const double thumbnailRadiusTopLeft = 14;
  static const double thumbnailRadiusBottomLeft = 14;
  static const double placeholderIconSize = 40;
  static const double trailingSpacing = 12;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class VideoResultCardWidget extends StatelessWidget {
  final VideoModel video;
  final String query;
  final VoidCallback onTap;

  const VideoResultCardWidget({
    super.key,
    required this.video,
    required this.query,
    required this.onTap,
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
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: _PhoneSizes.bottomMargin.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_PhoneSizes.thumbnailRadiusTopLeft.r),
                bottomLeft: Radius.circular(
                  _PhoneSizes.thumbnailRadiusBottomLeft.r,
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: _PhoneSizes.thumbnailWidth.w,
                height: _PhoneSizes.thumbnailHeight.h,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  width: _PhoneSizes.thumbnailWidth.w,
                  height: _PhoneSizes.thumbnailHeight.h,
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.placeholderIconSize.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: _PhoneSizes.thumbnailSpacing.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _PhoneSizes.verticalPadding.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightTextWidget(
                      text: video.title,
                      highlight: query,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.titleFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: _PhoneSizes.spacingSmall.h),
                    if (video.universityName != null)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: _PhoneSizes.uniFontSize.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: _PhoneSizes.spacingMedium.h),
                    Text(
                      video.formattedViewCount,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _PhoneSizes.viewFontSize.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: _PhoneSizes.trailingSpacing.w),
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
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: _TabletSizes.bottomMargin),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_TabletSizes.thumbnailRadiusTopLeft),
                bottomLeft: Radius.circular(
                  _TabletSizes.thumbnailRadiusBottomLeft,
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: _TabletSizes.thumbnailWidth,
                height: _TabletSizes.thumbnailHeight,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  width: _TabletSizes.thumbnailWidth,
                  height: _TabletSizes.thumbnailHeight,
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: _TabletSizes.placeholderIconSize,
                  ),
                ),
              ),
            ),
            SizedBox(width: _TabletSizes.thumbnailSpacing),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: _TabletSizes.verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightTextWidget(
                      text: video.title,
                      highlight: query,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: _TabletSizes.spacingSmall),
                    if (video.universityName != null)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: _TabletSizes.uniFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: _TabletSizes.spacingMedium),
                    Text(
                      video.formattedViewCount,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.viewFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: _TabletSizes.trailingSpacing),
          ],
        ),
      ),
    );
  }
}
