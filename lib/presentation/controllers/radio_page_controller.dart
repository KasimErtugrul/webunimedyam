import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

import '../../data/models/university_model.dart';
import '../../data/repositories/video_repository.dart';
import '../../services/analytics_service.dart';

class RadioPageController extends GetxController {
  final VideoRepository videoRepository;

  RadioPageController({required this.videoRepository});

  final universities = <UniversityModel>[].obs;
  final isLoading = true.obs;

  final Rx<PlaybackState> playbackState = PlaybackState.unknown.obs;
  final Rx<Metadata?> metadata = Rx<Metadata?>(null);
  final Rx<String?> currentUrl = Rx<String?>(null);

  StreamSubscription? _stateSub;
  StreamSubscription? _metaSub;
  StreamSubscription? _remoteCommandSub;

  PageController? pageController;
  int currentIndex = 0;

  @override
  void onInit() {
    super.onInit();
    _stateSub = RadioPlayer.playbackStateStream.listen((s) {
      playbackState.value = s;
    });
    _metaSub = RadioPlayer.metadataStream.listen((m) {
      metadata.value = m;
    });
    _setupRemoteControls();
    _loadRadios();
  }

  Future<void> _loadRadios() async {
    try {
      final all = await videoRepository.getUniversities();
      universities.value = all
          .where((u) => u.radioLink != null && u.radioLink!.isNotEmpty)
          .toList();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void _setupRemoteControls() {
    RadioPlayer.setNavigationControls(
      showNextButton: true,
      showPreviousButton: true,
    );
    _remoteCommandSub = RadioPlayer.remoteCommandStream.listen((command) {
      if (command == RemoteCommand.nextTrack) {
        nextStation();
      } else if (command == RemoteCommand.previousTrack) {
        previousStation();
      }
    });
  }

  void nextStation() {
    if (universities.isEmpty || pageController == null) return;
    final next = (currentIndex + 1) % universities.length;
    pageController!.animateToPage(
      next,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void previousStation() {
    if (universities.isEmpty || pageController == null) return;
    final prev = (currentIndex - 1) % universities.length;
    pageController!.animateToPage(
      prev,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void playStation(UniversityModel uni) {
    final url = uni.radioLink!;
    if (currentUrl.value == url) return;
    currentUrl.value = url;
    metadata.value = null;
    RadioPlayer.setStation(
      title: uni.name!,
      url: url,
      logoNetworkUrl: uni.logoUrl,
      parseStreamMetadata: true,
    );
    RadioPlayer.play();
    AnalyticsService.instance.logEvent(
      'radio_play',
      parameters: {
        'university_id': uni.id ?? -1,
        'university_name': uni.name ?? 'unknown',
      },
    );
  }

  /// Tüm stream'leri iptal et, radyoyu durdur ve state'i sıfırla.
  Future<void> stopEverything() async {
    await _stateSub?.cancel();
    await _metaSub?.cancel();
    await _remoteCommandSub?.cancel();
    _stateSub = null;
    _metaSub = null;
    _remoteCommandSub = null;

    try {
      await RadioPlayer.pause();
    } catch (_) {}
    try {
      RadioPlayer.reset();
    } catch (_) {}

    currentUrl.value = null;
    metadata.value = null;
    playbackState.value = PlaybackState.unknown;
  }

  @override
  void onClose() {
    // onClose senkron çalışır; fire-and-forget yeterli
    stopEverything();
    super.onClose();
  }

  
}