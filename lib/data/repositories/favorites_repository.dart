import 'dart:developer';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

class FavoritesRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  FavoritesRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  })  : _supabase = supabase,
        _local = local;

  // ─── Local ────────────────────────────────────────────────────────────────

  Future<List<VideoModel>> getFavoriteVideos() async {
    log('❤️💾 [Favori] Favori videolar LOCAL\'den okunuyor...');
    final videos = await _local.getFavoriteVideos();
    log('❤️✅ [Favori] \${videos.length} favori video bulundu (local)');
    return videos;
  }

  Future<void> saveFavoriteVideoLocally(VideoModel video) async {
    log('❤️💾➕ [Favori] Video local\'e kaydediliyor → \${video.videoId}');
    await _local.saveFavoriteVideo(video);
  }

  Future<void> removeFavoriteVideoLocally(String videoId) async {
    log('❤️💾🗑️ [Favori] Video local\'den siliniyor → $videoId');
    await _local.removeFavoriteVideo(videoId);
  }

  Future<void> clearLocalFavorites() async {
    log('❤️🧹 [Favori] Tüm local favoriler temizleniyor');
    await _local.clearFavoriteVideos();
  }

  // ─── Remote (Supabase) ────────────────────────────────────────────────────

  Future<List<String>> getFavoriteVideoIds(String userId) async {
    log('❤️☁️ [Favori] Favori ID\'leri Supabase\'den çekiliyor → $userId');
    final ids = await _supabase.getFavoriteVideoIds(userId);
    log('❤️✅ [Favori] \${ids.length} favori ID geldi (remote)');
    return ids;
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
}
