// lib/data/repositories/university_stats_repository.dart

import 'dart:developer';

import 'package:hive_ce/hive.dart';

import '../datasources/local/app_cache_box.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/university_stats_model.dart';

/// TTL: 30 dakika.
/// Tek RPC çağrısı (get_home_university_stats) — artık university_leaderboard_mat
/// materialized view üzerinden çalışıyor; okümaları bloklamaz, pg_cron ile saatlik yenilenir.
/// 'newly_discovered' eşiği dinamik (%20 yüzdelik dilimi) — hardcoded 50 yok.
/// Bireysel getList() metodları offline fallback veya nadir kullanımlar için korundu.
class UniversityStatsRepository {
  final SupabaseDataSource _supabase;

  static const _ttlMinutes = 30;
  static const _bundleCacheKey = 'uni_stats_bundle';
  static const _bundleTimeKey = 'uni_stats_bundle_time';

  UniversityStatsRepository({required SupabaseDataSource supabase})
    : _supabase = supabase;

  Box get _box => AppCacheBox.instance;

  Map<String, dynamic> _asMap(dynamic v) =>
      Map<String, dynamic>.from(v as Map);

  // ─── Bundle Cache ────────────────────────────────────────────────────────

  Future<bool> _isBundleCacheValid() async {
    try {
      final cacheTime = _box.get(_bundleTimeKey) as DateTime?;
      if (cacheTime == null) return false;
      return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
          _ttlMinutes;
    } catch (e, stacktrace) {
      log(
        'Bundle cache geçerlilik kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }

  Future<Map<String, dynamic>?> _getBundleFromCache() async {
    try {
      final raw = _box.get(_bundleCacheKey);
      if (raw == null) return null;
      return _asMap(raw);
    } catch (e, stacktrace) {
      log(
        'Bundle cache\'den veri okunurken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  Future<void> _saveBundleToCache(Map<String, dynamic> data) async {
    try {
      await _box.put(_bundleCacheKey, data);
      await _box.put(_bundleTimeKey, DateTime.now().toUtc());
    } catch (e, stacktrace) {
      log(
        'Bundle cache\'e veri yazılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  List<UniversityStatsModel> _parseList(dynamic raw) {
    if (raw == null) return [];
    try {
      return (raw as List)
          .map(
            (e) => UniversityStatsModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (e, stacktrace) {
      log(
        'Üniversite istatistik listesi parse edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  // ─── Ana Bundle Metodu ───────────────────────────────────────────────────

  /// Tüm 8 listeyi tek RPC çağrısıyla çeker.
  /// Cache geçerliyse Supabase'e gitmez.
  Future<Map<String, List<UniversityStatsModel>>> getAllStats() async {
    // 1. Cache kontrolü
    try {
      if (await _isBundleCacheValid()) {
        final cached = await _getBundleFromCache();
        if (cached != null) {
          return _bundleToMap(cached);
        }
      }
    } catch (e, stacktrace) {
      log(
        'Bundle cache kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    // 2. RPC ile tek çağrı
    try {
      final data = await _supabase.getHomeUniversityStats();
      if (data != null) {
        await _saveBundleToCache(data);
        return _bundleToMap(data);
      }
    } catch (e, stacktrace) {
      log(
        'Üniversite istatistikleri RPC ile getirilirken hata oluştu: $e → stale cache deneniyor',
        error: e,
        stackTrace: stacktrace,
      );
    }

    // 3. Stale cache fallback
    try {
      final stale = await _getBundleFromCache();
      if (stale != null) {
        return _bundleToMap(stale);
      }
    } catch (e, stacktrace) {
      log(
        'Stale cache okunurken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    log('Üniversite istatistikleri için cache bulunamadı → boş map dönülüyor');
    return _emptyBundle();
  }

  Map<String, List<UniversityStatsModel>> _bundleToMap(
    Map<String, dynamic> data,
  ) {
    try {
      return {
        'most_watched': _parseList(data['most_watched']),
        'most_liked': _parseList(data['most_liked']),
        'popular_in_app': _parseList(data['popular_in_app']),
        'most_favorited': _parseList(data['most_favorited']),
        'most_active_last_30': _parseList(data['most_active_last_30']),
        'biggest_channels': _parseList(data['biggest_channels']),
        'richest_archive': _parseList(data['richest_archive']),
        'newly_discovered': _parseList(data['newly_discovered']),
      };
    } catch (e, stacktrace) {
      log(
        'Bundle verisi dönüştürülürken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return _emptyBundle();
    }
  }

  Map<String, List<UniversityStatsModel>> _emptyBundle() => {
    'most_watched': [],
    'most_liked': [],
    'popular_in_app': [],
    'most_favorited': [],
    'most_active_last_30': [],
    'biggest_channels': [],
    'richest_archive': [],
    'newly_discovered': [],
  };

  // ─── Bireysel metodlar (geriye dönük uyumluluk / nadir kullanım) ─────────

  String _cacheKey(String orderBy, {String? filterColumn}) =>
      'uni_stats_${orderBy}_${filterColumn ?? 'nofilter'}';

  String _cacheTimeKey(String orderBy, {String? filterColumn}) =>
      'uni_stats_time_${orderBy}_${filterColumn ?? 'nofilter'}';

  Future<bool> _isCacheValid(String orderBy, {String? filterColumn}) async {
    try {
      final cacheTime =
          _box.get(_cacheTimeKey(orderBy, filterColumn: filterColumn))
              as DateTime?;
      if (cacheTime == null) return false;
      return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
          _ttlMinutes;
    } catch (e, stacktrace) {
      log(
        'Cache geçerlilik kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return false;
    }
  }

  Future<List<UniversityStatsModel>?> _getFromCache(
    String orderBy, {
    String? filterColumn,
  }) async {
    try {
      final raw =
          _box.get(_cacheKey(orderBy, filterColumn: filterColumn)) as List?;
      if (raw == null) return null;
      return raw.map((e) => UniversityStatsModel.fromMap(_asMap(e))).toList();
    } catch (e, stacktrace) {
      log(
        'Cache\'den veri okunurken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  Future<void> _saveToCache(
    String orderBy,
    List<UniversityStatsModel> data, {
    String? filterColumn,
  }) async {
    try {
      await _box.put(
        _cacheKey(orderBy, filterColumn: filterColumn),
        data.map((e) => e.toMap()).toList(),
      );
      await _box.put(
        _cacheTimeKey(orderBy, filterColumn: filterColumn),
        DateTime.now().toUtc(),
      );
    } catch (e, stacktrace) {
      log(
        'Cache\'e veri yazılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  Future<List<UniversityStatsModel>> getList({
    required String orderBy,
    int limit = 10,
    String? filterColumn,
    String? filterOperator,
    dynamic filterValue,
  }) async {
    try {
      if (await _isCacheValid(orderBy, filterColumn: filterColumn)) {
        final cached = await _getFromCache(orderBy, filterColumn: filterColumn);
        if (cached != null && cached.isNotEmpty) return cached;
      }
    } catch (e, stacktrace) {
      log(
        'Cache kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    try {
      final data = await _supabase.getUniversityStatsList(
        orderBy: orderBy,
        limit: limit,
        filterColumn: filterColumn,
        filterOperator: filterOperator,
        filterValue: filterValue,
      );
      await _saveToCache(orderBy, data, filterColumn: filterColumn);
      return data;
    } catch (e, stacktrace) {
      log(
        'Üniversite istatistik listesi getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      final stale = await _getFromCache(orderBy, filterColumn: filterColumn);
      return stale ?? [];
    }
  }

  Future<List<UniversityStatsModel>> getMostWatched() =>
      getList(orderBy: 'total_yt_views');

  Future<List<UniversityStatsModel>> getMostLiked() =>
      getList(orderBy: 'total_yt_likes');

  Future<List<UniversityStatsModel>> getPopularInApp() =>
      getList(orderBy: 'app_total_views');

  Future<List<UniversityStatsModel>> getMostFavorited() =>
      getList(orderBy: 'app_total_favorites');

  Future<List<UniversityStatsModel>> getMostActiveLast30Days() =>
      getList(orderBy: 'videos_last_30_days');

  Future<List<UniversityStatsModel>> getBiggestChannels() =>
      getList(orderBy: 'subscriber_count');

  Future<List<UniversityStatsModel>> getRichestArchive() =>
      getList(orderBy: 'total_duration_sec');

  Future<List<UniversityStatsModel>> getNewlyDiscovered() => getList(
    orderBy: 'app_total_viewers',
    filterColumn: 'app_total_views',
    filterOperator: 'lt',
    filterValue: 50,
  );
}