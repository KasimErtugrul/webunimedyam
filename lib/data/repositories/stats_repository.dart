import 'dart:developer';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/user_stats_model.dart';

class StatsRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  StatsRepository({
    required SupabaseDataSource supabaseDataSource,
    required LocalDataSource localDataSource,
  })  : _supabase = supabaseDataSource,
        _local = localDataSource;

  /// Önce local cache'e bakar (1 saatlik TTL).
  /// Cache yoksa/dolmuşsa Supabase'den çeker ve cache'e yazar.
  /// Ağ hatası olursa, süresi dolmuş olsa bile eski (stale) cache'i dönmeye çalışır.
  Future<UserStatsModel?> getUserStats({bool forceRefresh = false}) async {
    // 1. Force refresh değilse ve cache'de varsa (TTL dahilinde) direkt dön
    if (!forceRefresh) {
      try {
        final cached = await _local.getCachedUserStats();
        if (cached != null) {
          log('📊💾 [Stats] Kullanıcı istatistikleri LOCAL cache\'den geldi');
          return cached;
        }
        log('📊⏳ [Stats] Local cache boş veya süresi dolmuş');
      } catch (e) {
        log('📊❌ [Stats] Cache okuma hatası: $e');
      }
    }

    // 2. Cache yoksa veya forceRefresh ise Supabase'den çek
    try {
      log('📊☁️ [Stats] Kullanıcı istatistikleri Supabase\'den çekiliyor...');
      final data = await _supabase.getMyStats();
      if (data == null) {
        log('📊⚠️ [Stats] Supabase\'den veri gelmedi');
        return null;
      }
      final stats = UserStatsModel.fromMap(data);
      await _local.cacheUserStats(stats);
      log('📊✅ [Stats] İstatistikler geldi ve cache\'e yazıldı (remote)');
      return stats;
    } catch (e) {
      // 3. Ağ hatası: Uygulama çökmesin, süresi geçmiş eski cache'i bile dönelim (Stale fallback)
      log('📊❌ [Stats] Remote hata: $e → stale cache deneniyor');
      try {
        final stale = await _local.getCachedUserStats(); 
        log(stale != null ? '📊💾 [Stats] Stale cache döndürüldü' : '📊❌ [Stats] Stale cache de yok');
        return stale;
      } catch (staleError) {
        log('📊❌ [Stats] Stale cache okunurken hata: $staleError');
        return null;
      }
    }
  }

  Future<void> clearCache() => _local.clearUserStats();
}