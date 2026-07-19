// lib/presentation/screens/university_detail/university_detail_screen.dart

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:readmore/readmore.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/university_detail_controller.dart';
import '../home/tabs/home_tab/widgets/video_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarExpandedHeight = 240;
  static const double appBarTitleSize = 16;
  static const double appBarLogoSize = 30;
  static const double appBarLogoIconSize = 18;
  static const double appBarActionIconSize = 26;
  static const double appBarActionPaddingRight = 8;
  static const double appBarLeadingIconSize = 22;

  // Header
  static const double headerTopPadding = 56;
  static const double headerLogoOuterSize = 100;
  static const double headerLogoInnerSize = 78;
  static const double headerLogoPadding = 6;
  static const double headerLogoBorderWidth = 2;
  static const double headerLogoShadowBlur = 24;
  static const double headerLogoShadowSpread = 2;
  static const double headerNameFontSize = 19;
  static const double headerNameLineHeight = 1.3;
  static const double headerCitySpacing = 6;
  static const double headerCityFontSize = 13;
  static const double headerCityIconSize = 14;
  static const double headerCityIconSpacing = 3;
  static const double headerBadgeSpacing = 10;
  static const double headerBadgePaddingHorizontal = 12;
  static const double headerBadgePaddingVertical = 4;
  static const double headerBadgeBorderRadius = 20;
  static const double headerBadgeIconSize = 12;
  static const double headerBadgeFontSize = 11;
  static const double headerPaddingHorizontal = 32;

  // TabBar
  static const double tabBarHeight = 48;
  static const double tabBarIndicatorWeight = 2.5;
  static const double tabBarLabelFontSize = 14;
  static const double tabBarUnselectedLabelFontSize = 14;

  // About Tab
  static const double aboutPaddingHorizontal = 16;
  static const double aboutPaddingTop = 20;
  static const double aboutPaddingBottom = 32;
  static const double aboutSectionSpacing = 20;
  static const double aboutSectionTitleSpacing = 8;
  static const double aboutDescriptionFontSize = 13;
  static const double aboutDescriptionLineHeight = 1.6;
  static const double aboutCardPadding = 14;
  static const double aboutCardBorderRadius = 14;

  // Info Row
  static const double infoRowPaddingHorizontal = 14;
  static const double infoRowPaddingVertical = 12;
  static const double infoRowIconSize = 34;
  static const double infoRowIconRadius = 9;
  static const double infoRowIconInnerSize = 17;
  static const double infoRowIconSpacing = 12;
  static const double infoRowLabelFontSize = 11;
  static const double infoRowValueFontSize = 13;
  static const double infoRowValueSpacing = 2;

  // Link Button
  static const double linkButtonPaddingHorizontal = 14;
  static const double linkButtonPaddingVertical = 12;
  static const double linkButtonIconSize = 34;
  static const double linkButtonIconRadius = 9;
  static const double linkButtonIconInnerSize = 17;
  static const double linkButtonIconSpacing = 12;
  static const double linkButtonLabelFontSize = 13;
  static const double linkButtonTrailingIconSize = 16;

  // Radio Inline Card
  static const double radioCardPadding = 14;
  static const double radioCardBorderRadius = 14;
  static const double radioIconContainerSize = 46;
  static const double radioIconContainerRadius = 12;
  static const double radioIconSize = 22;
  static const double radioIconSpacing = 14;
  static const double radioTitleFontSize = 14;
  static const double radioSubtitleFontSize = 11.5;
  static const double radioPlayButtonSize = 44;
  static const double radioPlayButtonRadius = 24;
  static const double radioPlayIconSize = 24;
  static const double radioWaveBarWidth = 3;
  static const double radioWaveBarSpacing = 1.5;
  static const double radioWaveBarBorderRadius = 2;
  static const double radioWaveBarMaxHeight = 20;
  static const double radioWaveBarMinHeight = 6;
  static const double radioWaveBarAlpha = 0.3;

  // Mini Player
  static const double miniPlayerPaddingHorizontal = 16;
  static const double miniPlayerPaddingVertical = 10;
  static const double miniPlayerLogoSize = 42;
  static const double miniPlayerLogoRadius = 10;
  static const double miniPlayerLogoSpacing = 12;
  static const double miniPlayerTitleFontSize = 13;
  static const double miniPlayerSubtitleFontSize = 11;
  static const double miniPlayerPlayIconSize = 36;
  static const double miniPlayerStopIconSize = 28;
  static const double miniPlayerLoadingSize = 20;

  // Shorts List Card
  static const double shortsCardPadding = 10;
  static const double shortsCardBorderRadius = 14;
  static const double shortsThumbnailWidth = 68;
  static const double shortsThumbnailHeight = 100;
  static const double shortsThumbnailRadius = 10;
  static const double shortsThumbnailSpacing = 12;
  static const double shortsTitleFontSize = 13;
  static const double shortsTitleLineHeight = 1.3;
  static const double shortsDescFontSize = 11;
  static const double shortsDescLineHeight = 1.3;
  static const double shortsMetaFontSize = 10.5;
  static const double shortsMetaSpacing = 10;
  static const double shortsBadgePaddingHorizontal = 6;
  static const double shortsBadgePaddingVertical = 2;
  static const double shortsBadgeBorderRadius = 4;
  static const double shortsBadgeIconSize = 10;
  static const double shortsBadgeFontSize = 8;
  static const double shortsDurationChipPaddingHorizontal = 5;
  static const double shortsDurationChipPaddingVertical = 2;
  static const double shortsDurationChipBorderRadius = 4;
  static const double shortsDurationChipFontSize = 9;
  static const double shortsPlayOverlaySize = 28;
  static const double shortsPlayIconSize = 18;
  static const double shortsListSeparator = 8;

  // Error View
  static const double errorIconSize = 48;
  static const double errorSpacingLarge = 16;
  static const double errorSpacingSmall = 16;
  static const double errorFontSize = 14;

  // Empty View
  static const double emptyIconContainerSize = 72;
  static const double emptyIconSize = 36;
  static const double emptySpacingLarge = 16;
  static const double emptySpacingSmall = 6;
  static const double emptyTitleFontSize = 16;
  static const double emptySubtitleFontSize = 13;

  // Shimmer
  static const double shimmerVideoHeight = 100;
  static const double shimmerVideoBorderRadius = 16;
  static const double shimmerShortsHeight = 120;
  static const double shimmerShortsBorderRadius = 14;

  // Section Title
  static const double sectionTitleFontSize = 15;

  // Favorite Button
  static const double favButtonPaddingVertical = 13;
  static const double favButtonBorderRadius = 14;
  static const double favButtonIconSize = 18;
  static const double favButtonFontSize = 14;
  static const double favButtonLoadingSize = 16;
}

class _TabletSizes {
  // AppBar
  static const double appBarExpandedHeight = 300;
  static const double appBarTitleSize = 20;
  static const double appBarLogoSize = 36;
  static const double appBarLogoIconSize = 22;
  static const double appBarActionIconSize = 30;
  static const double appBarActionPaddingRight = 12;
  static const double appBarLeadingIconSize = 26;

  // Header
  static const double headerTopPadding = 70;
  static const double headerLogoOuterSize = 130;
  static const double headerLogoInnerSize = 100;
  static const double headerLogoPadding = 8;
  static const double headerLogoBorderWidth = 2.5;
  static const double headerLogoShadowBlur = 30;
  static const double headerLogoShadowSpread = 3;
  static const double headerNameFontSize = 24;
  static const double headerNameLineHeight = 1.35;
  static const double headerCitySpacing = 8;
  static const double headerCityFontSize = 16;
  static const double headerCityIconSize = 18;
  static const double headerCityIconSpacing = 4;
  static const double headerBadgeSpacing = 14;
  static const double headerBadgePaddingHorizontal = 16;
  static const double headerBadgePaddingVertical = 6;
  static const double headerBadgeBorderRadius = 24;
  static const double headerBadgeIconSize = 14;
  static const double headerBadgeFontSize = 13;
  static const double headerPaddingHorizontal = 48;

  // TabBar
  static const double tabBarHeight = 56;
  static const double tabBarIndicatorWeight = 3;
  static const double tabBarLabelFontSize = 16;
  static const double tabBarUnselectedLabelFontSize = 16;

  // About Tab
  static const double aboutPaddingHorizontal = 24;
  static const double aboutPaddingTop = 28;
  static const double aboutPaddingBottom = 40;
  static const double aboutSectionSpacing = 24;
  static const double aboutSectionTitleSpacing = 10;
  static const double aboutDescriptionFontSize = 16;
  static const double aboutDescriptionLineHeight = 1.7;
  static const double aboutCardPadding = 18;
  static const double aboutCardBorderRadius = 16;

  // Info Row
  static const double infoRowPaddingHorizontal = 18;
  static const double infoRowPaddingVertical = 16;
  static const double infoRowIconSize = 42;
  static const double infoRowIconRadius = 11;
  static const double infoRowIconInnerSize = 21;
  static const double infoRowIconSpacing = 16;
  static const double infoRowLabelFontSize = 13;
  static const double infoRowValueFontSize = 16;
  static const double infoRowValueSpacing = 3;

  // Link Button
  static const double linkButtonPaddingHorizontal = 18;
  static const double linkButtonPaddingVertical = 16;
  static const double linkButtonIconSize = 42;
  static const double linkButtonIconRadius = 11;
  static const double linkButtonIconInnerSize = 21;
  static const double linkButtonIconSpacing = 16;
  static const double linkButtonLabelFontSize = 16;
  static const double linkButtonTrailingIconSize = 20;

  // Radio Inline Card
  static const double radioCardPadding = 18;
  static const double radioCardBorderRadius = 16;
  static const double radioIconContainerSize = 56;
  static const double radioIconContainerRadius = 14;
  static const double radioIconSize = 28;
  static const double radioIconSpacing = 18;
  static const double radioTitleFontSize = 16;
  static const double radioSubtitleFontSize = 13;
  static const double radioPlayButtonSize = 54;
  static const double radioPlayButtonRadius = 28;
  static const double radioPlayIconSize = 28;
  static const double radioWaveBarWidth = 4;
  static const double radioWaveBarSpacing = 2;
  static const double radioWaveBarBorderRadius = 3;
  static const double radioWaveBarMaxHeight = 26;
  static const double radioWaveBarMinHeight = 8;
  static const double radioWaveBarAlpha = 0.3;

  // Mini Player
  static const double miniPlayerPaddingHorizontal = 24;
  static const double miniPlayerPaddingVertical = 14;
  static const double miniPlayerLogoSize = 50;
  static const double miniPlayerLogoRadius = 12;
  static const double miniPlayerLogoSpacing = 16;
  static const double miniPlayerTitleFontSize = 16;
  static const double miniPlayerSubtitleFontSize = 13;
  static const double miniPlayerPlayIconSize = 42;
  static const double miniPlayerStopIconSize = 34;
  static const double miniPlayerLoadingSize = 24;

  // Shorts List Card
  static const double shortsCardPadding = 14;
  static const double shortsCardBorderRadius = 16;
  static const double shortsThumbnailWidth = 88;
  static const double shortsThumbnailHeight = 130;
  static const double shortsThumbnailRadius = 12;
  static const double shortsThumbnailSpacing = 16;
  static const double shortsTitleFontSize = 16;
  static const double shortsTitleLineHeight = 1.35;
  static const double shortsDescFontSize = 13;
  static const double shortsDescLineHeight = 1.35;
  static const double shortsMetaFontSize = 12;
  static const double shortsMetaSpacing = 14;
  static const double shortsBadgePaddingHorizontal = 8;
  static const double shortsBadgePaddingVertical = 3;
  static const double shortsBadgeBorderRadius = 5;
  static const double shortsBadgeIconSize = 12;
  static const double shortsBadgeFontSize = 9;
  static const double shortsDurationChipPaddingHorizontal = 6;
  static const double shortsDurationChipPaddingVertical = 3;
  static const double shortsDurationChipBorderRadius = 5;
  static const double shortsDurationChipFontSize = 10;
  static const double shortsPlayOverlaySize = 36;
  static const double shortsPlayIconSize = 22;
  static const double shortsListSeparator = 10;

  // Error View
  static const double errorIconSize = 56;
  static const double errorSpacingLarge = 20;
  static const double errorSpacingSmall = 20;
  static const double errorFontSize = 16;

  // Empty View
  static const double emptyIconContainerSize = 88;
  static const double emptyIconSize = 44;
  static const double emptySpacingLarge = 20;
  static const double emptySpacingSmall = 8;
  static const double emptyTitleFontSize = 20;
  static const double emptySubtitleFontSize = 16;

  // Shimmer
  static const double shimmerVideoHeight = 120;
  static const double shimmerVideoBorderRadius = 18;
  static const double shimmerShortsHeight = 150;
  static const double shimmerShortsBorderRadius = 16;

  // Section Title
  static const double sectionTitleFontSize = 18;

  // Favorite Button
  static const double favButtonPaddingVertical = 16;
  static const double favButtonBorderRadius = 16;
  static const double favButtonIconSize = 22;
  static const double favButtonFontSize = 16;
  static const double favButtonLoadingSize = 20;
}

// ═══════════════════════════════════════════════════════════
// BUSINESS LOGIC: Radyo Akışını Yöneten GetX Controller
// ═══════════════════════════════════════════════════════════

class UniversityRadioController extends GetxController {
  final Rx<PlaybackState> playbackState = PlaybackState.unknown.obs;
  final Rx<Metadata?> metadata = Rx<Metadata?>(null);
  final Rx<String?> currentPlayingUrl = Rx<String?>(null);
  final Rx<String?> currentPlayingName = Rx<String?>(null);
  final Rx<String?> currentPlayingLogo = Rx<String?>(null);

  StreamSubscription? _playbackStateSub;
  StreamSubscription? _metadataSub;

  @override
  void onInit() {
    super.onInit();
    _playbackStateSub = RadioPlayer.playbackStateStream.listen((state) {
      playbackState.value = state;
    });
    _metadataSub = RadioPlayer.metadataStream.listen((meta) {
      metadata.value = meta;
    });
  }

  void togglePlayPause({
    required String url,
    required String name,
    String? logoUrl,
  }) {
    if (currentPlayingUrl.value == url) {
      if (playbackState.value == PlaybackState.playing) {
        RadioPlayer.pause();
      } else {
        RadioPlayer.play();
      }
    } else {
      currentPlayingUrl.value = url;
      currentPlayingName.value = name;
      currentPlayingLogo.value = logoUrl;
      metadata.value = null;
      RadioPlayer.setStation(
        title: name,
        url: url,
        logoNetworkUrl: logoUrl,
        parseStreamMetadata: true,
      );
      RadioPlayer.play();
    }
  }

  void stopRadio() {
    RadioPlayer.reset();
    currentPlayingUrl.value = null;
    currentPlayingName.value = null;
    currentPlayingLogo.value = null;
    metadata.value = null;
    playbackState.value = PlaybackState.unknown;
  }

  bool get isPlaying => playbackState.value == PlaybackState.playing;
  bool get isBuffering => playbackState.value == PlaybackState.buffering;
  bool get isRadioActive => currentPlayingUrl.value != null;

  @override
  void onClose() {
    _playbackStateSub?.cancel();
    _metadataSub?.cancel();
    super.onClose();
  }
}

// ═══════════════════════════════════════════════════════════
// ANA SAYFA: UniversityDetailScreen
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
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: _PhoneSizes.appBarExpandedHeight.h,
                    pinned: true,
                    floating: false,
                    backgroundColor: AppTheme.bg(context),
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPri(context),
                        size: _PhoneSizes.appBarLeadingIconSize.sp,
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
                                padding: EdgeInsets.only(right: 10.w),
                                child: ClipOval(
                                  child: Container(
                                    width: _PhoneSizes.appBarLogoSize.w,
                                    height: _PhoneSizes.appBarLogoSize.w,
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      imageUrl: uni.logoUrl!,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, _, _) => Icon(
                                        Icons.school_rounded,
                                        size: _PhoneSizes.appBarLogoIconSize.sp,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: _PhoneSizes.appBarLogoIconSize.sp,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            Flexible(
                              child: Text(
                                uni.name ?? '',
                                style: TextStyle(
                                  fontSize: _PhoneSizes.appBarTitleSize.sp,
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
                            right: _PhoneSizes.appBarActionPaddingRight.w,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 44.w,
                                  height: 44.w,
                                  child: Center(
                                    child: SizedBox(
                                      width: 20.w,
                                      height: 20.w,
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
                                      size: _PhoneSizes.appBarActionIconSize.sp,
                                    ),
                                  ),
                                  onPressed: controller.toggleFavorite,
                                ),
                        );
                      }),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _HeaderPhone(controller: controller),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegatePhone(context: context),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _AboutTabPhone(
                      controller: controller,
                      radioController: radioController,
                    ),
                    _VideosTabPhone(controller: controller),
                    _ShortsTabPhone(controller: controller),
                  ],
                ),
              ),
            ),
            _RadioMiniPlayerPhone(radioController: radioController),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  SliverAppBar(
                    expandedHeight: _TabletSizes.appBarExpandedHeight,
                    pinned: true,
                    floating: false,
                    backgroundColor: AppTheme.bg(context),
                    scrolledUnderElevation: 0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.textPri(context),
                        size: _TabletSizes.appBarLeadingIconSize,
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
                                padding: EdgeInsets.only(right: 12),
                                child: ClipOval(
                                  child: Container(
                                    width: _TabletSizes.appBarLogoSize,
                                    height: _TabletSizes.appBarLogoSize,
                                    color: Colors.white,
                                    child: CachedNetworkImage(
                                      imageUrl: uni.logoUrl!,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, _, _) => Icon(
                                        Icons.school_rounded,
                                        size: _TabletSizes.appBarLogoIconSize,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Icon(
                                  Icons.school_rounded,
                                  size: _TabletSizes.appBarLogoIconSize,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            Flexible(
                              child: Text(
                                uni.name ?? '',
                                style: TextStyle(
                                  fontSize: _TabletSizes.appBarTitleSize,
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
                            right: _TabletSizes.appBarActionPaddingRight,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
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
                                      size: _TabletSizes.appBarActionIconSize,
                                    ),
                                  ),
                                  onPressed: controller.toggleFavorite,
                                ),
                        );
                      }),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _HeaderTablet(controller: controller),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegateTablet(context: context),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _AboutTabTablet(
                      controller: controller,
                      radioController: radioController,
                    ),
                    _VideosTabTablet(controller: controller),
                    _ShortsTabTablet(controller: controller),
                  ],
                ),
              ),
            ),
            _RadioMiniPlayerTablet(radioController: radioController),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (PHONE)
// ═══════════════════════════════════════════════════════════════════════

// ─── Radio Mini Player (Phone) ──────────────────────────────────────────────

class _RadioMiniPlayerPhone extends StatelessWidget {
  final UniversityRadioController radioController;
  const _RadioMiniPlayerPhone({required this.radioController});

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
              offset: Offset(0, -2.h),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.miniPlayerPaddingHorizontal.w,
              vertical: _PhoneSizes.miniPlayerPaddingVertical.h,
            ),
            child: Row(
              children: [
                Container(
                  width: _PhoneSizes.miniPlayerLogoSize.w,
                  height: _PhoneSizes.miniPlayerLogoSize.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.miniPlayerLogoRadius.r,
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
                          size: _PhoneSizes.miniPlayerLogoSize.sp * 0.6,
                        ),
                ),
                SizedBox(width: _PhoneSizes.miniPlayerLogoSpacing.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: _PhoneSizes.miniPlayerTitleFontSize.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        artistText,
                        style: TextStyle(
                          fontSize: _PhoneSizes.miniPlayerSubtitleFontSize.sp,
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
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: SizedBox(
                      width: _PhoneSizes.miniPlayerLoadingSize.w,
                      height: _PhoneSizes.miniPlayerLoadingSize.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
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
                      size: _PhoneSizes.miniPlayerPlayIconSize.sp,
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
                      size: _PhoneSizes.miniPlayerStopIconSize.sp,
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

// ─── Header (Phone) ──────────────────────────────────────────────────────────

class _HeaderPhone extends StatelessWidget {
  final UniversityDetailController controller;
  const _HeaderPhone({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) {
        return Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      final hasLogo = uni.logoUrl != null && uni.logoUrl!.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.06),
              AppTheme.bg(context).withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: _PhoneSizes.headerTopPadding.h),
            Container(
              width: _PhoneSizes.headerLogoOuterSize.w,
              height: _PhoneSizes.headerLogoOuterSize.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
              child: Center(
                child: Container(
                  width: _PhoneSizes.headerLogoInnerSize.w,
                  height: _PhoneSizes.headerLogoInnerSize.w,
                  padding: EdgeInsets.all(_PhoneSizes.headerLogoPadding.w),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.18),
                      width: _PhoneSizes.headerLogoBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        blurRadius: _PhoneSizes.headerLogoShadowBlur.r,
                        spreadRadius: _PhoneSizes.headerLogoShadowSpread.r,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => Center(
                              child: SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: _PhoneSizes.headerLogoInnerSize.sp * 0.4,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: _PhoneSizes.headerLogoInnerSize.sp * 0.4,
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: _PhoneSizes.headerBadgeSpacing.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.headerPaddingHorizontal.w,
              ),
              child: Text(
                uni.name ?? '',
                style: TextStyle(
                  fontSize: _PhoneSizes.headerNameFontSize.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPri(context),
                  height: _PhoneSizes.headerNameLineHeight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (uni.city != null) ...[
              SizedBox(height: _PhoneSizes.headerCitySpacing.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: _PhoneSizes.headerCityIconSize.sp,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: _PhoneSizes.headerCityIconSpacing.w),
                  Text(
                    uni.city!,
                    style: TextStyle(
                      fontSize: _PhoneSizes.headerCityFontSize.sp,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: _PhoneSizes.headerBadgeSpacing.h),
            Obx(() {
              if (!controller.isFavorite.value) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.headerBadgePaddingHorizontal.w,
                  vertical: _PhoneSizes.headerBadgePaddingVertical.h,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.headerBadgeBorderRadius.r,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: _PhoneSizes.headerBadgeIconSize.sp,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Favorilerimde',
                      style: TextStyle(
                        fontSize: _PhoneSizes.headerBadgeFontSize.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ─── TabBar Delegate (Phone) ────────────────────────────────────────────────

class _TabBarDelegatePhone extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  const _TabBarDelegatePhone({required this.context});

  @override
  double get minExtent => _PhoneSizes.tabBarHeight;
  @override
  double get maxExtent => _PhoneSizes.tabBarHeight;

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
            indicatorWeight: _PhoneSizes.tabBarIndicatorWeight,
            labelStyle: TextStyle(
              fontSize: _PhoneSizes.tabBarLabelFontSize.sp,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: _PhoneSizes.tabBarUnselectedLabelFontSize.sp,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Hakkında'),
              Tab(text: 'Videolar'),
              Tab(text: 'Shorts'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegatePhone oldDelegate) => false;
}

// ─── About Tab (Phone) ──────────────────────────────────────────────────────

class _AboutTabPhone extends StatelessWidget {
  final UniversityDetailController controller;
  final UniversityRadioController radioController;
  const _AboutTabPhone({
    required this.controller,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) return const Center(child: CircularProgressIndicator());
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          _PhoneSizes.aboutPaddingHorizontal.w,
          _PhoneSizes.aboutPaddingTop.h,
          _PhoneSizes.aboutPaddingHorizontal.w,
          _PhoneSizes.aboutPaddingBottom.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FavoriteButtonPhone(controller: controller),
            SizedBox(height: _PhoneSizes.aboutSectionSpacing.h),
            _SectionTitlePhone(title: 'Açıklama'),
            SizedBox(height: _PhoneSizes.aboutSectionTitleSpacing.h),
            _DescriptionCardPhone(uni: uni),
            SizedBox(height: _PhoneSizes.aboutSectionSpacing.h),
            _SectionTitlePhone(title: 'Genel Bilgiler'),
            SizedBox(height: _PhoneSizes.aboutSectionTitleSpacing.h),
            _InfoCardPhone(uni: uni, controller: controller),
            SizedBox(height: _PhoneSizes.aboutSectionSpacing.h),
            if (uni.websiteUrl != null ||
                uni.customUrl != null ||
                (uni.radioLink != null && uni.radioLink!.isNotEmpty)) ...[
              _SectionTitlePhone(title: 'Bağlantılar'),
              SizedBox(height: _PhoneSizes.aboutSectionTitleSpacing.h),
              if (uni.websiteUrl != null && uni.websiteUrl!.isNotEmpty)
                _LinkButtonPhone(
                  icon: Icons.language_rounded,
                  label: 'Resmi Web Sitesi',
                  url: uni.websiteUrl!,
                ),
              if (uni.customUrl != null && uni.customUrl!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _LinkButtonPhone(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'YouTube Kanalı',
                  url: 'https://www.youtube.com/${uni.customUrl}',
                  color: const Color(0xFFFF0000),
                ),
              ],
              if (uni.radioLink != null && uni.radioLink!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _RadioInlineCardPhone(
                  university: uni,
                  radioController: radioController,
                ),
              ],
              SizedBox(height: _PhoneSizes.aboutSectionSpacing.h),
            ],
            if (uni.channelId != null) ...[
              _SectionTitlePhone(title: 'YouTube Kanalı'),
              SizedBox(height: _PhoneSizes.aboutSectionTitleSpacing.h),
              _ChannelCardPhone(uni: uni),
            ],
          ],
        ),
      );
    });
  }
}

class _FavoriteButtonPhone extends StatelessWidget {
  final UniversityDetailController controller;
  const _FavoriteButtonPhone({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFav = controller.isFavorite.value;
      final isLoading = controller.isFavoriteLoading.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : controller.toggleFavorite,
          icon: isLoading
              ? SizedBox(
                  width: _PhoneSizes.favButtonLoadingSize.w,
                  height: _PhoneSizes.favButtonLoadingSize.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isFav
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: _PhoneSizes.favButtonIconSize.sp,
                ),
          label: Text(
            isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
            style: TextStyle(
              fontSize: _PhoneSizes.favButtonFontSize.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFav
                ? AppTheme.card(context)
                : AppTheme.primaryColor,
            foregroundColor: isFav ? AppTheme.primaryColor : Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              vertical: _PhoneSizes.favButtonPaddingVertical.h,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                _PhoneSizes.favButtonBorderRadius.r,
              ),
              side: isFav
                  ? BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    )
                  : BorderSide.none,
            ),
          ),
        ),
      );
    });
  }
}

class _DescriptionCardPhone extends StatelessWidget {
  final dynamic uni;
  const _DescriptionCardPhone({required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_PhoneSizes.aboutCardPadding.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.aboutCardBorderRadius.r,
        ),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ReadMoreText(
        (uni.description != null && uni.description!.isNotEmpty)
            ? uni.description!
            : 'Bu üniversite için açıklama bulunmuyor.',
        trimMode: TrimMode.Line,
        trimLines: 5,
        trimCollapsedText: ' Daha fazla',
        trimExpandedText: ' Daha az',
        style: TextStyle(
          fontSize: _PhoneSizes.aboutDescriptionFontSize.sp,
          color: AppTheme.textSec(context),
          height: _PhoneSizes.aboutDescriptionLineHeight,
          fontStyle: (uni.description != null && uni.description!.isNotEmpty)
              ? FontStyle.normal
              : FontStyle.italic,
        ),
        moreStyle: TextStyle(
          fontSize: _PhoneSizes.aboutDescriptionFontSize.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
        lessStyle: TextStyle(
          fontSize: _PhoneSizes.aboutDescriptionFontSize.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _InfoCardPhone extends StatelessWidget {
  final dynamic uni;
  final UniversityDetailController controller;
  const _InfoCardPhone({required this.uni, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.aboutCardBorderRadius.r,
        ),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _InfoRowPhone(
            icon: Icons.location_on_rounded,
            label: 'Şehir',
            value: uni.city ?? '—',
            isFirst: true,
          ),
          _InfoRowPhone(
            icon: Icons.calendar_today_rounded,
            label: 'Kuruluş Yılı',
            value: uni.foundedYear != null ? '${uni.foundedYear}' : '—',
          ),
          _InfoRowPhone(
            icon: Icons.play_circle_rounded,
            label: 'Video Sayısı',
            value: uni.videoCount != null ? '${uni.videoCount}' : '—',
          ),
          _InfoRowPhone(
            icon: Icons.people_rounded,
            label: 'Abone Sayısı',
            value: uni.subscriberCount != null
                ? controller.formattedSubscriberCount
                : '—',
          ),
          _InfoRowPhone(
            icon: Icons.visibility_rounded,
            label: 'Toplam İzlenme',
            value: uni.viewCount != null ? controller.formattedViewCount : '—',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ChannelCardPhone extends StatelessWidget {
  final dynamic uni;
  const _ChannelCardPhone({required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.aboutCardBorderRadius.r,
        ),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _InfoRowPhone(
            icon: Icons.tag_rounded,
            label: 'Kanal ID',
            value: uni.channelId!,
            isFirst: true,
            isLast: uni.channelSyncedAt == null,
          ),
          if (uni.channelSyncedAt != null)
            _InfoRowPhone(
              icon: Icons.sync_rounded,
              label: 'Son Senkronizasyon',
              value: _formatDate(uni.channelSyncedAt!),
              isLast: true,
            ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

class _InfoRowPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  const _InfoRowPhone({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _PhoneSizes.infoRowPaddingHorizontal.w,
            vertical: _PhoneSizes.infoRowPaddingVertical.h,
          ),
          child: Row(
            children: [
              Container(
                width: _PhoneSizes.infoRowIconSize.w,
                height: _PhoneSizes.infoRowIconSize.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.infoRowIconRadius.r,
                  ),
                ),
                child: Icon(
                  icon,
                  size: _PhoneSizes.infoRowIconInnerSize.sp,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: _PhoneSizes.infoRowIconSpacing.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: _PhoneSizes.infoRowLabelFontSize.sp,
                        color: AppTheme.textSec(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.infoRowValueSpacing.h),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: _PhoneSizes.infoRowValueFontSize.sp,
                        color: AppTheme.textPri(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 14.w,
            endIndent: 14.w,
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}

class _LinkButtonPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color? color;
  const _LinkButtonPhone({
    required this.icon,
    required this.label,
    required this.url,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppTheme.primaryColor;
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri))
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(_PhoneSizes.aboutCardBorderRadius.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.linkButtonPaddingHorizontal.w,
          vertical: _PhoneSizes.linkButtonPaddingVertical.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(
            _PhoneSizes.aboutCardBorderRadius.r,
          ),
          border: Border.all(
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: _PhoneSizes.linkButtonIconSize.w,
              height: _PhoneSizes.linkButtonIconSize.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.linkButtonIconRadius.r,
                ),
              ),
              child: Icon(
                icon,
                size: _PhoneSizes.linkButtonIconInnerSize.sp,
                color: iconColor,
              ),
            ),
            SizedBox(width: _PhoneSizes.linkButtonIconSpacing.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: _PhoneSizes.linkButtonLabelFontSize.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPri(context),
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: _PhoneSizes.linkButtonTrailingIconSize.sp,
              color: AppTheme.textSec(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Radio Inline Card (Phone) ──────────────────────────────────────────────

class _RadioInlineCardPhone extends StatelessWidget {
  final dynamic university;
  final UniversityRadioController radioController;
  const _RadioInlineCardPhone({
    required this.university,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isThisPlaying =
          radioController.currentPlayingUrl.value == university.radioLink;
      final bool buffering = isThisPlaying && radioController.isBuffering;
      final bool playing = isThisPlaying && radioController.isPlaying;

      return Container(
        padding: EdgeInsets.all(_PhoneSizes.radioCardPadding.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isThisPlaying
                ? [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    AppTheme.card(context),
                  ]
                : [AppTheme.card(context), AppTheme.card(context)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(
            _PhoneSizes.radioCardBorderRadius.r,
          ),
          border: Border.all(
            color: isThisPlaying
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                : AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: _PhoneSizes.radioIconContainerSize.w,
              height: _PhoneSizes.radioIconContainerSize.w,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.radioIconContainerRadius.r,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (playing || buffering)
                    _RadioWaveAnimationPhone(isActive: playing),
                  Icon(
                    buffering
                        ? Icons.hdr_weak_rounded
                        : (playing
                              ? Icons.equalizer_rounded
                              : Icons.radio_rounded),
                    color: const Color(0xFF8B5CF6),
                    size: _PhoneSizes.radioIconSize.sp,
                  ),
                ],
              ),
            ),
            SizedBox(width: _PhoneSizes.radioIconSpacing.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversite Radyosu',
                    style: TextStyle(
                      fontSize: _PhoneSizes.radioTitleFontSize.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isThisPlaying
                        ? (playing
                              ? 'Canlı Yayın Dinleniyor...'
                              : (buffering
                                    ? 'Yayına Bağlanılıyor...'
                                    : 'Yayın Duraklatıldı'))
                        : 'Canlı yayını dinlemek için tıklayın',
                    style: TextStyle(
                      fontSize: _PhoneSizes.radioSubtitleFontSize.sp,
                      color: isThisPlaying
                          ? const Color(0xFF8B5CF6)
                          : AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.radioPlayButtonRadius.r,
                ),
                onTap: () {
                  radioController.togglePlayPause(
                    url: university.radioLink,
                    name: university.name,
                    logoUrl: university.logoUrl,
                  );
                },
                child: Container(
                  width: _PhoneSizes.radioPlayButtonSize.w,
                  height: _PhoneSizes.radioPlayButtonSize.w,
                  decoration: BoxDecoration(
                    color: isThisPlaying
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: isThisPlaying
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: Offset(0, 4.h),
                            ),
                          ]
                        : null,
                  ),
                  child: buffering
                      ? SizedBox(
                          width: _PhoneSizes.radioPlayButtonSize.w * 0.45,
                          height: _PhoneSizes.radioPlayButtonSize.w * 0.45,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isThisPlaying
                              ? Colors.white
                              : const Color(0xFF8B5CF6),
                          size: _PhoneSizes.radioPlayIconSize.sp,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RadioWaveAnimationPhone extends StatelessWidget {
  final bool isActive;
  const _RadioWaveAnimationPhone({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        _PhoneSizes.radioIconContainerRadius.r,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + (index * 150)),
            width: _PhoneSizes.radioWaveBarWidth.w,
            height: isActive
                ? (_PhoneSizes.radioWaveBarMaxHeight.h +
                      (index % 2 == 0
                          ? _PhoneSizes.radioWaveBarMaxHeight.h / 2
                          : 0))
                : _PhoneSizes.radioWaveBarMinHeight.h,
            margin: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.radioWaveBarSpacing.w,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFF8B5CF6,
              ).withValues(alpha: _PhoneSizes.radioWaveBarAlpha),
              borderRadius: BorderRadius.circular(
                _PhoneSizes.radioWaveBarBorderRadius.r,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Section Title (Phone) ──────────────────────────────────────────────────

class _SectionTitlePhone extends StatelessWidget {
  final String title;
  const _SectionTitlePhone({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: _PhoneSizes.sectionTitleFontSize.sp,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPri(context),
      ),
    );
  }
}

// ─── Videos Tab (Phone) ────────────────────────────────────────────────────

class _VideosTabPhone extends StatelessWidget {
  final UniversityDetailController controller;
  const _VideosTabPhone({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final videoList = controller.videoOnly;
      if (isLoading) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: 6,
          itemBuilder: (_, _) => _VideoShimmerPhone(),
        );
      }
      if (error.isNotEmpty) {
        return _ErrorViewPhone(error: error, onRetry: controller.loadVideos);
      }
      if (videoList.isEmpty) {
        return _EmptyViewPhone(
          icon: Icons.videocam_off_rounded,
          title: 'Henüz video yok',
          subtitle: 'Bu üniversiteye ait video bulunamadı.',
        );
      }
      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: ListView.builder(
          padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
          itemCount: videoList.length,
          itemBuilder: (_, i) => VideoCardWidget(video: videoList[i]),
        ),
      );
    });
  }
}

class _VideoShimmerPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: _PhoneSizes.shimmerVideoHeight.h,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(
              _PhoneSizes.shimmerVideoBorderRadius.r,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shorts Tab (Phone) ────────────────────────────────────────────────────

class _ShortsTabPhone extends StatelessWidget {
  final UniversityDetailController controller;
  const _ShortsTabPhone({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final shortsList = controller.shortsOnly;
      if (isLoading) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount: 6,
          itemBuilder: (_, _) => const _ShortsListShimmerPhone(),
        );
      }
      if (error.isNotEmpty) {
        return _ErrorViewPhone(error: error, onRetry: controller.loadVideos);
      }
      if (shortsList.isEmpty) {
        return _EmptyViewPhone(
          icon: Icons.movie_filter_outlined,
          title: 'Henüz Shorts yok',
          subtitle: 'Bu üniversiteye ait shorts video bulunamadı.',
        );
      }
      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: ListView.separated(
          padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
          itemCount: shortsList.length,
          separatorBuilder: (_, _) =>
              SizedBox(height: _PhoneSizes.shortsListSeparator.h),
          itemBuilder: (_, i) => _ShortsListCardPhone(
            video: shortsList[i],
            onTap: () => _openShortsPlayer(shortsList, i),
          ),
        ),
      );
    });
  }

  void _openShortsPlayer(List<VideoModel> shorts, int initialIndex) {
    Get.toNamed(
      AppRoutes.simpleShortsPlayer,
      arguments: {'shorts': shorts, 'initialIndex': initialIndex},
    );
  }
}

class _ShortsListCardPhone extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  const _ShortsListCardPhone({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.shortsCardBorderRadius.r,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            _PhoneSizes.shortsCardBorderRadius.r,
          ),
          child: Container(
            padding: EdgeInsets.all(_PhoneSizes.shortsCardPadding.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnailPhone(context),
                SizedBox(width: _PhoneSizes.shortsThumbnailSpacing.w),
                Expanded(
                  child: SizedBox(
                    height: _PhoneSizes.shortsThumbnailHeight.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ShortsBadgePhone(),
                            if (video.formattedDuration.isNotEmpty) ...[
                              SizedBox(width: 6.w),
                              _DurationChipPhone(
                                duration: video.formattedDuration,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _PhoneSizes.shortsTitleFontSize.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPri(context),
                            height: _PhoneSizes.shortsTitleLineHeight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (video.description.isNotEmpty)
                          Text(
                            video.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _PhoneSizes.shortsDescFontSize.sp,
                              color: AppTheme.textSec(context),
                              height: _PhoneSizes.shortsDescLineHeight,
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: _PhoneSizes.shortsMetaFontSize.sp * 1.2,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              video.formattedViewCount,
                              style: TextStyle(
                                fontSize: _PhoneSizes.shortsMetaFontSize.sp,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                            SizedBox(width: _PhoneSizes.shortsMetaSpacing.w),
                            Icon(
                              Icons.schedule_rounded,
                              size: _PhoneSizes.shortsMetaFontSize.sp * 1.1,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              timeago.format(video.publishedAt, locale: 'tr'),
                              style: TextStyle(
                                fontSize: _PhoneSizes.shortsMetaFontSize.sp,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                          ],
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

  Widget _buildThumbnailPhone(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_PhoneSizes.shortsThumbnailRadius.r),
      child: SizedBox(
        width: _PhoneSizes.shortsThumbnailWidth.w,
        height: _PhoneSizes.shortsThumbnailHeight.h,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: video.bestThumbnail,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
              ),
              errorWidget: (_, _, _) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: _PhoneSizes.shortsPlayOverlaySize.sp * 0.8,
                ),
              ),
            ),
            Center(
              child: Container(
                width: _PhoneSizes.shortsPlayOverlaySize.w,
                height: _PhoneSizes.shortsPlayOverlaySize.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: _PhoneSizes.shortsPlayIconSize.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortsBadgePhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.shortsBadgePaddingHorizontal.w,
        vertical: _PhoneSizes.shortsBadgePaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.shortsBadgeBorderRadius.r,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill_rounded,
            size: _PhoneSizes.shortsBadgeIconSize.sp,
            color: Colors.white,
          ),
          SizedBox(width: 2.w),
          Text(
            'SHORTS',
            style: TextStyle(
              fontSize: _PhoneSizes.shortsBadgeFontSize.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationChipPhone extends StatelessWidget {
  final String duration;
  const _DurationChipPhone({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.shortsDurationChipPaddingHorizontal.w,
        vertical: _PhoneSizes.shortsDurationChipPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.shortsDurationChipBorderRadius.r,
        ),
      ),
      child: Text(
        duration,
        style: TextStyle(
          fontSize: _PhoneSizes.shortsDurationChipFontSize.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSec(context),
        ),
      ),
    );
  }
}

class _ShortsListShimmerPhone extends StatelessWidget {
  const _ShortsListShimmerPhone();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: _PhoneSizes.shimmerShortsHeight.h,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(
              _PhoneSizes.shimmerShortsBorderRadius.r,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error View (Phone) ──────────────────────────────────────────────────────

class _ErrorViewPhone extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorViewPhone({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: _PhoneSizes.errorIconSize.sp,
              color: AppTheme.textSec(context),
            ),
            SizedBox(height: _PhoneSizes.errorSpacingLarge.h),
            Text(
              error,
              style: TextStyle(
                fontSize: _PhoneSizes.errorFontSize.sp,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _PhoneSizes.errorSpacingSmall.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: _PhoneSizes.errorIconSize.sp * 0.4,
              ),
              label: Text(
                'Tekrar Dene',
                style: TextStyle(fontSize: _PhoneSizes.errorFontSize.sp - 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty View (Phone) ──────────────────────────────────────────────────────

class _EmptyViewPhone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyViewPhone({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _PhoneSizes.emptyIconContainerSize.w,
              height: _PhoneSizes.emptyIconContainerSize.w,
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: _PhoneSizes.emptyIconSize.sp,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: _PhoneSizes.emptySpacingLarge.h),
            Text(
              title,
              style: TextStyle(
                fontSize: _PhoneSizes.emptyTitleFontSize.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: _PhoneSizes.emptySpacingSmall.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: _PhoneSizes.emptySubtitleFontSize.sp,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (TABLET)
// ═══════════════════════════════════════════════════════════════════════

// ─── Radio Mini Player (Tablet) ──────────────────────────────────────────────

class _RadioMiniPlayerTablet extends StatelessWidget {
  final UniversityRadioController radioController;
  const _RadioMiniPlayerTablet({required this.radioController});

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
              width: 2,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _TabletSizes.miniPlayerPaddingHorizontal,
              vertical: _TabletSizes.miniPlayerPaddingVertical,
            ),
            child: Row(
              children: [
                Container(
                  width: _TabletSizes.miniPlayerLogoSize,
                  height: _TabletSizes.miniPlayerLogoSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      _TabletSizes.miniPlayerLogoRadius,
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
                          size: _TabletSizes.miniPlayerLogoSize * 0.6,
                        ),
                ),
                SizedBox(width: _TabletSizes.miniPlayerLogoSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                          fontSize: _TabletSizes.miniPlayerTitleFontSize,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3),
                      Text(
                        artistText,
                        style: TextStyle(
                          fontSize: _TabletSizes.miniPlayerSubtitleFontSize,
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
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: _TabletSizes.miniPlayerLoadingSize,
                      height: _TabletSizes.miniPlayerLoadingSize,
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
                      size: _TabletSizes.miniPlayerPlayIconSize,
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
                      size: _TabletSizes.miniPlayerStopIconSize,
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

// ─── Header (Tablet) ──────────────────────────────────────────────────────────

class _HeaderTablet extends StatelessWidget {
  final UniversityDetailController controller;
  const _HeaderTablet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) {
        return Container(
          color: Colors.transparent,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      final hasLogo = uni.logoUrl != null && uni.logoUrl!.isNotEmpty;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.06),
              AppTheme.bg(context).withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: _TabletSizes.headerTopPadding),
            Container(
              width: _TabletSizes.headerLogoOuterSize,
              height: _TabletSizes.headerLogoOuterSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
              child: Center(
                child: Container(
                  width: _TabletSizes.headerLogoInnerSize,
                  height: _TabletSizes.headerLogoInnerSize,
                  padding: EdgeInsets.all(_TabletSizes.headerLogoPadding),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.18),
                      width: _TabletSizes.headerLogoBorderWidth,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        blurRadius: _TabletSizes.headerLogoShadowBlur,
                        spreadRadius: _TabletSizes.headerLogoShadowSpread,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => Center(
                              child: SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: _TabletSizes.headerLogoInnerSize * 0.4,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: _TabletSizes.headerLogoInnerSize * 0.4,
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: _TabletSizes.headerBadgeSpacing),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.headerPaddingHorizontal,
              ),
              child: Text(
                uni.name ?? '',
                style: TextStyle(
                  fontSize: _TabletSizes.headerNameFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPri(context),
                  height: _TabletSizes.headerNameLineHeight,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (uni.city != null) ...[
              SizedBox(height: _TabletSizes.headerCitySpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: _TabletSizes.headerCityIconSize,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: _TabletSizes.headerCityIconSpacing),
                  Text(
                    uni.city!,
                    style: TextStyle(
                      fontSize: _TabletSizes.headerCityFontSize,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: _TabletSizes.headerBadgeSpacing),
            Obx(() {
              if (!controller.isFavorite.value) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.headerBadgePaddingHorizontal,
                  vertical: _TabletSizes.headerBadgePaddingVertical,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    _TabletSizes.headerBadgeBorderRadius,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: _TabletSizes.headerBadgeIconSize,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Favorilerimde',
                      style: TextStyle(
                        fontSize: _TabletSizes.headerBadgeFontSize,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

// ─── TabBar Delegate (Tablet) ────────────────────────────────────────────────

class _TabBarDelegateTablet extends SliverPersistentHeaderDelegate {
  final BuildContext context;
  const _TabBarDelegateTablet({required this.context});

  @override
  double get minExtent => _TabletSizes.tabBarHeight;
  @override
  double get maxExtent => _TabletSizes.tabBarHeight;

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
            indicatorWeight: _TabletSizes.tabBarIndicatorWeight,
            labelStyle: TextStyle(
              fontSize: _TabletSizes.tabBarLabelFontSize,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: _TabletSizes.tabBarUnselectedLabelFontSize,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Hakkında'),
              Tab(text: 'Videolar'),
              Tab(text: 'Shorts'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegateTablet oldDelegate) => false;
}

// ─── About Tab (Tablet) ──────────────────────────────────────────────────────

class _AboutTabTablet extends StatelessWidget {
  final UniversityDetailController controller;
  final UniversityRadioController radioController;
  const _AboutTabTablet({
    required this.controller,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) return const Center(child: CircularProgressIndicator());
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          _TabletSizes.aboutPaddingHorizontal,
          _TabletSizes.aboutPaddingTop,
          _TabletSizes.aboutPaddingHorizontal,
          _TabletSizes.aboutPaddingBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FavoriteButtonTablet(controller: controller),
            SizedBox(height: _TabletSizes.aboutSectionSpacing),
            _SectionTitleTablet(title: 'Açıklama'),
            SizedBox(height: _TabletSizes.aboutSectionTitleSpacing),
            _DescriptionCardTablet(uni: uni),
            SizedBox(height: _TabletSizes.aboutSectionSpacing),
            _SectionTitleTablet(title: 'Genel Bilgiler'),
            SizedBox(height: _TabletSizes.aboutSectionTitleSpacing),
            _InfoCardTablet(uni: uni, controller: controller),
            SizedBox(height: _TabletSizes.aboutSectionSpacing),
            if (uni.websiteUrl != null ||
                uni.customUrl != null ||
                (uni.radioLink != null && uni.radioLink!.isNotEmpty)) ...[
              _SectionTitleTablet(title: 'Bağlantılar'),
              SizedBox(height: _TabletSizes.aboutSectionTitleSpacing),
              if (uni.websiteUrl != null && uni.websiteUrl!.isNotEmpty)
                _LinkButtonTablet(
                  icon: Icons.language_rounded,
                  label: 'Resmi Web Sitesi',
                  url: uni.websiteUrl!,
                ),
              if (uni.customUrl != null && uni.customUrl!.isNotEmpty) ...[
                SizedBox(height: 10),
                _LinkButtonTablet(
                  icon: Icons.play_circle_fill_rounded,
                  label: 'YouTube Kanalı',
                  url: 'https://www.youtube.com/${uni.customUrl}',
                  color: const Color(0xFFFF0000),
                ),
              ],
              if (uni.radioLink != null && uni.radioLink!.isNotEmpty) ...[
                SizedBox(height: 10),
                _RadioInlineCardTablet(
                  university: uni,
                  radioController: radioController,
                ),
              ],
              SizedBox(height: _TabletSizes.aboutSectionSpacing),
            ],
            if (uni.channelId != null) ...[
              _SectionTitleTablet(title: 'YouTube Kanalı'),
              SizedBox(height: _TabletSizes.aboutSectionTitleSpacing),
              _ChannelCardTablet(uni: uni),
            ],
          ],
        ),
      );
    });
  }
}

class _FavoriteButtonTablet extends StatelessWidget {
  final UniversityDetailController controller;
  const _FavoriteButtonTablet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isFav = controller.isFavorite.value;
      final isLoading = controller.isFavoriteLoading.value;
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : controller.toggleFavorite,
          icon: isLoading
              ? SizedBox(
                  width: _TabletSizes.favButtonLoadingSize,
                  height: _TabletSizes.favButtonLoadingSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isFav
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: _TabletSizes.favButtonIconSize,
                ),
          label: Text(
            isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
            style: TextStyle(
              fontSize: _TabletSizes.favButtonFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFav
                ? AppTheme.card(context)
                : AppTheme.primaryColor,
            foregroundColor: isFav ? AppTheme.primaryColor : Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              vertical: _TabletSizes.favButtonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                _TabletSizes.favButtonBorderRadius,
              ),
              side: isFav
                  ? BorderSide(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                    )
                  : BorderSide.none,
            ),
          ),
        ),
      );
    });
  }
}

class _DescriptionCardTablet extends StatelessWidget {
  final dynamic uni;
  const _DescriptionCardTablet({required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_TabletSizes.aboutCardPadding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.aboutCardBorderRadius),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: ReadMoreText(
        (uni.description != null && uni.description!.isNotEmpty)
            ? uni.description!
            : 'Bu üniversite için açıklama bulunmuyor.',
        trimMode: TrimMode.Line,
        trimLines: 5,
        trimCollapsedText: ' Daha fazla',
        trimExpandedText: ' Daha az',
        style: TextStyle(
          fontSize: _TabletSizes.aboutDescriptionFontSize,
          color: AppTheme.textSec(context),
          height: _TabletSizes.aboutDescriptionLineHeight,
          fontStyle: (uni.description != null && uni.description!.isNotEmpty)
              ? FontStyle.normal
              : FontStyle.italic,
        ),
        moreStyle: TextStyle(
          fontSize: _TabletSizes.aboutDescriptionFontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
        lessStyle: TextStyle(
          fontSize: _TabletSizes.aboutDescriptionFontSize,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}

class _InfoCardTablet extends StatelessWidget {
  final dynamic uni;
  final UniversityDetailController controller;
  const _InfoCardTablet({required this.uni, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.aboutCardBorderRadius),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _InfoRowTablet(
            icon: Icons.location_on_rounded,
            label: 'Şehir',
            value: uni.city ?? '—',
            isFirst: true,
          ),
          _InfoRowTablet(
            icon: Icons.calendar_today_rounded,
            label: 'Kuruluş Yılı',
            value: uni.foundedYear != null ? '${uni.foundedYear}' : '—',
          ),
          _InfoRowTablet(
            icon: Icons.play_circle_rounded,
            label: 'Video Sayısı',
            value: uni.videoCount != null ? '${uni.videoCount}' : '—',
          ),
          _InfoRowTablet(
            icon: Icons.people_rounded,
            label: 'Abone Sayısı',
            value: uni.subscriberCount != null
                ? controller.formattedSubscriberCount
                : '—',
          ),
          _InfoRowTablet(
            icon: Icons.visibility_rounded,
            label: 'Toplam İzlenme',
            value: uni.viewCount != null ? controller.formattedViewCount : '—',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _ChannelCardTablet extends StatelessWidget {
  final dynamic uni;
  const _ChannelCardTablet({required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.aboutCardBorderRadius),
        border: Border.all(
          color: AppTheme.isDark(context)
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _InfoRowTablet(
            icon: Icons.tag_rounded,
            label: 'Kanal ID',
            value: uni.channelId!,
            isFirst: true,
            isLast: uni.channelSyncedAt == null,
          ),
          if (uni.channelSyncedAt != null)
            _InfoRowTablet(
              icon: Icons.sync_rounded,
              label: 'Son Senkronizasyon',
              value: _formatDate(uni.channelSyncedAt!),
              isLast: true,
            ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

class _InfoRowTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isFirst;
  final bool isLast;
  const _InfoRowTablet({
    required this.icon,
    required this.label,
    required this.value,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: _TabletSizes.infoRowPaddingHorizontal,
            vertical: _TabletSizes.infoRowPaddingVertical,
          ),
          child: Row(
            children: [
              Container(
                width: _TabletSizes.infoRowIconSize,
                height: _TabletSizes.infoRowIconSize,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    _TabletSizes.infoRowIconRadius,
                  ),
                ),
                child: Icon(
                  icon,
                  size: _TabletSizes.infoRowIconInnerSize,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: _TabletSizes.infoRowIconSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: _TabletSizes.infoRowLabelFontSize,
                        color: AppTheme.textSec(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: _TabletSizes.infoRowValueSpacing),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: _TabletSizes.infoRowValueFontSize,
                        color: AppTheme.textPri(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 18,
            endIndent: 18,
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }
}

class _LinkButtonTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final Color? color;
  const _LinkButtonTablet({
    required this.icon,
    required this.label,
    required this.url,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppTheme.primaryColor;
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri))
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      },
      borderRadius: BorderRadius.circular(_TabletSizes.aboutCardBorderRadius),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.linkButtonPaddingHorizontal,
          vertical: _TabletSizes.linkButtonPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(
            _TabletSizes.aboutCardBorderRadius,
          ),
          border: Border.all(
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: _TabletSizes.linkButtonIconSize,
              height: _TabletSizes.linkButtonIconSize,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.linkButtonIconRadius,
                ),
              ),
              child: Icon(
                icon,
                size: _TabletSizes.linkButtonIconInnerSize,
                color: iconColor,
              ),
            ),
            SizedBox(width: _TabletSizes.linkButtonIconSpacing),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: _TabletSizes.linkButtonLabelFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPri(context),
                ),
              ),
            ),
            Icon(
              Icons.open_in_new_rounded,
              size: _TabletSizes.linkButtonTrailingIconSize,
              color: AppTheme.textSec(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Radio Inline Card (Tablet) ──────────────────────────────────────────────

class _RadioInlineCardTablet extends StatelessWidget {
  final dynamic university;
  final UniversityRadioController radioController;
  const _RadioInlineCardTablet({
    required this.university,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isThisPlaying =
          radioController.currentPlayingUrl.value == university.radioLink;
      final bool buffering = isThisPlaying && radioController.isBuffering;
      final bool playing = isThisPlaying && radioController.isPlaying;

      return Container(
        padding: EdgeInsets.all(_TabletSizes.radioCardPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isThisPlaying
                ? [
                    const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    AppTheme.card(context),
                  ]
                : [AppTheme.card(context), AppTheme.card(context)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(
            _TabletSizes.radioCardBorderRadius,
          ),
          border: Border.all(
            color: isThisPlaying
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                : AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: _TabletSizes.radioIconContainerSize,
              height: _TabletSizes.radioIconContainerSize,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.radioIconContainerRadius,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (playing || buffering)
                    _RadioWaveAnimationTablet(isActive: playing),
                  Icon(
                    buffering
                        ? Icons.hdr_weak_rounded
                        : (playing
                              ? Icons.equalizer_rounded
                              : Icons.radio_rounded),
                    color: const Color(0xFF8B5CF6),
                    size: _TabletSizes.radioIconSize,
                  ),
                ],
              ),
            ),
            SizedBox(width: _TabletSizes.radioIconSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Üniversite Radyosu',
                    style: TextStyle(
                      fontSize: _TabletSizes.radioTitleFontSize,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    isThisPlaying
                        ? (playing
                              ? 'Canlı Yayın Dinleniyor...'
                              : (buffering
                                    ? 'Yayına Bağlanılıyor...'
                                    : 'Yayın Duraklatıldı'))
                        : 'Canlı yayını dinlemek için tıklayın',
                    style: TextStyle(
                      fontSize: _TabletSizes.radioSubtitleFontSize,
                      color: isThisPlaying
                          ? const Color(0xFF8B5CF6)
                          : AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  _TabletSizes.radioPlayButtonRadius,
                ),
                onTap: () {
                  radioController.togglePlayPause(
                    url: university.radioLink,
                    name: university.name,
                    logoUrl: university.logoUrl,
                  );
                },
                child: Container(
                  width: _TabletSizes.radioPlayButtonSize,
                  height: _TabletSizes.radioPlayButtonSize,
                  decoration: BoxDecoration(
                    color: isThisPlaying
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    boxShadow: isThisPlaying
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: buffering
                      ? SizedBox(
                          width: _TabletSizes.radioPlayButtonSize * 0.45,
                          height: _TabletSizes.radioPlayButtonSize * 0.45,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: isThisPlaying
                              ? Colors.white
                              : const Color(0xFF8B5CF6),
                          size: _TabletSizes.radioPlayIconSize,
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RadioWaveAnimationTablet extends StatelessWidget {
  final bool isActive;
  const _RadioWaveAnimationTablet({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        _TabletSizes.radioIconContainerRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + (index * 150)),
            width: _TabletSizes.radioWaveBarWidth,
            height: isActive
                ? (_TabletSizes.radioWaveBarMaxHeight +
                      (index % 2 == 0
                          ? _TabletSizes.radioWaveBarMaxHeight / 2
                          : 0))
                : _TabletSizes.radioWaveBarMinHeight,
            margin: EdgeInsets.symmetric(
              horizontal: _TabletSizes.radioWaveBarSpacing,
            ),
            decoration: BoxDecoration(
              color: const Color(
                0xFF8B5CF6,
              ).withValues(alpha: _TabletSizes.radioWaveBarAlpha),
              borderRadius: BorderRadius.circular(
                _TabletSizes.radioWaveBarBorderRadius,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Section Title (Tablet) ──────────────────────────────────────────────────

class _SectionTitleTablet extends StatelessWidget {
  final String title;
  const _SectionTitleTablet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      style: TextStyle(
        fontSize: _TabletSizes.sectionTitleFontSize,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPri(context),
      ),
    );
  }
}

// ─── Videos Tab (Tablet) ────────────────────────────────────────────────────

class _VideosTabTablet extends StatelessWidget {
  final UniversityDetailController controller;
  const _VideosTabTablet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final videoList = controller.videoOnly;
      final crossAxisCount =
          MediaQuery.orientationOf(context) == Orientation.landscape ? 3 : 2;
      if (isLoading) {
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => _VideoShimmerTablet(),
        );
      }
      if (error.isNotEmpty) {
        return _ErrorViewTablet(error: error, onRetry: controller.loadVideos);
      }
      if (videoList.isEmpty) {
        return _EmptyViewTablet(
          icon: Icons.videocam_off_rounded,
          title: 'Henüz video yok',
          subtitle: 'Bu üniversiteye ait video bulunamadı.',
        );
      }
      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 40),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: videoList.length,
          itemBuilder: (_, i) => VideoCardWidget(video: videoList[i]),
        ),
      );
    });
  }
}

class _VideoShimmerTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: _TabletSizes.shimmerVideoHeight,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(
              _TabletSizes.shimmerVideoBorderRadius,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Shorts Tab (Tablet) ────────────────────────────────────────────────────

class _ShortsTabTablet extends StatelessWidget {
  final UniversityDetailController controller;
  const _ShortsTabTablet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final shortsList = controller.shortsOnly;
      final crossAxisCount =
          MediaQuery.orientationOf(context) == Orientation.landscape ? 3 : 2;
      if (isLoading) {
        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 168,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 6,
          itemBuilder: (_, _) => const _ShortsListShimmerTablet(),
        );
      }
      if (error.isNotEmpty) {
        return _ErrorViewTablet(error: error, onRetry: controller.loadVideos);
      }
      if (shortsList.isEmpty) {
        return _EmptyViewTablet(
          icon: Icons.movie_filter_outlined,
          title: 'Henüz Shorts yok',
          subtitle: 'Bu üniversiteye ait shorts video bulunamadı.',
        );
      }
      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: GridView.builder(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 40),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 168,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: shortsList.length,
          itemBuilder: (_, i) => _ShortsListCardTablet(
            video: shortsList[i],
            onTap: () => _openShortsPlayer(shortsList, i),
          ),
        ),
      );
    });
  }

  void _openShortsPlayer(List<VideoModel> shorts, int initialIndex) {
    Get.toNamed(
      AppRoutes.simpleShortsPlayer,
      arguments: {'shorts': shorts, 'initialIndex': initialIndex},
    );
  }
}

class _ShortsListCardTablet extends StatelessWidget {
  final VideoModel video;
  final VoidCallback onTap;
  const _ShortsListCardTablet({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(
          _TabletSizes.shortsCardBorderRadius,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            _TabletSizes.shortsCardBorderRadius,
          ),
          child: Container(
            padding: EdgeInsets.all(_TabletSizes.shortsCardPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnailTablet(context),
                SizedBox(width: _TabletSizes.shortsThumbnailSpacing),
                Expanded(
                  child: SizedBox(
                    height: _TabletSizes.shortsThumbnailHeight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _ShortsBadgeTablet(),
                            if (video.formattedDuration.isNotEmpty) ...[
                              SizedBox(width: 8),
                              _DurationChipTablet(
                                duration: video.formattedDuration,
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: _TabletSizes.shortsTitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPri(context),
                            height: _TabletSizes.shortsTitleLineHeight,
                          ),
                        ),
                        SizedBox(height: 6),
                        if (video.description.isNotEmpty)
                          Text(
                            video.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: _TabletSizes.shortsDescFontSize,
                              color: AppTheme.textSec(context),
                              height: _TabletSizes.shortsDescLineHeight,
                            ),
                          ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: _TabletSizes.shortsMetaFontSize * 1.2,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 4),
                            Text(
                              video.formattedViewCount,
                              style: TextStyle(
                                fontSize: _TabletSizes.shortsMetaFontSize,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                            SizedBox(width: _TabletSizes.shortsMetaSpacing),
                            Icon(
                              Icons.schedule_rounded,
                              size: _TabletSizes.shortsMetaFontSize * 1.1,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 4),
                            Text(
                              timeago.format(video.publishedAt, locale: 'tr'),
                              style: TextStyle(
                                fontSize: _TabletSizes.shortsMetaFontSize,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                          ],
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

  Widget _buildThumbnailTablet(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_TabletSizes.shortsThumbnailRadius),
      child: SizedBox(
        width: _TabletSizes.shortsThumbnailWidth,
        height: _TabletSizes.shortsThumbnailHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: video.bestThumbnail,
              fit: BoxFit.cover,
              placeholder: (_, _) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
              ),
              errorWidget: (_, _, _) => Container(
                color: AppTheme.isDark(context)
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE8E8E8),
                child: Icon(
                  Icons.play_circle_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: _TabletSizes.shortsPlayOverlaySize * 0.8,
                ),
              ),
            ),
            Center(
              child: Container(
                width: _TabletSizes.shortsPlayOverlaySize,
                height: _TabletSizes.shortsPlayOverlaySize,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: _TabletSizes.shortsPlayIconSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortsBadgeTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.shortsBadgePaddingHorizontal,
        vertical: _TabletSizes.shortsBadgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(
          _TabletSizes.shortsBadgeBorderRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_fill_rounded,
            size: _TabletSizes.shortsBadgeIconSize,
            color: Colors.white,
          ),
          SizedBox(width: 3),
          Text(
            'SHORTS',
            style: TextStyle(
              fontSize: _TabletSizes.shortsBadgeFontSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationChipTablet extends StatelessWidget {
  final String duration;
  const _DurationChipTablet({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.shortsDurationChipPaddingHorizontal,
        vertical: _TabletSizes.shortsDurationChipPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(
          _TabletSizes.shortsDurationChipBorderRadius,
        ),
      ),
      child: Text(
        duration,
        style: TextStyle(
          fontSize: _TabletSizes.shortsDurationChipFontSize,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSec(context),
        ),
      ),
    );
  }
}

class _ShortsListShimmerTablet extends StatelessWidget {
  const _ShortsListShimmerTablet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          height: _TabletSizes.shimmerShortsHeight,
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(
              _TabletSizes.shimmerShortsBorderRadius,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Error View (Tablet) ──────────────────────────────────────────────────────

class _ErrorViewTablet extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorViewTablet({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: _TabletSizes.errorIconSize,
              color: AppTheme.textSec(context),
            ),
            SizedBox(height: _TabletSizes.errorSpacingLarge),
            Text(
              error,
              style: TextStyle(
                fontSize: _TabletSizes.errorFontSize,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _TabletSizes.errorSpacingSmall),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(
                Icons.refresh_rounded,
                size: _TabletSizes.errorIconSize * 0.4,
              ),
              label: Text(
                'Tekrar Dene',
                style: TextStyle(fontSize: _TabletSizes.errorFontSize - 1),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty View (Tablet) ──────────────────────────────────────────────────────

class _EmptyViewTablet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyViewTablet({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _TabletSizes.emptyIconContainerSize,
              height: _TabletSizes.emptyIconContainerSize,
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: _TabletSizes.emptyIconSize,
                color: AppTheme.textSec(context),
              ),
            ),
            SizedBox(height: _TabletSizes.emptySpacingLarge),
            Text(
              title,
              style: TextStyle(
                fontSize: _TabletSizes.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPri(context),
              ),
            ),
            SizedBox(height: _TabletSizes.emptySpacingSmall),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: _TabletSizes.emptySubtitleFontSize,
                color: AppTheme.textSec(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
