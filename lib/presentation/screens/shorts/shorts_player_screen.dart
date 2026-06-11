// lib/presentation/screens/shorts/shorts_player_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/themes/app_theme.dart';
import '../../../data/models/shorts_model.dart';

/// Tam ekran dikey swipe ile shorts oynatıcısı.
/// youtube_shorts paketi yerine youtube_player_iframe kullanıyoruz —
/// zaten projede mevcut, ek bağımlılık gerektirmiyor.
///
/// Kullanım:
///   Get.toNamed(AppRoutes.shortsPlayer, arguments: {
///     'shorts': List<ShortsModel>,
///     'initialIndex': int,
///   });
class ShortsPlayerScreen extends StatefulWidget {
  const ShortsPlayerScreen({super.key});

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  late final List<ShortsModel> _shorts;
  late final PageController _pageController;
  late int _currentIndex;

  // Her sayfa için ayrı bir controller tutuyoruz.
  // Aktif olan oynar, diğerleri dispose edilir.
  YoutubePlayerController? _activeYtController;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>;
    _shorts = List<ShortsModel>.from(args['shorts'] as List);
    _currentIndex = (args['initialIndex'] as int?) ?? 0;

    _pageController = PageController(initialPage: _currentIndex);
    _initController(_currentIndex);

    // Tam ekran dikey mod
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initController(int index) {
    _activeYtController?.close();
    _activeYtController = YoutubePlayerController.fromVideoId(
      videoId: _shorts[index].videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: false,
        loop: true,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _activeYtController?.close();
    _pageController.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _initController(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Sayfa Kaydırıcı ────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: _shorts.length,
            itemBuilder: (context, index) {
              final short = _shorts[index];
              final isActive = index == _currentIndex;

              return _ShortsPage(
                short: short,
                isActive: isActive,
                ytController: isActive ? _activeYtController : null,
              );
            },
          ),

          // ── Üst Bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'SHORTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '${_currentIndex + 1} / ${_shorts.length}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tek bir shorts sayfası ──────────────────────────────────────────────────

class _ShortsPage extends StatelessWidget {
  final ShortsModel short;
  final bool isActive;
  final YoutubePlayerController? ytController;

  const _ShortsPage({
    required this.short,
    required this.isActive,
    this.ytController,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Arka Plan: Thumbnail (yüklenirken / controller yokken) ──────
        CachedNetworkImage(
          imageUrl: short.bestThumbnail,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(color: Colors.black),
        ),

        // ── YouTube Player (tam ekran) ──────────────────────────────────
        if (isActive && ytController != null)
          YoutubePlayer(
            controller: ytController!,
            aspectRatio: 9 / 16,
          ),

        // ── Karartma gradyanı (alt bilgi için) ─────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 220.h,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black87,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // ── Alt Bilgi: üniversite + başlık ─────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Üniversite logosu + adı
                  Row(
                    children: [
                      if (short.logoUrl != null && short.logoUrl!.isNotEmpty)
                        Container(
                          width: 36.w,
                          height: 36.w,
                          margin: EdgeInsets.only(right: 10.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white38,
                              width: 1,
                            ),
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

                  SizedBox(height: 8.h),

                  // Video başlığı
                  Text(
                    short.title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13.sp,
                      height: 1.35,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Sağ kenar: eylem butonları ──────────────────────────────────
        Positioned(
          right: 12.w,
          bottom: 100.h,
          child: Column(
            children: [
              _ActionBtn(
                icon: Icons.play_circle_outline_rounded,
                label: 'İzle',
                onTap: () => Get.toNamed(
                  '/player',
                  parameters: {'videoId': short.videoId},
                ),
              ),
              SizedBox(height: 20.h),
              _ActionBtn(
                icon: Icons.share_rounded,
                label: 'Paylaş',
                onTap: () {
                  final url =
                      'https://www.youtube.com/shorts/${short.videoId}';
                  Clipboard.setData(ClipboardData(text: url));
                  Get.snackbar(
                    'Bağlantı Kopyalandı',
                    short.title,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.black87,
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.black45,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}