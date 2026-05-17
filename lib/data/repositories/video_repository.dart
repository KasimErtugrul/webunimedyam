import 'dart:developer';

import '../datasources/local/local_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/university_model.dart';
import '../models/playlist_model.dart';

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
  //
  // Strateji:
  //   1. Local cache geçerliyse (< 14 dk) → Supabase isteği YOK, local'den sun.
  //   2. Cache süresi dolmuşsa veya hiç yoksa → Supabase'den çek, local'e kaydet.
  //   3. Supabase başarısız olursa → eski local veriyi döndür (offline fallback).
  //
  // Cron 14 dk'da bir çalıştığından TTL ile mükemmel senkron oluruz.

  Future<List<VideoModel>> getLatestVideosPerUniversity() async {
    // 1. Cache geçerli mi?
    if (await _local.isCacheValid()) {
      final cached = await _local.getCachedVideos();
      if (cached.isNotEmpty) {
        log('VIDEO CACHE HIT: ${cached.length} video (cron henüz çalışmadı veya aktif saat dışı)');
        return cached;
      }
    }

    // 2. Cache süresi dolmuş veya boş → Supabase'den çek
    try {
      final videos = await _supabase.getLatestVideoPerUniversity();
      log('VIDEO CACHE MISS: Supabase\'den ${videos.length} video çekildi');
      // Local'e kaydet, bir sonraki açılış cache'ten gelsin
      await _local.cacheVideos(videos);
      return videos;
    } catch (e) {
      log('Supabase hatası, eski cache kullanılıyor: $e');
      // 3. Offline fallback — eski cache bile olsa göster
      final stale = await _local.getCachedVideos();
      return stale;
    }
  }

  // ─── Video: Üniversiteye Göre ──────────────────────────────────────────────
  //
  // Üniversite filtrelemesi Supabase'e özgü (her üniversite ayrı sorgu),
  // bu yüzden local cache'i bypass edip direkt çekiyoruz.
  // Ana sayfa cache'ini bozmamak için ayrı tutuyoruz.

  Future<List<VideoModel>> getVideosByUniversity(int universityId) async {
    try {
      final videos = await _supabase.getCachedVideosByUniversity(universityId);
      log('Üniversite $universityId: ${videos.length} video');
      return videos;
    } catch (e) {
      log('Üniversite videoları hatası: $e');
      // Fallback: local cache'teki tüm videolar içinden filtrele
      final all = await _local.getCachedVideos();
      return all.where((v) => v.universityId == universityId).toList();
    }
  }

  // ─── Pull-to-Refresh ───────────────────────────────────────────────────────
  //
  // Kullanıcı manuel yenilediğinde cache'i geçersiz kıl ve Supabase'den çek.

  Future<List<VideoModel>> refreshVideos() async {
    await _local.clearCache(); // TTL'yi sıfırla
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
}
