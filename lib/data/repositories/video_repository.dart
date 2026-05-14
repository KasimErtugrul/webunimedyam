import 'dart:developer';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/university_model.dart';
import '../models/playlist_model.dart';

class VideoRepository {
  final SupabaseDataSource _supabase;
  // ignore: unused_field
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

  // ─── Video: Ana Sayfa ─────────────────────────────────────────────────────

  /// Her üniversiteden en son video — latest_videos_per_university view.
  Future<List<VideoModel>> getLatestVideosPerUniversity() async {
    try {
      final videos = await _supabase.getLatestVideoPerUniversity();
      log('SUPABASE latest_videos_per_university: ${videos.length} video');
      return videos;
    } catch (e) {
      log('latest_videos_per_university hatasi: $e');
      return [];
    }
  }

  // ─── Video: Üniversiteye Göre ─────────────────────────────────────────────

  Future<List<VideoModel>> getVideosByUniversity(int universityId) async {
    try {
      final videos = await _supabase.getCachedVideosByUniversity(universityId);
      log('SUPABASE universite $universityId: ${videos.length} video');
      return videos;
    } catch (e) {
      log('Universite videolari hatasi: $e');
      return [];
    }
  }

  // ─── Refresh ──────────────────────────────────────────────────────────────

  Future<List<VideoModel>> refreshVideos() async {
    return await getLatestVideosPerUniversity();
  }

  // ─── Oynatma Listeleri ────────────────────────────────────────────────────

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
      log('getPlaylists hatasi: $e');
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
      log('getPlaylistVideos hatasi: $e');
      return [];
    }
  }
}
