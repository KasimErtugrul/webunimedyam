// lib/presentation/screens/university_wheel/widgets/university_wheel_news_tile_widget.dart
//
// Sağ panelde, aktif üniversitenin "haberi" (videosu) olarak gösterilen
// kompakt liste satırı.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';

class UniversityWheelNewsTile extends StatelessWidget {
  final VideoModel video;

  const UniversityWheelNewsTile({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    timeago.setLocaleMessages('tr', timeago.TrMessages());
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Küçük resim ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 96.w,
                height: 64.w,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Container(
                        color: AppTheme.surface(context),
                        child: Icon(
                          Icons.play_circle_outline_rounded,
                          color: AppTheme.textSec(context),
                        ),
                      ),
                      placeholder: (_, _) =>
                          Container(color: AppTheme.surface(context)),
                    ),
                    if (video.formattedDuration.isNotEmpty)
                      Positioned(
                        right: 3.w,
                        bottom: 3.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            video.formattedDuration,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),

            // ── Başlık + meta ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    '${video.formattedViewCount} • ${timeago.format(video.publishedAt, locale: 'tr')}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 10.5.sp,
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
}
