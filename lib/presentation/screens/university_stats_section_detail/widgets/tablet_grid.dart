// lib/presentation/screens/university_stats_section_detail/widgets/tablet_grid.dart
//
// TABLET — "Tümü" (kanal istatistiği detay) sayfasının grid gövdesi.
// Keşfet tablet tasarım diliyle uyumlu: ~1140px ortalı içerik, hedef kart
// genişliğine göre otomatik kolon sayısı, logo'lu dikey kanal kartları.
// Mevcut controller (ilk sayfa / sonsuz kaydırma / footer) aynen kullanılır;
// telefon gövdesi bu dosyadan geçmez.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/hover_tap.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/university_stats_model.dart';
import '../../../controllers/university_stats_section_detail_controller.dart';
import '../../home/tabs/home_tab/universities/university_sections_config.dart';
import '../utils/university_stats_section_detail_sizes.dart';

class UniversityStatsSectionDetailTabletSkeleton extends StatelessWidget {
  const UniversityStatsSectionDetailTabletSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int count = (constraints.maxWidth / 280).floor().clamp(1, 4);
          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: count,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 200,
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

class UniversityStatsSectionDetailTabletGrid extends StatelessWidget {
  const UniversityStatsSectionDetailTabletGrid({
    super.key,
    required this.sizes,
  });

  final UniversityStatsSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UniversityStatsSectionDetailController>();
    final cfg = uniSectionConfigs
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
            if (cfg != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 4),
                  child: Text(
                    cfg.description,
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
                  const double targetItemWidth = 280;
                  const double gap = 16;
                  final int crossAxisCount = (available / targetItemWidth)
                      .floor()
                      .clamp(1, 4);

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: gap,
                      mainAxisSpacing: gap,
                      mainAxisExtent: 200,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => UniversityStatsSectionDetailGridCard(
                        item: controller.items[index],
                        statLabel:
                            cfg?.statLabelBuilder(controller.items[index]) ??
                            '',
                        statIcon: cfg?.statIcon ?? Icons.bar_chart_rounded,
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
                        'Tüm kanallar gösterildi',
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
// TABLET KANAL KARTI — Keşfet'teki kanal kartı diliyle aynı:
// logo + ad + şehir + renkli istatistik satırı; kart üniversite
// detay sayfasını açar.
// ═══════════════════════════════════════════════════════════

class UniversityStatsSectionDetailGridCard extends StatelessWidget {
  const UniversityStatsSectionDetailGridCard({
    super.key,
    required this.item,
    required this.statLabel,
    required this.statIcon,
  });

  final UniversityStatsModel item;
  final String statLabel;
  final IconData statIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasLogo = item.logoUrl != null && item.logoUrl!.isNotEmpty;
    final initials = item.name.isNotEmpty
        ? item.name
              .substring(0, item.name.length > 2 ? 2 : item.name.length)
              .toUpperCase()
        : 'ÜN';

    return TapCursor(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: item.universityId),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: hasLogo
                  ? CachedNetworkImage(
                      imageUrl: item.logoUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  : Text(
                      initials,
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const Spacer(),
            // Ad + şehir
            Text(
              item.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
            if (item.city != null && item.city!.isNotEmpty) ...[
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(
                      item.city!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            // İstatistik satırı (bölümün gerçek metriği)
            Row(
              children: [
                Icon(statIcon, size: 15, color: scheme.primary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    statLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
