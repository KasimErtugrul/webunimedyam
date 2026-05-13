import 'dart:developer';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/university_model.dart';
import '../models/playlist_model.dart';
import '../datasources/remote/youtube_datasource.dart';

class VideoRepository {
  final LocalDataSource _local;
  final YouTubeDataSource _youtube;
  final SupabaseDataSource _supabase;

  VideoRepository({
    required LocalDataSource local,
    required YouTubeDataSource youtube,
    required SupabaseDataSource supabase,
  })  : _local = local,
        _youtube = youtube,
        _supabase = supabase;

  // ─── Üniversiteler ────────────────────────────────────────────────────────

  Future<List<UniversityModel>> getUniversities() async {
    return await _supabase.getUniversities();
  }

  // ─── Video: Tüm Üniversiteler (Ana Sayfa) ─────────────────────────────────

  /// Ana sayfa: her üniversiteden en son video — view üzerinden tek sorgu.
  Future<List<VideoModel>> getLatestVideosPerUniversity() async {
    try {
      final videos = await _supabase.getLatestVideoPerUniversity();
      if (videos.isNotEmpty) {
        log('✅ SUPABASE latest_videos_per_university: ${videos.length} video');
        return videos;
      }
    } catch (e) {
      log('❌ latest_videos_per_university hatası: $e');
    }
    // View boşsa tüm önbelleği dene
    return await getVideos();
  }

  // ─── Video: Tüm Cache ─────────────────────────────────────────────────────

  Future<List<VideoModel>> getVideos() async {
    // 1) Local cache geçerliyse oradan dön
    try {
      if (await _local.isCacheValid()) {
        final localVideos = await _local.getCachedVideos();
        if (localVideos.isNotEmpty) {
          log('✅ LOCAL CACHE\'den geldi: ${localVideos.length} video');
          return localVideos;
        }
      }
    } catch (_) {}

    // 2) Supabase cache
    try {
      final supabaseVideos = await _supabase.getCachedVideos();
      if (supabaseVideos.isNotEmpty) {
        log('✅ SUPABASE\'den geldi: ${supabaseVideos.length} video');
        await _local.cacheVideos(supabaseVideos);
        return supabaseVideos;
      }
    } catch (e) {
      log('❌ SUPABASE\'den video çekme hatası: $e');
    }

    // 3) YouTube API (son çare)
    log('⚠️ YOUTUBE API\'den geldi (fallback)');
    return await _refreshFromYouTube();
  }

  // ─── Video: Üniversiteye Göre ─────────────────────────────────────────────

  Future<List<VideoModel>> getVideosByUniversity(int universityId) async {
    try {
      final videos =
          await _supabase.getCachedVideosByUniversity(universityId);
      if (videos.isNotEmpty) {
        log('✅ SUPABASE üniversite $universityId: ${videos.length} video');
        return videos;
      }
    } catch (e) {
      log('❌ Üniversite videoları hatası: $e');
    }
    return [];
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  Future<List<VideoModel>> refreshVideos() async {
    try {
      await _local.clearCache();
    } catch (_) {}
    return await _refreshFromYouTube();
  }

  Future<List<VideoModel>> _refreshFromYouTube() async {
    final videos = await _youtube.getChannelVideos();

    try {
      await _supabase.upsertVideos(videos);
    } catch (e) {
      log('❌ SUPABASE\'ye video ekleme hatası: $e');
    }

    try {
      await _local.cacheVideos(videos);
    } catch (e) {
      log('❌ LOCAL CACHE\'ye video ekleme hatası: $e');
    }

    return videos;
  }

  // ─── Oynatma Listeleri ────────────────────────────────────────────────────

  Future<List<PlaylistModel>> getPlaylists({int maxResults = 20}) async {
    return await _youtube.getChannelPlaylists(maxResults: maxResults);
  }

  Future<List<VideoModel>> getPlaylistVideos(
    String playlistId, {
    int maxResults = 20,
  }) async {
    return await _youtube.getPlaylistVideos(playlistId,
        maxResults: maxResults);
  }
}