// lib/data/repositories/video_repository.dart

import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/university_model.dart';
import '../models/playlist_model.dart';
import '../models/video_engagement_model.dart';

// VideoSectionType enum — video_sections_config.dart'ta da export edilir,
// merkezi tanım buradadır.
enum VideoSectionType {
  trending,
  mostWatched,
  mostLiked,
  mostFavorited,
  mostCommented,
  newUndiscovered,
}

class VideoRepository {
  final SupabaseDataSource _supabase;
  final LocalDataSource _local;

  VideoRepository({
    required SupabaseDataSource supabase,
    required LocalDataSource local,
  })  : _supabase = supabase,
        _local = local;

  // ─── Üniversiteler ─────────────────────────────────────────────────────────

  Future<UniversityModel> getUniversityById(int id) async {
    return await _supabase.getUniversityById(id);
  }

  // Geriye dönük uyumluluk için stub tutuldu.
  Future<List<UniversityModel>> getUniversities() async {
    log('🏛️ [Video] getUniversities → getUniversitiesAndPlaylists\'e yönlendiriliyor');
    final rows = await getUniversitiesAndPlaylists();
    return rows.map((r) => UniversityModel.fromSupabase(r)).toList();
  }

  /// Tek sorguda hem UniversityModel hem PlaylistModel verisi döner.
  /// FIX: Eklendi! İnternet yoksa uygulama çökmemeli, boş liste dönmeli.
  Future<List<Map<String, dynamic>>> getUniversitiesAndPlaylists() async {
    try {
      log('🏛️☁️ [Video] Üniversiteler + playlist verisi TEK sorguda Supabase\'den çekiliyor...');
      final rows = await _supabase.getUniversitiesWithStats();
      log('🏛️✅ [Video] ${rows.length} üniversite geldi (remote, tek istek)');
      return rows;
    } catch (e) {
      log('🏛️❌ [Video] Üniversiteler yüklenemedi (offline?): $e');
      return []; // Uygulama çökmesin, boş liste dönsün
    }
  }

  // ─── Video: Ana Sayfa ──────────────────────────────────────────────────────
  Future<List<VideoModel>> getLatestVideosPerUniversity() async {
    if (await _local.isCacheValid()) {
      final cached = await _local.getCachedVideos();
      if (cached.isNotEmpty) {
        log('🎬💾 [Video] Ana sayfa videoları LOCAL cache\'den geldi → ${cached.length} video');
        return cached;
      }
    }

    try {
      log('🎬☁️ [Video] Cache geçersiz, Supabase\'den çekiliyor...');
      final videos = await _supabase.getLatestVideoPerUniversity();
      log('🎬✅ [Video] ${videos.length} video geldi → local cache\'e yazıldı (remote)');
      await _local.cacheVideos(videos);
      return videos;
    } catch (e) {
      log('🎬❌ [Video] Supabase hatası: $e → eski cache deneniyor');
      final stale = await _local.getCachedVideos();
      log(stale.isNotEmpty ? '🎬💾 [Video] Stale cache döndürüldü: ${stale.length} video' : '🎬❌ [Video] Stale cache de boş');
      return stale; // Offline ise eski cache veya boş liste döner, app çökmez
    }
  }

  // ─── Video: Üniversiteye Göre ──────────────────────────────────────────────
  Future<List<VideoModel>> getVideosByUniversity(int universityId) async {
    try {
      log('🎬☁️ [Video] Üniversite $universityId videoları Supabase\'den çekiliyor...');
      final videos = await _supabase.getCachedVideosByUniversity(universityId);
      log('🎬✅ [Video] Üniversite $universityId → ${videos.length} video (remote)');
      return videos;
    } catch (e) {
      log('🎬❌ [Video] Üniversite $universityId hata: $e → local cache\'e dönülüyor');
      final all = await _local.getCachedVideos();
      final filtered = all.where((v) => v.universityId == universityId).toList();
      log('🎬💾 [Video] Local fallback: ${filtered.length} video bulundu');
      return filtered;
    }
  }

  // ─── Pull-to-Refresh ───────────────────────────────────────────────────────
  Future<List<VideoModel>> refreshVideos() async {
    log('🔄🧹 [Video] Pull-to-refresh: local cache temizleniyor...');
    await _local.clearCache();
    await _local.clearVideoSectionCache();
    log('🔄☁️ [Video] Veriler Supabase\'den yenileniyor...');
    return await getLatestVideosPerUniversity();
  }

  // ─── Oynatma Listeleri ─────────────────────────────────────────────────────
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      log('🎵☁️ [Video] Playlist listesi Supabase\'den çekiliyor...');
      final unis = await _supabase.getUniversitiesWithVideoCount();
      final playlists = unis
          .map((u) => PlaylistModel.fromUniversity(
                u,
                videoCount: (u['video_count'] as int?) ?? 0,
                thumbnailUrl: u['thumbnail_url'] as String? ?? '',
              ))
          .toList();
      log('🎵✅ [Video] ${playlists.length} playlist geldi (remote)');
      return playlists;
    } catch (e) {
      log('🎵❌ [Video] getPlaylists hatası: $e');
      return [];
    }
  }

  Future<List<VideoModel>> getPlaylistVideos(
    String universityId, {
    int maxResults = 20,
  }) async {
    try {
      return await _supabase.getCachedVideosByUniversity(
        int.parse(universityId),
      );
    } catch (e) {
      log('getPlaylistVideos hatası: $e');
      return [];
    }
  }

  // ─── Video Engagement — Ana Sayfa RPC Bundle ─────────────────────────────

  static const _bundleCacheKey = 'video_sections_bundle';
  static const _bundleTimeKey  = 'video_sections_bundle_time';
  static const _bundleTtlMinutes = 30;

  Future<bool> _isBundleCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final timeStr = prefs.getString(_bundleTimeKey);
    if (timeStr == null) return false;
    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return false;
    return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes < _bundleTtlMinutes;
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

  List<VideoEngagementModel> _parseSection(dynamic raw) {
    if (raw == null) return [];
    return (raw as List).map((e) =>
        VideoEngagementModel.fromMap(Map<String, dynamic>.from(e as Map))).toList();
  }

  /// 6 video section'ını tek RPC çağrısıyla çeker.
  /// Dönüş: key → liste map'i.
  Future<Map<String, List<VideoEngagementModel>>> getAllVideoSections() async {
    // 1. Cache kontrolü
    if (await _isBundleCacheValid()) {
      final cached = await _getBundleFromCache();
      if (cached != null) {
        log('📺💾 [Video] Video sections bundle LOCAL cache\'den geldi');
        return _bundleToSectionMap(cached);
      }
    }

    // 2. RPC çağrısı
    try {
      log('📺☁️ [Video] Video sections RPC → get_home_video_sections');
      final data = await _supabase.getHomeVideoSections();
      if (data != null) {
        log('📺✅ [Video] Video sections bundle geldi, cache\'e yazıldı');
        await _saveBundleToCache(data);
        return _bundleToSectionMap(data);
      }
    } catch (e) {
      log('📺❌ [Video] Video sections RPC hata: $e → stale cache deneniyor');
    }

    // 3. Stale fallback
    final stale = await _getBundleFromCache();
    if (stale != null) {
      log('📺💾 [Video] Stale video sections bundle döndürüldü');
      return _bundleToSectionMap(stale);
    }

    log('📺❌ [Video] Stale cache de yok → boş map');
    return _emptyBundle();
  }

  Map<String, List<VideoEngagementModel>> _bundleToSectionMap(Map<String, dynamic> data) {
    return {
      'trending':        _parseSection(data['trending']),
      'most_watched':    _parseSection(data['most_watched']),
      'most_liked':      _parseSection(data['most_liked']),
      'most_favorited':  _parseSection(data['most_favorited']),
      'most_commented':  _parseSection(data['most_commented']),
      'new_undiscovered':_parseSection(data['new_undiscovered']),
    };
  }

  Map<String, List<VideoEngagementModel>> _emptyBundle() => {
    'trending': [],
    'most_watched': [],
    'most_liked': [],
    'most_favorited': [],
    'most_commented': [],
    'new_undiscovered': [],
  };

  // ─── Video Engagement — Ana Sayfa (ilk 10, 30 dk TTL cache) ─────────────

  Future<List<VideoEngagementModel>> getTrendingVideos() =>
      _cachedSection('trending', () => _supabase.getTrendingVideos(limit: 10));

  Future<List<VideoEngagementModel>> getMostWatchedVideos() =>
      _cachedSection('most_watched', () => _supabase.getMostWatchedVideos(limit: 10));

  Future<List<VideoEngagementModel>> getMostLikedVideos() =>
      _cachedSection('most_liked', () => _supabase.getMostLikedVideos(limit: 10));

  Future<List<VideoEngagementModel>> getMostFavoritedVideos() =>
      _cachedSection('most_favorited', () => _supabase.getMostFavoritedVideos(limit: 10));

  Future<List<VideoEngagementModel>> getMostCommentedVideos() =>
      _cachedSection('most_commented', () => _supabase.getMostCommentedVideos(limit: 10));

  Future<List<VideoEngagementModel>> getNewUndiscoveredVideos() =>
      _cachedSection('new_undiscovered', () => _supabase.getNewAndUndiscoveredVideos(limit: 10));

  /// UniversityStatsRepository ile aynı TTL pattern'i: 30 dk.
  /// Pull-to-refresh → refreshVideoSections() cache'i temizler.
  Future<List<VideoEngagementModel>> _cachedSection(
    String key,
    Future<List<Map<String, dynamic>>> Function() fetch,
  ) async {
    try {
      final cached = await _local.getCachedVideoSection(key);
      if (cached != null) {
        log('📺💾 [Video] Seksiyon LOCAL cache\'den geldi → $key');
        return cached;
      }
      final data = await fetch();
      final models = data.map(VideoEngagementModel.fromMap).toList();
      await _local.cacheVideoSection(key, models);
      log('📺✅ [Video] Seksiyon Supabase\'den çekildi → $key, cache\'e yazıldı (remote)');
      return models;
    } catch (e) {
      log('📺❌ [Video] Seksiyon hata ($key): $e → stale cache deneniyor');
      final stale = await _local.getCachedVideoSection(key);
      return stale ?? [];
    }
  }

  // ─── Video Engagement — Sayfalı (detay sayfası) ───────────────────────────

  /// Verilen seksiyon tipine göre sayfalı veri çeker.
  Future<List<VideoEngagementModel>> getVideoSectionPage({
    required VideoSectionType sectionType,
    required int offset,
    int limit = 10,
  }) async {
    try {
      log('📺☁️ [Video] Sayfa yükleniyor → $sectionType offset=$offset limit=$limit');
      final List<Map<String, dynamic>> data;

      switch (sectionType) {
        case VideoSectionType.trending:
          data = await _supabase.getTrendingVideos(
              limit: limit, offset: offset);
        case VideoSectionType.mostWatched:
          data = await _supabase.getMostWatchedVideos(
              limit: limit, offset: offset);
        case VideoSectionType.mostLiked:
          data = await _supabase.getMostLikedVideos(
              limit: limit, offset: offset);
        case VideoSectionType.mostFavorited:
          data = await _supabase.getMostFavoritedVideos(
              limit: limit, offset: offset);
        case VideoSectionType.mostCommented:
          data = await _supabase.getMostCommentedVideos(
              limit: limit, offset: offset);
        case VideoSectionType.newUndiscovered:
          data = await _supabase.getNewAndUndiscoveredVideos(
              limit: limit, offset: offset);
      }

      final models = data.map(VideoEngagementModel.fromMap).toList();
      log('📺✅ [Video] Sayfa geldi → $sectionType ${models.length} video (remote)');
      return models;
    } catch (e) {
      log('📺❌ [Video] Sayfa hata ($sectionType): $e');
      return []; // Sayfa yüklenemezse boş döner, pagination durur ama app çökmez
    }
  }
}