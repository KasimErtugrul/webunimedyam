// lib/data/repositories/university_stats_repository.dart

import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/remote/supabase_datasource.dart';
import '../models/university_stats_model.dart';

/// TTL: 30 dakika.
/// Tek RPC çağrısı (get_home_university_stats) — artık university_leaderboard_mat
/// materialized view üzerinden çalışıyor; okümaları bloklamaz, pg_cron ile saatlik yenilenir.
/// ‘newly_discovered’ eşiği dinamik (%20 yüzdelik dilimi) — hardcoded 50 yok.
/// Bireysel getList() metodları offline fallback veya nadir kullanımlar için korundu.
class UniversityStatsRepository {
  final SupabaseDataSource _supabase;

  static const _ttlMinutes = 30;
  static const _bundleCacheKey = 'uni_stats_bundle';
  static const _bundleTimeKey = 'uni_stats_bundle_time';

  UniversityStatsRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── Bundle Cache ────────────────────────────────────────────────────────

  Future<bool> _isBundleCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_bundleTimeKey);
    if (timeStr == null) return false;
    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return false;
    return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes < _ttlMinutes;
  }

  Future<Map<String, dynamic>?> _getBundleFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_bundleCacheKey);
    if (jsonStr == null) return null;
    try {
      return Map<String, dynamic>.from(json.decode(jsonStr) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveBundleToCache(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bundleCacheKey, json.encode(data));
    await prefs.setString(_bundleTimeKey, DateTime.now().toUtc().toIso8601String());
  }

  List<UniversityStatsModel> _parseList(dynamic raw) {
    if (raw == null) return [];
    return (raw as List)
        .map((e) => UniversityStatsModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ─── Ana Bundle Metodu ───────────────────────────────────────────────────

  /// Tüm 8 listeyi tek RPC çağrısıyla çeker.
  /// Cache geçerliyse Supabase'e gitmez.
  Future<Map<String, List<UniversityStatsModel>>> getAllStats() async {
    // 1. Cache kontrolü
    if (await _isBundleCacheValid()) {
      final cached = await _getBundleFromCache();
      if (cached != null) {
        log('🏛️💾 [UniStats] Bundle LOCAL cache\'den geldi');
        return _bundleToMap(cached);
      }
    }

    // 2. RPC ile tek çağrı
    try {
      log('🏛️☁️ [UniStats] Bundle RPC çağrısı → get_home_university_stats');
      final data = await _supabase.getHomeUniversityStats();
      if (data != null) {
        log('🏛️✅ [UniStats] Bundle geldi, cache\'e yazıldı');
        await _saveBundleToCache(data);
        return _bundleToMap(data);
      }
    } catch (e) {
      log('🏛️❌ [UniStats] RPC hatası: $e → stale cache deneniyor');
    }

    // 3. Stale cache fallback
    final stale = await _getBundleFromCache();
    if (stale != null) {
      log('🏛️💾 [UniStats] Stale bundle cache döndürüldü');
      return _bundleToMap(stale);
    }

    log('🏛️❌ [UniStats] Stale cache de yok → boş map');
    return _emptyBundle();
  }

  Map<String, List<UniversityStatsModel>> _bundleToMap(Map<String, dynamic> data) {
    return {
      'most_watched':       _parseList(data['most_watched']),
      'most_liked':         _parseList(data['most_liked']),
      'popular_in_app':     _parseList(data['popular_in_app']),
      'most_favorited':     _parseList(data['most_favorited']),
      'most_active_last_30':_parseList(data['most_active_last_30']),
      'biggest_channels':   _parseList(data['biggest_channels']),
      'richest_archive':    _parseList(data['richest_archive']),
      'newly_discovered':   _parseList(data['newly_discovered']),
    };
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
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_cacheTimeKey(orderBy, filterColumn: filterColumn));
    if (timeStr == null) return false;
    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return false;
    return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes < _ttlMinutes;
  }

  Future<List<UniversityStatsModel>?> _getFromCache(String orderBy, {String? filterColumn}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_cacheKey(orderBy, filterColumn: filterColumn));
    if (jsonStr == null) return null;
    try {
      final list = json.decode(jsonStr) as List;
      return list
          .map((e) => UniversityStatsModel.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(String orderBy, List<UniversityStatsModel> data,
      {String? filterColumn}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey(orderBy, filterColumn: filterColumn),
      json.encode(data.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      _cacheTimeKey(orderBy, filterColumn: filterColumn),
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<List<UniversityStatsModel>> getList({
    required String orderBy,
    int limit = 10,
    String? filterColumn,
    String? filterOperator,
    dynamic filterValue,
  }) async {
    if (await _isCacheValid(orderBy, filterColumn: filterColumn)) {
      final cached = await _getFromCache(orderBy, filterColumn: filterColumn);
      if (cached != null && cached.isNotEmpty) return cached;
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
    } catch (e) {
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

  Future<List<UniversityStatsModel>> getNewlyDiscovered() =>
      getList(
        orderBy: 'app_total_viewers',
        filterColumn: 'app_total_views',
        filterOperator: 'lt',
        filterValue: 50,
      );
}