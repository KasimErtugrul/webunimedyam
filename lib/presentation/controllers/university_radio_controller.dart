/* import 'dart:async';

import 'package:get/get.dart';
import 'package:radio_player/radio_player.dart';

class UniversityRadioController extends GetxController {
  final Rx<PlaybackState> playbackState = PlaybackState.unknown.obs;
  final Rx<Metadata?> metadata = Rx<Metadata?>(null);
  final Rx<String?> currentPlayingUrl = Rx<String?>(null);
  final Rx<String?> currentPlayingName = Rx<String?>(null);
  final Rx<String?> currentPlayingLogo = Rx<String?>(null);

  StreamSubscription? _playbackStateSub;
  StreamSubscription? _metadataSub;

  @override
  void onInit() {
    super.onInit();
    _playbackStateSub = RadioPlayer.playbackStateStream.listen((state) {
      playbackState.value = state;
    });
    _metadataSub = RadioPlayer.metadataStream.listen((meta) {
      metadata.value = meta;
    });
  }

  void togglePlayPause({
    required String url,
    required String name,
    String? logoUrl,
  }) {
    if (currentPlayingUrl.value == url) {
      if (playbackState.value == PlaybackState.playing) {
        RadioPlayer.pause();
      } else {
        RadioPlayer.play();
      }
    } else {
      currentPlayingUrl.value = url;
      currentPlayingName.value = name;
      currentPlayingLogo.value = logoUrl;
      metadata.value = null;
      RadioPlayer.setStation(
        title: name,
        url: url,
        logoNetworkUrl: logoUrl,
        parseStreamMetadata: true,
      );
      RadioPlayer.play();
    }
  }

  void stopRadio() {
    RadioPlayer.reset();
    currentPlayingUrl.value = null;
    currentPlayingName.value = null;
    currentPlayingLogo.value = null;
    metadata.value = null;
    playbackState.value = PlaybackState.unknown;
  }

  bool get isPlaying => playbackState.value == PlaybackState.playing;
  bool get isBuffering => playbackState.value == PlaybackState.buffering;
  bool get isRadioActive => currentPlayingUrl.value != null;

  @override
  void onClose() {
    _playbackStateSub?.cancel();
    _metadataSub?.cancel();
    super.onClose();
  }
} */
