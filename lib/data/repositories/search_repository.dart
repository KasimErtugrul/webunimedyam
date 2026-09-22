import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/university_model.dart';

class SearchRepository {
  final SupabaseDataSource _supabase;

  SearchRepository({required SupabaseDataSource supabase})
    : _supabase = supabase;

  // ─── OKUMA İŞLEMLERİ (Read) ──────────────────────────────────────────────
  // İnternet yoksa veya RPC hatası alınsa bile uygulama çökmemeli.
  // Boş liste döner, UI "Sonuç bulunamadı" gösterir.

  Future<List<VideoModel>> searchVideos(String query, {int limit = 30}) async {
    try {
      final results = await _supabase.searchVideos(query, limit: limit);
      return results;
    } catch (e, stacktrace) {
      log('Arama yapılırken hata oluştu: $e', error: e, stackTrace: stacktrace);
      return []; // Hata yutma değil, offline güvenliği. UI çökmez, boş sonuç döner.
    }
  }

  /// Aramayı arka planda loglar (trend başlıklar bunun üzerine kurulu).
  /// Kasıtlı olarak exception fırlatmaz — arama akışını asla bloklamamalı.
  Future<void> logSearchQuery(String query) {
    return _supabase.logSearchQuery(query);
  }

  Future<List<Map<String, dynamic>>> getTrendingSearches({
    int daysBack = 14,
    int limit = 8,
  }) async {
    try {
      return await _supabase.getTrendingSearches(
        daysBack: daysBack,
        limit: limit,
      );
    } catch (e, stacktrace) {
      log('Trend aramalar getirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      return [];
    }
  }

  Future<List<UniversityModel>> getPopularUniversities({int limit = 6}) async {
    try {
      return await _supabase.getPopularUniversities(limit: limit);
    } catch (e, stacktrace) {
      log('Popüler üniversiteler getirilirken hata oluştu: $e', error: e, stackTrace: stacktrace);
      return [];
    }
  }
}
