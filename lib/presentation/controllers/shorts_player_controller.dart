// lib/presentation/controllers/shorts_player_controller.dart
//
// Shorts Player ekranının ayrı controller'ı.
// Navigasyon artık dikey PageView/swipe DEĞİL — ana sayfa appbar'ındaki
// "wheel" (ListWheelScrollView tabanlı, döner logo seçici) sistemiyle aynı
// mantık: üstte üniversite logolarından oluşan bir teker, kullanıcı tekeri
// çevirdikçe (onWheelChanged) o üniversitenin shorts'u aşağıda oynar.

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../data/models/shorts_model.dart';

class ShortsPlayerController extends GetxController {
  // ─── State ─────────────────────────────────────────────────────────────
  late List<ShortsModel> shorts;

  final currentIndex = 0.obs;
  final isMuted = false.obs;
  final isPaused = false.obs;

  /// YoutubePlayer widget'ını her video değişiminde tazelemek için.
  final playerKey = 0.obs;

  YoutubePlayerController? ytController;
  Timer? _progressTimer;

  /// İlerleme çubuğu 500ms'de bir güncellenir — bunun için tüm ekranı
  /// yeniden çizdirecek bir Rx yerine hafif bir ValueNotifier kullanılır.
  final progressNotifier = ValueNotifier<double>(0.0);

  ShortsModel? get current =>
      (shorts.isEmpty || currentIndex.value >= shorts.length)
      ? null
      : shorts[currentIndex.value];

  // ─── Lifecycle ────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>;
    shorts = List<ShortsModel>.from(args['shorts'] as List);
    final initial = (args['initialIndex'] as int?) ?? 0;
    currentIndex.value = shorts.isEmpty
        ? 0
        : initial.clamp(0, shorts.length - 1);

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    if (shorts.isNotEmpty) {
      _initPlayer(currentIndex.value);
    }
  }

  @override
  void onClose() {
    _progressTimer?.cancel();
    ytController?.close();
    progressNotifier.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.onClose();
  }

  // ─── Wheel navigasyonu ────────────────────────────────────────────────

  /// Wheel'de tekerlek dönüp yeni bir üniversite logosu ortaya geldiğinde
  /// (kullanıcı sürükleyerek ya da bir logoya dokunarak) çağrılır.
  void onWheelChanged(int index) {
    if (index < 0 || index >= shorts.length) return;
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    _initPlayer(index);
  }

  void _initPlayer(int index) {
    _progressTimer?.cancel();
    ytController?.close();

    progressNotifier.value = 0.0;
    isPaused.value = false;

    ytController = YoutubePlayerController.fromVideoId(
      videoId: shorts[index].videoId,
      autoPlay: true,
      params: YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        mute: isMuted.value,
        loop: false,
        enableCaption: false,
        playsInline: true,
        strictRelatedVideos: true,
      ),
    );

    // Obx bu değeri dinliyor; ytController plain bir alan olduğu için
    // reaktif değil — playerKey ARTIŞI, yeni ytController atandıktan
    // SONRA yapılır ki Obx yeniden çizildiğinde güncel controller'ı görsün.
    playerKey.value++;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      if (ytController == null) return;
      try {
        final dur = await ytController!.duration;
        final cur = await ytController!.currentTime;
        if (dur > 0) {
          final p = (cur / dur).clamp(0.0, 1.0);
          progressNotifier.value = p;
          // Video bitince otomatik olarak bir sonraki üniversiteye geç —
          // wheel de bu değişikliği (didUpdateWidget üzerinden) görüp
          // kendini otomatik döndürür.
          if (p >= 0.99 && currentIndex.value < shorts.length - 1) {
            onWheelChanged(currentIndex.value + 1);
          }
        }
      } catch (e, stacktrace) {
        log(
          'Shorts player ilerleme okunurken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
      }
    });
  }

  // ─── Kontroller ───────────────────────────────────────────────────────

  Future<void> togglePlayPause() async {
    if (ytController == null) return;
    if (isPaused.value) {
      await ytController!.playVideo();
    } else {
      await ytController!.pauseVideo();
    }
    isPaused.value = !isPaused.value;
  }

  Future<void> toggleMute() async {
    if (ytController == null) return;
    if (isMuted.value) {
      await ytController!.unMute();
    } else {
      await ytController!.mute();
    }
    isMuted.value = !isMuted.value;
  }
}
