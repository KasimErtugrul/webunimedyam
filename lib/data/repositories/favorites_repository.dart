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
    return await _local.getFavoriteVideos();
  }

  Future<void> saveFavoriteVideoLocally(VideoModel video) async {
    await _local.saveFavoriteVideo(video);
  }

  Future<void> removeFavoriteVideoLocally(String videoId) async {
    await _local.removeFavoriteVideo(videoId);
  }

  Future<void> clearLocalFavorites() async {
    await _local.clearFavoriteVideos();
  }

  // ─── Remote (Supabase) ────────────────────────────────────────────────────

  Future<List<String>> getFavoriteVideoIds(String userId) async {
    return await _supabase.getFavoriteVideoIds(userId);
  }

  Future<void> addFavorite(String userId, String videoId) async {
    await _supabase.addFavorite(userId, videoId);
  }

  Future<void> removeFavorite(String userId, String videoId) async {
    await _supabase.removeFavorite(userId, videoId);
  }
}
