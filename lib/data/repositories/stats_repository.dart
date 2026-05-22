import 'dart:developer';
import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/user_stats_model.dart';

class StatsRepository {
  final SupabaseDataSource supabaseDataSource;
  final LocalDataSource localDataSource;

  StatsRepository({
    required this.supabaseDataSource,
    required this.localDataSource,
  });

  /// Önce local cache'e bakar (1 saatlik TTL).
  /// Cache yoksa/dolmuşsa Supabase'den çeker ve cache'e yazar.
  Future<UserStatsModel?> getUserStats({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cached = await localDataSource.getCachedUserStats();
        if (cached != null) {
          log('📊💾 [Stats] Kullanıcı istatistikleri LOCAL cache\'den geldi');
          return cached;
        }
        log('📊⏳ [Stats] Local cache boş veya süresi dolmuş');
      } catch (e) {
        log('📊❌ [Stats] Cache okuma hatası: $e');
      }
    }

    try {
      log('📊☁️ [Stats] Kullanıcı istatistikleri Supabase\'den çekiliyor...');
      final data = await supabaseDataSource.getMyStats();
      if (data == null) {
        log('📊⚠️ [Stats] Supabase\'den veri gelmedi');
        return null;
      }
      final stats = UserStatsModel.fromMap(data);
      await localDataSource.cacheUserStats(stats);
      log('📊✅ [Stats] İstatistikler geldi ve cache\'e yazıldı (remote)');
      return stats;
    } catch (e) {
      log('📊❌ [Stats] Remote hata: $e → stale cache deneniyor');
      final stale = await localDataSource.getCachedUserStats();
      log(stale != null ? '📊💾 [Stats] Stale cache döndürüldü' : '📊❌ [Stats] Stale cache de yok');
      return stale;
    }
  }

  Future<void> clearCache() => localDataSource.clearUserStats();
}