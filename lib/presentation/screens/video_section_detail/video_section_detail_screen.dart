// lib/presentation/screens/video_section_detail/video_section_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/video_engagement_model.dart';
import '../../controllers/video_section_detail_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarIconSize = 24;
  static const double appBarTitleSize = 17;

  // Card
  static const double cardMarginHorizontal = 14;
  static const double cardMarginVertical = 5;
  static const double cardPadding = 10;
  static const double cardBorderRadius = 12;

  // Thumbnail
  static const double thumbnailWidth = 120;
  static const double thumbnailHeight = 80;
  static const double thumbnailBorderRadius = 8;
  static const double thumbnailIconSize = 28;
  static const double thumbnailSpacing = 10;

  // Duration badge
  static const double durationBadgeBottom = 4;
  static const double durationBadgeRight = 4;
  static const double durationBadgePaddingHorizontal = 4;
  static const double durationBadgePaddingVertical = 2;
  static const double durationBadgeBorderRadius = 3;
  static const double durationBadgeFontSize = 9;

  // Meta
  static const double titleFontSize = 13;
  static const double titleLineHeight = 1.35;
  static const double titleSpacing = 4;
  static const double channelFontSize = 11;
  static const double statSpacing = 8;
  static const double statRunSpacing = 2;
  static const double statIconSize = 10;
  static const double statFontSize = 10;
  static const double statSpacingSmall = 2;
  static const double dateFontSize = 10;
  static const double metaSpacing = 6;

  // Footer
  static const double footerPaddingVertical = 20;
  static const double footerLoaderSize = 24;
  static const double footerLoaderStrokeWidth = 2.5;
  static const double footerTextFontSize = 13;

  // List padding
  static const double listVerticalPadding = 8;
}

class _TabletSizes {
  // AppBar
  static const double appBarIconSize = 28;
  static const double appBarTitleSize = 20;

  // Card
  static const double cardMarginHorizontal = 20;
  static const double cardMarginVertical = 8;
  static const double cardPadding = 14;
  static const double cardBorderRadius = 14;

  // Thumbnail
  static const double thumbnailWidth = 160;
  static const double thumbnailHeight = 100;
  static const double thumbnailBorderRadius = 10;
  static const double thumbnailIconSize = 34;
  static const double thumbnailSpacing = 14;

  // Duration badge
  static const double durationBadgeBottom = 6;
  static const double durationBadgeRight = 6;
  static const double durationBadgePaddingHorizontal = 6;
  static const double durationBadgePaddingVertical = 3;
  static const double durationBadgeBorderRadius = 4;
  static const double durationBadgeFontSize = 11;

  // Meta
  static const double titleFontSize = 16;
  static const double titleLineHeight = 1.4;
  static const double titleSpacing = 6;
  static const double channelFontSize = 13;
  static const double statSpacing = 10;
  static const double statRunSpacing = 3;
  static const double statIconSize = 12;
  static const double statFontSize = 12;
  static const double statSpacingSmall = 3;
  static const double dateFontSize = 12;
  static const double metaSpacing = 8;

  // Footer
  static const double footerPaddingVertical = 24;
  static const double footerLoaderSize = 30;
  static const double footerLoaderStrokeWidth = 3;
  static const double footerTextFontSize = 15;

  // List padding
  static const double listVerticalPadding = 12;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class VideoSectionDetailScreen extends StatelessWidget {
  const VideoSectionDetailScreen({super.key});

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
    final controller = Get.find<VideoSectionDetailController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: _PhoneSizes.appBarIconSize.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.sectionTitle,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: _PhoneSizes.appBarTitleSize.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
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
              padding: EdgeInsets.symmetric(
                vertical: _PhoneSizes.listVerticalPadding.h,
              ),
              itemCount:
                  controller.items.length +
                  (controller.hasMore.value ? 1 : 1),
              itemBuilder: (context, index) {
                if (index == controller.items.length) {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _PhoneSizes.footerPaddingVertical.h,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: _PhoneSizes.footerLoaderSize.w,
                          height: _PhoneSizes.footerLoaderSize.h,
                          child: CircularProgressIndicator(
                            strokeWidth: _PhoneSizes.footerLoaderStrokeWidth,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  if (!controller.hasMore.value &&
                      controller.items.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _PhoneSizes.footerPaddingVertical.h,
                      ),
                      child: Center(
                        child: Text(
                          'Tüm videolar gösterildi',
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _PhoneSizes.footerTextFontSize.sp,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return _VideoDetailCardPhone(item: controller.items[index]);
              },
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<VideoSectionDetailController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: _TabletSizes.appBarIconSize,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.sectionTitle,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: _TabletSizes.appBarTitleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.loadFirstPage,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              if (scroll.metrics.pixels >=
                  scroll.metrics.maxScrollExtent - 300) {
                controller.loadNextPage();
              }
              return false;
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                vertical: _TabletSizes.listVerticalPadding,
              ),
              itemCount:
                  controller.items.length +
                  (controller.hasMore.value ? 1 : 1),
              itemBuilder: (context, index) {
                if (index == controller.items.length) {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _TabletSizes.footerPaddingVertical,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: _TabletSizes.footerLoaderSize,
                          height: _TabletSizes.footerLoaderSize,
                          child: CircularProgressIndicator(
                            strokeWidth: _TabletSizes.footerLoaderStrokeWidth,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  if (!controller.hasMore.value &&
                      controller.items.isNotEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _TabletSizes.footerPaddingVertical,
                      ),
                      child: Center(
                        child: Text(
                          'Tüm videolar gösterildi',
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _TabletSizes.footerTextFontSize,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return _VideoDetailCardTablet(item: controller.items[index]);
              },
            ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _VideoDetailCardPhone extends StatelessWidget {
  final VideoEngagementModel item;

  const _VideoDetailCardPhone({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: item.toVideoModel(),
        parameters: {'videoId': item.toVideoModel().videoId},
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.cardMarginHorizontal.w,
          vertical: _PhoneSizes.cardMarginVertical.h,
        ),
        padding: EdgeInsets.all(_PhoneSizes.cardPadding.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(
                _PhoneSizes.thumbnailBorderRadius.r,
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    width: _PhoneSizes.thumbnailWidth.w,
                    height: _PhoneSizes.thumbnailHeight.h,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: item.fallbackThumbnailUrl,
                      width: _PhoneSizes.thumbnailWidth.w,
                      height: _PhoneSizes.thumbnailHeight.h,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholderPhone(context),
                    ),
                    placeholder: (_, _) => _shimmerBoxPhone(context),
                  ),
                  if (item.duration.isNotEmpty)
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
                          _formatDuration(item.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.durationBadgeFontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: _PhoneSizes.thumbnailSpacing.w),
            // ── Meta ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _PhoneSizes.titleFontSize.sp,
                      fontWeight: FontWeight.w600,
                      height: _PhoneSizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.titleSpacing.h),
                  Text(
                    item.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.channelFontSize.sp,
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.metaSpacing.h),
                  Wrap(
                    spacing: _PhoneSizes.statSpacing.w,
                    runSpacing: _PhoneSizes.statRunSpacing.h,
                    children: [
                      _statChipPhone(
                        context,
                        icon: Icons.play_circle_outline_rounded,
                        label: _formatNum(item.ytViewCount),
                      ),
                      _statChipPhone(
                        context,
                        icon: Icons.trending_up_rounded,
                        label: '${item.engagementScore} etkileşim puanı',
                        highlight: true,
                      ),
                    ],
                  ),
                  SizedBox(height: _PhoneSizes.titleSpacing.h),
                  Text(
                    _timeAgo(item.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.dateFontSize.sp,
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

  Widget _statChipPhone(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool highlight = false,
  }) {
    final color = highlight
        ? AppTheme.primaryColor
        : AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _PhoneSizes.statIconSize.sp, color: color),
        SizedBox(width: _PhoneSizes.statSpacingSmall.w),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: _PhoneSizes.statFontSize.sp,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _placeholderPhone(BuildContext context) => Container(
        width: _PhoneSizes.thumbnailWidth.w,
        height: _PhoneSizes.thumbnailHeight.h,
        color: AppTheme.surface(context),
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: AppTheme.textSec(context),
          size: _PhoneSizes.thumbnailIconSize.sp,
        ),
      );

  Widget _shimmerBoxPhone(BuildContext context) => Container(
        width: _PhoneSizes.thumbnailWidth.w,
        height: _PhoneSizes.thumbnailHeight.h,
        color: AppTheme.surface(context),
      );
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _VideoDetailCardTablet extends StatelessWidget {
  final VideoEngagementModel item;

  const _VideoDetailCardTablet({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: item.toVideoModel(),
        parameters: {'videoId': item.toVideoModel().videoId},
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: _TabletSizes.cardMarginHorizontal,
          vertical: _TabletSizes.cardMarginVertical,
        ),
        padding: EdgeInsets.all(_TabletSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(
                _TabletSizes.thumbnailBorderRadius,
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    width: _TabletSizes.thumbnailWidth,
                    height: _TabletSizes.thumbnailHeight,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: item.fallbackThumbnailUrl,
                      width: _TabletSizes.thumbnailWidth,
                      height: _TabletSizes.thumbnailHeight,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => _placeholderTablet(context),
                    ),
                    placeholder: (_, _) => _shimmerBoxTablet(context),
                  ),
                  if (item.duration.isNotEmpty)
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
                          _formatDuration(item.duration),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.durationBadgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: _TabletSizes.thumbnailSpacing),
            // ── Meta ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.titleFontSize,
                      fontWeight: FontWeight.w600,
                      height: _TabletSizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.titleSpacing),
                  Text(
                    item.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.channelFontSize,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.metaSpacing),
                  Wrap(
                    spacing: _TabletSizes.statSpacing,
                    runSpacing: _TabletSizes.statRunSpacing,
                    children: [
                      _statChipTablet(
                        context,
                        icon: Icons.play_circle_outline_rounded,
                        label: _formatNum(item.ytViewCount),
                      ),
                      _statChipTablet(
                        context,
                        icon: Icons.trending_up_rounded,
                        label: '${item.engagementScore} etkileşim puanı',
                        highlight: true,
                      ),
                    ],
                  ),
                  SizedBox(height: _TabletSizes.titleSpacing),
                  Text(
                    _timeAgo(item.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.dateFontSize,
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

  Widget _statChipTablet(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool highlight = false,
  }) {
    final color = highlight
        ? AppTheme.primaryColor
        : AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _TabletSizes.statIconSize, color: color),
        SizedBox(width: _TabletSizes.statSpacingSmall),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: _TabletSizes.statFontSize,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _placeholderTablet(BuildContext context) => Container(
        width: _TabletSizes.thumbnailWidth,
        height: _TabletSizes.thumbnailHeight,
        color: AppTheme.surface(context),
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: AppTheme.textSec(context),
          size: _TabletSizes.thumbnailIconSize,
        ),
      );

  Widget _shimmerBoxTablet(BuildContext context) => Container(
        width: _TabletSizes.thumbnailWidth,
        height: _TabletSizes.thumbnailHeight,
        color: AppTheme.surface(context),
      );
}

// ═══════════════════════════════════════════════════════════════════════
// ORTAK YARDIMCI FONKSİYONLAR
// ═══════════════════════════════════════════════════════════════════════

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