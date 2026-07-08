// lib/data/repositories/watch_progress_repository.dart
//
// Tamamen local (cihaz-içi) çalışır — Supabase'e hiçbir şey yazmaz/okumaz.
// "Yarım Bırakılan Videolar" / "İzlemeye Devam Et" özelliğinin veri katmanı.

import 'dart:developer';

import 'package:get/get.dart';

import '../datasources/local/local_datasource.dart';
import '../models/video_model.dart';
import '../models/watch_progress_model.dart';

class WatchProgressRepository extends GetxService {
  final LocalDataSource _local;

  WatchProgressRepository({required LocalDataSource local}) : _local = local;

  /// Ana sayfada gösterilecek "yarım bırakılan" videolar (en yeni önce).
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

  /// Player açılırken: bu video daha önce yarım bırakıldıysa kaldığı saniyeyi
  /// döner, aksi halde null.
  Future<int?> getResumePositionSeconds(String videoId) async {
    try {
      final entry = await _local.getWatchProgress(videoId);
      if (entry == null) return null;
      return entry.positionSeconds;
    } catch (e, stacktrace) {
      log(
        'Devam pozisyonu okunurken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  /// Oynatma sırasında periyodik olarak (ör. her 5 sn'de bir) çağrılır.
  Future<void> saveProgress({
    required VideoModel video,
    required int positionSeconds,
    required int durationSeconds,
  }) async {
    try {
      await _local.saveWatchProgress(
        video: video,
        positionSeconds: positionSeconds,
        durationSeconds: durationSeconds,
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
    } catch (e, stacktrace) {
      log(
        'İzleme ilerlemesi silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }
}
