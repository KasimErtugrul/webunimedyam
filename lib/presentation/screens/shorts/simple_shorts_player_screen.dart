// lib/presentation/screens/shorts/simple_shorts_player_screen.dart

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/video_model.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Top bar
  static const double topBarPaddingHorizontal = 4;
  static const double topBarPaddingVertical = 2;
  static const double backIconSize = 20;
  static const double shortsBadgePaddingHorizontal = 8;
  static const double shortsBadgePaddingVertical = 3;
  static const double shortsBadgeBorderRadius = 5;
  static const double shortsBadgeFontSize = 10;
  static const double shortsBadgeLetterSpacing = 1.2;
  static const double counterFontSize = 12;
  static const double counterSpacing = 8;
  static const double muteButtonSize = 34;
  static const double muteIconSize = 16;

  // Chip row
  static const double chipRowHeight = 38;
  static const double chipPaddingHorizontal = 12;
  static const double chipMarginRight = 8;
  static const double chipPaddingHorizontalInner = 6;
  static const double chipPaddingVertical = 4;
  static const double chipBorderRadius = 20;
  static const double chipBorderWidth = 1;
  static const double chipThumbnailSize = 24;
  static const double chipThumbnailBorderRadius = 4;
  static const double chipThumbnailSpacing = 6;
  static const double chipTitleMaxWidth = 80;
  static const double chipFontSize = 10;

  // Player
  static const double playerAspectRatio = 9 / 16;
  static const double playPauseOverlaySize = 64;
  static const double playPauseIconSize = 40;

  // Bottom content
  static const double bottomPaddingHorizontal = 16;
  static const double bottomPaddingVertical = 10;
  static const double titleFontSize = 13;
  static const double titleLineHeight = 1.35;
  static const double viewCountFontSize = 11;
  static const double viewCountSpacing = 4;

  // Progress bar
  static const double progressBarHeight = 4;
  static const double progressBarRadius = 2;

  // Text buttons
  static const double textBtnPaddingVertical = 8;
  static const double textBtnBorderRadius = 8;
  static const double textBtnBorderWidth = 1;
  static const double textBtnIconSize = 16;
  static const double textBtnLabelFontSize = 12;
  static const double textBtnSpacing = 5;
  static const double textBtnSpacingHorizontal = 10;
}

class _TabletSizes {
  // Top bar
  static const double topBarPaddingHorizontal = 6;
  static const double topBarPaddingVertical = 4;
  static const double backIconSize = 24;
  static const double shortsBadgePaddingHorizontal = 10;
  static const double shortsBadgePaddingVertical = 4;
  static const double shortsBadgeBorderRadius = 6;
  static const double shortsBadgeFontSize = 12;
  static const double shortsBadgeLetterSpacing = 1.4;
  static const double counterFontSize = 14;
  static const double counterSpacing = 10;
  static const double muteButtonSize = 40;
  static const double muteIconSize = 20;

  // Chip row
  static const double chipRowHeight = 44;
  static const double chipPaddingHorizontal = 16;
  static const double chipMarginRight = 10;
  static const double chipPaddingHorizontalInner = 8;
  static const double chipPaddingVertical = 5;
  static const double chipBorderRadius = 24;
  static const double chipBorderWidth = 1.2;
  static const double chipThumbnailSize = 30;
  static const double chipThumbnailBorderRadius = 5;
  static const double chipThumbnailSpacing = 8;
  static const double chipTitleMaxWidth = 100;
  static const double chipFontSize = 12;

  // Player
  static const double playerAspectRatio = 9 / 16;
  static const double playPauseOverlaySize = 76;
  static const double playPauseIconSize = 48;

  // Bottom content
  static const double bottomPaddingHorizontal = 20;
  static const double bottomPaddingVertical = 14;
  static const double titleFontSize = 16;
  static const double titleLineHeight = 1.4;
  static const double viewCountFontSize = 13;
  static const double viewCountSpacing = 6;

  // Progress bar
  static const double progressBarHeight = 5;
  static const double progressBarRadius = 3;

  // Text buttons
  static const double textBtnPaddingVertical = 10;
  static const double textBtnBorderRadius = 10;
  static const double textBtnBorderWidth = 1.2;
  static const double textBtnIconSize = 20;
  static const double textBtnLabelFontSize = 14;
  static const double textBtnSpacing = 6;
  static const double textBtnSpacingHorizontal = 12;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class SimpleShortsPlayerScreen extends StatefulWidget {
  const SimpleShortsPlayerScreen({super.key});

  @override
  State<SimpleShortsPlayerScreen> createState() =>
      _SimpleShortsPlayerScreenState();
}

class _SimpleShortsPlayerScreenState extends State<SimpleShortsPlayerScreen> {
  late final List<VideoModel> _shorts;
  late final ScrollController _chipScrollController;
  int _currentIndex = 0;

  YoutubePlayerController? _ytController;
  Timer? _progressTimer;
  double _progress = 0.0;
  bool _isMuted = false;
  bool _isPaused = false;

  int _playerKey = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _shorts = List<VideoModel>.from(args['shorts'] as List);
    _currentIndex = (args['initialIndex'] as int?) ?? 0;
    _chipScrollController = ScrollController();
    _initYtController(_currentIndex);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollChipIntoView(_currentIndex);
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _ytController?.close();
    _chipScrollController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _initYtController(int index) {
    _progressTimer?.cancel();
    _ytController?.close();

    if (mounted) {
      setState(() {
        _progress = 0.0;
        _isPaused = false;
        _playerKey++;
      });
    }

    _ytController = YoutubePlayerController.fromVideoId(
      videoId: _shorts[index].videoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: _isMuted,
        loop: false,
        enableCaption: false,
        playsInline: true,
        strictRelatedVideos: true,
      ),
    );

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (!mounted || _ytController == null) return;
      try {
        final dur = await _ytController!.duration;
        final cur = await _ytController!.currentTime;
        if (!mounted) return;
        if (dur > 0) {
          final p = (cur / dur).clamp(0.0, 1.0);
          setState(() => _progress = p);
          if (p >= 0.99 && _currentIndex < _shorts.length - 1) {
            _goToIndex(_currentIndex + 1);
          }
        }
      } catch (_) {}
    });
  }

  void _goToIndex(int index) {
    if (index < 0 || index >= _shorts.length) return;
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _initYtController(index);
    _scrollChipIntoView(index);
  }

  void _scrollChipIntoView(int index) {
    const chipWidth = 120.0;
    final offset = (index * chipWidth) - chipWidth;
    if (_chipScrollController.hasClients) {
      _chipScrollController.animateTo(
        offset.clamp(0.0, _chipScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _togglePlayPause() async {
    if (_ytController == null) return;
    if (_isPaused) {
      await _ytController!.playVideo();
    } else {
      await _ytController!.pauseVideo();
    }
    if (mounted) setState(() => _isPaused = !_isPaused);
  }

  Future<void> _toggleMute() async {
    if (_ytController == null) return;
    if (_isMuted) {
      await _ytController!.unMute();
    } else {
      await _ytController!.mute();
    }
    if (mounted) setState(() => _isMuted = !_isMuted);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 5 — TEK DALLANMA NOKTASI
  // ═══════════════════════════════════════════════════════════════════════

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
    final short = _shorts[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBarPhone(),
            _VideoChipRowPhone(
              shorts: _shorts,
              currentIndex: _currentIndex,
              scrollController: _chipScrollController,
              onSelect: _goToIndex,
            ),
            SizedBox(height: _PhoneSizes.topBarPaddingVertical.h),
            AspectRatio(
              aspectRatio: _PhoneSizes.playerAspectRatio,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: short.bestThumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_ytController != null)
                    YoutubePlayer(
                      key: ValueKey(_playerKey),
                      controller: _ytController!,
                      aspectRatio: _PhoneSizes.playerAspectRatio,
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPaused ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            width: _PhoneSizes.playPauseOverlaySize.w,
                            height: _PhoneSizes.playPauseOverlaySize.w,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: _PhoneSizes.playPauseIconSize.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.bottomPaddingHorizontal.w,
                  vertical: _PhoneSizes.bottomPaddingVertical.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: _PhoneSizes.titleFontSize.sp,
                        height: _PhoneSizes.titleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _PhoneSizes.viewCountSpacing.h),
                    Text(
                      short.formattedViewCount,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: _PhoneSizes.viewCountFontSize.sp,
                      ),
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _PhoneSizes.progressBarRadius.r,
                      ),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: _PhoneSizes.progressBarHeight.h,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.viewCountSpacing.h),
                    Row(
                      children: [
                        Expanded(
                          child: _TextBtnPhone(
                            icon: Icons.play_circle_outline_rounded,
                            label: 'Tam İzle',
                            onTap: () => Get.toNamed(
                              AppRoutes.player,
                              parameters: {'videoId': short.videoId},
                            ),
                          ),
                        ),
                        SizedBox(width: _PhoneSizes.textBtnSpacingHorizontal.w),
                        Expanded(
                          child: _TextBtnPhone(
                            icon: Icons.share_rounded,
                            label: 'Paylaş',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      'https://www.youtube.com/shorts/${short.videoId}',
                                ),
                              );
                              Get.snackbar(
                                'Kopyalandı',
                                short.title,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black87,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                                margin: EdgeInsets.all(
                                  _PhoneSizes.bottomPaddingHorizontal.w,
                                ),
                              );
                            },
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
    );
  }

  Widget _buildTopBarPhone() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.topBarPaddingHorizontal.w,
        vertical: _PhoneSizes.topBarPaddingVertical.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: _PhoneSizes.backIconSize.sp,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.shortsBadgePaddingHorizontal.w,
              vertical: _PhoneSizes.shortsBadgePaddingVertical.h,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(
                _PhoneSizes.shortsBadgeBorderRadius.r,
              ),
            ),
            child: Text(
              'SHORTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: _PhoneSizes.shortsBadgeFontSize.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: _PhoneSizes.shortsBadgeLetterSpacing,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} / ${_shorts.length}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: _PhoneSizes.counterFontSize.sp,
            ),
          ),
          SizedBox(width: _PhoneSizes.counterSpacing.w),
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              width: _PhoneSizes.muteButtonSize.w,
              height: _PhoneSizes.muteButtonSize.w,
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: _PhoneSizes.muteIconSize.sp,
              ),
            ),
          ),
          SizedBox(width: _PhoneSizes.topBarPaddingHorizontal.w),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final short = _shorts[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBarTablet(),
            _VideoChipRowTablet(
              shorts: _shorts,
              currentIndex: _currentIndex,
              scrollController: _chipScrollController,
              onSelect: _goToIndex,
            ),
            SizedBox(height: _TabletSizes.topBarPaddingVertical),
            AspectRatio(
              aspectRatio: _TabletSizes.playerAspectRatio,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: short.bestThumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_ytController != null)
                    YoutubePlayer(
                      key: ValueKey(_playerKey),
                      controller: _ytController!,
                      aspectRatio: _TabletSizes.playerAspectRatio,
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPaused ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            width: _TabletSizes.playPauseOverlaySize,
                            height: _TabletSizes.playPauseOverlaySize,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: _TabletSizes.playPauseIconSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.bottomPaddingHorizontal,
                  vertical: _TabletSizes.bottomPaddingVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: _TabletSizes.titleFontSize,
                        height: _TabletSizes.titleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _TabletSizes.viewCountSpacing),
                    Text(
                      short.formattedViewCount,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: _TabletSizes.viewCountFontSize,
                      ),
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        _TabletSizes.progressBarRadius,
                      ),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: _TabletSizes.progressBarHeight,
                      ),
                    ),
                    SizedBox(height: _TabletSizes.viewCountSpacing),
                    Row(
                      children: [
                        Expanded(
                          child: _TextBtnTablet(
                            icon: Icons.play_circle_outline_rounded,
                            label: 'Tam İzle',
                            onTap: () => Get.toNamed(
                              AppRoutes.player,
                              parameters: {'videoId': short.videoId},
                            ),
                          ),
                        ),
                        SizedBox(width: _TabletSizes.textBtnSpacingHorizontal),
                        Expanded(
                          child: _TextBtnTablet(
                            icon: Icons.share_rounded,
                            label: 'Paylaş',
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      'https://www.youtube.com/shorts/${short.videoId}',
                                ),
                              );
                              Get.snackbar(
                                'Kopyalandı',
                                short.title,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.black87,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                                margin: EdgeInsets.all(
                                  _TabletSizes.bottomPaddingHorizontal,
                                ),
                              );
                            },
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
    );
  }

  Widget _buildTopBarTablet() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.topBarPaddingHorizontal,
        vertical: _TabletSizes.topBarPaddingVertical,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: _TabletSizes.backIconSize,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _TabletSizes.shortsBadgePaddingHorizontal,
              vertical: _TabletSizes.shortsBadgePaddingVertical,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(
                _TabletSizes.shortsBadgeBorderRadius,
              ),
            ),
            child: Text(
              'SHORTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: _TabletSizes.shortsBadgeFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: _TabletSizes.shortsBadgeLetterSpacing,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} / ${_shorts.length}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: _TabletSizes.counterFontSize,
            ),
          ),
          SizedBox(width: _TabletSizes.counterSpacing),
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              width: _TabletSizes.muteButtonSize,
              height: _TabletSizes.muteButtonSize,
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: _TabletSizes.muteIconSize,
              ),
            ),
          ),
          SizedBox(width: _TabletSizes.topBarPaddingHorizontal),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _VideoChipRowPhone extends StatelessWidget {
  final List<VideoModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  const _VideoChipRowPhone({
    required this.shorts,
    required this.currentIndex,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _PhoneSizes.chipRowHeight.h,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _PhoneSizes.chipPaddingHorizontal.w),
        itemCount: shorts.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final video = shorts[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: _PhoneSizes.chipMarginRight.w),
              padding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.chipPaddingHorizontalInner.w,
                vertical: _PhoneSizes.chipPaddingVertical.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(_PhoneSizes.chipBorderRadius.r),
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white24,
                        width: _PhoneSizes.chipBorderWidth,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.chipThumbnailBorderRadius.r,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: _PhoneSizes.chipThumbnailSize.w,
                      height: _PhoneSizes.chipThumbnailSize.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.play_circle_outline,
                        size: _PhoneSizes.chipThumbnailSize.sp * 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: _PhoneSizes.chipThumbnailSpacing.w),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _PhoneSizes.chipTitleMaxWidth.w,
                    ),
                    child: Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _PhoneSizes.chipFontSize.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TextBtnPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TextBtnPhone({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: _PhoneSizes.textBtnPaddingVertical.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(_PhoneSizes.textBtnBorderRadius.r),
          border: Border.all(
            color: Colors.white12,
            width: _PhoneSizes.textBtnBorderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: _PhoneSizes.textBtnIconSize.sp,
            ),
            SizedBox(width: _PhoneSizes.textBtnSpacing.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: _PhoneSizes.textBtnLabelFontSize.sp,
                fontWeight: FontWeight.w500,
              ),
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

class _VideoChipRowTablet extends StatelessWidget {
  final List<VideoModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  const _VideoChipRowTablet({
    required this.shorts,
    required this.currentIndex,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _TabletSizes.chipRowHeight,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: _TabletSizes.chipPaddingHorizontal),
        itemCount: shorts.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final video = shorts[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: _TabletSizes.chipMarginRight),
              padding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.chipPaddingHorizontalInner,
                vertical: _TabletSizes.chipPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(_TabletSizes.chipBorderRadius),
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white24,
                        width: _TabletSizes.chipBorderWidth,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      _TabletSizes.chipThumbnailBorderRadius,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: _TabletSizes.chipThumbnailSize,
                      height: _TabletSizes.chipThumbnailSize,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.play_circle_outline,
                        size: _TabletSizes.chipThumbnailSize * 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: _TabletSizes.chipThumbnailSpacing),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _TabletSizes.chipTitleMaxWidth,
                    ),
                    child: Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _TabletSizes.chipFontSize,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TextBtnTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TextBtnTablet({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: _TabletSizes.textBtnPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(_TabletSizes.textBtnBorderRadius),
          border: Border.all(
            color: Colors.white12,
            width: _TabletSizes.textBtnBorderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: _TabletSizes.textBtnIconSize,
            ),
            SizedBox(width: _TabletSizes.textBtnSpacing),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: _TabletSizes.textBtnLabelFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}