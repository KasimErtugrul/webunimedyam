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
        if (cached != null) return cached;
      } catch (e) {
        log('[StatsRepository] cache read error: $e');
      }
    }

    try {
      final data = await supabaseDataSource.getMyStats();
      if (data == null) return null;
      final stats = UserStatsModel.fromMap(data);
      await localDataSource.cacheUserStats(stats);
      return stats;
    } catch (e) {
      log('[StatsRepository] remote fetch error: $e');
      // Network hatası → stale cache'i dön (varsa)
      return localDataSource.getCachedUserStats();
    }
  }

  Future<void> clearCache() => localDataSource.clearUserStats();
}