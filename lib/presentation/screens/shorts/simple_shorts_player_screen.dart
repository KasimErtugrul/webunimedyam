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
import 'utils/simple_shorts_player_sizes.dart';


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
  late final PageController _pageController;
  int _currentIndex = 0;

  YoutubePlayerController? _ytController;
  Timer? _progressTimer;
  bool _isMuted = false;
  bool _isPaused = false;

  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  int _playerKey = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _shorts = List<VideoModel>.from(args['shorts'] as List);
    _currentIndex = (args['initialIndex'] as int?) ?? 0;
    _chipScrollController = ScrollController();
    _pageController = PageController(initialPage: _currentIndex);
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
    _pageController.dispose();
    _progressNotifier.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  void _initYtController(int index) {
    _progressTimer?.cancel();
    _ytController?.close();

    _progressNotifier.value = 0.0;
    if (mounted) {
      setState(() {
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
          _progressNotifier.value = p;
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
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _initYtController(index);
    _scrollChipIntoView(index);
  }

  void _scrollChipIntoView(int index) {
    const chipWidth = 90.0;
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
    final SimpleShortsPlayerSizes sizes = Responsive.isTablet(context)
        ? const SimpleShortsPlayerTabletSizes()
        : const SimpleShortsPlayerPhoneSizes();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _shorts.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) =>
                _buildPage(sizes, _shorts[index], index),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTopBar(sizes),
                  SimpleShortsPlayerVideoChipRow(
                    sizes: sizes,
                    shorts: _shorts,
                    currentIndex: _currentIndex,
                    scrollController: _chipScrollController,
                    onSelect: _goToIndex,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(SimpleShortsPlayerSizes sizes, VideoModel short, int index) {
    final isActive = index == _currentIndex;
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(
          imageUrl: short.bestThumbnail,
          fit: BoxFit.cover,
        ),
        if (isActive && _ytController != null)
          IgnorePointer(
            child: YoutubePlayer(
              key: ValueKey(_playerKey),
              controller: _ytController!,
            ),
          ),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: isActive ? _togglePlayPause : () => _goToIndex(index),
          ),
        ),
        if (isActive && _isPaused)
          Center(
            child: Icon(
              Icons.play_arrow_rounded,
              color: Colors.white.withValues(alpha: 0.85),
              size: sizes.playIconSize,
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              sizes.bottomPaddingHorizontal,
              60.h,
              sizes.bottomPaddingHorizontal,
              0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.88),
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: sizes.bottomPaddingVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: sizes.titleFontSize,
                        height: sizes.titleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sizes.viewCountSpacing),
                    Text(
                      short.formattedViewCount,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: sizes.viewCountFontSize,
                      ),
                    ),
                    SizedBox(height: sizes.topBarPaddingVertical),
                    isActive
                        ? ValueListenableBuilder<double>(
                            valueListenable: _progressNotifier,
                            builder: (context, progress, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(
                                sizes.progressBarRadius,
                              ),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                                minHeight: sizes.progressBarHeight,
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(
                              sizes.progressBarRadius,
                            ),
                            child: LinearProgressIndicator(
                              value: 0,
                              backgroundColor: Colors.white24,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                              minHeight: sizes.progressBarHeight,
                            ),
                          ),
                    SizedBox(height: sizes.topBarPaddingVertical),
                    Row(
                      children: [
                        Expanded(
                          child: SimpleShortsPlayerTextButton(
                            sizes: sizes,
                            icon: Icons.play_circle_outline_rounded,
                            label: 'Tam İzle',
                            onTap: () => Get.toNamed(
                              AppRoutes.player,
                              parameters: {'videoId': short.videoId},
                            ),
                          ),
                        ),
                        SizedBox(width: sizes.textBtnSpacingHorizontal),
                        Expanded(
                          child: SimpleShortsPlayerTextButton(
                            sizes: sizes,
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
                                  sizes.bottomPaddingHorizontal,
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
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(SimpleShortsPlayerSizes sizes) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.topBarPaddingHorizontal,
        vertical: sizes.topBarPaddingVertical,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: sizes.backIconSize,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.shortsBadgePaddingHorizontal,
              vertical: sizes.shortsBadgePaddingVertical,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(
                sizes.shortsBadgeBorderRadius,
              ),
            ),
            child: Text(
              'SHORTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: sizes.shortsBadgeFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: sizes.shortsBadgeLetterSpacing,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} / ${_shorts.length}',
            style: TextStyle(
              color: Colors.white60,
              fontSize: sizes.counterFontSize,
            ),
          ),
          SizedBox(width: sizes.counterSpacing),
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              width: sizes.muteButtonSize,
              height: sizes.muteButtonSize,
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: sizes.muteIconSize,
              ),
            ),
          ),
          SizedBox(width: sizes.topBarPaddingHorizontal),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ALT WIDGET'LAR (TEK SINIF, sizes İLE)
// ═══════════════════════════════════════════════════════════

// ─── Video Chip Row ─────────────────────────────────────────────────────────

class SimpleShortsPlayerVideoChipRow extends StatelessWidget {
  final SimpleShortsPlayerSizes sizes;
  final List<VideoModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  const SimpleShortsPlayerVideoChipRow({super.key, 
    required this.sizes,
    required this.shorts,
    required this.currentIndex,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: sizes.chipRowHeight,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: sizes.chipPaddingHorizontal),
        itemCount: shorts.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final video = shorts[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: sizes.chipMarginRight),
              padding: EdgeInsets.symmetric(
                horizontal: sizes.chipPaddingHorizontalInner,
                vertical: sizes.chipPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(sizes.chipBorderRadius),
                border: isSelected
                    ? null
                    : Border.all(
                        color: Colors.white24,
                        width: sizes.chipBorderWidth,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      sizes.chipThumbnailBorderRadius,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: sizes.chipThumbnailSize,
                      height: sizes.chipThumbnailSize,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Icon(
                        Icons.play_circle_outline,
                        size: sizes.chipThumbnailSize * 0.6,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: sizes.chipThumbnailSpacing),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: sizes.chipTitleMaxWidth,
                    ),
                    child: Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sizes.chipFontSize,
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

// ─── Text Button ────────────────────────────────────────────────────────────

class SimpleShortsPlayerTextButton extends StatelessWidget {
  final SimpleShortsPlayerSizes sizes;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SimpleShortsPlayerTextButton({super.key, 
    required this.sizes,
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
          vertical: sizes.textBtnPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(sizes.textBtnBorderRadius),
          border: Border.all(
            color: Colors.white12,
            width: sizes.textBtnBorderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: sizes.textBtnIconSize,
            ),
            SizedBox(width: sizes.textBtnSpacing),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: sizes.textBtnLabelFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}