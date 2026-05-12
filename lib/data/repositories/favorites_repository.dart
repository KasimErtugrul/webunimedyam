import '../datasources/remote/supabase_datasource.dart';

class FavoritesRepository {
  final SupabaseDataSource _supabase;

  FavoritesRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

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