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
      log('🔍☁️ [Arama] Supabase\'de aranıyor → "$query" (limit: $limit)');
      final results = await _supabase.searchVideos(query, limit: limit);
      log('🔍✅ [Arama] ${results.length} sonuç bulundu → "$query"');
      return results;
    } catch (e) {
      log('🔍❌ [Arama] Arama başarısız (offline veya RPC hatası?): $e');
      return []; // Hata yutma değil, offline güvenliği. UI çökmez, boş sonuç döner.
    }
  }
}