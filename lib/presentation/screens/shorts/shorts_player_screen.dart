// lib/presentation/screens/shorts/shorts_player_screen.dart
//
// "Shorts Oynatıcı — Saf Video" tasarımından ilham alınarak yeniden
// düzenlendi: video artık tam ekranı kaplayan bir overlay değil, üzerinde
// KESİNLİKLE buton/metin/gradyan barındırmayan saf bir kart. İlerleme,
// aksiyonlar (beğen/kaydet/paylaş/ses), kanal bilgisi ve aynı üniversitenin
// diğer shorts'ları videonun ALTINDA, kaydırılabilir panellerde yer alır.
//
// Mockup'taki fazlalıklar (canlı sohbet, üniversite kategori şeridi, emoji
// tepki çubuğu) bilinçli olarak alınmadı — bu ekranın amacı tek bir kısa
// videoyu üniversiteler arası "wheel" ile gezmek, sosyal bir akış değil.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'shorts_player_screen_widgets/shorts_fullscreen.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../core/widgets/hover_tap.dart';
import '../../../core/utils/share_helper.dart';
import '../../../data/models/shorts_model.dart';
import '../../controllers/shorts_player_controller.dart';
import 'shorts_player_screen_widgets/action_bar.dart';
import 'shorts_player_screen_widgets/info_card.dart';
import 'shorts_player_screen_widgets/logo_wheel.dart';
import 'shorts_player_screen_widgets/related_shelf.dart';
import 'utils/shorts_player_sizes.dart';

class ShortsPlayerScreen extends StatefulWidget {
  const ShortsPlayerScreen({super.key});

  @override
  State<ShortsPlayerScreen> createState() => _ShortsPlayerScreenState();
}

class _ShortsPlayerScreenState extends State<ShortsPlayerScreen> {
  final ShortsPlayerController controller = Get.find<ShortsPlayerController>();

  // Sosyal aksiyonlar için — henüz bir engagement repository bağlı değil,
  // bu yüzden yalnızca UI-only, videoId'ye göre saklanan yerel durum.
  final Set<String> _likedIds = {};
  final Set<String> _savedIds = {};
  final Set<int> _followedUniversityIds = {};

  void _toggleLike(String videoId) => setState(() {
    if (!_likedIds.remove(videoId)) _likedIds.add(videoId);
  });

  void _toggleSave(String videoId) => setState(() {
    if (!_savedIds.remove(videoId)) _savedIds.add(videoId);
  });

  void _toggleFollow(int universityId) => setState(() {
    if (!_followedUniversityIds.remove(universityId)) {
      _followedUniversityIds.add(universityId);
    }
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.shorts.isEmpty) {
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

      // KURAL 5 — TEK DALLANMA NOKTASI (üçlü ölçek: web → tablet → telefon)
      final ShortsPlayerSizes sizes = Responsive.isWeb(context)
          ? const ShortsPlayerWebSizes()
          : Responsive.isTablet(context)
          ? const ShortsPlayerTabletSizes()
          : const ShortsPlayerPhoneSizes();

      final short = controller.current!;
      final related = controller.shorts
          .where(
            (s) =>
                s.universityId == short.universityId &&
                s.videoId != short.videoId,
          )
          .toList();

      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(sizes, short),
              ShortsPlayerUniversityLogoWheel(
                sizes: sizes,
                shorts: controller.shorts,
                activeIndex: controller.currentIndex.value,
                onChanged: controller.onWheelChanged,
              ),
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
    });
  }

  // ─── Düzenler ─────────────────────────────────────────────────────────

  Widget _buildPhoneBody(
    ShortsPlayerSizes sizes,
    ShortsModel short,
    List<ShortsModel> related,
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
        ShortsPlayerRelatedShelf<ShortsModel>(
          sizes: sizes,
          universityName: short.universityName,
          items: related,
          thumbnailOf: (s) => s.bestThumbnail,
          titleOf: (s) => s.title,
          durationOf: (s) => s.duration,
          onSelect: (item) => controller.onWheelChanged(
            controller.shorts.indexWhere((s) => s.videoId == item.videoId),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletBody(
    ShortsPlayerSizes sizes,
    ShortsModel short,
    List<ShortsModel> related,
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
              ShortsPlayerRelatedShelf<ShortsModel>(
                sizes: sizes,
                universityName: short.universityName,
                items: related,
                thumbnailOf: (s) => s.bestThumbnail,
                titleOf: (s) => s.title,
                durationOf: (s) => s.duration,
                onSelect: (item) => controller.onWheelChanged(
                  controller.shorts.indexWhere(
                    (s) => s.videoId == item.videoId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Parçalar ─────────────────────────────────────────────────────────

  Widget _buildTopBar(ShortsPlayerSizes sizes, ShortsModel short) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.topBarPaddingHorizontal,
        vertical: sizes.topBarPaddingVertical,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
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
                color: Colors.black,
                fontSize: sizes.shortsBadgeFontSize,
                fontWeight: FontWeight.w800,
                letterSpacing: sizes.shortsBadgeLetterSpacing,
              ),
            ),
          ),
          const Spacer(),
          Obx(
            () => Text(
              '${controller.currentIndex.value + 1} / ${controller.shorts.length}',
              style: TextStyle(
                color: Colors.white60,
                fontSize: sizes.counterFontSize,
              ),
            ),
          ),
          SizedBox(width: sizes.counterSpacing),
          TapCursor(
            onTap: controller.toggleMute,
            child: Container(
              width: sizes.muteButtonSize,
              height: sizes.muteButtonSize,
              decoration: const BoxDecoration(
                color: Colors.white12,
                shape: BoxShape.circle,
              ),
              child: Obx(
                () => Icon(
                  controller.isMuted.value
                      ? Icons.volume_off_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: sizes.muteIconSize,
                ),
              ),
            ),
          ),
          SizedBox(width: sizes.topBarPaddingHorizontal),
        ],
      ),
    );
  }

  Widget _buildVideoCard(ShortsPlayerSizes sizes, ShortsModel short) {
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
                  CachedNetworkImage(
                    imageUrl: short.bestThumbnail,
                    fit: BoxFit.cover,
                  ),
                  Obx(() {
                    final yt = controller.ytController;
                    if (yt == null) return const SizedBox.shrink();
                    return IgnorePointer(
                      child: YoutubePlayer(
                        key: ValueKey(controller.playerKey.value),
                        controller: yt,
                        gestureRecognizers:
                            const <Factory<OneSequenceGestureRecognizer>>{},
                        // Shorts dikey: tam ekranda da 9:16 oranıyla ekranı kaplar.
                        aspectRatio: 9 / 16,
                        autoFullScreen: false,
                        controlsBuilder: (context, isFullscreen) =>
                            ShortsFullscreen.controls(yt, isFullscreen),
                      ),
                    );
                  }),
                  Positioned.fill(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.togglePlayPause,
                    ),
                  ),
                  Obx(
                    () => AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: controller.isPaused.value ? 1 : 0,
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: sizes.playIconSize,
                        ),
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
      valueListenable: controller.progressNotifier,
      builder: (context, progress, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(sizes.progressBarRadius),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryColor,
              ),
              minHeight: sizes.progressBarHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(ShortsPlayerSizes sizes, ShortsModel short) {
    return Obx(
      () => ShortsPlayerActionBar(
        sizes: sizes,
        isLiked: _likedIds.contains(short.videoId),
        isSaved: _savedIds.contains(short.videoId),
        isMuted: controller.isMuted.value,
        onLike: () => _toggleLike(short.videoId),
        onSave: () => _toggleSave(short.videoId),
        onShare: () => ShareHelper.shareVideo(
          videoId: short.videoId,
          title: short.title,
          universityName: short.universityName,
          thumbnailUrl: short.bestThumbnail,
        ),
        onToggleMute: controller.toggleMute,
      ),
    );
  }

  Widget _buildInfoCard(ShortsPlayerSizes sizes, ShortsModel short) {
    return ShortsPlayerInfoCard(
      sizes: sizes,
      universityName: short.universityName,
      logoUrl: short.logoUrl,
      description: short.description,
      isFollowing: _followedUniversityIds.contains(short.universityId),
      onToggleFollow: () => _toggleFollow(short.universityId),
      onWatchFull: () =>
          Get.toNamed(AppRoutes.player, parameters: {'videoId': short.videoId}),
    );
  }
}
