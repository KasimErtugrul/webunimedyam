import 'dart:developer';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';

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
}
