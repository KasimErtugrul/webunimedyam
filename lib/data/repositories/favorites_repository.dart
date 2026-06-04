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
  })  : _supabase = supabase,
        _local = local;

  // ─── OKUMA ───────────────────────────────────────────────────────────────

  /// Mevcut kullanıcının kendi favorilerini döner (local-first).
  Future<List<VideoModel>> getFavoriteVideos() async {
    try {
      log('❤️💾 [Favori] Favori videolar LOCAL\'den okunuyor...');
      final videos = await _local.getFavoriteVideos();
      log('❤️✅ [Favori] ${videos.length} favori video bulundu (local)');
      return videos;
    } catch (e) {
      log('❤️❌ [Favori] Local favoriler okunamadı: $e');
      return [];
    }
  }

  /// Belirli bir kullanıcının favori videolarını döner.
  /// - Kendi userId'si → local-first
  /// - Başka userId  → doğrudan Supabase (local cache bypass)
  Future<List<VideoModel>> getUserFavoriteVideos(String userId) async {
    final currentUserId = _supabase.currentUser?.id;

    if (currentUserId == userId) {
      return _getSelfFavoriteVideos(userId);
    } else {
      return _getOtherUserFavoriteVideos(userId);
    }
  }

  Future<List<VideoModel>> _getSelfFavoriteVideos(String userId) async {
    try {
      final localFavorites = await _local.getFavoriteVideos();
      if (localFavorites.isNotEmpty) {
        log('❤️💾 [Favori] Kendi favorileri LOCAL\'den geldi');
        return localFavorites;
      }
      log('❤️☁️ [Favori] Local boş, Supabase\'den çekiliyor → $userId');
      final remoteFavorites = await _supabase.getUserFavoriteVideos(userId);
      for (var video in remoteFavorites) {
        await _local.saveFavoriteVideo(video);
      }
      log('❤️💾 [Favori] ${remoteFavorites.length} favori local\'e yazıldı');
      return remoteFavorites;
    } catch (e) {
      log('❤️❌ [Favori] Kendi favorileri yüklenemedi: $e');
      return [];
    }
  }

  Future<List<VideoModel>> _getOtherUserFavoriteVideos(String userId) async {
    try {
      // RLS izin vermiyorsa Supabase zaten boş döndürür
      log('❤️☁️ [Favori] Başka kullanıcı favorileri Supabase\'den → $userId');
      final videos = await _supabase.getUserFavoriteVideos(userId);
      log('❤️✅ [Favori] ${videos.length} favori video: $userId');
      return videos;
    } catch (e) {
      log('❤️❌ [Favori] Başka kullanıcı favorileri yüklenemedi ($userId): $e');
      return [];
    }
  }

  Future<List<String>> getFavoriteVideoIds(String userId) async {
    try {
      final localVideos = await _local.getFavoriteVideos();
      if (localVideos.isNotEmpty) {
        log('❤️💾 [Favori] ID\'ler LOCAL\'den geldi (${localVideos.length} adet)');
        return localVideos.map((v) => v.videoId).toList();
      }
      log('❤️☁️ [Favori] Favori ID\'leri Supabase\'den çekiliyor → $userId');
      final ids = await _supabase.getFavoriteVideoIds(userId);
      log('❤️✅ [Favori] ${ids.length} favori ID geldi (remote)');
      return ids;
    } catch (e) {
      log('❤️❌ [Favori] Favori ID\'leri çekilemedi: $e');
      return [];
    }
  }

  // ─── YAZMA ───────────────────────────────────────────────────────────────

  Future<void> saveFavoriteVideoLocally(VideoModel video) async {
    log('❤️💾➕ [Favori] Video local\'e kaydediliyor → ${video.videoId}');
    await _local.saveFavoriteVideo(video);
    _favoriteChangeController.add(
      FavoriteChange(videoId: video.videoId, isFavorite: true, video: video),
    );
  }

  Future<void> removeFavoriteVideoLocally(String videoId) async {
    log('❤️💾🗑️ [Favori] Video local\'den siliniyor → $videoId');
    await _local.removeFavoriteVideo(videoId);
    _favoriteChangeController.add(
      FavoriteChange(videoId: videoId, isFavorite: false),
    );
  }

  Future<void> clearLocalFavorites() async {
    log('❤️🧹 [Favori] Tüm local favoriler temizleniyor');
    await _local.clearFavoriteVideos();
  }

  Future<void> addFavorite(String userId, String videoId) async {
    log('❤️☁️➕ [Favori] Favori Supabase\'e ekleniyor → $videoId');
    await _supabase.addFavorite(userId, videoId);
    log('❤️✅ [Favori] Favori eklendi (remote)');
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    log('❤️☁️🗑️ [Favori] Favori Supabase\'den siliniyor → $videoId');
    await _supabase.removeFavorite(userId, videoId);
    log('❤️✅ [Favori] Favori silindi (remote)');
  }

  @override
  void onClose() {
    _favoriteChangeController.close();
    super.onClose();
  }
}