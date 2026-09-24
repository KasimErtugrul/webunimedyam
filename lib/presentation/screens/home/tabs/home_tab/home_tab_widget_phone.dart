// lib/presentation/screens/home/widgets/tabs/home_tab/home_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
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

class _PhoneSizes {
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

  // ── Utility Bar (Canlı Radyo Pili + Liste/Çark Anahtarı) ────────────────
  // NOT: Bu değerler ScreenUtil (.w/.h/.sp/.r) İLE ÇARPILIR — bu yüzden
  // sadece GERÇEK telefonlarda kullanılmalı. Responsive.isTablet(context)
  // true dönen (katlanır telefon açık hâli, tablet, split-screen vb.) HER
  // GENİŞ EKRANDA bunun yerine _TabletSizes'taki SABİT (ScreenUtil'siz)
  // karşılıkları kullanılır — aksi hâlde ScreenUtil'in ölçek katsayısı
  // (ekranGenişliği / 375 tasarım genişliği) geniş ekranlarda 2x'in üzerine
  // çıkıp bu küçük kontrolleri (pil, hap, anahtar) orantısızca büyütür.
  static const double radioDotSize = 8;
  static const double radioIconSize = 16;
  static const double radioGapSmall = 6;
  static const double radioGapTiny = 4;
  static const double radioPadH = 12;
  static const double radioPadV = 6;
  static const double radioBadgePadH = 6;
  static const double radioBadgePadV = 2;
  static const double radioBadgeRadius = 4;
  static const double viewToggleOuterPad = 2;
  static const double viewToggleOuterRadius = 8;
  static const double viewToggleButtonSize = 32;
  static const double viewToggleIconSize = 18;
  /*   static const double categoryChipPadH = 14;
  static const double categoryChipPadV = 8; */
}

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

  // ── Utility Bar (Canlı Radyo Pili + Liste/Çark Anahtarı) — SABİT PİKSEL ──
  // ScreenUtil'e HİÇ dokunmaz; geniş/tablet/katlanır-açık ekranlarda bu
  // sabit değerler kullanılır (bkz. _PhoneSizes'taki açıklama).
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
  /*   static const double categoryChipPadH = 16;
  static const double categoryChipPadV = 9; */
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class HomeTabWidgetPhone extends StatefulWidget {
  const HomeTabWidgetPhone({super.key});

  @override
  State<HomeTabWidgetPhone> createState() => _HomeTabWidgetPhoneState();
}

class _HomeTabWidgetPhoneState extends State<HomeTabWidgetPhone> {
  final controller = Get.find<HomeController>();
  final ScrollController _scrollController = ScrollController();
  // RefreshIndicator'ı kod içinden (kullanıcı parmağıyla çekmeden) de
  // tetikleyebilmek için: BottomNavigationBar'da "Ana Sayfa"ya basıldığında
  // hem spinner görünsün hem de gerçek yenileme mantığı (onRefresh) çalışsın.
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  Worker? _authWorker;
  Worker? _homeResetWorker;
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
              // ── Üst Bar (ÜniTV / KAMPÜS YAYINI) artık burada değil ──────
              // Bu bar HomeScreen'in Scaffold.appBar'ına taşındı, böylece
              // bottom navigation'daki TÜM sekmelerde sabit kalıyor.
              // (bkz. presentation/screens/home/widgets/unitv_app_bar.dart)

              // ── Canlı Radyo Pili + Görünüm Anahtarı ─────────────────────
              SliverToBoxAdapter(
                child: _buildUtilityBar(
                  context,
                  isTablet: Responsive.isTablet(context),
                ),
              ),

              /*  // ── Kategori / Filtre Hapları ────────────────────────────────
              SliverToBoxAdapter(
                child: _buildCategoryChips(
                  context,
                  isTablet: Responsive.isTablet(context),
                ),
              ), */

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

              // ── Yaklaşan Canlı Yayın Şeridi ──────────────────────────────
              SliverToBoxAdapter(
                child: _buildUpcomingLiveBanner(
                  context,
                  isTablet: Responsive.isTablet(context),
                ),
              ),

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

  // Tasarımdaki "Kampüs FM Canlı" pili + Liste/Çark görünüm anahtarı.
  // (Header'ın hemen altında, ayrı bir yatay şerit.)
  //
  // ÖNEMLİ: Bu bölümdeki TÜM ölçüler artık `isTablet` parametresine göre
  // _PhoneSizes (ScreenUtil .w/.h/.sp/.r ile ölçeklenen) veya _TabletSizes
  // (sabit piksel) sabitlerinden seçiliyor. Önceden buradaki iç elemanlar
  // (radyo noktası, ikon, rozet, görünüm anahtarı düğmeleri) HER ZAMAN
  // ScreenUtil ile ölçekleniyordu; katlanır bir telefon açıldığında ekran
  // "tablet" sayılsa bile (Responsive.isTablet == true) bu küçük kontroller
  // hâlâ ScreenUtil'in telefon tasarımına (375 genişlik) göre hesapladığı
  // orantısız büyük bir ölçek katsayısıyla çarpılıyor, bu da düğmelerin
  // saçma şekilde büyümesine yol açıyordu. Artık tablet/geniş ekranda sabit
  // piksel değerleri kullanılıyor.
  Widget _buildUtilityBar(BuildContext context, {required bool isTablet}) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = isTablet
        ? _TabletSizes.titleSpacingLarge
        : _PhoneSizes.titleSpacingLarge.w;

    final double dotSize = isTablet
        ? _TabletSizes.radioDotSize
        : _PhoneSizes.radioDotSize.w;
    final double radioIconSize = isTablet
        ? _TabletSizes.radioIconSize
        : _PhoneSizes.radioIconSize.sp;
    final double gapSmall = isTablet
        ? _TabletSizes.radioGapSmall
        : _PhoneSizes.radioGapSmall.w;
    final double gapTiny = isTablet
        ? _TabletSizes.radioGapTiny
        : _PhoneSizes.radioGapTiny.w;
    final double radioPadH = isTablet
        ? _TabletSizes.radioPadH
        : _PhoneSizes.radioPadH.w;
    final double radioPadV = isTablet
        ? _TabletSizes.radioPadV
        : _PhoneSizes.radioPadV.h;
    final double badgePadH = isTablet
        ? _TabletSizes.radioBadgePadH
        : _PhoneSizes.radioBadgePadH.w;
    final double badgePadV = isTablet
        ? _TabletSizes.radioBadgePadV
        : _PhoneSizes.radioBadgePadV.h;
    final double badgeRadius = isTablet
        ? _TabletSizes.radioBadgeRadius
        : _PhoneSizes.radioBadgeRadius.r;
    final double toggleOuterPad = isTablet
        ? _TabletSizes.viewToggleOuterPad
        : _PhoneSizes.viewToggleOuterPad.w;
    final double toggleOuterRadius = isTablet
        ? _TabletSizes.viewToggleOuterRadius
        : _PhoneSizes.viewToggleOuterRadius.r;
    final double toggleButtonSize = isTablet
        ? _TabletSizes.viewToggleButtonSize
        : _PhoneSizes.viewToggleButtonSize.w;
    final double toggleIconSize = isTablet
        ? _TabletSizes.viewToggleIconSize
        : _PhoneSizes.viewToggleIconSize.sp;

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

  /* // Tasarımdaki kategori/filtre hapları.
  // NOT: Backend'de henüz kategoriye göre video filtreleme endpoint'i
  // olmadığı için bu satır şimdilik SADECE GÖRSEL (tasarımla birebir) —
  // seçili çip yerelde tutuluyor, gerçek bir filtreleme tetiklemiyor.
  // Kategori filtreleme API'si eklendiğinde `controller`'a bağlanabilir.
  Widget _buildCategoryChips(BuildContext context, {required bool isTablet}) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = isTablet
        ? _TabletSizes.titleSpacingLarge
        : _PhoneSizes.titleSpacingLarge.w;
    final rowHeight = isTablet ? 44.0 : 40.h;
    final chipGap = isTablet ? 10.0 : 8.w;
    final chipPadH = isTablet
        ? _TabletSizes.categoryChipPadH
        : _PhoneSizes.categoryChipPadH.w;
    final chipPadV = isTablet
        ? _TabletSizes.categoryChipPadV
        : _PhoneSizes.categoryChipPadV.h;
    const categories = [
      'Tümü',
      'Mühendislik & Teknoloji',
      'Tıp & Sağlık',
      'Kampüs & Kültür',
      'Akademik Dersler',
    ];

    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        itemCount: categories.length,
        separatorBuilder: (_, _) => SizedBox(width: chipGap),
        itemBuilder: (context, index) {
          final selected = _selectedCategoryIndex == index;
          return _CategoryChip(
            label: categories[index],
            selected: selected,
            onTap: () => setState(() => _selectedCategoryIndex = index),
            scheme: scheme,
            padH: chipPadH,
            padV: chipPadV,
          );
        },
      ),
    );
  } */

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  // "Üniversitelerin Son Videoları" bölüm başlığı.
  // Tasarım: sol → 📹 ikon + başlık (altında bizim ek açıklama satırımız
  // duruyor — tasarımda yok ama bilgi amaçlı olduğu için kaldırılmadı);
  // sağ → filtre seçici. "En Yeniler" (Tümü) / "Takip Ettiklerim" /
  // "Takip Etmediklerim" / "Canlı Yayın" arasında geçiş yapar — seçim
  // FeedController.feedFilter'a yazılır ve feed o filtreyle (10'luk
  // sayfalama korunarak) yeniden yüklenir.
  Widget _buildContentHeader(BuildContext context, {required bool isTablet}) {
    final titleFontSize = isTablet
        ? _TabletSizes.contentTitleFontSize
        : _PhoneSizes.contentTitleFontSize.sp;
    final subSpacing = isTablet
        ? _TabletSizes.contentTitleSubSpacing
        : _PhoneSizes.contentTitleSubSpacing.h;
    final subtitleFontSize = isTablet
        ? _TabletSizes.contentSubtitleFontSize
        : _PhoneSizes.contentSubtitleFontSize.sp;
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

  // Filtre sonucu boş çıktığında (örn. hiç üniversite takip edilmiyor ya da
  // şu anda canlı yayında kimse yok) gösterilecek mesaj — kullanıcı bunu
  // filtre değilse ayrı bir "hata" gibi değil, filtreye özgü bir bilgi
  // olarak görsün diye _buildEmptyWidget* burada değil, mesaj burada.
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

  // "Yaklaşan Canlı Yayın" alt şeridi.
  // DÜRÜST NOT: Bu bölüm tasarımda var ama backend'de henüz "yaklaşan canlı
  // yayın" verisini döndüren bir endpoint/controller alanı yok — bu yüzden
  // metinler şimdilik tasarımdaki örnekle aynı şekilde SABİT (placeholder).
  // Gerçek veri (etkinlik başlığı/saati) eklenince buraya bağlanmalı;
  // "Hatırlat" butonunun onTap'i de bu sebeple boş bırakıldı.
  Widget _buildUpcomingLiveBanner(
    BuildContext context, {
    required bool isTablet,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final hPad = isTablet
        ? _TabletSizes.titleSpacingLarge
        : _PhoneSizes.titleSpacingLarge.w;
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

    // FIX: Boş sonuç durumunda da bölüm başlığı (ve içindeki filtre
    // seçici) gösterilmeye devam eder. Önceden filtre sonucu boş
    // geldiğinde (örn. "Takip Ettiklerim" hiç takip yoksa, "Canlı Yayın"
    // kimse yayında değilse) başlık tamamen kayboluyor ve kullanıcının
    // filtreyi değiştirip geri dönecek bir yolu kalmıyordu.
    if (nonShorts.isEmpty) {
      final isTablet = Responsive.isTablet(context);
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: isTablet
                  ? EdgeInsets.fromLTRB(
                      _TabletSizes.contentTitlePadHorizontal,
                      _TabletSizes.contentTitlePadTop,
                      _TabletSizes.contentTitlePadHorizontal,
                      _TabletSizes.contentTitlePadBottom,
                    )
                  : EdgeInsets.fromLTRB(
                      _PhoneSizes.titleSpacingLarge.w,
                      _PhoneSizes.contentTitlePadTop.h,
                      _PhoneSizes.titleSpacingLarge.w,
                      _PhoneSizes.contentTitlePadBottom.h,
                    ),
              child: _buildContentHeader(context, isTablet: isTablet),
            ),
          ),
          SliverToBoxAdapter(
            child: isTablet
                ? _buildEmptyWidgetTablet(context)
                : _buildEmptyWidgetPhone(context),
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
          _feedEmptyMessage(controller.feedFilter.value),
          textAlign: TextAlign.center,
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

// ═══════════════════════════════════════════════════════════════════════
// Görünüm modu anahtarı içindeki tek düğme (Liste / Çark)
// Tasarım: seçili → bg-primary + text-on-primary; seçili değil → şeffaf +
// text-on-surface-variant. 32x32 dokunma alanı, rounded (radiusSm).
// ═══════════════════════════════════════════════════════════════════════
class _ViewModeButton extends StatelessWidget {
  const _ViewModeButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback onTap;
  // Artık ScreenUtil'e körü körüne güvenmiyor — çağıran taraf (isTablet'e
  // göre _PhoneSizes/_TabletSizes'tan seçilmiş) sabit değeri veriyor.
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: selected ? scheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          alignment: Alignment.center,
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

// ═══════════════════════════════════════════════════════════════════════
// Kategori/filtre hapı (chip)
// Tasarım: seçili → bg-primary/20 + text-primary + bold; seçili değil →
// bg-surface-container + text-on-surface-variant. rounded-full pill.
// ═══════════════════════════════════════════════════════════════════════
/* class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.scheme,
    required this.padH,
    required this.padV,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme scheme;
  final double padH;
  final double padV;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.20)
              : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
} */
