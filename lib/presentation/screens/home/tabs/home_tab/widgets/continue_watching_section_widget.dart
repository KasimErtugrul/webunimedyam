// lib/presentation/screens/home/tabs/home_tab/widgets/continue_watching_section_widget.dart
//
// "İzlemeye Devam Et" — ana sayfada, kullanıcının yarıda bıraktığı videoları
// gösteren yatay liste. Veri tamamen local (Hive) kaynaklıdır; herhangi bir
// ağ isteği yapılmaz.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/watch_progress_model.dart';

class ContinueWatchingSectionWidget extends StatelessWidget {
  final List<WatchProgressModel> items;
  final void Function(String videoId) onRemove;

  const ContinueWatchingSectionWidget({
    super.key,
    required this.items,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 10.h),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: 18.sp,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'İzlemeye Devam Et',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 178.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ContinueWatchingCardWidget(
                key: ValueKey(item.video.videoId),
                item: item,
                onRemove: () => onRemove(item.video.videoId),
              );
            },
          ),
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class ContinueWatchingCardWidget extends StatelessWidget {
  final WatchProgressModel item;
  final VoidCallback onRemove;

  const ContinueWatchingCardWidget({
    super.key,
    required this.item,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final video = item.video;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: 168.w,
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
                  // Karartma gradyanı (alt taraf)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 30.h,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Kalan süre
                  Positioned(
                    bottom: 9.h,
                    left: 8.w,
                    child: Text(
                      '${item.formattedRemaining} kaldı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Kaldır butonu
                  Positioned(
                    top: 6.h,
                    right: 6.w,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  // Oynat ikonu (ortada, hafif)
                  Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 34.sp,
                    ),
                  ),
                  // İlerleme çubuğu — thumbnail'in en altında
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      child: LinearProgressIndicator(
                        value: item.progressFraction,
                        minHeight: 3.h,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Başlık + üniversite ──────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    video.universityName ?? video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 9.5.sp,
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
