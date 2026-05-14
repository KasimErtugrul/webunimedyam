import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

class SearchRepository {
  final SupabaseDataSource _supabase;

  SearchRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  Future<List<VideoModel>> searchVideos(String query, {int limit = 30}) async {
    return await _supabase.searchVideos(query, limit: limit);
  }
}
