// lib/presentation/screens/video_section_detail/widgets/video_section_detail_tablet.dart
//
// TABLET — "Tümü" (video bölümü detay) sayfasının grid gövdesi.
// Tasarım dili Keşfet tablet düzeniyle aynı: yatayda ortalı ~1140px içerik,
// hedef kart genişliğine göre otomatik kolon sayısı, 16:9 thumbnail'li
// dikey kartlar, sayfa sonu bildirimi ve sonsuz kaydırma (mevcut controller
// altyapısı aynen kullanılır). Telefon gövdesi bu dosyadan hiç geçmez.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_engagement_model.dart';
import '../../../controllers/video_section_detail_controller.dart';
import '../../home/tabs/home_tab/videos/video_sections_config.dart';
import '../util/video_section_detail_screen_functions.dart';
import '../util/video_section_detail_screen_sizes.dart';
import 'video_section_detail_screen_stat_chip.dart';

class VideoSectionDetailTabletSkeleton extends StatelessWidget {
  const VideoSectionDetailTabletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int count = (constraints.maxWidth / 300).floor().clamp(1, 4);
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 320,
            ),
            itemCount: count * 3,
            itemBuilder: (_, _) => Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoSectionDetailTabletGrid extends StatelessWidget {
  const VideoSectionDetailTabletGrid({super.key, required this.sizes});

  final VideoSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VideoSectionDetailController>();
    // Bölüm açıklaması (bilgi diyalogundaki aynı gerçek metin) tablette
    // listenin üstünde gösterilir.
    final config = videoSectionConfigs
        .where((c) => c.type == controller.sectionType)
        .firstOrNull;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Tasarımdaki max-w-[1140px]: çok geniş ekranlarda içerik ortalanır.
        final double hPad = constraints.maxWidth > 1188
            ? (constraints.maxWidth - 1140) / 2
            : 24;

        return CustomScrollView(
          slivers: [
            if (config != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 4),
                  child: Text(
                    config.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final double available = constraints.crossAxisExtent;
                  const double targetItemWidth = 300;
                  const double gap = 16;
                  final int crossAxisCount =
                      (available / targetItemWidth).floor().clamp(1, 4);
                  final double itemWidth =
                      (available - (crossAxisCount - 1) * gap) / crossAxisCount;
                  // 16:9 thumbnail + başlık/kanal/chip/tarih bloğu.
                  final double mainAxisExtent = itemWidth * 9 / 16 + 150;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                      mainAxisExtent: mainAxisExtent,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _VideoSectionDetailTabletCard(
                        item: controller.items[index],
                      ),
                      childCount: controller.items.length,
                    ),
                  );
                },
              ),
            ),
            // ── Footer: sayfalama yükleyicisi / "tümü gösterildi" ────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoadingMore.value) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes.footerPaddingVertical,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: sizes.footerLoaderWidth,
                        height: sizes.footerLoaderHeight,
                        child: CircularProgressIndicator(
                          strokeWidth: sizes.footerLoaderStrokeWidth,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  );
                }
                if (!controller.hasMore.value && controller.items.isNotEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: sizes.footerPaddingVertical,
                    ),
                    child: Center(
                      child: Text(
                        'Tüm videolar gösterildi',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: sizes.footerTextFontSize,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TABLET DİKEY KART
// ═══════════════════════════════════════════════════════════

class _VideoSectionDetailTabletCard extends StatelessWidget {
  const _VideoSectionDetailTabletCard({required this.item});

  final VideoEngagementModel item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: item.toVideoModel(),
        parameters: {'videoId': item.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 16:9 Thumbnail + süre ───────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: item.fallbackThumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                    placeholder: (_, _) =>
                        Container(color: scheme.surfaceContainerHighest),
                  ),
                  if (item.duration.isNotEmpty)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          VideoSectionDetailScreenFunctions.formatDuration(
                            item.duration,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // ── İçerik ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 3,
                    children: [
                      VideoSectionDetailScreenStatChip(
                        sizes: _TabletChipSizes.instance,
                        icon: Icons.play_circle_outline_rounded,
                        label: VideoSectionDetailScreenFunctions.formatNum(
                          item.ytViewCount,
                        ),
                      ),
                      VideoSectionDetailScreenStatChip(
                        sizes: _TabletChipSizes.instance,
                        icon: Icons.trending_up_rounded,
                        label: '${item.engagementScore} etkileşim puanı',
                        highlight: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    VideoSectionDetailScreenFunctions.timeAgo(item.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 11,
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

// Mevcut StatChip widget'ı `VideoSectionDetailSizes` istiyor; tablet grid
// kartı için chip boyutlarını burada sabitliyoruz (mevcut tablet değerleri).
class _TabletChipSizes implements VideoSectionDetailSizes {
  static const _TabletChipSizes instance = _TabletChipSizes();
  const _TabletChipSizes();

  @override
  double get statIconSize => 13;
  @override
  double get statFontSize => 12;
  @override
  double get statSpacing => 4;

  // Chip'in kullanmadığı üyeler — arayüz sözleşmesi gereği var.
  @override
  double get appBarIconSize => 28;
  @override
  double get appBarTitleSize => 20;
  @override
  double get cardMarginHorizontal => 0;
  @override
  double get cardMarginVertical => 0;
  @override
  double get cardPadding => 12;
  @override
  double get cardBorderRadius => 16;
  @override
  double get thumbnailWidth => 0;
  @override
  double get thumbnailHeight => 0;
  @override
  double get thumbnailBorderRadius => 10;
  @override
  double get thumbnailIconSize => 34;
  @override
  double get thumbnailSpacing => 0;
  @override
  double get durationBadgeBottom => 8;
  @override
  double get durationBadgeRight => 8;
  @override
  double get durationBadgePaddingHorizontal => 7;
  @override
  double get durationBadgePaddingVertical => 3;
  @override
  double get durationBadgeBorderRadius => 5;
  @override
  double get durationBadgeFontSize => 10.5;
  @override
  double get titleFontSize => 15;
  @override
  double get titleLineHeight => 1.3;
  @override
  double get titleSpacing => 4;
  @override
  double get channelFontSize => 12;
  @override
  double get statRunSpacing => 3;
  @override
  double get statSpacingSmall => 3;
  @override
  double get dateFontSize => 11;
  @override
  double get metaSpacing => 8;
  @override
  double get footerPaddingVertical => 24;
  @override
  double get footerLoaderWidth => 30;
  @override
  double get footerLoaderHeight => 30;
  @override
  double get footerLoaderStrokeWidth => 3;
  @override
  double get footerTextFontSize => 14;
  @override
  double get listVerticalPadding => 12;
  @override
  double get scrollLoadThreshold => 300;
}
