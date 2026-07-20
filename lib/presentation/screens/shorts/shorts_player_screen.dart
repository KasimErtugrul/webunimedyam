// lib/presentation/screens/shorts/shorts_player_screen.dart

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
import '../../../data/models/shorts_model.dart';

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
  static const double chipRowHeight = 32;
  static const double chipPaddingHorizontal = 12;
  static const double chipMarginRight = 8;
  static const double chipPaddingHorizontalInner = 10;
  static const double chipPaddingVertical = 5;
  static const double chipBorderRadius = 20;
  static const double chipBorderWidth = 1;
  static const double chipLogoSize = 14;
  static const double chipLogoSpacing = 4;
  static const double chipFontSize = 10;

  // Bottom content padding
  static const double bottomPaddingHorizontal = 16;
  static const double bottomPaddingVertical = 10;
  static const double logoContainerSize = 30;
  static const double logoSpacing = 8;
  static const double titleFontSize = 13;
  static const double subtitleFontSize = 12;
  static const double subtitleLineHeight = 1.35;

  // Play button
  static const double playButtonSize = 56;
  static const double playIconSize = 30;

  // Nav button
  static const double navBtnSize = 48;
  static const double navBtnIconSize = 24;
  static const double navBtnSpacing = 4;
  static const double navBtnLabelFontSize = 9;
  static const double navBtnBorderWidth = 1;
  static const double navBtnDisabledAlpha = 0.04;
  static const double navBtnEnabledAlpha = 0.12;

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
  static const double chipRowHeight = 38;
  static const double chipPaddingHorizontal = 16;
  static const double chipMarginRight = 10;
  static const double chipPaddingHorizontalInner = 12;
  static const double chipPaddingVertical = 6;
  static const double chipBorderRadius = 24;
  static const double chipBorderWidth = 1.2;
  static const double chipLogoSize = 18;
  static const double chipLogoSpacing = 6;
  static const double chipFontSize = 12;

  // Bottom content padding
  static const double bottomPaddingHorizontal = 20;
  static const double bottomPaddingVertical = 14;
  static const double logoContainerSize = 36;
  static const double logoSpacing = 10;
  static const double titleFontSize = 16;
  static const double subtitleFontSize = 14;
  static const double subtitleLineHeight = 1.4;

  // Play button
  static const double playButtonSize = 68;
  static const double playIconSize = 36;

  // Nav button
  static const double navBtnSize = 56;
  static const double navBtnIconSize = 28;
  static const double navBtnSpacing = 6;
  static const double navBtnLabelFontSize = 11;
  static const double navBtnBorderWidth = 1.2;
  static const double navBtnDisabledAlpha = 0.04;
  static const double navBtnEnabledAlpha = 0.12;

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
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class ShortsPlayerScreen extends StatefulWidget {
  const ShortsPlayerScreen({super.key});

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  late final List<ShortsModel> _shorts;
  late final ScrollController _chipScrollController;
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
    _shorts = List<ShortsModel>.from(args['shorts'] as List);
    _currentIndex = (args['initialIndex'] as int?) ?? 0;
    _chipScrollController = ScrollController();
    _initYtController(_currentIndex);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _ytController?.close();
    _chipScrollController.dispose();
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
            // Top bar
            _buildTopBarPhone(),
            // Chip row
            _UniversityChipRowPhone(
              shorts: _shorts,
              currentIndex: _currentIndex,
              scrollController: _chipScrollController,
              onSelect: _goToIndex,
            ),
            SizedBox(height: _PhoneSizes.topBarPaddingVertical.h),
            // Player
            AspectRatio(
              aspectRatio: 9 / 16,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: short.bestThumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_ytController != null)
                    Positioned.fill(
                      child: YoutubePlayer(
                        key: ValueKey(_playerKey),
                        controller: _ytController!,
                      ),
                    ),
                ],
              ),
            ),
            // Bottom info
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
                    // University row
                    Row(
                      children: [
                        if (short.logoUrl != null && short.logoUrl!.isNotEmpty)
                          Container(
                            width: _PhoneSizes.logoContainerSize.w,
                            height: _PhoneSizes.logoContainerSize.w,
                            margin: EdgeInsets.only(
                              right: _PhoneSizes.logoSpacing.w,
                            ),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: short.logoUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            short.universityName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: _PhoneSizes.titleFontSize.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _PhoneSizes.topBarPaddingVertical.h),
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: _PhoneSizes.subtitleFontSize.sp,
                        height: _PhoneSizes.subtitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBtnPhone(
                          icon: Icons.skip_previous_rounded,
                          label: 'Önceki',
                          enabled: _currentIndex > 0,
                          onTap: () => _goToIndex(_currentIndex - 1),
                        ),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: _PhoneSizes.playButtonSize.w,
                            height: _PhoneSizes.playButtonSize.w,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                              size: _PhoneSizes.playIconSize.sp,
                            ),
                          ),
                        ),
                        _NavBtnPhone(
                          icon: Icons.skip_next_rounded,
                          label: 'Sonraki',
                          enabled: _currentIndex < _shorts.length - 1,
                          onTap: () => _goToIndex(_currentIndex + 1),
                        ),
                      ],
                    ),
                    SizedBox(height: _PhoneSizes.topBarPaddingVertical.h),
                    // Progress bar
                    ValueListenableBuilder<double>(
                      valueListenable: _progressNotifier,
                      builder: (context, progress, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _PhoneSizes.progressBarRadius.r,
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          minHeight: _PhoneSizes.progressBarHeight.h,
                        ),
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.topBarPaddingVertical.h),
                    // Action buttons
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
                        SizedBox(width: _PhoneSizes.textBtnSpacing.w),
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

  // ─── Top Bar Phone ──────────────────────────────────────────────────────────

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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: _PhoneSizes.backIconSize,
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
            // Top bar
            _buildTopBarTablet(),
            // Chip row
            _UniversityChipRowTablet(
              shorts: _shorts,
              currentIndex: _currentIndex,
              scrollController: _chipScrollController,
              onSelect: _goToIndex,
            ),
            SizedBox(height: _TabletSizes.topBarPaddingVertical),
            // Player
            AspectRatio(
              aspectRatio: 9 / 16,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: short.bestThumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (_ytController != null)
                    Positioned.fill(
                      child: YoutubePlayer(
                        key: ValueKey(_playerKey),
                        controller: _ytController!,
                      ),
                    ),
                ],
              ),
            ),
            // Bottom info
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
                    // University row
                    Row(
                      children: [
                        if (short.logoUrl != null && short.logoUrl!.isNotEmpty)
                          Container(
                            width: _TabletSizes.logoContainerSize,
                            height: _TabletSizes.logoContainerSize,
                            margin: EdgeInsets.only(
                              right: _TabletSizes.logoSpacing,
                            ),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: short.logoUrl!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            short.universityName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: _TabletSizes.titleFontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: _TabletSizes.topBarPaddingVertical),
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: _TabletSizes.subtitleFontSize,
                        height: _TabletSizes.subtitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBtnTablet(
                          icon: Icons.skip_previous_rounded,
                          label: 'Önceki',
                          enabled: _currentIndex > 0,
                          onTap: () => _goToIndex(_currentIndex - 1),
                        ),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: _TabletSizes.playButtonSize,
                            height: _TabletSizes.playButtonSize,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                              size: _TabletSizes.playIconSize,
                            ),
                          ),
                        ),
                        _NavBtnTablet(
                          icon: Icons.skip_next_rounded,
                          label: 'Sonraki',
                          enabled: _currentIndex < _shorts.length - 1,
                          onTap: () => _goToIndex(_currentIndex + 1),
                        ),
                      ],
                    ),
                    SizedBox(height: _TabletSizes.topBarPaddingVertical),
                    // Progress bar
                    ValueListenableBuilder<double>(
                      valueListenable: _progressNotifier,
                      builder: (context, progress, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.progressBarRadius,
                        ),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          minHeight: _TabletSizes.progressBarHeight,
                        ),
                      ),
                    ),
                    SizedBox(height: _TabletSizes.topBarPaddingVertical),
                    // Action buttons
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
                        SizedBox(width: _TabletSizes.textBtnSpacing),
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

  // ─── Top Bar Tablet ──────────────────────────────────────────────────────────

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
            icon: const Icon(
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

// ─── University Chip Row (Phone) ─────────────────────────────────────────────

class _UniversityChipRowPhone extends StatelessWidget {
  final List<ShortsModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final void Function(int) onSelect;

  const _UniversityChipRowPhone({
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
          final short = shorts[index];
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
                    : Colors.white.withValues(alpha:0.12),
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
                  if (short.logoUrl != null && short.logoUrl!.isNotEmpty) ...[
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: short.logoUrl!,
                        width: _PhoneSizes.chipLogoSize.w,
                        height: _PhoneSizes.chipLogoSize.w,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(width: _PhoneSizes.chipLogoSpacing.w),
                  ],
                  Text(
                    _abbr(short.universityName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _PhoneSizes.chipFontSize.sp,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
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

  String _abbr(String name) {
    final words = name
        .replaceAll('Üniversitesi', '')
        .replaceAll('Üniversite', '')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length <= 2) return words.join(' ');
    return words.map((w) => w[0].toUpperCase()).take(4).join();
  }
}

// ─── Navigation Button (Phone) ─────────────────────────────────────────────────

class _NavBtnPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtnPhone({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _PhoneSizes.navBtnSize.w,
            height: _PhoneSizes.navBtnSize.w,
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.white.withValues(alpha:_PhoneSizes.navBtnEnabledAlpha)
                  : Colors.white.withValues(alpha:_PhoneSizes.navBtnDisabledAlpha),
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? Colors.white24 : Colors.white12,
                width: _PhoneSizes.navBtnBorderWidth,
              ),
            ),
            child: Icon(
              icon,
              color: enabled ? Colors.white : Colors.white30,
              size: _PhoneSizes.navBtnIconSize.sp,
            ),
          ),
          SizedBox(height: _PhoneSizes.navBtnSpacing.h),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white60 : Colors.white24,
              fontSize: _PhoneSizes.navBtnLabelFontSize.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Text Button (Phone) ──────────────────────────────────────────────────────

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

// ─── University Chip Row (Tablet) ─────────────────────────────────────────────

class _UniversityChipRowTablet extends StatelessWidget {
  final List<ShortsModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final void Function(int) onSelect;

  const _UniversityChipRowTablet({
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
          final short = shorts[index];
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
                    : Colors.white.withValues(alpha:0.12),
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
                  if (short.logoUrl != null && short.logoUrl!.isNotEmpty) ...[
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: short.logoUrl!,
                        width: _TabletSizes.chipLogoSize,
                        height: _TabletSizes.chipLogoSize,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(width: _TabletSizes.chipLogoSpacing),
                  ],
                  Text(
                    _abbr(short.universityName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _TabletSizes.chipFontSize,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
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

  String _abbr(String name) {
    final words = name
        .replaceAll('Üniversitesi', '')
        .replaceAll('Üniversite', '')
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.length <= 2) return words.join(' ');
    return words.map((w) => w[0].toUpperCase()).take(4).join();
  }
}

// ─── Navigation Button (Tablet) ─────────────────────────────────────────────────

class _NavBtnTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtnTablet({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _TabletSizes.navBtnSize,
            height: _TabletSizes.navBtnSize,
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.white.withValues(alpha:_TabletSizes.navBtnEnabledAlpha)
                  : Colors.white.withValues(alpha:_TabletSizes.navBtnDisabledAlpha),
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? Colors.white24 : Colors.white12,
                width: _TabletSizes.navBtnBorderWidth,
              ),
            ),
            child: Icon(
              icon,
              color: enabled ? Colors.white : Colors.white30,
              size: _TabletSizes.navBtnIconSize,
            ),
          ),
          SizedBox(height: _TabletSizes.navBtnSpacing),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white60 : Colors.white24,
              fontSize: _TabletSizes.navBtnLabelFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Text Button (Tablet) ──────────────────────────────────────────────────────

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