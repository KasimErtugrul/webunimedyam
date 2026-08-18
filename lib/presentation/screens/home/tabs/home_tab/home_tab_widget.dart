// lib/presentation/screens/home/widgets/tabs/home_tab/home_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/home_controller.dart';
import '../../../../controllers/shorts_controller.dart';
import 'shorts/shorts_row_widget.dart';
import 'widgets/continue_watching_section_widget.dart';
import 'widgets/home_feed_wheel_widget.dart';
import 'widgets/video_card_widget.dart';
import 'widgets/video_grid_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double titleIconSize = 30;
  static const double titleIconBorderRadius = 8;
  static const double titleIconInnerSize = 18;
  static const double titleSpacing = 8;

  // Spacing
  static const double titleSpacingLarge = 16;
  static const double bottomSpacing = 24;
  static const double shimmerItemSpacingVertical = 7;
  static const double shimmerItemSpacingHorizontal = 14;
  static const double shimmerBorderRadius = 16;
  static const double shimmerImageHeight = 196;
  static const double shimmerAvatarSize = 42;
  static const double shimmerAvatarSpacing = 12;
  static const double shimmerAvatarRadius = 10;
  static const double shimmerTitleHeight = 14;
  static const double shimmerTitleWidth = 160;
  static const double shimmerSubtitleHeight = 11;
  static const double shimmerSubtitleWidth = 100;
  static const double shimmerSpacingSmall = 6;
  static const double shimmerSpacingMedium = 8;
  static const double shimmerPaddingTop = 12;
  static const double shimmerPaddingBottom = 14;
  static const double shimmerPaddingLeft = 14;
  static const double shimmerPaddingRight = 14;
  static const int shimmerShimmerCount = 4; // ✅ int olarak düzeltildi

  // Error
  static const double errorPadding = 32;
  static const double errorIconSize = 48;
  static const double errorSpacing = 16;
  static const double errorFontSize = 14;
  static const double errorButtonWidth = 100;
  static const double errorButtonHeight = 40;

  // Empty
  static const double emptyPadding = 32;
  static const double emptyFontSize = 14;

  // Auth Dialog
  static const double dialogBorderRadius = 16;
  static const double dialogButtonRadius = 8;

  // İzlemeye Devam Et ile Üniversitelerin Son Videoları arasındaki ek boşluk
  static const double continueWatchingExtraSpacing = 20;

  // İçerik Bölüm Başlığı ("Üniversitelerin Son Videoları")
  static const double contentTitlePadTop = 20;
  static const double contentTitlePadBottom = 10;
  static const double contentTitleFontSize = 18;
  static const double contentTitleSubSpacing = 4;
  static const double contentSubtitleFontSize = 12;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double titleIconSize = 36;
  static const double titleIconBorderRadius = 10;
  static const double titleIconInnerSize = 22;
  static const double titleSpacing = 10;

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
  static const double shimmerSpacingMedium = 10;
  static const double shimmerPaddingTop = 14;
  static const double shimmerPaddingBottom = 16;
  static const double shimmerPaddingLeft = 16;
  static const double shimmerPaddingRight = 16;
  static const int shimmerShimmerCount = 3; // ✅ int olarak düzeltildi

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
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class HomeTabWidget extends StatefulWidget {
  const HomeTabWidget({super.key});

  @override
  State<HomeTabWidget> createState() => _HomeTabWidgetState();
}

class _HomeTabWidgetState extends State<HomeTabWidget> {
  final controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();
  // RefreshIndicator'ı kod içinden (kullanıcı parmağıyla çekmeden) de
  // tetikleyebilmek için: BottomNavigationBar'da "Ana Sayfa"ya basıldığında
  // hem spinner görünsün hem de gerçek yenileme mantığı (onRefresh) çalışsın.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Worker? _authWorker;
  Worker? _homeResetWorker;

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

    // BottomNavigationBar'daki "Ana Sayfa"ya basıldığında (nerede olursak
    // olalım, hatta zaten bu sekmedeyken bile) HomeController bu sinyali
    // artırır; biz de listeyi en üste kaydırıp yenilemeyi tetikleriz.
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

    // RefreshIndicator'ın kendi görsel spinner'ını göstererek onRefresh'i
    // tetikler; böylece pull-to-refresh ile tam olarak aynı veri yenileme
    // akışı (refreshVideos, loadVideoSections, vs.) çalışır.
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
              // ── Üst Bar — Sadece Logo/Aksiyonlar (Shorts YOK) ──────────
              // KURAL 5 — TEK DALLANMA NOKTASI
              Responsive.isTablet(context)
                  ? _buildAppBarTablet(context)
                  : _buildAppBarPhone(context),

              // ── Shorts — artık listenin en üstünde, ayrı bir sliver ────
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
                        // Bir sonraki bölümle ("Üniversitelerin Son Videoları")
                        // arada biraz daha nefes alan bir boşluk olsun.
                        SizedBox(
                          height: Responsive.isTablet(context)
                              ? _TabletSizes.continueWatchingExtraSpacing
                              : _PhoneSizes.continueWatchingExtraSpacing.h,
                        ),
                      ],
                    ),
                  );
                }),
              ),

              // ── İçerik Alanı ─────────────────────────────────────────────
              Obx(() => _buildContentSliver(context)),

              // ── Alt Boşluk ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: Responsive.isTablet(context)
                      ? _TabletSizes.bottomSpacing
                      : _PhoneSizes.bottomSpacing.h,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI) — AppBar
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildAppBarPhone(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.bg(context),
      automaticallyImplyLeading: false,
      titleSpacing: _PhoneSizes.titleSpacingLarge.w,
      toolbarHeight: kToolbarHeight,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isWheelView.value
                  ? Icons.view_list_rounded
                  : Icons.blur_circular_rounded,
            ),
            tooltip: controller.isWheelView.value
                ? 'Liste Görünümü'
                : 'Wheel Görünümü',
            onPressed: controller.toggleWheelView,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.radio_rounded),
          onPressed: () => Get.toNamed(AppRoutes.radio),
        ),
      ],
      title: Row(
        children: [
          Container(
            width: _PhoneSizes.titleIconSize.w,
            height: _PhoneSizes.titleIconSize.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                _PhoneSizes.titleIconBorderRadius.r,
              ),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: _PhoneSizes.titleIconInnerSize.sp,
            ),
          ),
          SizedBox(width: _PhoneSizes.titleSpacing.w),
          Text('ÜniTV'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ) — AppBar
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildAppBarTablet(BuildContext context) {
    return SliverAppBar(
      pinned: false,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppTheme.bg(context),
      automaticallyImplyLeading: false,
      titleSpacing: _TabletSizes.titleSpacingLarge,
      toolbarHeight: kToolbarHeight,
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.isWheelView.value
                  ? Icons.view_list_rounded
                  : Icons.blur_circular_rounded,
            ),
            tooltip: controller.isWheelView.value
                ? 'Liste Görünümü'
                : 'Wheel Görünümü',
            onPressed: controller.toggleWheelView,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.radio_rounded),
          onPressed: () => Get.toNamed(AppRoutes.radio),
        ),
      ],
      title: Row(
        children: [
          Container(
            width: _TabletSizes.titleIconSize,
            height: _TabletSizes.titleIconSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(
                _TabletSizes.titleIconBorderRadius,
              ),
            ),
            child: Image.asset(
              'assets/logo/logo.png',
              width: _TabletSizes.titleIconInnerSize,
              height: _TabletSizes.titleIconInnerSize,
            ),
          ),
          SizedBox(width: _TabletSizes.titleSpacing),
          Text('ÜniTV'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildContentSliver(BuildContext context) {
    if (controller.isLoading.value) {
      return SliverToBoxAdapter(
        child: Responsive.isTablet(context)
            ? _buildVideoShimmerTablet(context)
            : _buildVideoShimmerPhone(context),
      );
    }

    if (controller.errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Responsive.isTablet(context)
            ? _buildErrorWidgetTablet(context)
            : _buildErrorWidgetPhone(context),
      );
    }

    final nonShorts = controller.videos.where((v) => !v.isShorts).toList();

    if (nonShorts.isEmpty) {
      return SliverToBoxAdapter(
        child: Responsive.isTablet(context)
            ? _buildEmptyWidgetTablet(context)
            : _buildEmptyWidgetPhone(context),
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

    // ── TABLET: Grid görünümü (dikeyde 2, yatayda 3 sütun) ───────────────
    // Tek bir kartın tüm ekranı kaplamasını önlemek için üniversitelerin
    // son videoları burada her zaman bir grid'de gösterilir. Kolon sayısı
    // ekran yönüne göre değişir: dikey (portrait) konumda kartların çok
    // küçülmemesi için 2, yatay (landscape) konumda ekstra genişlikten
    // yararlanmak için 3 sütun kullanılır.
    //
    // NOT: childAspectRatio ile TAHMİNİ yükseklik vermek yerine, kartın
    // gerçek içerik yüksekliğini (küçük resim + gövde) piksel piksel
    // hesaplayıp mainAxisExtent olarak veriyoruz. Böylece hiçbir zaman
    // "RenderFlex overflowed" (sarı-siyah şerit) hatası oluşmaz —
    // yükseklik tahmine değil, gerçek layout matematiğine dayanıyor.
    if (Responsive.isTablet(context)) {
      const double horizontalPadding = 16;
      const double gridSpacing = 16;
      final Orientation orientation = MediaQuery.orientationOf(context);
      final int crossAxisCount = orientation == Orientation.portrait ? 2 : 3;

      return SliverMainAxisGroup(
        slivers: [
          // ── Bölüm Başlığı ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.contentTitlePadHorizontal,
                _TabletSizes.contentTitlePadTop,
                _TabletSizes.contentTitlePadHorizontal,
                _TabletSizes.contentTitlePadBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversitelerin Son Videoları',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.contentTitleFontSize,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.contentTitleSubSpacing),
                  Text(
                    'Takip ettiğin ve diğer üniversitelerden en yeni paylaşımlar burada.',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.contentSubtitleFontSize,
                    ),
                  ),
                ],
              ),
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

                    // Küçük resim yüksekliği (16:9)
                    final thumbHeight = itemWidth * 9 / 16;

                    // Gövde yüksekliği — VideoGridCardWidget'taki gerçek
                    // değerlerin toplamı (bkz. kGridCardBodyHeight sabiti,
                    // kart dosyasında tanımlıdır ve tek kaynak odur).
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
        // ── Bölüm Başlığı ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              _PhoneSizes.titleSpacingLarge.w,
              _PhoneSizes.contentTitlePadTop.h,
              _PhoneSizes.titleSpacingLarge.w,
              _PhoneSizes.contentTitlePadBottom.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Üniversitelerin Son Videoları',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.contentTitleFontSize.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: _PhoneSizes.contentTitleSubSpacing.h),
                Text(
                  'Takip ettiğin ve diğer üniversitelerden en yeni paylaşımlar burada.',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.contentSubtitleFontSize.sp,
                  ),
                ),
              ],
            ),
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

  // ── Phone Error Widget ──
  Widget _buildErrorWidgetPhone(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_PhoneSizes.errorPadding.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSec(context),
            size: _PhoneSizes.errorIconSize.sp,
          ),
          SizedBox(height: _PhoneSizes.errorSpacing.h),
          Text(
            controller.errorMessage.value,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _PhoneSizes.errorFontSize.sp,
            ),
          ),
          SizedBox(height: _PhoneSizes.errorSpacing.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
                _PhoneSizes.errorButtonWidth.w,
                _PhoneSizes.errorButtonHeight.h,
              ),
            ),
            onPressed: controller.loadVideos,
            child: Text(
              'Tekrar Dene',
              style: TextStyle(fontSize: _PhoneSizes.errorFontSize.sp),
            ),
          ),
        ],
      ),
    );
  }

  // ── Phone Empty Widget ──
  Widget _buildEmptyWidgetPhone(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_PhoneSizes.emptyPadding.w),
      child: Center(
        child: Text(
          'Henüz video yok.',
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _PhoneSizes.emptyFontSize.sp,
          ),
        ),
      ),
    );
  }

  // ── Phone Shimmer ──
  Widget _buildVideoShimmerPhone(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          _PhoneSizes.shimmerShimmerCount,
          (_) => Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.shimmerItemSpacingHorizontal.w,
              vertical: _PhoneSizes.shimmerItemSpacingVertical.h,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.shimmerBorderRadius.r,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: _PhoneSizes.shimmerImageHeight.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_PhoneSizes.shimmerBorderRadius.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _PhoneSizes.shimmerPaddingLeft.w,
                      _PhoneSizes.shimmerPaddingTop.h,
                      _PhoneSizes.shimmerPaddingRight.w,
                      _PhoneSizes.shimmerPaddingBottom.h,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: _PhoneSizes.shimmerAvatarSize.w,
                          height: _PhoneSizes.shimmerAvatarSize.w,
                          margin: EdgeInsets.only(
                            right: _PhoneSizes.shimmerAvatarSpacing.w,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(
                              _PhoneSizes.shimmerAvatarRadius.r,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: _PhoneSizes.shimmerTitleHeight.h,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(
                                height: _PhoneSizes.shimmerSpacingSmall.h,
                              ),
                              Container(
                                height: _PhoneSizes.shimmerTitleHeight.h,
                                width: _PhoneSizes.shimmerTitleWidth.w,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(
                                height: _PhoneSizes.shimmerSpacingMedium.h,
                              ),
                              Container(
                                height: _PhoneSizes.shimmerSubtitleHeight.h,
                                width: _PhoneSizes.shimmerSubtitleWidth.w,
                                color: AppTheme.surface(context),
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
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  // ── Tablet Error Widget ──
  Widget _buildErrorWidgetTablet(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_TabletSizes.errorPadding),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSec(context),
            size: _TabletSizes.errorIconSize,
          ),
          SizedBox(height: _TabletSizes.errorSpacing),
          Text(
            controller.errorMessage.value,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.errorFontSize,
            ),
          ),
          SizedBox(height: _TabletSizes.errorSpacing),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(
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
      padding: EdgeInsets.all(_TabletSizes.emptyPadding),
      child: Center(
        child: Text(
          'Henüz video yok.',
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _TabletSizes.emptyFontSize,
          ),
        ),
      ),
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
            padding: EdgeInsets.symmetric(
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_TabletSizes.shimmerBorderRadius),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      _TabletSizes.shimmerPaddingLeft,
                      _TabletSizes.shimmerPaddingTop,
                      _TabletSizes.shimmerPaddingRight,
                      _TabletSizes.shimmerPaddingBottom,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: _TabletSizes.shimmerAvatarSize,
                          height: _TabletSizes.shimmerAvatarSize,
                          margin: EdgeInsets.only(
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
                              SizedBox(
                                height: _TabletSizes.shimmerSpacingSmall,
                              ),
                              Container(
                                height: _TabletSizes.shimmerTitleHeight,
                                width: _TabletSizes.shimmerTitleWidth,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(
                                height: _TabletSizes.shimmerSpacingMedium,
                              ),
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ORTAK METODLAR
  // ═══════════════════════════════════════════════════════════════════════

  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            Responsive.isTablet(context)
                ? _TabletSizes.dialogBorderRadius
                : _PhoneSizes.dialogBorderRadius.r,
          ),
        ),
        title: const Text(
          'Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
          style: TextStyle(color: Color(0xFF9E9EB8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF9E9EB8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.isTablet(context)
                      ? _TabletSizes.dialogButtonRadius
                      : _PhoneSizes.dialogButtonRadius.r,
                ),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}
