// lib/presentation/screens/university_detail/university_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/university_detail_controller.dart';
import '../../controllers/university_radio_controller.dart';
import 'tabs/about_tab/about_tab.dart';
import 'tabs/live_tab/live_tab.dart';
import 'tabs/shorts_tab/shorts_tab.dart';
import 'tabs/videos_tab/videos_tab.dart';
import 'utils/university_detail_sizes.dart';
import 'widgets/university_detail_header_widget.dart';

// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════
// BUSINESS LOGIC: Radyo Akışını Yöneten GetX Controller
// ═══════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════
// ANA SAYFA (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({super.key});

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  late final UniversityDetailController controller;
  late final UniversityRadioController radioController;
  late final String _radioTag;
  final ScrollController _scrollController = ScrollController();
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<UniversityDetailController>();
    _radioTag = 'uni_radio_${identityHashCode(this)}';
    radioController = Get.put(UniversityRadioController(), tag: _radioTag);
    _scrollController.addListener(_updateTitleOpacity);
  }

  @override
  void dispose() {
    radioController.stopRadio();
    Get.delete<UniversityRadioController>(tag: _radioTag);
    _scrollController.removeListener(_updateTitleOpacity);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateTitleOpacity() {
    if (!_scrollController.hasClients) return;
    final double offset = _scrollController.offset;
    final double maxScroll = 240.h - kToolbarHeight;
    final double fadeStart = maxScroll * 0.99;
    final double fadeEnd = maxScroll;
    double newOpacity;
    if (offset <= fadeStart) {
      newOpacity = 0.0;
    } else if (offset >= fadeEnd) {
      newOpacity = 1.0;
    } else {
      newOpacity = ((offset - fadeStart) / (fadeEnd - fadeStart)).clamp(
        0.0,
        1.0,
      );
    }
    if (newOpacity != _titleOpacity) {
      setState(() => _titleOpacity = newOpacity);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TEK DALLANMA NOKTASI – sizes burada belirlenir, alt widget'lara iletilir
    final UniversityDetailSizes sizes = Responsive.isTablet(context)
        ? const UniversityDetailTabletSizes()
        : const UniversityDetailPhoneSizes();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: sizes.appBarExpandedHeight,
                    pinned: true,
                    floating: false,
                    backgroundColor: AppTheme.bg(context),
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPri(context),
                        size: sizes.appBarLeadingIconSize,
                      ),
                      onPressed: () => Get.back(),
                    ),
                    title: Opacity(
                      opacity: _titleOpacity,
                      child: Obx(() {
                        final uni = controller.university.value;
                        if (uni == null) return const SizedBox.shrink();
                        final hasLogo =
                            uni.logoUrl != null && uni.logoUrl!.isNotEmpty;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasLogo)
                              Padding(
                                padding: EdgeInsets.only(
                                  right: sizes.isTablet ? 12 : 10.w,
                                ),
                                child: ClipOval(
                                  child: Container(
                                    width: sizes.appBarLogoSize,
                                    height: sizes.appBarLogoSize,
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      imageUrl: uni.logoUrl!,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, _, _) => Icon(
                                        Icons.school_rounded,
                                        size: sizes.appBarLogoIconSize,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.only(
                                  right: sizes.isTablet ? 10 : 8.w,
                                ),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: sizes.appBarLogoIconSize,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            Flexible(
                              child: Text(
                                uni.name ?? '',
                                style: TextStyle(
                                  fontSize: sizes.appBarTitleSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPri(context),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    actions: [
                      Obx(() {
                        final isFav = controller.isFavorite.value;
                        final isLoading = controller.isFavoriteLoading.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: sizes.appBarActionPaddingRight,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: sizes.appBarActionIconSize * 1.6,
                                  height: sizes.appBarActionIconSize * 1.6,
                                  child: Center(
                                    child: SizedBox(
                                      width: sizes.appBarActionIconSize * 0.8,
                                      height: sizes.appBarActionIconSize * 0.8,
                                      child: CircularProgressIndicator(
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
                                    duration: const Duration(milliseconds: 250),
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
                                      size: sizes.appBarActionIconSize,
                                    ),
                                  ),
                                  onPressed: controller.toggleFavorite,
                                ),
                        );
                      }),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: UniversityDetailHeader(
                        sizes: sizes,
                        controller: controller,
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(sizes: sizes, context: context),
                  ),
                ],
                body: TabBarView(
                  children: [
                    UniversityDetailAboutTab(
                      sizes: sizes,
                      controller: controller,
                      radioController: radioController,
                    ),
                    UniversityDetailVideosTab(
                      sizes: sizes,
                      controller: controller,
                    ),
                    UniversityDetailShortsTab(
                      sizes: sizes,
                      controller: controller,
                    ),
                    UniversityDetailLiveTab(
                      sizes: sizes,
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ),
            UniversityDetailRadioMiniPlayer(
              sizes: sizes,
              radioController: radioController,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// TAB BAR DELEGATE
// ═══════════════════════════════════════════════════════════

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final UniversityDetailSizes sizes;
  final BuildContext context;
  const _TabBarDelegate({required this.sizes, required this.context});

  @override
  double get minExtent => sizes.tabBarHeight;
  @override
  double get maxExtent => sizes.tabBarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox.expand(
        child: Container(
          color: AppTheme.bg(context),
          child: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSec(context),
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: sizes.tabBarIndicatorWeight,
            labelStyle: TextStyle(
              fontSize: sizes.tabBarLabelFontSize,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: sizes.tabBarUnselectedLabelFontSize,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Hakkında'),
              Tab(text: 'Videolar'),
              Tab(text: 'Shorts'),
              Tab(text: 'Canlı'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}

// ─── Radio Mini Player ─────────────────────────────────────────────────────

class UniversityDetailRadioMiniPlayer extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityRadioController radioController;
  const UniversityDetailRadioMiniPlayer({
    super.key,
    required this.sizes,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!radioController.isRadioActive) return const SizedBox.shrink();

      final meta = radioController.metadata.value;
      final titleText =
          meta?.title ?? radioController.currentPlayingName.value ?? 'Yayın';
      final artistText = meta?.artist ?? 'Canlı Yayın';

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.isDark(context)
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              width: sizes.isTablet ? 2 : 1.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.miniPlayerPaddingHorizontal,
              vertical: sizes.miniPlayerPaddingVertical,
            ),
            child: Row(
              children: [
                Container(
                  width: sizes.miniPlayerLogoSize,
                  height: sizes.miniPlayerLogoSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      sizes.miniPlayerLogoRadius,
                    ),
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: radioController.currentPlayingLogo.value != null
                      ? CachedNetworkImage(
                          imageUrl: radioController.currentPlayingLogo.value!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.radio_rounded,
                          color: AppTheme.primaryColor,
                          size: sizes.miniPlayerLogoSize * 0.6,
                        ),
                ),
                SizedBox(width: sizes.miniPlayerLogoSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: sizes.miniPlayerTitleFontSize,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: sizes.isTablet ? 3 : 2),
                      Text(
                        artistText,
                        style: TextStyle(
                          fontSize: sizes.miniPlayerSubtitleFontSize,
                          color: AppTheme.textSec(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (radioController.isBuffering)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.miniPlayerLoadingSize * 0.5,
                    ),
                    child: SizedBox(
                      width: sizes.miniPlayerLoadingSize,
                      height: sizes.miniPlayerLoadingSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: Icon(
                      radioController.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppTheme.primaryColor,
                      size: sizes.miniPlayerPlayIconSize,
                    ),
                    onPressed: () {
                      radioController.togglePlayPause(
                        url: radioController.currentPlayingUrl.value!,
                        name: radioController.currentPlayingName.value!,
                        logoUrl: radioController.currentPlayingLogo.value,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      color: AppTheme.textSec(context),
                      size: sizes.miniPlayerStopIconSize,
                    ),
                    onPressed: radioController.stopRadio,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
