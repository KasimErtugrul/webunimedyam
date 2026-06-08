// lib/presentation/screens/player/player_screen_widgets/suggested_video_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';

class SuggestedVideoCard extends StatelessWidget {
  final VideoModel video;

  const SuggestedVideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.offNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
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
                        size: 32.sp,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 32.h,
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
                  // Süre chip — sağ alt
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 5.h,
                      right: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
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

            // ── Alt: Başlık + Kanal ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 7.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 9.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Görüntülenme chip
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: 9.sp,
                          color: AppTheme.primaryColor,
                        ),
                        SizedBox(width: 3.w),
                        Flexible(
                          child: Text(
                            video.formattedViewCount,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 8.5.sp,
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
          ],
        ),
      ),
    );
  }
}
