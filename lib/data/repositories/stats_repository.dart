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
  }) : _supabase = supabaseDataSource,
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
          return cached;
        }
      } catch (e, stacktrace) {
        log(
          'Kullanıcı istatistikleri cache\'den okunurken hata oluştu: $e',
          error: e,
          stackTrace: stacktrace,
        );
      }
    }

    // 2. Cache yoksa veya forceRefresh ise Supabase'den çek
    try {
      final data = await _supabase.getMyStats();
      if (data == null) {
        return null;
      }
      final stats = UserStatsModel.fromMap(data);
      await _local.cacheUserStats(stats);
      return stats;
    } catch (e, stacktrace) {
      // 3. Ağ hatası: Uygulama çökmesin, süresi geçmiş eski cache'i bile dönelim (Stale fallback)
      log(
        'Kullanıcı istatistikleri remote\'dan getirilirken hata oluştu: $e → stale cache deneniyor',
        error: e,
        stackTrace: stacktrace,
      );
      try {
        final stale = await _local.getCachedUserStats();
        return stale;
      } catch (staleError, staleStacktrace) {
        log(
          'Stale cache okunurken hata oluştu: $staleError',
          error: staleError,
          stackTrace: staleStacktrace,
        );
        return null;
      }
    }
  }

  Future<void> clearCache() async {
    try {
      await _local.clearUserStats();
    } catch (e, stacktrace) {
      log(
        'Kullanıcı istatistikleri cache\'i temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }
}
