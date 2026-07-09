// lib/presentation/screens/video_section_detail/video_section_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_engagement_model.dart';
import '../../controllers/video_section_detail_controller.dart';

class VideoSectionDetailScreen extends StatelessWidget {
  const VideoSectionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoSectionDetailController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.sectionTitle,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.loadFirstPage,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                  scroll.metrics.maxScrollExtent - 200) {
                controller.loadNextPage();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount:
                  controller.items.length +
                  (controller.hasMore.value ? 1 : 1), // +1 footer
              itemBuilder: (context, index) {
                // Footer: yükleniyor göstergesi veya "tümü gösterildi"
                if (index == controller.items.length) {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  if (!controller.hasMore.value &&
                      controller.items.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Center(
                        child: Text(
                          'Tüm videolar gösterildi',
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return VideoDetailCard(item: controller.items[index]);
              },
            ),
          ),
        );
      }),
    );
  }
}

// ─── Dikey liste kartı ────────────────────────────────────────────────────────

class VideoDetailCard extends StatelessWidget {
  final VideoEngagementModel item;

  const VideoDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.player, arguments: item.toVideoModel(),parameters: {'videoId': item.toVideoModel().videoId},),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    width: 120.w,
                    height: 80.h,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: item.fallbackThumbnailUrl,
                      width: 120.w,
                      height: 80.h,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholder(context),
                    ),
                    placeholder: (_, _) => _shimmerBox(context),
                  ),
                  // Süre chip
                  if (item.duration.isNotEmpty)
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Text(
                          _formatDuration(item.duration),
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

            SizedBox(width: 10.w),

            // ── Meta ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Kanal adı
                  Text(
                    item.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 11.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // İstatistikler satırı
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 2.h,
                    children: [
                      _statChip(
                        context,
                        icon: Icons.play_circle_outline_rounded,
                        label: _formatNum(item.ytViewCount),
                      ),
                      _statChip(
                        context,
                        icon: Icons.trending_up_rounded,
                        label: '${item.engagementScore} etkileşim puanı',
                        highlight: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  // Tarih
                  Text(
                    _timeAgo(item.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 10.sp,
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

  Widget _statChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool highlight = false,
  }) {
    final color = highlight ? AppTheme.primaryColor : AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.sp, color: color),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.sp,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) => Container(
    width: 120.w,
    height: 80.h,
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: 28.sp,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(width: 120.w, height: 80.h, color: AppTheme.surface(context));
}

// ─── Yardımcı fonksiyonlar ────────────────────────────────────────────────────

String _formatDuration(String iso) {
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

String _formatNum(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
  return n.toString();
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 365) return '${diff.inDays ~/ 365} yıl önce';
  if (diff.inDays >= 30) return '${diff.inDays ~/ 30} ay önce';
  if (diff.inDays >= 1) return '${diff.inDays} gün önce';
  if (diff.inHours >= 1) return '${diff.inHours} saat önce';
  return '${diff.inMinutes} dakika önce';
}
