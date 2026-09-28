// lib/presentation/screens/shorts/shorts_player_screen_widgets/shorts_fullscreen.dart
//
// Shorts ekranları için tam ekran butonu (youtube_player_iframe 6.x).
//
// Yalnızca paketin resmi API'leri kullanılır:
//  - YoutubePlayer.controlsBuilder → butonu player'ın üstüne çizer
//    (inline'da ve tam ekranda çağrılır).
//  - YoutubePlayerController.enterFullScreen / exitFullScreen
//
// Ekran döndürme / SystemChrome müdahalesi YOK: tam ekran, dikey (portrait)
// ekranı olduğu gibi kaplar. Oran, YoutubePlayer(aspectRatio: 9 / 16) ile verilir.
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

abstract final class ShortsFullscreen {
  /// `YoutubePlayer(controlsBuilder: ...)` için.
  static Widget controls(
    YoutubePlayerController controller,
    bool isFullscreen,
  ) {
    return _ShortsFullscreenControls(
      controller: controller,
      isFullscreen: isFullscreen,
    );
  }
}

class _ShortsFullscreenControls extends StatelessWidget {
  const _ShortsFullscreenControls({
    required this.controller,
    required this.isFullscreen,
  });

  final YoutubePlayerController controller;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: isFullscreen
            ? controller.exitFullScreen
            : controller.enterFullScreen,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            isFullscreen
                ? Icons.fullscreen_exit_rounded
                : Icons.fullscreen_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );

    if (isFullscreen) {
      return SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(padding: const EdgeInsets.all(12), child: button),
        ),
      );
    }
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(padding: const EdgeInsets.all(8), child: button),
    );
  }
}