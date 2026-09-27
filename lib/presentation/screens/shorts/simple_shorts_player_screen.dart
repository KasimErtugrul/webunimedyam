// lib/presentation/screens/shorts/simple_shorts_player_screen.dart
//
// Tek üniversitenin shorts akışı (üniversite detay > Shorts sekmesinden
// açılır). Artık ShortsPlayerScreen (üniversiteler arası "wheel" ekranı) ile
// BİREBİR AYNI "Shorts Oynatıcı — Saf Video" tasarımını paylaşıyor: video
// üzerinde hiçbir buton/metin yok, ilerleme/aksiyonlar/kanal kartı videonun
// ALTINDA. Tek fark: burada üniversiteler arası geçiş için bir "wheel"
// gerekmiyor (zaten tek üniversitedeyiz) — bunun yerine üstte sade bir
// appbar var, açıklamanın hemen altında "Bu Üniversitenin Diğer Shorts
// Videoları" rafı geliyor; bu raf, üniversite detay sayfasının Shorts
// sekmesinden gelen TÜM video listesini (mevcut hariç) kullanıyor.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../core/utils/share_helper.dart';
import '../../../data/models/video_model.dart';
import 'shorts_player_screen_widgets/action_bar.dart';
import 'shorts_player_screen_widgets/info_card.dart';
import 'shorts_player_screen_widgets/related_shelf.dart';
import 'utils/shorts_player_sizes.dart';

class SimpleShortsPlayerScreen extends StatefulWidget {
  const SimpleShortsPlayerScreen({super.key});

  @override
  State<SimpleShortsPlayerScreen> createState() =>
      _SimpleShortsPlayerScreenState();
}

class _SimpleShortsPlayerScreenState extends State<SimpleShortsPlayerScreen> {
  late final List<VideoModel> _shorts;
  late final String? _universityLogoUrl;
  int _currentIndex = 0;

  YoutubePlayerController? _ytController;
  Timer? _progressTimer;
  bool _isMuted = false;
  bool _isPaused = false;

  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);
  int _playerKey = 0;

  // Sosyal aksiyonlar için — henüz bir engagement repository bağlı değil,
  // bu yüzden yalnızca UI-only, videoId'ye göre saklanan yerel durum.
  final Set<String> _likedIds = {};
  final Set<String> _savedIds = {};
  bool _isFollowing = false;

  VideoModel get _current => _shorts[_currentIndex];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _shorts = List<VideoModel>.from(args['shorts'] as List);
    _currentIndex = ((args['initialIndex'] as int?) ?? 0).clamp(0, _shorts.length - 1);
    // University detay ekranından geçilirse logo burada iletilebilir
    // (bkz. UniversityDetailShortsTab._openShorts). Yoksa info kartı
    // otomatik olarak ikon fallback'ine düşer.
    _universityLogoUrl = args['logoUrl'] as String?;

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initYtController(_currentIndex);
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _ytController?.close();
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
  }

  void _goToVideo(VideoModel video) {
    _goToIndex(_shorts.indexWhere((v) => v.videoId == video.videoId));
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

  void _toggleLike(String videoId) => setState(() {
    if (!_likedIds.remove(videoId)) _likedIds.add(videoId);
  });

  void _toggleSave(String videoId) => setState(() {
    if (!_savedIds.remove(videoId)) _savedIds.add(videoId);
  });

  void _toggleFollow() => setState(() => _isFollowing = !_isFollowing);

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 5 — TEK DALLANMA NOKTASI
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_shorts.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Gösterilecek shorts bulunamadı.',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final ShortsPlayerSizes sizes = Responsive.isTablet(context)
        ? const ShortsPlayerTabletSizes()
        : const ShortsPlayerPhoneSizes();

    final short = _current;
    final related = _shorts.where((v) => v.videoId != short.videoId).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(sizes),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  sizes.pageHorizontalPadding,
                  sizes.sectionSpacing,
                  sizes.pageHorizontalPadding,
                  sizes.sectionSpacing * 2,
                ),
                child: sizes.isTablet
                    ? _buildTabletBody(sizes, short, related)
                    : _buildPhoneBody(sizes, short, related),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Düzenler ─────────────────────────────────────────────────────────

  Widget _buildPhoneBody(
    ShortsPlayerSizes sizes,
    VideoModel short,
    List<VideoModel> related,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVideoCard(sizes, short),
        SizedBox(height: sizes.sectionSpacing),
        _buildProgressBar(sizes),
        SizedBox(height: sizes.sectionSpacing),
        _buildActionBar(sizes, short),
        SizedBox(height: sizes.sectionSpacing),
        _buildInfoCard(sizes, short),
        SizedBox(height: sizes.sectionSpacing * 1.5),
        _buildRelatedShelf(sizes, short, related),
      ],
    );
  }

  Widget _buildTabletBody(
    ShortsPlayerSizes sizes,
    VideoModel short,
    List<VideoModel> related,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: sizes.videoMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoCard(sizes, short),
              SizedBox(height: sizes.sectionSpacing),
              _buildProgressBar(sizes),
              SizedBox(height: sizes.sectionSpacing),
              _buildActionBar(sizes, short),
            ],
          ),
        ),
        SizedBox(width: sizes.sectionSpacing * 1.5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(sizes, short),
              SizedBox(height: sizes.sectionSpacing * 1.5),
              _buildRelatedShelf(sizes, short, related),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Parçalar ─────────────────────────────────────────────────────────

  Widget _buildTopBar(ShortsPlayerSizes sizes) {
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
              borderRadius: BorderRadius.circular(sizes.shortsBadgeBorderRadius),
            ),
            child: Text(
              'SHORTS',
              style: TextStyle(
                color: Colors.black,
                fontSize: sizes.shortsBadgeFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: sizes.shortsBadgeLetterSpacing,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} / ${_shorts.length}',
            style: TextStyle(color: Colors.white60, fontSize: sizes.counterFontSize),
          ),
          SizedBox(width: sizes.counterSpacing),
          GestureDetector(
            onTap: _toggleMute,
            child: Container(
              width: sizes.muteButtonSize,
              height: sizes.muteButtonSize,
              decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
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

  Widget _buildVideoCard(ShortsPlayerSizes sizes, VideoModel short) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sizes.videoMaxWidth),
        child: AspectRatio(
          aspectRatio: sizes.videoAspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(sizes.videoBorderRadius),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: short.bestThumbnail, fit: BoxFit.cover),
                  if (_ytController != null)
                    IgnorePointer(
                      child: YoutubePlayer(
                        key: ValueKey(_playerKey),
                        controller: _ytController!,
                        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                      ),
                    ),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _togglePlayPause,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _isPaused ? 1 : 0,
                    child: Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white.withValues(alpha: 0.85),
                        size: sizes.playIconSize,
                      ),
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

  Widget _buildProgressBar(ShortsPlayerSizes sizes) {
    return ValueListenableBuilder<double>(
      valueListenable: _progressNotifier,
      builder: (context, progress, _) => ClipRRect(
        borderRadius: BorderRadius.circular(sizes.progressBarRadius),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white12,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          minHeight: sizes.progressBarHeight,
        ),
      ),
    );
  }

  Widget _buildActionBar(ShortsPlayerSizes sizes, VideoModel short) {
    return ShortsPlayerActionBar(
      sizes: sizes,
      isLiked: _likedIds.contains(short.videoId),
      isSaved: _savedIds.contains(short.videoId),
      isMuted: _isMuted,
      onLike: () => _toggleLike(short.videoId),
      onSave: () => _toggleSave(short.videoId),
      onShare: () => ShareHelper.shareVideo(
        videoId: short.videoId,
        title: short.title,
        universityName: short.universityName,
        thumbnailUrl: short.bestThumbnail,
      ),
      onToggleMute: _toggleMute,
    );
  }

  Widget _buildInfoCard(ShortsPlayerSizes sizes, VideoModel short) {
    return ShortsPlayerInfoCard(
      sizes: sizes,
      universityName: short.universityName ?? short.channelTitle,
      logoUrl: _universityLogoUrl,
      description: short.description,
      isFollowing: _isFollowing,
      onToggleFollow: _toggleFollow,
      onWatchFull: () => Get.toNamed(
        AppRoutes.player,
        parameters: {'videoId': short.videoId},
      ),
    );
  }

  Widget _buildRelatedShelf(
    ShortsPlayerSizes sizes,
    VideoModel short,
    List<VideoModel> related,
  ) {
    return ShortsPlayerRelatedShelf<VideoModel>(
      sizes: sizes,
      universityName: short.universityName ?? short.channelTitle,
      items: related,
      thumbnailOf: (v) => v.bestThumbnail,
      titleOf: (v) => v.title,
      durationOf: (v) => v.formattedDuration,
      onSelect: _goToVideo,
    );
  }
}
