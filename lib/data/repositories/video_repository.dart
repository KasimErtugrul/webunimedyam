// lib/data/repositories/video_repository.dart

import 'dart:developer';

import 'package:hive_ce/hive.dart';

import '../datasources/local/app_cache_box.dart';
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
  }) : _supabase = supabase,
       _local = local;

  Box get _box => AppCacheBox.instance;

  Map<String, dynamic> _asMap(dynamic v) =>
      Map<String, dynamic>.from(v as Map);

  // ─── Üniversiteler ─────────────────────────────────────────────────────────

  Future<UniversityModel> getUniversityById(int id) async {
    try {
      return await _supabase.getUniversityById(id);
    } catch (e, stacktrace) {
      log(
        'Üniversite ID ile getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      rethrow;
    }
  }

  // Geriye dönük uyumluluk için stub tutuldu.
  Future<List<UniversityModel>> getUniversities() async {
    try {
      final rows = await getUniversitiesAndPlaylists();
      return rows.map((r) => UniversityModel.fromSupabase(r)).toList();
    } catch (e, stacktrace) {
      log(
        'Üniversiteler getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  /// Tek sorguda hem UniversityModel hem PlaylistModel verisi döner.
  /// FIX: Eklendi! İnternet yoksa uygulama çökmemeli, boş liste dönmeli.
  Future<List<Map<String, dynamic>>> getUniversitiesAndPlaylists() async {
    // Önce local cache kontrolü
    try {
      if (await _local.isUniversityCacheValid()) {
        final cached = await _local.getCachedUniversities();
        if (cached.isNotEmpty) {
          return cached;
        }
      }
    } catch (e, stacktrace) {
      log(
        'Üniversite cache kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    try {
      final rows = await _supabase.getUniversitiesWithStats();
      await _local.cacheUniversities(rows);
      return rows;
    } catch (e, stacktrace) {
      log(
        'Üniversiteler yüklenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      try {
        final stale = await _local.getCachedUniversities();
        if (stale.isNotEmpty) {
          return stale;
        }
      } catch (staleError, staleStacktrace) {
        log(
          'Stale üniversite cache okunurken hata oluştu: $staleError',
          error: staleError,
          stackTrace: staleStacktrace,
        );
      }
      return [];
    }
  }

  // ─── Video: Ana Sayfa ──────────────────────────────────────────────────────
  Future<List<VideoModel>> getLatestVideosPerUniversity({
    int page = 0,
    int pageSize = 10,
  }) async {
    final offset = page * pageSize;

    // Sayfalama isteği (page > 0): Cache kontrolünü atla, direkt remote'a git.
    if (page > 0) {
      try {
        final videos = await _supabase.getLatestVideoPerUniversity(
          limit: pageSize,
          offset: offset,
        );
        return videos;
      } catch (e, stacktrace) {
        log(
          'Video sayfası yüklenirken hata oluştu (sayfa $page): $e',
          error: e,
          stackTrace: stacktrace,
        );
        return []; // Cache sadece 1. sayfayı tuttuğu için, hata durumunda boş liste döner.
      }
    }

    // İlk Sayfa (page == 0): Mevcut cache-first davranışı koru.
    try {
      if (await _local.isCacheValid()) {
        final cached = await _local.getCachedVideos();
        if (cached.isNotEmpty) {
          return cached;
        }
      }
    } catch (e, stacktrace) {
      log(
        'Video cache kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    try {
      // Cache geçersizse pageSize parametresini kullan, varsayılan 500'e güvenme.
      final videos = await _supabase.getLatestVideoPerUniversity(
        limit: pageSize,
        offset: 0,
      );
      await _local.cacheVideos(videos);
      return videos;
    } catch (e, stacktrace) {
      log(
        'Supabase\'den videolar getirilirken hata oluştu: $e → eski cache deneniyor',
        error: e,
        stackTrace: stacktrace,
      );
      try {
        final stale = await _local.getCachedVideos();
        return stale; // Offline ise eski cache veya boş liste döner, app çökmez
      } catch (staleError, staleStacktrace) {
        log(
          'Stale video cache okunurken hata oluştu: $staleError',
          error: staleError,
          stackTrace: staleStacktrace,
        );
        return [];
      }
    }
  }

  // ─── Video: Üniversiteye Göre ──────────────────────────────────────────────
  Future<List<VideoModel>> getVideosByUniversity(
    int universityId, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final videos = await _supabase.getCachedVideosByUniversity(
        universityId,
        limit: limit,
        offset: offset,
      );

      return videos;
    } catch (e, stacktrace) {
      log(
        'Üniversite videoları getirilirken hata oluştu ($universityId): $e',
        error: e,
        stackTrace: stacktrace,
      );
      try {
        final all = await _local.getCachedVideos();
        final filtered = all
            .where((v) => v.universityId == universityId)
            .toList();
        final start = offset.clamp(0, filtered.length);
        final end = (offset + limit).clamp(0, filtered.length);
        return filtered.sublist(start, end);
      } catch (staleError, staleStacktrace) {
        log(
          'Local fallback videolar okunurken hata oluştu: $staleError',
          error: staleError,
          stackTrace: staleStacktrace,
        );
        return [];
      }
    }
  }

  // ─── Video: Canlı Yayınlar ─────────────────────────────────────────────────
  Future<List<VideoModel>> getLiveVideosByUniversity(int universityId) async {
    try {
      return await _supabase.getLiveVideosByUniversity(universityId);
    } catch (e, stacktrace) {
      log(
        'Üniversite canlı yayınları getirilirken hata oluştu ($universityId): $e',
        error: e,
        stackTrace: stacktrace,
      );
      // Offline/hata durumunda yerel cache'teki videolardan canlı olanları filtrele.
      try {
        final all = await _local.getCachedVideos();
        return all
            .where((v) => v.universityId == universityId && v.isLiveBroadcast)
            .toList();
      } catch (staleError, staleStacktrace) {
        log(
          'Local fallback canlı yayınlar okunurken hata oluştu: $staleError',
          error: staleError,
          stackTrace: staleStacktrace,
        );
        return [];
      }
    }
  }

  // ─── Pull-to-Refresh ───────────────────────────────────────────────────────
  Future<List<VideoModel>> refreshVideos() async {
    try {
      await _local.clearCache();
      await _local.clearVideoSectionCache();
      // FIX: Trend/En Çok İzlenen/vb. ana sayfa bölümleri ayrı bir bundle
      // cache'i kullanıyordu ve yukarıdaki temizlemeler ona dokunmuyordu.
      // Artık pull-to-refresh bunu da temizliyor.
      await clearBundleCache();
      // Varsayılan parametreler (page=0) ile çağırır, ilk sayfayı yeniler.
      return await getLatestVideosPerUniversity();
    } catch (e, stacktrace) {
      log(
        'Videolar yenilenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  // ─── Oynatma Listeleri ─────────────────────────────────────────────────────
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final unis = await _supabase.getUniversitiesWithVideoCount();
      final playlists = unis
          .map(
            (u) => PlaylistModel.fromUniversity(
              u,
              videoCount: (u['video_count'] as int?) ?? 0,
              thumbnailUrl: u['thumbnail_url'] as String? ?? '',
            ),
          )
          .toList();
      return playlists;
    } catch (e, stacktrace) {
      log(
        'Oynatma listeleri getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
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
    } catch (e, stacktrace) {
      log(
        'Oynatma listesi videoları getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  // ─── Video: Tek Kayıt (Deep Link) ─────────────────────────────────────────
  // BUG FIX: Deep link ile (bkz. deep_link_service.dart) player ekranına
  // gidildiğinde elde sadece videoId string'i olur, tam bir VideoModel
  // nesnesi olmaz (normal navigasyonda — video kartına tıklama gibi —
  // zaten elimizde tam model vardır ve Get.arguments ile taşınır). Bu
  // metod, sadece videoId ile Supabase'ten tek bir videoyu çeker.
  Future<VideoModel?> getVideoById(String videoId) async {
    try {
      return await _supabase.getVideoById(videoId);
    } catch (e, stacktrace) {
      log(
        'Video ID ile getirilirken hata oluştu ($videoId): $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  // ─── Öneri Sistemi ────────────────────────────────────────────────────────
  Future<List<VideoModel>> getSuggestedVideos(String videoId) async {
    try {
      final videos = await _supabase.getSuggestedVideos(videoId);
      return videos;
    } catch (e, stacktrace) {
      log(
        'Önerilen videolar getirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  // ─── Video Engagement — Ana Sayfa RPC Bundle ─────────────────────────────

  static const _bundleCacheKey = 'video_sections_bundle';
  static const _bundleTimeKey = 'video_sections_bundle_time';
  static const _bundleTtlMinutes = 30;

  Future<bool> _isBundleCacheValid() async {
    try {
      final cacheTime = _box.get(_bundleTimeKey) as DateTime?;
      if (cacheTime == null) return false;
      return DateTime.now().toUtc().difference(cacheTime.toUtc()).inMinutes <
          _bundleTtlMinutes;
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

  /// FIX: Ana sayfa "Trend/En Çok İzlenen/vb." bölümlerinin cache'i
  /// clearVideoSectionCache()'den TAMAMEN AYRI bir key alanı kullanıyordu
  /// (_bundleCacheKey / _bundleTimeKey), bu yüzden pull-to-refresh bu
  /// bölümleri hiç yenilemiyordu — 30 dk'lık TTL dolana kadar bayat kalıyordu.
  /// refreshVideos() artık bunu da temizliyor.
  Future<void> clearBundleCache() async {
    try {
      await _box.delete(_bundleCacheKey);
      await _box.delete(_bundleTimeKey);
    } catch (e, stacktrace) {
      log(
        'Bundle cache temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  List<VideoEngagementModel> _parseSection(dynamic raw) {
    if (raw == null) return [];
    try {
      return (raw as List)
          .map(
            (e) => VideoEngagementModel.fromMap(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (e, stacktrace) {
      log(
        'Video section parse edilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return [];
    }
  }

  /// 6 video section'ını tek RPC çağrısıyla çeker.
  /// Dönüş: key → liste map'i.
  Future<Map<String, List<VideoEngagementModel>>> getAllVideoSections() async {
    // 1. Cache kontrolü
    try {
      if (await _isBundleCacheValid()) {
        final cached = await _getBundleFromCache();
        if (cached != null) {
          return _bundleToSectionMap(cached);
        }
      }
    } catch (e, stacktrace) {
      log(
        'Bundle cache kontrolü yapılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    // 2. RPC çağrısı
    try {
      final data = await _supabase.getHomeVideoSections();
      if (data != null) {
        await _saveBundleToCache(data);
        return _bundleToSectionMap(data);
      }
    } catch (e, stacktrace) {
      log(
        'Video sections RPC çağrısı yapılırken hata oluştu: $e → stale cache deneniyor',
        error: e,
        stackTrace: stacktrace,
      );
    }

    // 3. Stale fallback
    try {
      final stale = await _getBundleFromCache();
      if (stale != null) {
        return _bundleToSectionMap(stale);
      }
    } catch (e, stacktrace) {
      log(
        'Stale bundle cache okunurken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }

    log('Video sections için cache bulunamadı → boş map dönülüyor');
    return _emptyBundle();
  }

  Map<String, List<VideoEngagementModel>> _bundleToSectionMap(
    Map<String, dynamic> data,
  ) {
    try {
      final trending = _parseSection(data['trending']);
      final mostWatched = _parseSection(data['most_watched']);
      final mostLiked = _parseSection(data['most_liked']);
      final mostFavorited = _parseSection(data['most_favorited']);
      final mostCommented = _parseSection(data['most_commented']);
      final newUndiscovered = _parseSection(data['new_undiscovered']);

      // Section'lar arası tekrarı önle:
      // Önce eklenen section'lar öncelikli — her video yalnızca bir kez görünür.
      final seen = <String>{};

      List<VideoEngagementModel> dedup(List<VideoEngagementModel> list) {
        final result = <VideoEngagementModel>[];
        for (final v in list) {
          if (seen.add(v.videoId)) result.add(v);
        }
        return result;
      }

      return {
        'trending': dedup(trending),
        'most_watched': dedup(mostWatched),
        'most_liked': dedup(mostLiked),
        'most_favorited': dedup(mostFavorited),
        'most_commented': dedup(mostCommented),
        'new_undiscovered': dedup(newUndiscovered),
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

  Future<List<VideoEngagementModel>> getMostWatchedVideos() => _cachedSection(
    'most_watched',
    () => _supabase.getMostWatchedVideos(limit: 10),
  );

  Future<List<VideoEngagementModel>> getMostLikedVideos() => _cachedSection(
    'most_liked',
    () => _supabase.getMostLikedVideos(limit: 10),
  );

  Future<List<VideoEngagementModel>> getMostFavoritedVideos() => _cachedSection(
    'most_favorited',
    () => _supabase.getMostFavoritedVideos(limit: 10),
  );

  Future<List<VideoEngagementModel>> getMostCommentedVideos() => _cachedSection(
    'most_commented',
    () => _supabase.getMostCommentedVideos(limit: 10),
  );

  Future<List<VideoEngagementModel>> getNewUndiscoveredVideos() =>
      _cachedSection(
        'new_undiscovered',
        () => _supabase.getNewAndUndiscoveredVideos(limit: 10),
      );

  /// UniversityStatsRepository ile aynı TTL pattern'i: 30 dk.
  /// Pull-to-refresh → refreshVideoSections() cache'i temizler.
  Future<List<VideoEngagementModel>> _cachedSection(
    String key,
    Future<List<Map<String, dynamic>>> Function() fetch,
  ) async {
    try {
      final cached = await _local.getCachedVideoSection(key);
      if (cached != null) {
        return cached;
      }
      final data = await fetch();
      final models = data.map(VideoEngagementModel.fromMap).toList();
      await _local.cacheVideoSection(key, models);
      return models;
    } catch (e, stacktrace) {
      log(
        'Video section getirilirken hata oluştu ($key): $e → stale cache deneniyor',
        error: e,
        stackTrace: stacktrace,
      );
      try {
        final stale = await _local.getCachedVideoSection(key);
        return stale ?? [];
      } catch (staleError, staleStacktrace) {
        log(
          'Stale video section cache okunurken hata oluştu: $staleError',
          error: staleError,
          stackTrace: staleStacktrace,
        );
        return [];
      }
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
      final List<Map<String, dynamic>> data;

      switch (sectionType) {
        case VideoSectionType.trending:
          data = await _supabase.getTrendingVideos(
            limit: limit,
            offset: offset,
          );
        case VideoSectionType.mostWatched:
          data = await _supabase.getMostWatchedVideos(
            limit: limit,
            offset: offset,
          );
        case VideoSectionType.mostLiked:
          data = await _supabase.getMostLikedVideos(
            limit: limit,
            offset: offset,
          );
        case VideoSectionType.mostFavorited:
          data = await _supabase.getMostFavoritedVideos(
            limit: limit,
            offset: offset,
          );
        case VideoSectionType.mostCommented:
          data = await _supabase.getMostCommentedVideos(
            limit: limit,
            offset: offset,
          );
        case VideoSectionType.newUndiscovered:
          data = await _supabase.getNewAndUndiscoveredVideos(
            limit: limit,
            offset: offset,
            useRandomSampling: false,
          );
      }

      final models = data.map(VideoEngagementModel.fromMap).toList();
      return models;
    } catch (e, stacktrace) {
      log(
        'Video section sayfası getirilirken hata oluştu ($sectionType): $e',
        error: e,
        stackTrace: stacktrace,
      );
      return []; // Sayfa yüklenemezse boş döner, pagination durur ama app çökmez
    }
  }
}