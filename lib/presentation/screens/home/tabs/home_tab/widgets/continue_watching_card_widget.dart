// lib/presentation/screens/home/tabs/home_tab/widgets/continue_watching_card_widget.dart
//
// "İzlemeye Devam Et" yatay listesindeki tek bir video kartı.
// Karta basınca video, PlayerController._initPlayer() içinde
// WatchProgressRepository'den okunan kaldığı saniyeden otomatik devam eder.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/watch_progress_model.dart';

class ContinueWatchingCardWidget extends StatelessWidget {
  final WatchProgressModel progress;
  final VoidCallback? onRemove;

  const ContinueWatchingCardWidget({
    super.key,
    required this.progress,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final video = progress.video;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: 170.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail + ilerleme çubuğu ─────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: 32.sp,
                      ),
                    ),
                    placeholder: (_, _) =>
                        Container(color: AppTheme.surface(context)),
                  ),
                  // Karartma
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                  // Ortadaki oynat ikonu
                  Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 34.sp,
                    ),
                  ),
                  // Kalan süre chip'i + kaldırma (✕) butonu — sağ üst
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✕ — "artık izlemek istemiyorum, listeden kaldır"
                        if (onRemove != null)
                          GestureDetector(
                            onTap: onRemove,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: EdgeInsets.all(3.w),
                              margin: EdgeInsets.only(right: 4.w),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 11.sp,
                              ),
                            ),
                          ),
                        if (progress.remainingLabel.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              progress.remainingLabel,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // İlerleme çubuğu — alt kenar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: ClipRRect(
                      child: LinearProgressIndicator(
                        value: progress.progressRatio,
                        minHeight: 3.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: AlwaysStoppedAnimation(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Başlık + kanal ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  SizedBox(height: 3.h),
                  Text(
                    video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 9.sp,
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
