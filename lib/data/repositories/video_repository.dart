import 'dart:developer';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/university_model.dart';
import '../models/playlist_model.dart';

class VideoRepository {
  final LocalDataSource _local;
  final SupabaseDataSource _supabase;

  VideoRepository({
    required LocalDataSource local,
    required SupabaseDataSource supabase,
  })  : _local = local,
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

    return [];
  }

  // ─── Video: Üniversiteye Göre ─────────────────────────────────────────────

  Future<List<VideoModel>> getVideosByUniversity(int universityId) async {
    try {
      final videos = await _supabase.getCachedVideosByUniversity(universityId);
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

  /// Cache'i temizler ve Supabase'den tekrar yükler.
  /// Sync'i tetiklemek istiyorsan edge function'ı çağır.
  Future<List<VideoModel>> refreshVideos() async {
    try {
      await _local.clearCache();
    } catch (_) {}
    return await getVideos();
  }

  // ─── Oynatma Listeleri (Üniversite bazlı) ────────────────────────────────

  /// Üniversiteleri birer playlist olarak döner.
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
      log('❌ getPlaylists hatası: $e');
      return [];
    }
  }

  /// Bir "playlist" aslında bir üniversitenin videoları.
  Future<List<VideoModel>> getPlaylistVideos(
    String universityId, {
    int maxResults = 20,
  }) async {
    try {
      return await _supabase.getCachedVideosByUniversity(
        int.parse(universityId),
      );
    } catch (e) {
      log('❌ getPlaylistVideos hatası: $e');
      return [];
    }
  }
}
