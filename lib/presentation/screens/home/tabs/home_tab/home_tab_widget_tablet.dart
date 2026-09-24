// lib/presentation/screens/home/widgets/tabs/home_tab/home_tab_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../data/models/video_engagement_model.dart';
import '../../../../../data/repositories/video_repository.dart'
    show HomeFeedFilter;
import '../../../../controllers/home/home_controller.dart';
import '../../../../controllers/shorts_controller.dart';
import 'shorts/shorts_row_widget.dart';
import 'widgets/continue_watching_section_widget.dart';
import 'widgets/home_feed_wheel_widget.dart';
import 'widgets/video_card_widget.dart';
import 'widgets/video_grid_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════


class _TabletSizes {
  // Spacing - tablet için daha geniş
  static const double titleSpacingLarge = 20;
  static const double bottomSpacing = 30;
  static const double shimmerItemSpacingVertical = 10;
  static const double shimmerItemSpacingHorizontal = 18;
  static const double shimmerBorderRadius = 20;
  static const double shimmerImageHeight = 240;
  static const double shimmerAvatarSize = 48;
  static const double shimmerAvatarSpacing = 14;
  static const double shimmerAvatarRadius = 12;
  static const double shimmerTitleHeight = 16;
  static const double shimmerTitleWidth = 200;
  static const double shimmerSubtitleHeight = 13;
  static const double shimmerSubtitleWidth = 120;
  static const double shimmerSpacingSmall = 8;
  /*   static const double shimmerSpacingMedium = 10;
 */
  static const double shimmerPaddingTop = 14;
  static const double shimmerPaddingBottom = 16;
  static const double shimmerPaddingLeft = 16;
  static const double shimmerPaddingRight = 16;
  static const int shimmerShimmerCount = 3;

  // Error
  static const double errorPadding = 40;
  static const double errorIconSize = 56;
  static const double errorSpacing = 20;
  static const double errorFontSize = 16;
  static const double errorButtonWidth = 120;
  static const double errorButtonHeight = 48;

  // Empty
  static const double emptyPadding = 40;
  static const double emptyFontSize = 16;

  // Auth Dialog - tablet için daha büyük
  static const double dialogBorderRadius = 20;
  static const double dialogButtonRadius = 10;

  // İzlemeye Devam Et ile Üniversitelerin Son Videoları arasındaki ek boşluk
  static const double continueWatchingExtraSpacing = 24;

  // İçerik Bölüm Başlığı ("Üniversitelerin Son Videoları")
  static const double contentTitlePadHorizontal = 16;
  static const double contentTitlePadTop = 20;
  static const double contentTitlePadBottom = 12;
  static const double contentTitleFontSize = 20;
  static const double contentTitleSubSpacing = 4;
  static const double contentSubtitleFontSize = 13;

  // ── Utility Bar (Canlı Radyo Pili + Liste/Çark Anahtarı) — SABİT PİKSEL ──
  static const double radioDotSize = 9;
  static const double radioIconSize = 18;
  static const double radioGapSmall = 7;
  static const double radioGapTiny = 5;
  static const double radioPadH = 14;
  static const double radioPadV = 7;
  static const double radioBadgePadH = 7;
  static const double radioBadgePadV = 2.5;
  static const double radioBadgeRadius = 5;
  static const double viewToggleOuterPad = 3;
  static const double viewToggleOuterRadius = 9;
  static const double viewToggleButtonSize = 36;
  static const double viewToggleIconSize = 20;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class HomeTabWidgetTablet extends StatefulWidget {
  const HomeTabWidgetTablet({super.key});

  @override
  State<HomeTabWidgetTablet> createState() => _HomeTabWidgetTabletState();
}

class _HomeTabWidgetTabletState extends State<HomeTabWidgetTablet> {
  final controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Worker? _authWorker;
  Worker? _homeResetWorker;

  // ── Carousel Slider state ────────────────────────────────────────────────
  // Aktif sayfa indeksi (alttaki nokta göstergeleri için).
  int _currentCarouselIndex = 0;

  // Kategori çipleri şimdilik yerel/görsel state (bkz. _buildCategoryChips).
  /*   final int _selectedCategoryIndex = 0;
 */

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get.find<ShortsController>().loadShorts();
    });

    _scrollController.addListener(_onScroll);

    _authWorker = ever(controller.showAuthRequired, (required) {
      if (required) {
        _showAuthDialog();
        controller.showAuthRequired.value = false;
      }
    });

    _homeResetWorker = ever<int>(controller.homeTabResetSignal, (_) {
      _resetToTopAndRefresh();
    });
  }

  // "Ana Sayfa" sekmesine basıldığında çağrılır: listeyi en üste kaydırır
  // ve ardından pull-to-refresh ile aynı yenileme mantığını (spinner dahil)
  // programatik olarak tetikler.
  void _resetToTopAndRefresh() {
    if (!mounted) return;

    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshIndicatorKey.currentState?.show();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      controller.loadMoreVideos();
    }
  }

  void _maybeAutoLoadMore() {
    if (!mounted) return;
    if (!_scrollController.hasClients) return;
    if (controller.isWheelView.value) return;
    if (!controller.hasMoreVideos.value || controller.isLoadingMore.value) {
      return;
    }
    if (_scrollController.position.maxScrollExtent <= 0) {
      controller.loadMoreVideos();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _authWorker?.dispose();
    _homeResetWorker?.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 5 — TEK DALLANMA NOKTASI
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoLoadMore());

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () async {
            await controller.refreshVideos();
            await controller.loadVideoSections();
            await controller.loadPlaylists();
            await controller.loadUniversityStats();
            await controller.loadContinueWatching();
            await Get.find<ShortsController>().refresh();
          },
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // ── CAROUSEL SLIDER (en üstte) ───────────────────────────────
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(flex: 2, child: _buildCarouselSlider(context)),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 50.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
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
                            topRight: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
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
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Sizlerle',
                              style: TextStyle(
                                color: AppTheme.textSec(
                                  context,
                                ).withValues(alpha: 0.85),
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 14.h),
                            Container(
                              width: 40.w,
                              height: 40.w,
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
                                size: 7.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Canlı Radyo Pili + Görünüm Anahtarı ─────────────────────
              SliverToBoxAdapter(
                child: _buildUtilityBar(
                  context,
                  isTablet: Responsive.isTablet(context),
                ),
              ),

              // ── Shorts ───────────────────────────────────────────────────
              const SliverToBoxAdapter(child: ShortsRowWidget()),

              // ── İzlemeye Devam Et ──
              SliverToBoxAdapter(
                child: Obx(() {
                  final items = controller.continueWatching.toList();
                  final showSection =
                      !controller.isWheelView.value && items.isNotEmpty;
                  if (!showSection) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 20.0.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContinueWatchingSectionWidget(
                          items: items,
                          onRemove: controller.removeFromContinueWatching,
                        ),
                        SizedBox(
                          height: _TabletSizes.continueWatchingExtraSpacing,
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // ── İçerik Alanı ─────────────────────────────────────────────
              Obx(() => _buildContentSliver(context)),

              // ── Yaklaşan Canlı Yayın Şeridi ──────────────────────────────
              SliverToBoxAdapter(
                child: _buildUpcomingLiveBanner(
                  context,
                  isTablet: Responsive.isTablet(context),
                ),
              ),

              // ── Alt Boşluk ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(height: _TabletSizes.bottomSpacing),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CAROUSEL SLIDER (en üstteki öne çıkan videolar)
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

      // Kart genişliği = ekran genişliği * viewportFraction.
      // Kart = 16:9 thumbnail + gövde (avatar / başlık satırı).
      final double fraction = isTablet ? .5 : 0.82;
      final double itemWidth =
          250.w; // MediaQuery.of(context).size.width * fraction;
      final double cardHeight = itemWidth * 9 / 16 + (isTablet ? 55.w : 90);
      // enlargeCenterPage ortadaki kartı görsel olarak büyüttüğü için
      // yüksekliğe pay bırakıyoruz. Kartta kesilme görürsen 1.2 → 1.3 yap.
      final double carouselHeight = cardHeight * .55;
      final scheme = Theme.of(context).colorScheme;

      return Column(
        children: [
          CarouselSlider(
            items: featured.map((video) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4.w),
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
              autoPlay: false, //featured.length > 1,
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

          // ── Nokta göstergeleri ─────────────────────────────────────────
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
                  margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 8.h),
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
    // bool isFeatured = false,
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
          borderRadius: BorderRadius.circular(2.r),
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
            // 16:9 Thumbnail & Rozetler
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
                    bottom: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        video.duration.isNotEmpty ? video.duration : '18:42',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 4.sp,
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
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isTablet ? 4.sp : 13.5.sp,
                      fontWeight: FontWeight.w700,
                      //height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8.h),

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
                            fontSize: isTablet ? 4.sp : 7.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Text(
                        timeAgoTr(video.publishedAt),
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 4.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          height: isTablet ? 280 : 240.h,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  // Tasarımdaki "Kampüs FM Canlı" pili + Liste/Çark görünüm anahtarı.
  Widget _buildUtilityBar(BuildContext context, {required bool isTablet}) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = _TabletSizes.titleSpacingLarge;

    final double dotSize = _TabletSizes.radioDotSize;
    final double radioIconSize = _TabletSizes.radioIconSize;
    final double gapSmall = _TabletSizes.radioGapSmall;
    final double gapTiny = _TabletSizes.radioGapTiny;
    final double radioPadH = _TabletSizes.radioPadH;
    final double radioPadV = _TabletSizes.radioPadV;
    final double badgePadH = _TabletSizes.radioBadgePadH;
    final double badgePadV = _TabletSizes.radioBadgePadV;
    final double badgeRadius = _TabletSizes.radioBadgeRadius;
    final double toggleOuterPad = _TabletSizes.viewToggleOuterPad;
    final double toggleOuterRadius = _TabletSizes.viewToggleOuterRadius;
    final double toggleButtonSize = _TabletSizes.viewToggleButtonSize;
    final double toggleIconSize = _TabletSizes.viewToggleIconSize;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Canlı Kampüs Radyosu Düğmesi
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            onTap: () => Get.toNamed(AppRoutes.radio),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: radioPadH,
                vertical: radioPadV,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: gapSmall),
                  Icon(
                    Icons.radio_rounded,
                    color: scheme.primary,
                    size: radioIconSize,
                  ),
                  SizedBox(width: gapSmall),
                  Text(
                    'Kampüs FM Canlı',
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: scheme.onSurface),
                  ),
                  SizedBox(width: gapTiny),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: badgePadH,
                      vertical: badgePadV,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(badgeRadius),
                    ),
                    child: Text(
                      'YAYINDA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Görünüm Modu Seçici (Liste vs Çark)
          Obx(
            () => Container(
              padding: EdgeInsets.all(toggleOuterPad),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(toggleOuterRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewModeButton(
                    icon: Icons.view_agenda_rounded,
                    tooltip: 'Liste Görünümü',
                    selected: !controller.isWheelView.value,
                    size: toggleButtonSize,
                    iconSize: toggleIconSize,
                    onTap: () {
                      if (controller.isWheelView.value) {
                        controller.toggleWheelView();
                      }
                    },
                  ),
                  _ViewModeButton(
                    icon: Icons.grid_view_rounded,
                    tooltip: 'Çark / Grid Görünümü',
                    selected: controller.isWheelView.value,
                    size: toggleButtonSize,
                    iconSize: toggleIconSize,
                    onTap: () {
                      if (!controller.isWheelView.value) {
                        controller.toggleWheelView();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildContentHeader(BuildContext context, {required bool isTablet}) {
    final titleFontSize = _TabletSizes.contentTitleFontSize;
    final subSpacing = _TabletSizes.contentTitleSubSpacing;
    final subtitleFontSize = _TabletSizes.contentSubtitleFontSize;
    final iconSize = isTablet ? 22.0 : 20.sp;
    final iconSpacing = isTablet ? 8.0 : 6.w;
    final sortFontSize = isTablet ? 14.0 : 13.sp;
    final sortIconSize = isTablet ? 20.0 : 18.sp;

    final activeFilter = controller.feedFilter.value;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.video_library_rounded,
                    size: iconSize,
                    color: AppTheme.primaryColor,
                  ),
                  SizedBox(width: iconSpacing),
                  Flexible(
                    child: Text(
                      'Üniversitelerin Son Videoları',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: subSpacing),
              Text(
                _feedFilterSubtitle(activeFilter),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: subtitleFontSize,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<HomeFeedFilter>(
          initialValue: activeFilter,
          tooltip: 'Videoları filtrele',
          onSelected: controller.setFeedFilter,
          itemBuilder: (context) => HomeFeedFilter.values
              .map((f) => _buildFeedFilterMenuItem(f, activeFilter))
              .toList(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 6 : 4.w,
              vertical: isTablet ? 4 : 4.h,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _feedFilterLabel(activeFilter),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sortFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: sortIconSize,
                  color: AppTheme.textSec(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<HomeFeedFilter> _buildFeedFilterMenuItem(
    HomeFeedFilter filter,
    HomeFeedFilter activeFilter,
  ) {
    final selected = filter == activeFilter;
    return PopupMenuItem<HomeFeedFilter>(
      value: filter,
      child: Row(
        children: [
          Icon(
            _feedFilterIcon(filter),
            size: 18,
            color: selected ? AppTheme.primaryColor : null,
          ),
          const SizedBox(width: 10),
          Text(
            _feedFilterLabel(filter),
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  IconData _feedFilterIcon(HomeFeedFilter filter) {
    switch (filter) {
      case HomeFeedFilter.latest:
        return Icons.new_releases_rounded;
      case HomeFeedFilter.followed:
        return Icons.favorite_rounded;
      case HomeFeedFilter.notFollowed:
        return Icons.explore_outlined;
      case HomeFeedFilter.live:
        return Icons.sensors_rounded;
    }
  }

  String _feedFilterLabel(HomeFeedFilter filter) {
    switch (filter) {
      case HomeFeedFilter.latest:
        return 'En Yeniler';
      case HomeFeedFilter.followed:
        return 'Takip Ettiklerim';
      case HomeFeedFilter.notFollowed:
        return 'Takip Etmediklerim';
      case HomeFeedFilter.live:
        return 'Canlı Yayın';
    }
  }

  String _feedFilterSubtitle(HomeFeedFilter filter) {
    switch (filter) {
      case HomeFeedFilter.latest:
        return 'Takip ettiğin ve diğer üniversitelerden en yeni paylaşımlar burada.';
      case HomeFeedFilter.followed:
        return 'Sadece takip ettiğin üniversitelerin en yeni videoları.';
      case HomeFeedFilter.notFollowed:
        return 'Henüz takip etmediğin üniversitelerden en yeni paylaşımlar.';
      case HomeFeedFilter.live:
        return 'Şu anda canlı yayında olan üniversiteler.';
    }
  }

  String _feedEmptyMessage(HomeFeedFilter filter) {
    switch (filter) {
      case HomeFeedFilter.latest:
        return 'Henüz video yok.';
      case HomeFeedFilter.followed:
        return controller.isLoggedIn
            ? 'Henüz hiçbir üniversiteyi takip etmiyorsun.\nÜniversiteler sekmesinden takip etmeye başlayabilirsin.'
            : 'Takip ettiğin üniversitelerin videolarını görmek için giriş yapman gerekiyor.';
      case HomeFeedFilter.notFollowed:
        return 'Takip etmediğin üniversite kalmamış 🎉';
      case HomeFeedFilter.live:
        return 'Şu anda canlı yayında olan üniversite yok.';
    }
  }

  Widget _buildUpcomingLiveBanner(
    BuildContext context, {
    required bool isTablet,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = _TabletSizes.titleSpacingLarge;
    final vGap = isTablet ? 24.0 : 24.h;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, vGap, hPad, isTablet ? 16 : 16.h),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [scheme.surfaceContainerHigh, scheme.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(isTablet ? 20 : 20.r),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 40 : 40.w,
              height: isTablet ? 40 : 40.w,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(isTablet ? 12 : 12.r),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.live_tv_rounded,
                color: scheme.primary,
                size: isTablet ? 24 : 24.sp,
              ),
            ),
            SizedBox(width: isTablet ? 12 : 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yaklaşan Canlı Yayın',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 14 : 14.sp,
                    ),
                  ),
                  Text(
                    'Yarın 14:00 • ODTÜ Mezuniyet Töreni',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: isTablet ? 12 : 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isTablet ? 8 : 8.w),
            InkWell(
              borderRadius: BorderRadius.circular(isTablet ? 8 : 8.r),
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 14.w,
                  vertical: isTablet ? 8 : 8.h,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(isTablet ? 8 : 8.r),
                ),
                child: Text(
                  'Hatırlat',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 13 : 13.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSliver(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(child: _buildVideoShimmerTablet(context));
    }

    if (controller.errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(child: _buildErrorWidgetTablet(context));
    }

    final nonShorts = controller.videos.where((v) => !v.isShorts).toList();

    if (nonShorts.isEmpty) {
      final isTablet = Responsive.isTablet(context);
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.contentTitlePadHorizontal,
                _TabletSizes.contentTitlePadTop,
                _TabletSizes.contentTitlePadHorizontal,
                _TabletSizes.contentTitlePadBottom,
              ),
              child: _buildContentHeader(context, isTablet: isTablet),
            ),
          ),
          SliverToBoxAdapter(child: _buildEmptyWidgetTablet(context)),
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

    final showLoader = controller.hasMoreVideos.value;
    final isLoadingMore = controller.isLoadingMore.value;

    // ── TABLET: Grid görünümü ─────────────────────────────────────────────
    if (Responsive.isTablet(context)) {
      const double horizontalPadding = 16;
      const double gridSpacing = 16;
      final Orientation orientation = MediaQuery.orientationOf(context);
      final int crossAxisCount = orientation == Orientation.portrait ? 2 : 3;

      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.contentTitlePadHorizontal,
                _TabletSizes.contentTitlePadTop,
                _TabletSizes.contentTitlePadHorizontal,
                _TabletSizes.contentTitlePadBottom,
              ),
              child: _buildContentHeader(context, isTablet: true),
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

    // ── PHONE: Tam genişlik liste görünümü ────────────────────────────────
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _TabletSizes.titleSpacingLarge.w,
              _TabletSizes.contentTitlePadTop.h,
              _TabletSizes.titleSpacingLarge.w,
              _TabletSizes.contentTitlePadBottom.h,
            ),
            child: _buildContentHeader(context, isTablet: false),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index >= nonShorts.length) {
              return isLoadingMore
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink();
            }

            return VideoCardWidget(video: nonShorts[index]);
          }, childCount: nonShorts.length + (showLoader ? 1 : 0)),
        ),
      ],
    );
  }

  // ── Tablet Shimmer ──
  Widget _buildVideoShimmerTablet(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          _TabletSizes.shimmerShimmerCount,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _TabletSizes.shimmerItemSpacingHorizontal,
              vertical: _TabletSizes.shimmerItemSpacingVertical,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.shimmerBorderRadius,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: _TabletSizes.shimmerImageHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(_TabletSizes.shimmerBorderRadius),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      _TabletSizes.shimmerPaddingLeft,
                      _TabletSizes.shimmerPaddingTop,
                      _TabletSizes.shimmerPaddingRight,
                      _TabletSizes.shimmerPaddingBottom,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // (Genişlik/renkler aşağıda Expanded ile kurulu)
                        _TabletShimmerBody(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tablet Error Widget ──
  Widget _buildErrorWidgetTablet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_TabletSizes.errorPadding),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSec(context),
            size: _TabletSizes.errorIconSize,
          ),
          const SizedBox(height: _TabletSizes.errorSpacing),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.errorFontSize,
            ),
          ),
          const SizedBox(height: _TabletSizes.errorSpacing),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(
                _TabletSizes.errorButtonWidth,
                _TabletSizes.errorButtonHeight,
              ),
            ),
            onPressed: controller.loadVideos,
            child: Text(
              'Tekrar Dene',
              style: TextStyle(fontSize: _TabletSizes.errorFontSize),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tablet Empty Widget ──
  Widget _buildEmptyWidgetTablet(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_TabletSizes.emptyPadding),
      child: Center(
        child: Text(
          _feedEmptyMessage(controller.feedFilter.value),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _TabletSizes.emptyFontSize,
          ),
        ),
      ),
    );
  }

  // Giriş gerektiren durumda gösterilen diyalog.
  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_TabletSizes.dialogBorderRadius),
        ),
        title: const Text('Giriş Gerekli'),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapman gerekiyor.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  _TabletSizes.dialogButtonRadius,
                ),
              ),
            ),
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}

// Tablet shimmer içindeki avatar + metin satırı.
class _TabletShimmerBody extends StatelessWidget {
  const _TabletShimmerBody();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: _TabletSizes.shimmerAvatarSize,
            height: _TabletSizes.shimmerAvatarSize,
            margin: const EdgeInsets.only(
              right: _TabletSizes.shimmerAvatarSpacing,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.circular(
                _TabletSizes.shimmerAvatarRadius,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: _TabletSizes.shimmerTitleHeight,
                  color: AppTheme.surface(context),
                ),
                const SizedBox(height: _TabletSizes.shimmerSpacingSmall),
                Container(
                  height: _TabletSizes.shimmerTitleHeight,
                  width: _TabletSizes.shimmerTitleWidth,
                  color: AppTheme.surface(context),
                ),
                const SizedBox(height: _TabletSizes.shimmerSpacingSmall),
                Container(
                  height: _TabletSizes.shimmerSubtitleHeight,
                  width: _TabletSizes.shimmerSubtitleWidth,
                  color: AppTheme.surface(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Görünüm modu (Liste / Çark) seçici düğmesi.
class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
