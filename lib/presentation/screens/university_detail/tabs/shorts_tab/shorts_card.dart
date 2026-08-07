// ─── Shorts Card (telefon / tablet) ────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_model.dart';
import '../../utils/university_detail_sizes.dart';

class UniversityDetailShortsCard extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final VideoModel video;
  final VoidCallback onTap;
  const UniversityDetailShortsCard({
    super.key,
    required this.sizes,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tablet ve telefon için farklı kart düzenleri
    return sizes.isTablet
        ? _ShortsListCardTablet(context)
        : _shortsGridCardPhone(context);
  }

  // Phone: dikey grid kartı
  Widget _shortsGridCardPhone(BuildContext context) {
    final String? thumbnailUrl = video.bestThumbnail.isNotEmpty
        ? video.bestThumbnail
        : null;
    final String title = video.title.isNotEmpty ? video.title : 'Shorts';
    final String desc = video.description;
    final String viewCount = video.formattedViewCount;
    final String timeAgoStr = _safeTimeAgo(video.publishedAt);
    final String duration = video.formattedDuration;

    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(sizes.shortsCardRadius),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(sizes.shortsCardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 3,
              child: _ShortsThumbnailPhone(
                sizes: sizes,
                thumbnailUrl: thumbnailUrl,
                duration: duration,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sizes.shortsTitleSize,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPri(context),
                      height: 1.3,
                    ),
                  ),
                  if (desc.isNotEmpty) ...[
                    SizedBox(height: 3.h),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: sizes.shortsDescSize,
                        color: AppTheme.textSec(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: sizes.shortsMetaSize,
                        color: AppTheme.textSec(context),
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          viewCount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.shortsMetaSize,
                            color: AppTheme.textSec(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.schedule_rounded,
                        size: sizes.shortsMetaSize,
                        color: AppTheme.textSec(context),
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          timeAgoStr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.shortsMetaSize,
                            color: AppTheme.textSec(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tablet: yatay liste kartı
  Widget _ShortsListCardTablet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.shortsCardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(sizes.shortsCardRadius),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnailTablet(context),
                SizedBox(width: sizes.shortsThumbnailSpacing),
                Expanded(
                  child: SizedBox(
                    height: sizes.shortsThumbnailHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ShortsBadge(sizes: sizes),
                            if (video.formattedDuration.isNotEmpty) ...[
                              SizedBox(width: 8),
                              _DurationChip(
                                sizes: sizes,
                                duration: video.formattedDuration,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.shortsTitleSize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPri(context),
                            height: sizes.shortsTitleLineHeight,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (video.description.isNotEmpty)
                          Text(
                            video.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: sizes.shortsDescSize,
                              color: AppTheme.textSec(context),
                              height: sizes.shortsDescLineHeight,
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: sizes.shortsMetaSize * 1.2,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                video.formattedViewCount,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: sizes.shortsMetaSize,
                                  color: AppTheme.textSec(context),
                                ),
                              ),
                            ),
                            SizedBox(width: sizes.shortsMetaSpacing),
                            Icon(
                              Icons.schedule_rounded,
                              size: sizes.shortsMetaSize * 1.1,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                timeago.format(video.publishedAt, locale: 'tr'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: sizes.shortsMetaSize,
                                  color: AppTheme.textSec(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailTablet(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(sizes.shortsThumbnailRadius),
      child: SizedBox(
        width: sizes.shortsThumbnailWidth,
        height: sizes.shortsThumbnailHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: video.bestThumbnail,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
              ),
              errorWidget: (_, _, _) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: sizes.shortsPlayOverlaySize * 0.8,
                ),
              ),
            ),
            Center(
              child: Container(
                width: sizes.shortsPlayOverlaySize,
                height: sizes.shortsPlayOverlaySize,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: sizes.shortsPlayIconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _safeTimeAgo(DateTime dateTime) {
    try {
      return timeago.format(dateTime, locale: 'tr');
    } catch (_) {
      return '';
    }
  }
}

// ─── Yardımcı Alt Widget'lar ───────────────────────────────────────────────

class _ShortsThumbnailPhone extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final String? thumbnailUrl;
  final String duration;
  const _ShortsThumbnailPhone({
    required this.sizes,
    required this.thumbnailUrl,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumbnailUrl != null)
          CachedNetworkImage(
            imageUrl: thumbnailUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => _placeholder(context),
            errorWidget: (_, _, _) => _placeholder(context),
          )
        else
          _placeholder(context),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 40.h,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 55.h,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8.h,
          left: 8.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(5.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  size: 12.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 2.w),
                Text(
                  'SHORTS',
                  style: TextStyle(
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (duration.isNotEmpty)
          Positioned(
            bottom: 8.h,
            right: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                duration,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        Center(
          child: Container(
            width: sizes.shortsPlayOverlaySize,
            height: sizes.shortsPlayOverlaySize,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8.r,
                ),
              ],
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: sizes.shortsPlayIconSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.08),
            AppTheme.primaryColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 32.sp,
          color: AppTheme.textSec(context).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _ShortsBadge extends StatelessWidget {
  final UniversityDetailSizes sizes;
  const _ShortsBadge({required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.shortsBadgePaddingHorizontal,
        vertical: sizes.shortsBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(sizes.shortsBadgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill_rounded,
            size: sizes.shortsBadgeIconSize,
            color: Colors.white,
          ),
          SizedBox(width: 3),
          Text(
            'SHORTS',
            style: TextStyle(
              fontSize: sizes.shortsBadgeFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final String duration;
  const _DurationChip({required this.sizes, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.shortsDurationChipPaddingHorizontal,
        vertical: sizes.shortsDurationChipPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          sizes.shortsDurationChipBorderRadius,
        ),
      ),
      child: Text(
        duration,
        style: TextStyle(
          fontSize: sizes.shortsDurationChipFontSize,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSec(context),
        ),
      ),
    );
  }
}





















