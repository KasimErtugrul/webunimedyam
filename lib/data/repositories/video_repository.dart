import '../datasources/local/local_datasource.dart';
import '../datasources/remote/youtube_datasource.dart';
import '../datasources/remote/supabase_datasource.dart';
import '../models/video_model.dart';
import '../models/playlist_model.dart';

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

  // ─── Kanal Videoları ──────────────────────────────────────────────────────

  Future<List<VideoModel>> getVideos() async {
    // 1. Önce local cache'e bak
    try {
      if (await _local.isCacheValid()) {
        final localVideos = await _local.getCachedVideos();
        if (localVideos.isNotEmpty) return localVideos;
      }
    } catch (_) {}

    // 2. Local yoksa Supabase'e bak
    try {
      final supabaseVideos = await _supabase.getCachedVideos();
      if (supabaseVideos.isNotEmpty) {
        try {
          await _local.cacheVideos(supabaseVideos);
        } catch (_) {}
        return supabaseVideos;
      }
    } catch (_) {}

    // 3. Her ikisi de boşsa YouTube API'ye git
    return await _refreshFromYouTube();
  }

  Future<List<VideoModel>> _refreshFromYouTube() async {
    final videos = await _youtube.getChannelVideos();

    try {
      await _supabase.upsertVideos(videos);
    } catch (_) {}

    try {
      await _local.cacheVideos(videos);
    } catch (_) {}

    return videos;
  }

  Future<List<VideoModel>> refreshVideos() async {
    try {
      await _local.clearCache();
    } catch (_) {}
    return await _refreshFromYouTube();
  }

  // ─── Oynatma Listeleri ────────────────────────────────────────────────────

  /// Kanalın oynatma listelerini döner.
  Future<List<PlaylistModel>> getPlaylists({int maxResults = 20}) async {
    return await _youtube.getChannelPlaylists(maxResults: maxResults);
  }

  /// Belirli bir oynatma listesinin videolarını döner.
  Future<List<VideoModel>> getPlaylistVideos(
    String playlistId, {
    int maxResults = 20,
  }) async {
    return await _youtube.getPlaylistVideos(playlistId,
        maxResults: maxResults);
  }
}
