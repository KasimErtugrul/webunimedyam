// lib/data/repositories/university_stats_repository.dart

import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/remote/supabase_datasource.dart';
import '../models/university_stats_model.dart';

/// Her liste için ayrı bir cache key kullanılır.
/// TTL: 30 dakika.
class UniversityStatsRepository {
  final SupabaseDataSource _supabase;

  static const _ttlMinutes = 30;

  UniversityStatsRepository({required SupabaseDataSource supabase})
      : _supabase = supabase;

  // ─── Genel Yardımcılar ───────────────────────────────────────────────────

  String _cacheKey(String orderBy, {String? filter}) =>
      'uni_stats_${orderBy}_${filter ?? 'nofilter'}';

  String _cacheTimeKey(String orderBy, {String? filter}) =>
      'uni_stats_time_${orderBy}_${filter ?? 'nofilter'}';

  Future<bool> _isCacheValid(String orderBy, {String? filter}) async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_cacheTimeKey(orderBy, filter: filter));
    if (timeStr == null) return false;
    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return false;
    return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
        _ttlMinutes;
  }

  Future<List<UniversityStatsModel>?> _getFromCache(
    String orderBy, {
    String? filter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_cacheKey(orderBy, filter: filter));
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

  Future<void> _saveToCache(
    String orderBy,
    List<UniversityStatsModel> data, {
    String? filter,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey(orderBy, filter: filter),
      json.encode(data.map((e) => e.toMap()).toList()),
    );
    await prefs.setString(
      _cacheTimeKey(orderBy, filter: filter),
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  // ─── Ana Metod ───────────────────────────────────────────────────────────

  Future<List<UniversityStatsModel>> getList({
    required String orderBy,
    int limit = 10,
    String? filter,
  }) async {
    // 1. Cache geçerliyse dön
    if (await _isCacheValid(orderBy, filter: filter)) {
      final cached = await _getFromCache(orderBy, filter: filter);
      if (cached != null && cached.isNotEmpty) {
        log('UNI_STATS CACHE HIT: $orderBy');
        return cached;
      }
    }

    // 2. Supabase'den çek
    try {
      final data = await _supabase.getUniversityStatsList(
        orderBy: orderBy,
        limit: limit,
        filter: filter,
      );
      log('UNI_STATS CACHE MISS: $orderBy — ${data.length} kayıt');
      await _saveToCache(orderBy, data, filter: filter);
      return data;
    } catch (e) {
      log('UNI_STATS fetch error ($orderBy): $e');
      // 3. Offline fallback: eski cache
      final stale = await _getFromCache(orderBy, filter: filter);
      return stale ?? [];
    }
  }

  // ─── 8 Hazır Liste Metodu ─────────────────────────────────────────────────

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
      getList(orderBy: 'app_total_viewers', filter: 'app_total_views.lt.50');
}