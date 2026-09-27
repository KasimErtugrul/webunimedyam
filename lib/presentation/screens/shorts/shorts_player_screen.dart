// lib/presentation/screens/shorts/shorts_player_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../core/utils/share_helper.dart';
import '../../../data/models/shorts_model.dart';
import '../../controllers/shorts_player_controller.dart';
import 'shorts_player_screen_widgets/logo_wheel.dart';
import 'shorts_player_screen_widgets/text_button.dart';
import 'utils/shorts_player_sizes.dart';

class ShortsPlayerScreen extends GetView<ShortsPlayerController> {
  const ShortsPlayerScreen({super.key});

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

      // KURAL 5 — TEK DALLANMA NOKTASI
      final ShortsPlayerSizes sizes = Responsive.isTablet(context)
          ? const ShortsPlayerTabletSizes()
          : const ShortsPlayerPhoneSizes();

      final short = controller.current!;
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(sizes, short),
              SizedBox(
                height: sizes.wheelHeight,
                child: ShortsPlayerUniversityLogoWheel(
                  sizes: sizes,
                  shorts: controller.shorts,
                  activeIndex: controller.currentIndex.value,
                  onChanged: controller.onWheelChanged,
                ),
              ),
              Expanded(child: _buildVideoArea(sizes, short)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopBar(ShortsPlayerSizes sizes, ShortsModel short) {
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
          // Right-hand cluster: takes all remaining width after the back
          // button + SHORTS badge. The Paylaş button is allowed to shrink
          // (its internal label ellipsizes) so the row can never overflow.
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
                GestureDetector(
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
                Flexible(
                  child: ShortsPlayerTextButton(
                    sizes: sizes,
                    icon: Icons.share_rounded,
                    label: 'Paylaş',
                    onTap: () => ShareHelper.shareVideo(
                      videoId: short.videoId,
                      title: short.title,
                      universityName: short.universityName,
                      thumbnailUrl: short.bestThumbnail,
                    ),
                  ),
                ),
                SizedBox(width: sizes.topBarPaddingHorizontal),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(ShortsPlayerSizes sizes, ShortsModel short) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CachedNetworkImage(imageUrl: short.bestThumbnail, fit: BoxFit.cover),
        Obx(() {
          final yt = controller.ytController;
          if (yt == null) return const SizedBox.shrink();
          return IgnorePointer(
            child: YoutubePlayer(
              key: ValueKey(controller.playerKey.value),
              controller: yt,
              gestureRecognizers:
                  const <Factory<OneSequenceGestureRecognizer>>{},
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
          () => controller.isPaused.value
              ? Center(
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white.withValues(alpha: 0.85),
                    size: sizes.playIconSize,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              sizes.bottomPaddingHorizontal,
              sizes.isTablet ? 72 : 60,
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
                padding: EdgeInsets.only(bottom: sizes.bottomPaddingVertical),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (short.logoUrl != null && short.logoUrl!.isNotEmpty)
                          Container(
                            width: sizes.logoContainerSize,
                            height: sizes.logoContainerSize,
                            margin: EdgeInsets.only(right: sizes.logoSpacing),
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
                              fontSize: sizes.titleFontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.topBarPaddingVertical),
                    Text(
                      short.title,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: sizes.subtitleFontSize,
                        height: sizes.subtitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sizes.topBarPaddingVertical),
                    ValueListenableBuilder<double>(
                      valueListenable: controller.progressNotifier,
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
                    ),
                    SizedBox(height: sizes.topBarPaddingVertical),
                    Row(
                      children: [
                        Expanded(
                          child: ShortsPlayerTextButton(
                            sizes: sizes,
                            icon: Icons.play_circle_outline_rounded,
                            label: 'Tam İzle',
                            onTap: () => Get.toNamed(
                              AppRoutes.player,
                              parameters: {'videoId': short.videoId},
                            ),
                          ),
                        ),
                        SizedBox(width: sizes.textBtnSpacing),
                        Expanded(
                          child: ShortsPlayerTextButton(
                            sizes: sizes,
                            icon: Icons.share_rounded,
                            label: 'Paylaş',
                            onTap: () => ShareHelper.shareVideo(
                              videoId: short.videoId,
                              title: short.title,
                              universityName: short.universityName,
                              thumbnailUrl: short.bestThumbnail,
                            ),
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
}