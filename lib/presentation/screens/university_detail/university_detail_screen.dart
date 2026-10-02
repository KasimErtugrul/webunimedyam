// lib/presentation/screens/university_detail/university_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../controllers/university_detail_controller.dart';
import 'tabs/about_tab/about_tab.dart';
import 'tabs/live_tab/live_tab.dart';
import 'tabs/shorts_tab/shorts_tab.dart';
import 'tabs/videos_tab/videos_tab.dart';
import 'university_detail_layout_spec.dart';
import 'widgets/university_detail_header_widget.dart';
import 'widgets/university_detail_tab_bar.dart';

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({super.key});

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  late final UniversityDetailController controller;
  final ScrollController _scrollController = ScrollController();

  /// Scroll tick'inde setState yerine ValueNotifier → sadece title rebuild.
  final ValueNotifier<double> _titleOpacity = ValueNotifier(0.0);
  final ValueNotifier<bool> _isPinned = ValueNotifier(false);

  /// Aktif layout spec'i; fade hesabında gerçek AppBar yüksekliğini kullanmak
  /// için `_onScroll` içinden erişilir. `build` tarafından güncellenir.
  UniversityDetailLayoutSpec? _spec;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UniversityDetailController>();

    // Stable tag: aynı üniversiteyi tekrar açınca aynı controller yaşamaya
    // devam eder, çift instance oluşmaz.

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Not: state'i başka ekran da kullanabilir, sadece durdurmuyoruz —
    // sadece controller'ı serbest bırakıyoruz. Radio çalıyorsa arka planda
    // çalmaya devam etsin diye bırakılır.
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _titleOpacity.dispose();
    _isPinned.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;

    // Fade mesafesi, AppBar'ın gerçek expandedHeight'ından türetilir; sabit
    // bir varsayım kullanılmaz. Build henüz çalışmadıysa hesap yapılmaz.
    final spec = _spec;
    if (spec == null) return;
    final maxScroll = spec.appBarExpandedHeight - kToolbarHeight;
    if (maxScroll <= 0) return;
    final fadeStart = maxScroll * 0.9;
    final fadeEnd = maxScroll;

    if (offset <= fadeStart) {
      _titleOpacity.value = 0;
    } else if (offset >= fadeEnd) {
      _titleOpacity.value = 1;
    } else {
      _titleOpacity.value = ((offset - fadeStart) / (fadeEnd - fadeStart))
          .clamp(0.0, 1.0);
    }

    // AppBar yüksekliğine yaklaşınca leading icon beyaz olsun mu? Şimdilik
    // sadece flag tut.
    _isPinned.value = offset > maxScroll * 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final spec = UniversityDetailLayoutSpec.of(context);
    _spec = spec;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Center(
          // WEB: içerik çok geniş ekranlarda kenarlara yayılmasın; klasik
          // web sitesi gibi ortalanmış maksimum genişlikte kalsın.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, _) => [
                      SliverAppBar(
                        expandedHeight: spec.appBarExpandedHeight,
                        pinned: true,
                        floating: false,
                        backgroundColor: AppTheme.bg(context),
                        scrolledUnderElevation: 0,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppTheme.textPri(context),
                            size: spec.appBarLeadingIconSize,
                          ),
                          onPressed: Get.back,
                        ),
                        title: ValueListenableBuilder<double>(
                          valueListenable: _titleOpacity,
                          builder: (context, opacity, _) {
                            if (opacity == 0) return const SizedBox.shrink();
                            return Opacity(
                              opacity: opacity,
                              child: Obx(() {
                                final uni = controller.university.value;
                                if (uni == null) return const SizedBox.shrink();
                                final hasLogo = uni.logoUrl?.isNotEmpty == true;
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (hasLogo)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: ClipOval(
                                          child: Container(
                                            width: spec.appBarLogoSize,
                                            height: spec.appBarLogoSize,
                                            color: Colors.white,
                                            child: CachedNetworkImage(
                                              imageUrl: uni.logoUrl!,
                                              fit: BoxFit.contain,
                                              errorWidget: (_, _, _) => Icon(
                                                Icons.school_rounded,
                                                size: spec.appBarLogoIconSize,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          size: spec.appBarLogoIconSize,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    Flexible(
                                      child: Text(
                                        uni.name ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: spec.appBarTitleFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPri(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            );
                          },
                        ),
                        actions: [
                          Obx(() {
                            final isFav = controller.isFavorite.value;
                            final isLoading =
                                controller.isFavoriteLoading.value;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: isLoading
                                  ? SizedBox(
                                      width: spec.appBarActionIconSize * 1.6,
                                      height: spec.appBarActionIconSize * 1.6,
                                      child: Center(
                                        child: SizedBox(
                                          width:
                                              spec.appBarActionIconSize * 0.7,
                                          height:
                                              spec.appBarActionIconSize * 0.7,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppTheme.primaryColor,
                                              ),
                                        ),
                                      ),
                                    )
                                  : IconButton(
                                      tooltip: isFav
                                          ? 'Favorilerden çıkar'
                                          : 'Favorilere ekle',
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        transitionBuilder: (child, anim) =>
                                            ScaleTransition(
                                              scale: anim,
                                              child: child,
                                            ),
                                        child: Icon(
                                          isFav
                                              ? Icons.bookmark_rounded
                                              : Icons.bookmark_border_rounded,
                                          key: ValueKey(isFav),
                                          color: isFav
                                              ? AppTheme.primaryColor
                                              : AppTheme.textPri(context),
                                          size: spec.appBarActionIconSize,
                                        ),
                                      ),
                                      onPressed: controller.toggleFavorite,
                                    ),
                            );
                          }),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                          background: UniversityDetailHeader(
                            spec: spec,
                            controller: controller,
                          ),
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _TabBarDelegate(spec: spec),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        UniversityDetailAboutTab(
                          spec: spec,
                          controller: controller,
                        ),
                        UniversityDetailVideosTab(
                          spec: spec,
                          controller: controller,
                        ),
                        UniversityDetailShortsTab(
                          spec: spec,
                          controller: controller,
                        ),
                        UniversityDetailLiveTab(
                          spec: spec,
                          controller: controller,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final UniversityDetailLayoutSpec spec;
  const _TabBarDelegate({required this.spec});

  @override
  double get minExtent => spec.tabBarHeight + 12;
  @override
  double get maxExtent => spec.tabBarHeight + 12;

  @override
  Widget build(BuildContext context, double _, bool _) {
    return Container(
      color: AppTheme.bg(context),
      child: UniversityDetailTabBar(spec: spec),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => old.spec != spec;
}
