import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/shorts_model.dart';

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

  // FIX: _progress artık setState yerine ValueNotifier ile güncelleniyor.
  // Önceden her 500ms'de bir setState() TÜM ekranı (player dahil) yeniden
  // build ediyordu. Kullanıcı videoya pinch/swipe ile native fullscreen'e
  // geçtiğinde (showFullscreenButton:false sadece YouTube'un UI butonunu
  // gizler, jestleri değil), tam o anda gelen bir setState WebView'in
  // layout'unu native fullscreen geçişiyle aynı anda yeniden hesaplatıyor;
  // bu da iframe player'ın videoyu sıfırlamasına (en baştan başlamasına)
  // yol açıyordu. ValueNotifier sayesinde artık sadece progress bar
  // widget'ı rebuild oluyor, player ağacı tamamen sabit kalıyor.
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  // FIX: Her yeni controller için benzersiz key → YoutubePlayer widget'ı
  // tamamen yeniden oluşturulur, eski controller'a kilitli kalmaz.
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

  // ─── YT Controller ────────────────────────────────────────────────────────

  void _initYtController(int index) {
    _progressTimer?.cancel();
    _ytController?.close();

    _progressNotifier.value = 0.0; // FIX: setState yerine notifier sıfırlanıyor
    if (mounted) {
      setState(() {
        _isPaused = false;
        _playerKey++; // FIX: key artırılınca YoutubePlayer tamamen yeniden oluşur
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
          _progressNotifier.value = p; // FIX: setState yerine notifier
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
    if (index == _currentIndex)
      return; // zaten bu index'teyiz, tekrar init etme
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

            // ── Chip satırı ───────────────────────────────────────────
            _UniversityChipRow(
              shorts: _shorts,
              currentIndex: _currentIndex,
              scrollController: _chipScrollController,
              onSelect: _goToIndex,
            ),

            SizedBox(height: 6.h),

            // ── YouTube Player ─────────────────────────────────────────
            // FIX: ValueKey(_playerKey) sayesinde index değiştiğinde
            // widget tamamen rebuild olur → yeni controller çalışır.
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
                  // FIX: YoutubePlayer artık Positioned.fill içinde.
                  // Önceden Stack'in içinde serbest (loose) constraint'lerle
                  // kendi aspectRatio'sunu (9/16) hesaplıyordu — bu, dış
                  // AspectRatio(9/16) kutusuyla çakışan ikinci bir oran
                  // hesaplaması yaratıyor ve bazı ekran boylarında video
                  // kutudan biraz taşıp Stack tarafından alttan kırpılıyordu.
                  // Positioned.fill ile artık kesin (tight) constraint
                  // veriliyor; player tam olarak 9:16 kutuyu dolduruyor,
                  // taşma/kırpılma olmuyor.
                  if (_ytController != null)
                    Positioned.fill(
                      child: YoutubePlayer(
                        key: ValueKey(_playerKey), // FIX: zorunlu!
                        controller: _ytController!,
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
                    // Logo + üniversite adı
                    Row(
                      children: [
                        if (short.logoUrl != null && short.logoUrl!.isNotEmpty)
                          Container(
                            width: 30.w,
                            height: 30.w,
                            margin: EdgeInsets.only(right: 8.w),
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
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12.sp,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // ── Navigasyon butonları ──────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBtn(
                          icon: Icons.skip_previous_rounded,
                          label: 'Önceki',
                          enabled: _currentIndex > 0,
                          onTap: () => _goToIndex(_currentIndex - 1),
                        ),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPaused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                              size: 30.sp,
                            ),
                          ),
                        ),
                        _NavBtn(
                          icon: Icons.skip_next_rounded,
                          label: 'Sonraki',
                          enabled: _currentIndex < _shorts.length - 1,
                          onTap: () => _goToIndex(_currentIndex + 1),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // ── Progress bar ──────────────────────────────────
                    // FIX: setState yerine ValueListenableBuilder — sadece
                    // bu küçük widget rebuild oluyor, player'a dokunulmuyor.
                    ValueListenableBuilder<double>(
                      valueListenable: _progressNotifier,
                      builder: (context, progress, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(2.r),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white24,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryColor,
                          ),
                          minHeight: 4,
                        ),
                      ),
                    ),

                    SizedBox(height: 8.h),

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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(5),
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

// ─── Üniversite Chip Satırı ───────────────────────────────────────────────────

class _UniversityChipRow extends StatelessWidget {
  final List<ShortsModel> shorts;
  final int currentIndex;
  final ScrollController scrollController;
  final void Function(int) onSelect;

  const _UniversityChipRow({
    required this.shorts,
    required this.currentIndex,
    required this.scrollController,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: shorts.length,
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final short = shorts[index];
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
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
                  if (short.logoUrl != null && short.logoUrl!.isNotEmpty) ...[
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: short.logoUrl!,
                        width: 14.w,
                        height: 14.w,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    _abbr(short.universityName),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
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

// ─── Navigasyon Butonu ────────────────────────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn({
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
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: enabled ? Colors.white12 : Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: enabled ? Colors.white24 : Colors.white12,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: enabled ? Colors.white : Colors.white30,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white60 : Colors.white24,
              fontSize: 9.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Metin Butonu ─────────────────────────────────────────────────────────────

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