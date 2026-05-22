import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

class SearchRepository {
  final SupabaseDataSource _supabase;

  SearchRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  Future<List<VideoModel>> searchVideos(String query, {int limit = 30}) async {
    log('🔍☁️ [Arama] Supabase\'de aranıyor → "$query" (limit: $limit)');
    final results = await _supabase.searchVideos(query, limit: limit);
    log('🔍✅ [Arama] \${results.length} sonuç bulundu → "$query"');
    return results;
  }
}
