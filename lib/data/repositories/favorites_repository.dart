// lib/data/repositories/favorites_repository.dart
//
// DÜZELTME: Başka kullanıcının favorileri için local cache KULLANILMAZ.
// Local cache yalnızca kendi favorileri için geçerlidir.
// Visibility kontrolü DB katmanında (RLS) yapılır — dart'ta user_settings çekilmez.

import 'dart:developer';
import 'dart:async';
import 'package:get/get.dart';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

/// Event sınıfı – favori değişikliklerini taşır
class FavoriteChange {
  final String videoId;
  final bool isFavorite;
  final VideoModel? video;

  FavoriteChange({required this.videoId, required this.isFavorite, this.video});
}

class FavoritesRepository extends GetxService {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  final _favoriteChangeController =
      StreamController<FavoriteChange>.broadcast();
  Stream<FavoriteChange> get onFavoriteChanged =>
      _favoriteChangeController.stream;

  FavoritesRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  }) : _supabase = supabase,
       _local = local;

  // ─── OKUMA ───────────────────────────────────────────────────────────────

  /// Mevcut kullanıcının kendi favorilerini döner (local-first).
  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      final videos = await _local.getFavoriteVideos();
      return videos;
    } catch (e, stacktrace) {
      log(
        'Favori videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  /// Belirli bir kullanıcının favori videolarını döner.
  /// - Kendi userId'si → Supabase (pagination için her zaman remote)
  /// - Başka userId  → doğrudan Supabase (local cache bypass)
  Future<List<VideoModel>> getUserFavoriteVideos(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Pagination gerektiğinden her zaman Supabase'e gidiyoruz
      return await _supabase.getUserFavoriteVideos(userId, limit: limit, offset: offset);
    } catch (e, stacktrace) {
      log(
        'Kullanıcı favori videoları getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<List<VideoModel>> getSelfFavoriteVideos(String userId) async {
    try {
      final localFavorites = await _local.getFavoriteVideos();
      if (localFavorites.isNotEmpty) {
        return localFavorites;
      }

      final remoteFavorites = await _supabase.getUserFavoriteVideos(userId);
      for (var video in remoteFavorites) {
        await _local.saveFavoriteVideo(video);
      }

      return remoteFavorites;
    } catch (e, stacktrace) {
      log(
        'Kendi favori videoları getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  Future<List<VideoModel>> getOtherUserFavoriteVideos(String userId) async {
    try {
      // RLS izin vermiyorsa Supabase zaten boş döndürür
      final videos = await _supabase.getUserFavoriteVideos(userId);
      return videos;
    } catch (e, stacktrace) {
      log(
        'Başka kullanıcının favori videoları getirilirken hata oluştu ($userId): $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  /// FIX: Önceki kod local'e "bakıyor" gibi görünüyordu ama aslında
  /// yanlış cache'e bakıyordu: getFavoriteVideos() sadece favoriler
  /// EKRANI için tutulan, OOM koruması amacıyla en fazla 100 kayıtla
  /// SINIRLI tam VideoModel listesiydi. Kullanıcının 100'den fazla
  /// favorisi varsa bu id listesi zaten eksikti; üstelik Supabase'e
  /// fallback yapıldığında sonuç HİÇ local'e yazılmıyordu — yani cache
  /// asla ısınmıyor, her cold start'ta favorites tablosundan TÜM
  /// satırlar (limit yok) tekrar çekiliyordu.
  ///
  /// Yeni davranış: ayrı, hafif (sadece id string'leri) ve sınırsız bir
  /// cache kullanılıyor (bkz. LocalDataSource.*FavoriteVideoIds), 30 dk
  /// TTL ile. addFavorite()/removeFavorite() bu cache'i anında
  /// mirror'lar, böylece TTL dolmadan da güncel kalır.
  Future<List<String>> getFavoriteVideoIds(String userId) async {
    try {
      if (await _local.isFavoriteIdsCacheValid()) {
        return (await _local.getCachedFavoriteVideoIds()).toList();
      }

      final ids = await _supabase.getFavoriteVideoIds(userId);
      await _local.cacheFavoriteVideoIds(ids.toSet());
      return ids;
    } catch (e, stacktrace) {
      log(
        'Favori video ID\'leri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      // Network hatasında son çare: elimizdeki (muhtemelen bayat) cache'i
      // dön — boş dönüp tüm favori ikonlarını sıfırlamaktan daha iyi.
      final stale = await _local.getCachedFavoriteVideoIds();
      return stale.toList();
    }
  }

  // ─── YAZMA ───────────────────────────────────────────────────────────────

  Future<void> saveFavoriteVideoLocally(VideoModel video) async {
    try {
      await _local.saveFavoriteVideo(video);
      _favoriteChangeController.add(
        FavoriteChange(videoId: video.videoId, isFavorite: true, video: video),
      );
    } catch (e, stacktrace) {
      log(
        'Favori video yerel olarak kaydedilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> removeFavoriteVideoLocally(String videoId) async {
    try {
      await _local.removeFavoriteVideo(videoId);
      _favoriteChangeController.add(
        FavoriteChange(videoId: videoId, isFavorite: false),
      );
    } catch (e, stacktrace) {
      log(
        'Favori video yerel olarak silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> clearLocalFavorites() async {
    try {
      await _local.clearFavoriteVideos();
    } catch (e, stacktrace) {
      log(
        'Yerel favoriler temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> addFavorite(String userId, String videoId) async {
    try {
      await _supabase.addFavorite(userId, videoId);
      // GÜNCELLEME: totalFavorited'i doğrudan yerelde de +1 yapıyoruz.
      await _local.recordLocalFavoriteChange(added: true);
      // FIX: favorite_video_ids cache'ini de mirror'la.
      await _local.addLocalFavoriteId(videoId);
    } catch (e, stacktrace) {
      log(
        'Favori eklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    try {
      await _supabase.removeFavorite(userId, videoId);
      await _local.recordLocalFavoriteChange(added: false);
      await _local.removeLocalFavoriteId(videoId);
    } catch (e, stacktrace) {
      log(
        'Favori silinirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  @override
  void onClose() {
    _favoriteChangeController.close();
    super.onClose();
  }
}