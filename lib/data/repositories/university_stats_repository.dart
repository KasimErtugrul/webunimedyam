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

  // FIX: Cache key artık string filter yerine tip güvenli parametrelerle oluşturuluyor.
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
    return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
        _ttlMinutes;
  }

  Future<List<UniversityStatsModel>?> _getFromCache(
    String orderBy, {
    String? filterColumn,
  }) async {
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

  Future<void> _saveToCache(
    String orderBy,
    List<UniversityStatsModel> data, {
    String? filterColumn,
  }) async {
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

  // ─── Ana Metod ───────────────────────────────────────────────────────────

  // FIX: Artık string filter yok! SupabaseDataSource ile aynı tip güvenli parametreler.
  Future<List<UniversityStatsModel>> getList({
    required String orderBy,
    int limit = 10,
    String? filterColumn,
    String? filterOperator, // 'gt', 'lt', 'eq' vb.
    dynamic filterValue,
  }) async {
    // 1. Cache geçerliyse dön
    if (await _isCacheValid(orderBy, filterColumn: filterColumn)) {
      final cached = await _getFromCache(orderBy, filterColumn: filterColumn);
      if (cached != null && cached.isNotEmpty) {
        log('🏛️💾 [UniStats] LOCAL cache\'den geldi → $orderBy (${cached.length} kayıt)');
        return cached;
      }
    }

    // 2. Supabase'den çek (Yeni tip güvenli metodu kullanarak)
    try {
      log('🏛️☁️ [UniStats] Cache geçersiz, Supabase\'den çekiliyor → $orderBy${filterColumn != null ? ' ($filterColumn $filterOperator $filterValue)' : ''}');
      final data = await _supabase.getUniversityStatsList(
        orderBy: orderBy,
        limit: limit,
        filterColumn: filterColumn,
        filterOperator: filterOperator,
        filterValue: filterValue,
      );
      log('🏛️✅ [UniStats] Supabase\'den geldi → $orderBy, ${data.length} kayıt, cache\'e yazıldı (remote)');
      await _saveToCache(orderBy, data, filterColumn: filterColumn);
      return data;
    } catch (e) {
      log('🏛️❌ [UniStats] Hata ($orderBy): $e → stale cache deneniyor');
      // 3. Offline fallback: eski cache
      final stale = await _getFromCache(orderBy, filterColumn: filterColumn);
      if (stale != null && stale.isNotEmpty) {
        log('🏛️💾 [UniStats] Stale cache döndürüldü → $orderBy (${stale.length} kayıt)');
      } else {
        log('🏛️❌ [UniStats] Stale cache de yok → boş liste döndürülüyor');
      }
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

  // FIX: String hack ('app_total_views.lt.50') yerine artık tip güvenli parametreler!
  Future<List<UniversityStatsModel>> getNewlyDiscovered() =>
      getList(
        orderBy: 'app_total_viewers',
        filterColumn: 'app_total_views',
        filterOperator: 'lt',
        filterValue: 50,
      );
}