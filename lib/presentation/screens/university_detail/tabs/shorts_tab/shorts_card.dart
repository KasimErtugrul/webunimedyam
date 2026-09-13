// lib/presentation/screens/university_detail/tabs/shorts_tab/shorts_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_model.dart';
import '../../university_detail_layout_spec.dart';

class UniversityDetailShortsCard extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final VideoModel video;
  final VoidCallback onTap;

  const UniversityDetailShortsCard({
    super.key,
    required this.spec,
    required this.video,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(spec.shortsCardRadius.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail + overlay
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, _, _) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: spec.shortsPlayOverlay.w * 0.7,
                      ),
                    ),
                  ),
                  // Alt gradient (badges için kontrast)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 50.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  // SHORTS badge
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 11.sp,
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
                  // Duration
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  // Center play
                  Center(
                    child: Container(
                      width: spec.shortsPlayOverlay.w,
                      height: spec.shortsPlayOverlay.w,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.42),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: spec.shortsPlayIcon.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Meta
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    video.title.isNotEmpty ? video.title : 'Shorts',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: spec.shortsTitleFontSize.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPri(context),
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_rounded,
                        size: spec.shortsMetaFontSize.sp + 1,
                        color: AppTheme.textSec(context),
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          video.formattedViewCount,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: spec.shortsMetaFontSize.sp,
                            color: AppTheme.textSec(context),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.schedule_rounded,
                        size: spec.shortsMetaFontSize.sp,
                        color: AppTheme.textSec(context),
                      ),
                      SizedBox(width: 3.w),
                      Flexible(
                        child: Text(
                          _timeAgo(video.publishedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: spec.shortsMetaFontSize.sp,
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

  String _timeAgo(DateTime d) {
    try {
      return timeago.format(d, locale: 'tr');
    } catch (_) {
      return '';
    }
  }
}