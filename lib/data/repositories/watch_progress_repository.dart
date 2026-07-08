// lib/data/repositories/watch_progress_repository.dart
//
// "İzlemeye Devam Et" (Continue Watching) özelliği için repository.
// BİLİNÇLİ OLARAK Supabase'e (remote) hiç dokunmaz — tamamen LocalDataSource
// (Hive) üzerinden çalışır. Böylece izleme ilerlemesi tamamen cihazda kalır.

import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';

import '../datasources/local/local_datasource.dart';
import '../models/video_model.dart';
import '../models/watch_progress_model.dart';

/// İlerleme kaydedildiğinde/kaldırıldığında yayılan olay.
/// HomeController gibi dinleyiciler, "İzlemeye Devam Et" satırını anında
/// güncelleyebilsin diye kullanılır.
class WatchProgressChange {
  final String videoId;
  final bool removed;

  WatchProgressChange({required this.videoId, required this.removed});
}

class WatchProgressRepository extends GetxService {
  final LocalDataSource _local;

  WatchProgressRepository({required LocalDataSource local}) : _local = local;

  final _changeController = StreamController<WatchProgressChange>.broadcast();
  Stream<WatchProgressChange> get onProgressChanged =>
      _changeController.stream;

  /// Ana sayfada gösterilecek "İzlemeye Devam Et" listesi
  /// (en son izlenen en üstte).
  Future<List<WatchProgressModel>> getContinueWatching() async {
    try {
      return await _local.getWatchProgressList();
    } catch (e, stacktrace) {
      log(
        'İzleme ilerlemesi listesi getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<WatchProgressModel?> getProgress(String videoId) async {
    try {
      return await _local.getWatchProgress(videoId);
    } catch (e, stacktrace) {
      log(
        'İzleme ilerlemesi getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  /// Videonun izleme ilerlemesini kaydeder. Kullanıcı videoyu bitirmeye
  /// yakın izlediyse (isNearlyFinished), kayıt tutmak yerine kaydı siler —
  /// tamamlanan videolar "İzlemeye Devam Et" listesinde görünmemeli.
  Future<void> saveProgress({
    required VideoModel video,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    try {
      final nearlyFinished =
          durationSeconds > 0 &&
          (durationSeconds - positionSeconds <= 5 ||
              positionSeconds / durationSeconds >= 0.95);

      if (nearlyFinished) {
        await removeProgress(video.videoId);
        return;
      }

      await _local.saveWatchProgress(
        video: video,
        positionSeconds: positionSeconds,
        durationSeconds: durationSeconds,
      );
      _changeController.add(
        WatchProgressChange(videoId: video.videoId, removed: false),
      );
    } catch (e, stacktrace) {
      log(
        'İzleme ilerlemesi kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> removeProgress(String videoId) async {
    try {
      await _local.removeWatchProgress(videoId);
      _changeController.add(
        WatchProgressChange(videoId: videoId, removed: true),
      );
    } catch (e, stacktrace) {
      log(
        'İzleme ilerlemesi silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<void> clearAll() async {
    try {
      await _local.clearWatchProgress();
    } catch (e, stacktrace) {
      log(
        'İzleme ilerlemeleri temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  @override
  void onClose() {
    _changeController.close();
    super.onClose();
  }
}
