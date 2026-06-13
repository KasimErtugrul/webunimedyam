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
import '../../../data/models/video_model.dart';

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

  // Her yeni controller için benzersiz key → YoutubePlayer tamamen yeniden oluşur
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

    // İlk açılışta doğru chip'i ortala
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

  // ─── YT Controller ────────────────────────────────────────────────────────

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

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      if (!mounted || _ytController == null) return;
      try {
        final dur = await _ytController!.duration;
        final cur = await _ytController!.currentTime;
        if (!mounted) return;
        if (dur > 0) {
          final p = (cur / dur).clamp(0.0, 1.0);
          setState(() => _progress = p);
          // Video bittiğinde otomatik sonrakine geç
          if (p >= 0.99 && _currentIndex < _shorts.length - 1) {
            _goToIndex(_currentIndex + 1);
          }
        }
      } catch (_) {}
    });
  }

  // ─── Navigasyon ───────────────────────────────────────────────────────────

  void _goToIndex(int index) {
    if (index < 0 || index >= _shorts.length) return;
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _initYtController(index);
    _scrollChipIntoView(index);
  }

  void _scrollChipIntoView(int index) {
    const chipWidth = 120.0; // Chip yaklaşık genişliği
    final offset = (index * chipWidth) - chipWidth;
    if (_chipScrollController.hasClients) {
      _chipScrollController.animateTo(
        offset.clamp(0.0, _chipScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  // ─── Kontroller ───────────────────────────────────────────────────────────

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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final short = _shorts[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Üst bar ───────────────────────────────────────────────
            _buildTopBar(),

            // ── Video Chip Satırı ──────────────────────────────────────
            _VideoChipRow(
              shorts: _shorts,
              currentIndex: _currentIndex,
              scrollController: _chipScrollController,
              onSelect: _goToIndex,
            ),

            SizedBox(height: 6.h),

            // ── YouTube Player ─────────────────────────────────────────
            AspectRatio(
              aspectRatio: 9 / 16,
              child: Stack(
                children: [
                  // Thumbnail arka plan
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: short.bestThumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Player
                  if (_ytController != null)
                    YoutubePlayer(
                      key: ValueKey(_playerKey),
                      controller: _ytController!,
                      aspectRatio: 9 / 16,
                    ),
                  // Dokunarak play/pause
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _isPaused ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            width: 64.w,
                            height: 64.w,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Alt bilgi + kontroller ─────────────────────────────────
            Expanded(
              child: Container(
                color: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Video başlığı ──────────────────────────────────
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // ── İzlenme sayısı ────────────────────────────────
                    Text(
                      short.formattedViewCount,
                      style: TextStyle(color: Colors.white54, fontSize: 11.sp),
                    ),

                    const Spacer(),

                    // ── Progress bar ──────────────────────────────────
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                        minHeight: 4,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    // ── Tam izle + paylaş ─────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _TextBtn(
                            icon: Icons.play_circle_outline_rounded,
                            label: 'Tam İzle',
                            onTap: () => Get.toNamed(
                              AppRoutes.player,
                              parameters: {'videoId': short.videoId},
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: _TextBtn(
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
                                margin: EdgeInsets.all(12.w),
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

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(5.r),
            ),
            child: Text(
              'SHORTS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} / ${_shorts.length}',
            style: TextStyle(color: Colors.white60, fontSize: 12.sp),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              width: 34.w,
              height: 34.w,
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 4.w),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Video Chip Satırı (Üniversite yerine videoların kendisi)
// ════════════════════════════════════════════════════════════════════════════

class _VideoChipRow extends StatelessWidget {
  final List<VideoModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelect;

  const _VideoChipRow({
    required this.shorts,
    required this.currentIndex,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38.h,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: shorts.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final video = shorts[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: isSelected
                    ? null
                    : Border.all(color: Colors.white24, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Video Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      width: 24.w,
                      height: 24.w,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.play_circle_outline,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  // Video Başlığı (Kısaltılmış)
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 80.w),
                    child: Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
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

// ════════════════════════════════════════════════════════════════════════════
// Metin Butonu
// ════════════════════════════════════════════════════════════════════════════

class _TextBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TextBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.white12, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 16.sp),
            SizedBox(width: 5.w),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
