// lib/data/repositories/video_repository.dart

import 'dart:developer';

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
  Future<List<UniversityModel>> getUniversities() async {
    return await _supabase.getUniversities();
  }

  // ─── Video: Ana Sayfa ──────────────────────────────────────────────────────
  Future<List<VideoModel>> getLatestVideosPerUniversity() async {
    if (await _local.isCacheValid()) {
      final cached = await _local.getCachedVideos();
      if (cached.isNotEmpty) {
        log('VIDEO CACHE HIT: ${cached.length} video (cron henüz çalışmadı veya aktif saat dışı)');
        return cached;
      }
    }

    try {
      final videos = await _supabase.getLatestVideoPerUniversity();
      log('VIDEO CACHE MISS: Supabase\'den ${videos.length} video çekildi');
      await _local.cacheVideos(videos);
      return videos;
    } catch (e) {
      log('Supabase hatası, eski cache kullanılıyor: $e');
      final stale = await _local.getCachedVideos();
      return stale;
    }
  }

  // ─── Video: Üniversiteye Göre ──────────────────────────────────────────────
  Future<List<VideoModel>> getVideosByUniversity(int universityId) async {
    try {
      final videos = await _supabase.getCachedVideosByUniversity(universityId);
      log('Üniversite $universityId: ${videos.length} video');
      return videos;
    } catch (e) {
      log('Üniversite videoları hatası: $e');
      final all = await _local.getCachedVideos();
      return all.where((v) => v.universityId == universityId).toList();
    }
  }

  // ─── Pull-to-Refresh ───────────────────────────────────────────────────────
  Future<List<VideoModel>> refreshVideos() async {
    await _local.clearCache();
    return await getLatestVideosPerUniversity();
  }

  // ─── Oynatma Listeleri ─────────────────────────────────────────────────────
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final unis = await _supabase.getUniversitiesWithVideoCount();
      return unis
          .map((u) => PlaylistModel.fromUniversity(
                u,
                videoCount: (u['video_count'] as int?) ?? 0,
                thumbnailUrl: u['thumbnail_url'] as String? ?? '',
              ))
          .toList();
    } catch (e) {
      log('getPlaylists hatası: $e');
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

  // ─── Video Engagement — Ana Sayfa (ilk 10, cache'siz) ────────────────────

  Future<List<VideoEngagementModel>> getTrendingVideos() async {
    try {
      final data = await _supabase.getTrendingVideos(limit: 10);
      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getTrendingVideos hatası: $e');
      return [];
    }
  }

  Future<List<VideoEngagementModel>> getMostWatchedVideos() async {
    try {
      final data = await _supabase.getMostWatchedVideos(limit: 10);
      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getMostWatchedVideos hatası: $e');
      return [];
    }
  }

  Future<List<VideoEngagementModel>> getMostLikedVideos() async {
    try {
      final data = await _supabase.getMostLikedVideos(limit: 10);
      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getMostLikedVideos hatası: $e');
      return [];
    }
  }

  Future<List<VideoEngagementModel>> getMostFavoritedVideos() async {
    try {
      final data = await _supabase.getMostFavoritedVideos(limit: 10);
      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getMostFavoritedVideos hatası: $e');
      return [];
    }
  }

  Future<List<VideoEngagementModel>> getMostCommentedVideos() async {
    try {
      final data = await _supabase.getMostCommentedVideos(limit: 10);
      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getMostCommentedVideos hatası: $e');
      return [];
    }
  }

  Future<List<VideoEngagementModel>> getNewUndiscoveredVideos() async {
    try {
      final data = await _supabase.getNewAndUndiscoveredVideos(limit: 10);
      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getNewUndiscoveredVideos hatası: $e');
      return [];
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

      return data.map(VideoEngagementModel.fromMap).toList();
    } catch (e) {
      log('getVideoSectionPage hatası ($sectionType): $e');
      return [];
    }
  }
}
