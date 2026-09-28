// lib/presentation/screens/home/tabs/home_tab/home_tab_widget_tablet.dart
//
// TABLET Home tab'ı — "Desktop & Tablet homepage" tasarımına göre kurgu.
//
// Bölüm sırası (tasarım): Hero (Canlı Banner + Carousel | Kampüs FM paneli)
//   → İzlemeye Devam Et → Shorts → Utility bar → İçerik başlığı + filtre
//   pill'leri → Video grid → "Daha Fazla Yükle" → Yaklaşan Canlı Yayın.
//
// Tasarımda olup kodda eksik olanlar EKLENDİ:
//   - HomeHeroLiveBannerWidget (tasarımdaki büyük canlı yayın banner'ı;
//     yalnızca gerçekten canlı yayında bir video varken görünür)
//   - HomeCampusRadioPanelWidget (sağdaki Kampüs FM paneli)
//   - Feed filtresinin pill'li sunumu (tasarımdaki kategori pill barı;
//     mevcut 4 feed filtresini pill olarak gösterir)
//   - "Daha Fazla Kampüs Yayını Yükle" butonu (auto-load'a ek manuel tetik)
//
// Kodda olup tasarımda OLMAYANlar KORUNDU (kaldırılmadı):
//   - Öne çıkan videolar carousel'i + nokta göstergeleri
//   - Utility bar (Kampüs FM Canlı pili + Liste/Çark görünüm anahtarı)
//   - Çark (wheel) görünümü, filtre menüsünün yaptığı işin tamamı,
//   - Yaklaşan Canlı Yayın şeridi, pull-to-refresh, sonsuz kaydırma.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../data/models/video_engagement_model.dart';
import '../../../../../data/repositories/video_repository.dart'
    show HomeFeedFilter;
import '../../../../../presentation/controllers/home/home_controller.dart';
import 'common/home_tab_logic.dart';
import 'common/home_tab_sizes.dart';
import 'common/home_tab_widgets.dart';
import 'shorts/shorts_row_widget.dart';
import 'widgets/home_campus_radio_panel_widget.dart';
import 'widgets/home_feed_wheel_widget.dart';
import 'widgets/home_hero_live_banner_widget.dart';
import 'widgets/video_grid_card_widget.dart';

class HomeTabWidgetTablet extends StatefulWidget {
  const HomeTabWidgetTablet({super.key});

  @override
  State<HomeTabWidgetTablet> createState() => _HomeTabWidgetTabletState();
}

class _HomeTabWidgetTabletState extends State<HomeTabWidgetTablet>
    with HomeTabLogic {
  static const TabletHomeTabSizes _sizes = TabletHomeTabSizes();

  @override
  HomeTabSizes get sizes => _sizes;

  // Hero ile bölümlerin ortak yatay boşluğu (tasarımdaki sayfa padding'i).
  double get _pagePad => sizes.titleSpacingLarge;

  // Carousel'in aktif sayfa indeksi (alttaki nokta göstergeleri için).
  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => maybeAutoLoadMore());

    // NOT: Bu tab, HomeScreen'in kendi Scaffold'u içinde IndexedStack ile
    // gösteriliyor; ayrı bir Scaffold yerine Container + SafeArea yeterli
    // (gereksiz iç içe Scaffold/Material ağacını önler).
    return Container(
      color: AppTheme.bg(context),
      child: SafeArea(
        child: RefreshIndicator(
          key: refreshIndicatorKey,
          color: Theme.of(context).colorScheme.primary,
          onRefresh: refreshHomeTab,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // ── Hero: Canlı Banner + Carousel | Kampüs FM paneli ────────
              SliverToBoxAdapter(child: _buildHeroRow(context)),

              // ── İzlemeye Devam Et (tasarım sırası: hero'dan hemen sonra) ─
              SliverToBoxAdapter(
                child: HomeContinueWatchingSection(
                  controller: controller,
                  sizes: sizes,
                ),
              ),

              // ── Shorts şeridi ───────────────────────────────────────────
              const SliverToBoxAdapter(child: ShortsRowWidget()),

              // ── Utility bar (Kampüs FM pili + görünüm anahtarı) ─────────
              SliverToBoxAdapter(
                child: HomeUtilityBar(controller: controller, sizes: sizes),
              ),

              // ── İçerik Alanı ────────────────────────────────────────────
              Obx(() => _buildContentSliver(context)),

              // ── Yaklaşan Canlı Yayın + alt boşluk ───────────────────────
              ...commonSliversAfterContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HERO SATIRI — sol: canlı banner + carousel, sağ: radyo paneli
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroRow(BuildContext context) {
    // Tasarım: xl'de 8:4, 2xl'de 9:3 kolon oranı. Genişlik arttıkça
    // radyo panelin payı daralır.
    return Padding(
      padding: EdgeInsets.fromLTRB(_pagePad, 8, _pagePad, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int leftFlex = constraints.maxWidth >= 1200 ? 3 : 2;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: leftFlex, child: _buildHeroLeftColumn(context)),
              SizedBox(width: _pagePad),
              const Expanded(
                flex: 1,
                child: HomeCampusRadioPanelWidget(),
              ),
            ],
          );
        },
      ),
    );
  }

  // Hero'nun sol sütunu: canlı yayın banner'ı (varsa) + öne çıkanlar
  // carousel'i. Banner tasarımdan gelir; carousel kodda zaten vardı,
  // tasarımda olmadığı için kaldırılmadı.
  Widget _buildHeroLeftColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tasarımdaki büyük "Canlı Yayın" banner'ı — SADECE gerçekten
        // canlı yayında olan bir video varken render edilir; canlı yayın
        // yoksa boş/yalan bir banner gösterilmez.
        Obx(() {
          final liveVideo = controller.videos
              .firstWhereOrNull((v) => v.isLiveBroadcast);
          if (liveVideo == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: HomeHeroLiveBannerWidget(video: liveVideo, height: 400),
          );
        }),
        _buildCarouselSlider(context),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CAROUSEL SLIDER (öne çıkan videolar) — kodda mevcut, aynen korundu
  // ═══════════════════════════════════════════════════════════

  Widget _buildCarouselSlider(BuildContext context) {
    final isTablet = Responsive.isTablet(context);

    return Obx(() {
      // Yüklenirken shimmer göster
      if (controller.isLoading.value) {
        return _buildCarouselShimmer(context, isTablet: isTablet);
      }

      // Hata varsa carousel'i tamamen gizle (ana içerik alanı zaten
      // hata widget'ını gösteriyor).
      if (controller.errorMessage.isNotEmpty) {
        return const SizedBox.shrink();
      }

      // Shorts olmayan ilk 10 video, öne çıkan carousel videoları.
      final featured = controller.videosMostWatched.toList();

      if (featured.isEmpty) return const SizedBox.shrink();

      // itemWidth, LayoutBuilder ile gerçek genişlikten hesaplanır; kart
      // içeriği (16:9 thumbnail + metin bloğu) hesaplanan yüksekliğin
      // tamamını kullanır.
      const double fraction = .5;
      final scheme = Theme.of(context).colorScheme;

      return LayoutBuilder(
        builder: (context, constraints) {
          final double itemWidth = constraints.maxWidth * fraction;
          final double thumbHeight = itemWidth * 9 / 16;
          final double textBlockHeight = _cardTextBlockHeight(isTablet);
          final double carouselHeight = thumbHeight + textBlockHeight;

          return Column(
            children: [
              CarouselSlider(
                items: featured.map((video) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildLargeVideoCard(
                      context,
                      scheme,
                      video: video,
                      badgeText: '',
                      badgeIcon: Icons.bolt_rounded,
                      isTablet: true,
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: carouselHeight,
                  viewportFraction: fraction,
                  enableInfiniteScroll: featured.length > 1,
                  enlargeCenterPage: false,
                  autoPlay: false,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 450),
                  onPageChanged: (index, reason) {
                    if (!mounted) return;
                    setState(() {
                      _currentCarouselIndex = index;
                    });
                  },
                ),
              ),

              // ── Nokta göstergeleri ────────────────────────────────────────
              if (featured.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(featured.length, (i) {
                    final active =
                        i ==
                        _currentCarouselIndex.clamp(0, featured.length - 1);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: active ? 18 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                      decoration: BoxDecoration(
                        color: active
                            ? AppTheme.primaryColor
                            : AppTheme.textSec(context).withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                    );
                  }),
                ),
            ],
          );
        },
      );
    });
  }

  // 3 satırlık başlık + kanal adı + tarih satırının gerektirdiği yükseklik.
  // _buildLargeVideoCard'daki font boyutlarıyla tutarlı; küçük bir
  // güvenlik payı eklendi.
  double _cardTextBlockHeight(bool isTablet) {
    final double titleFont = isTablet ? 15 : 13.5;
    final double metaFont = isTablet ? 12 : 11;
    const double padding = 10; // Padding(all: 5) üst+alt
    const double gap = 8; // başlık ile kanal adı arası SizedBox
    const double lineHeightFactor = 1.3;
    final double titleBlock = titleFont * lineHeightFactor * 3; // maxLines: 3
    final double metaBlock = metaFont * lineHeightFactor * 2; // kanal + tarih
    return padding + titleBlock + gap + metaBlock + 6; // +6 güvenlik payı
  }

  Widget _buildLargeVideoCard(
    BuildContext context,
    ColorScheme scheme, {
    required VideoEngagementModel video,
    required String badgeText,
    required IconData badgeIcon,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video.toVideoModel(),
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 Thumbnail & Süre
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: scheme.surfaceContainerHighest),
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: video.fallbackThumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient kaplama
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Sağ Alt Süre
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.duration.isNotEmpty ? video.duration : '18:42',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kart Alt Bilgileri
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isTablet ? 15 : 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeAgoTr(video.publishedAt),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: isTablet ? 11 : 10,
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

  // Carousel yüklenirken gösterilen shimmer bloğu.
  Widget _buildCarouselShimmer(BuildContext context, {required bool isTablet}) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: isTablet ? 280 : 240,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // İÇERİK GÖVDESİ (tablet: başlık + filtre pill'leri + grid)
  // ═══════════════════════════════════════════════════════════

  Widget _buildContentSliver(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(child: HomeVideoShimmer(sizes: sizes));
    }

    if (controller.errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: HomeErrorWidget(
          message: controller.errorMessage.value,
          onRetry: controller.loadVideos,
          sizes: sizes,
        ),
      );
    }

    final nonShorts = controller.videos.where((v) => !v.isShorts).toList();

    // FIX korunuyor: boş sonuçta da başlık + filtre pill'leri görünür.
    if (nonShorts.isEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: _TabletContentHeader(
              controller: controller,
              horizontalPad: _pagePad,
              topPad: sizes.contentTitlePadTop,
              bottomPad: sizes.contentTitlePadBottom,
            ),
          ),
          SliverToBoxAdapter(
            child: HomeEmptyWidget(
              message: controller.feedFilter.value.emptyMessage(
                isLoggedIn: controller.isLoggedIn,
              ),
              sizes: sizes,
            ),
          ),
        ],
      );
    }

    if (controller.isWheelView.value) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeFeedWheelWidget(
                videos: nonShorts,
                universities: controller.universities,
              ),
            ],
          ),
        ),
      );
    }

    // ── TABLET: Başlık + pill'ler + Grid görünümü ──────────────────────
    // Sütun sayısı, bu sliver'a gerçekte ayrılan yatay alana
    // (constraints.crossAxisExtent) göre hesaplanır; böylece padding'in
    // yediği yer de hesaba katılır.
    final double horizontalPadding = _pagePad;
    const double gridSpacing = 16;

    final showLoader = controller.hasMoreVideos.value;
    final isLoadingMore = controller.isLoadingMore.value;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: _TabletContentHeader(
            controller: controller,
            horizontalPad: _pagePad,
            topPad: sizes.contentTitlePadTop,
            bottomPad: sizes.contentTitlePadBottom,
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.crossAxisExtent;

                  // Hedef kart genişliği; mevcut alana göre sütun sayısı
                  // otomatik seçilir (portre/landscape farkı dahil).
                  const double targetItemWidth = 280;
                  final int crossAxisCount = (availableWidth / targetItemWidth)
                      .floor()
                      .clamp(1, 6);

                  final itemWidth =
                      (availableWidth - (crossAxisCount - 1) * gridSpacing) /
                      crossAxisCount;

                  final thumbHeight = itemWidth * 9 / 16;
                  final mainAxisExtent = thumbHeight + kGridCardBodyHeight;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
                      mainAxisExtent: mainAxisExtent,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          VideoGridCardWidget(video: nonShorts[index]),
                      childCount: nonShorts.length,
                    ),
                  );
                },
              ),
              // ── Tasarımdaki "Daha Fazla Kampüs Yayını Yükle" butonu ────
              // Sonsuz kaydırma hâlâ çalışır (scroll listener); bu buton
              // tasarımın gereği olarak MANUEL tetikleme noktasıdır.
              if (showLoader)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Center(
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : OutlinedButton.icon(
                              onPressed: controller.loadMoreVideos,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.textPri(context),
                                side: BorderSide(
                                  color: AppTheme.textSec(context)
                                      .withValues(alpha: 0.25),
                                ),
                                minimumSize: const Size(0, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                              ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text(
                                'Daha Fazla Kampüs Yayını Yükle',
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// TABLET İÇERİK BAŞLIĞI
// ─────────────────────────────────────────────────────────────────────────
// Kodda zaten olan başlık + alt açıklama KORUNDU; tasarımdaki kategori
// pill barının karşılığı olarak da mevcut 4 feed filtresi pill olarak
// sunuldu (PopupMenuButton'ın tabletteki görsel ikamesi — işlev aynı:
// controller.setFeedFilter). Telefon tarafı HomeContentHeader'ı
// (dropdown'lu haliyle) kullanmaya devam eder.
class _TabletContentHeader extends StatelessWidget {
  const _TabletContentHeader({
    required this.controller,
    required this.horizontalPad,
    required this.topPad,
    required this.bottomPad,
  });

  final HomeController controller;
  final double horizontalPad;
  final double topPad;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    final activeFilter = controller.feedFilter.value;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPad, topPad, horizontalPad, bottomPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.video_library_rounded,
                size: 22,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Üniversitelerin Son Videoları',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            activeFilter.subtitle,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          // Tasarımdaki yatay kaydırılabilir filtre pill barı.
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: HomeFeedFilter.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = HomeFeedFilter.values[index];
                final selected = filter == activeFilter;
                final scheme = Theme.of(context).colorScheme;
                return InkWell(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  onTap: () => controller.setFeedFilter(filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter.icon,
                          size: 16,
                          color: selected
                              ? scheme.onPrimary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filter.label,
                          style: TextStyle(
                            color: selected
                                ? scheme.onPrimary
                                : scheme.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
