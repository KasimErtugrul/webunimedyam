// lib/presentation/screens/home/tabs/home_tab/home_tab_widget_tablet.dart
//
// TABLET Home tab'ı. Ortak mantık common/ altında. Bu dosyada yalnızca
// tablet'e özgü kalıcı farklar duruyor:
//   1. Hero satırı: carousel + "Üniversite Radyoları" paneli
//   2. Büyük video kartı (_buildLargeVideoCard)
//   3. Grid içerik gövdesi (phone'daki liste yerine)
//
// NOT: kGridCardBodyHeight video_grid_card_widget.dart'tan geliyor
// (orijinaldekiyle aynı). Farklı bir dosyadaysa import'u düzelt.

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
import 'common/home_tab_logic.dart';
import 'common/home_tab_sizes.dart';
import 'common/home_tab_widgets.dart';
import 'widgets/home_feed_wheel_widget.dart';
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

  // Carousel'in aktif sayfa indeksi (alttaki nokta göstergeleri için).
  int _currentCarouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => maybeAutoLoadMore());

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          key: refreshIndicatorKey,
          color: Theme.of(context).colorScheme.primary,
          onRefresh: refreshHomeTab,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              // ── Hero: Carousel + Radyo Paneli (tablet'e özgü) ──────────
              SliverToBoxAdapter(child: _buildHeroRow(context)),

              ...commonSliversBeforeContent(),

              // ── İçerik Alanı ───────────────────────────────────────────
              Obx(() => _buildContentSliver(context)),

              ...commonSliversAfterContent(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HERO SATIRI (tablet'e özgü)
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeroRow(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildCarouselSlider(context)),
        Expanded(flex: 1, child: _buildRadioPanel(context)),
      ],
    );
  }

  // Sağdaki "Üniversite Radyoları" paneli.
  // DÜRÜST NOT (orijinalden korunmuştur): `width: 50.w` Expanded içinde
  // etkisizdir; carousel'in yükseklik hesabı da (itemWidth = 250.w) gerçek
  // render genişliğiyle ilişkili DEĞİL — bu blok mockup hero çalışmasında
  // yeniden kurulacak, şimdilik birebir korundu.
  Widget _buildRadioPanel(BuildContext context) {
    return Container(
      width: 50,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.65),
            AppTheme.primaryColor.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Üniversite Radyoları',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Sizlerle',
            style: TextStyle(
              color: AppTheme.textSec(context).withValues(alpha: 0.85),
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          SizedBox(height: 14),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: AppTheme.textSec(context),
              size: 7,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CAROUSEL SLIDER (öne çıkan videolar)
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

      // DÜRÜST NOT: itemWidth gerçek render genişliği değil (o, viewportFraction
      // × Expanded sonucu); yalnızca yükseklik tahmini için kullanılıyor.
      final double fraction = isTablet ? .5 : 0.82;
      final double itemWidth = 250;
      final double cardHeight = itemWidth * 9 / 16 + (isTablet ? 55 : 90);
      // enlargeCenterPage kapalı olduğu için yüksekliğe pay bırakılıyor.
      final double carouselHeight = cardHeight * .55;
      final scheme = Theme.of(context).colorScheme;

      return Column(
        children: [
          CarouselSlider(
            items: featured.map((video) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
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
                    i == _currentCarouselIndex.clamp(0, featured.length - 1);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 18 : 6,
                  height: 6,
                  margin: EdgeInsets.symmetric(horizontal: 3, vertical: 8),
                  decoration: BoxDecoration(
                    color: active
                        ? AppTheme.primaryColor
                        : AppTheme.textSec(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                );
              }),
            ),
        ],
      );
    });
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                          fontSize: 4,
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
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isTablet ? 4 : 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
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
                            fontSize: isTablet ? 4 : 7,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        timeAgoTr(video.publishedAt),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 4,
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
        padding: EdgeInsets.symmetric(horizontal: 16),
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
  // İÇERİK GÖVDESİ (tablet: grid)
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

    // FIX korunuyor: boş sonuçta da başlık + filtre seçici görünür.
    if (nonShorts.isEmpty) {
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                sizes.contentTitlePadHorizontal,
                sizes.contentTitlePadTop,
                sizes.contentTitlePadHorizontal,
                sizes.contentTitlePadBottom,
              ),
              child: HomeContentHeader(controller: controller, sizes: sizes),
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

    // ── TABLET: Grid görünümü ──────────────────────────────────────────
    // NOT: Kolon sayısı hâlâ orientation'a bağlı (mevcut davranış);
    // sidebar'ın yer yemesi hesaba katılmıyor. Mockup hero çalışmasında
    // LayoutBuilder'a geçilecek.
    const double horizontalPadding = 16;
    const double gridSpacing = 16;
    final Orientation orientation = MediaQuery.orientationOf(context);
    final int crossAxisCount = orientation == Orientation.portrait ? 2 : 3;

    final showLoader = controller.hasMoreVideos.value;
    final isLoadingMore = controller.isLoadingMore.value;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              sizes.contentTitlePadHorizontal,
              sizes.contentTitlePadTop,
              sizes.contentTitlePadHorizontal,
              sizes.contentTitlePadBottom,
            ),
            child: HomeContentHeader(controller: controller, sizes: sizes),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.crossAxisExtent;
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
              if (showLoader)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: isLoadingMore
                          ? const CircularProgressIndicator()
                          : const SizedBox.shrink(),
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
