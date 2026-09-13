// lib/presentation/controllers/player/watch_progress_tracker.dart
import 'dart:async';
import 'dart:developer';

import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../data/models/video_model.dart';
import '../../../data/repositories/watch_progress_repository.dart';

/// Player açıkken "İzlemeye Devam Et" mantığını kapsar:
///   • Açılışta kaydedilmiş konumdan devam ettirir
///   • Periyodik olarak konum/süre kaydeder
///   • Ekrandan çıkarken son konumu kaydeder
///
/// PlayerController bu sınıfı içinde barındırır; controller'lar arası
/// koordinasyon gerektirmez. Test edilebilir: youtubeController ve video
/// getter fonksiyonları enjekte edilir.
class WatchProgressTracker {
  WatchProgressTracker({
    required this.repository,
    required this.getController,
    required this.getVideo,
  });

  final WatchProgressRepository repository;
  final YoutubePlayerController? Function() getController;
  final VideoModel? Function() getVideo;

  Timer? _timer;
  int _lastPositionSeconds = 0;
  int _lastDurationSeconds = 0;
  bool _firstSaveDone = false;
  DateTime? _lastPersistAt;

  static const _persistInterval = Duration(seconds: 3);

  /// İlk kayıt için gereken minimum izleme süresi. Kullanıcı oynat tuşuna
  /// basmadan anlık girip çıkarsa "İzlemeye Devam Et" listesine düşmesin.
  static const _minSecondsForFirstSave = 5;

  /// Video açıldığında, daha önce kaydedilmiş konumdan devam ettirir.
  Future<void> restore() async {
    try {
      final controller = getController();
      final video = getVideo();
      if (video == null || controller == null) return;
      if (video.isLiveBroadcast) return;

      final saved = await repository.getProgress(video.videoId);
      if (saved == null) return;
      if (saved.isNearlyFinished) return;
      if (saved.positionSeconds < 2) return;

      final ready = await _waitUntilReady(controller);
      if (!ready) return;

      await controller.seekTo(
        seconds: saved.positionSeconds.toDouble(),
        allowSeekAhead: true,
      );

      _lastPositionSeconds = saved.positionSeconds;
      _lastDurationSeconds = saved.durationSeconds;
    } catch (e, st) {
      log('Kaydedilen ilerleme geri yüklenirken hata: $e',
          error: e, stackTrace: st);
    }
  }

  /// Periyodik kayıt döngüsünü başlatır (1 sn tick).
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Kayıt döngüsünü durdurur. `persistOnClose` bunu zaten çağırır.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Kullanıcı ekrandan çıkarken (onClose) çağrılır. Timer'ı durdurur ve
  /// bilinen son konumu ateşle-unut şeklinde kaydeder. Eğer ilk kayıt
  /// eşiğine hiç ulaşılmadıysa YENİ kayıt oluşturmaz.
  void persistOnClose() {
    stop();
    final video = getVideo();
    final shouldPersist =
        _firstSaveDone || _lastPositionSeconds >= _minSecondsForFirstSave;
    if (video == null || _lastDurationSeconds <= 0 || !shouldPersist) return;

    // onClose senkron olduğundan await edilemez; repository çağrısı Hive'a
    // yazmayı hemen kuyruğa alır, youtubeController.close() ile yarışmaz.
    unawaited(
      repository.saveProgress(
        video: video,
        positionSeconds: _lastPositionSeconds,
        durationSeconds: _lastDurationSeconds,
      ),
    );
  }

  // ─── İç ────────────────────────────────────────────────────────────────

  Future<void> _tick() async {
    final controller = getController();
    final video = getVideo();
    if (controller == null || video == null) return;
    if (video.isLiveBroadcast) return;

    try {
      final dur = await controller.duration;
      final cur = await controller.currentTime;
      if (dur <= 0) return;

      _lastPositionSeconds = cur.round();
      _lastDurationSeconds = dur.round();

      final now = DateTime.now();
      final isFirstSave =
          !_firstSaveDone && _lastPositionSeconds >= _minSecondsForFirstSave;
      final intervalPassed =
          _lastPersistAt == null ||
          now.difference(_lastPersistAt!) >= _persistInterval;

      if (isFirstSave || (intervalPassed && _firstSaveDone)) {
        await _persist();
        _firstSaveDone = true;
        _lastPersistAt = now;
      }
    } catch (_) {
      // Player henüz hazır değil — bir sonraki tick'te tekrar dene.
    }
  }

  Future<void> _persist() async {
    final video = getVideo();
    if (video == null || _lastDurationSeconds <= 0) return;
    await repository.saveProgress(
      video: video,
      positionSeconds: _lastPositionSeconds,
      durationSeconds: _lastDurationSeconds,
    );
  }

  /// YouTube iframe'inin gerçekten hazır olmasını bekler (en fazla ~6 sn).
  Future<bool> _waitUntilReady(YoutubePlayerController controller) async {
    for (var i = 0; i < 24; i++) {
      try {
        final dur = await controller.duration;
        if (dur > 0) return true;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }
}