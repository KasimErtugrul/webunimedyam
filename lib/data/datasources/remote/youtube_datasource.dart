import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../models/video_model.dart';
import '../../models/playlist_model.dart';

class YouTubeDataSource {
  static const _apiKey = 'AIzaSyC-AMaCwwl_im5PTiSzZtTASXpFt9kiroQ';
  static const _channelId = 'UCMvQuS3kK3rN7nTgz4yeggw';
  static const _baseUrl = 'https://www.googleapis.com/youtube/v3';

  // ─── Kanal Videoları ────────────────────────────────────────────────────────

  Future<List<VideoModel>> getChannelVideos({int maxResults = 20}) async {
    // 1. Uploads playlist ID'sini al
    final channelResponse = await http.get(
      Uri.parse(
        '$_baseUrl/channels?part=contentDetails&id=$_channelId&key=$_apiKey',
      ),
    );

    if (channelResponse.statusCode != 200) {
      throw Exception(
        'Kanal bilgisi alınamadı (${channelResponse.statusCode})',
      );
    }

    final channelData =
        json.decode(channelResponse.body) as Map<String, dynamic>;
    final items = channelData['items'] as List?;
    log('YouTubeDataSource getChannelVideos items: $items');
    if (items == null || items.isEmpty) {
      throw Exception('Kanal bulunamadı');
    }

    final uploadsPlaylistId =
        (items[0]['contentDetails']
                as Map<String, dynamic>)['relatedPlaylists']['uploads']
            as String?;
    if (uploadsPlaylistId == null || uploadsPlaylistId.isEmpty) {
      throw Exception('Uploads playlist ID alınamadı');
    }

    // 2. Playlist videolarını al
    return await getPlaylistVideos(uploadsPlaylistId, maxResults: maxResults);
  }

  // ─── Kanal Oynatma Listeleri ─────────────────────────────────────────────

  /// Kanalın herkese açık oynatma listelerini döner.
  Future<List<PlaylistModel>> getChannelPlaylists({int maxResults = 20}) async {
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/playlists'
        '?part=snippet,contentDetails'
        '&channelId=$_channelId'
        '&maxResults=$maxResults'
        '&key=$_apiKey',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Oynatma listeleri alınamadı (${response.statusCode})');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List? ?? [];
    return items
        .map(
          (item) => PlaylistModel.fromYouTubeApi(item as Map<String, dynamic>),
        )
        .toList();
  }

  /// Belirli bir oynatma listesinin videolarını döner.
  Future<List<VideoModel>> getPlaylistVideos(
    String playlistId, {
    int maxResults = 20,
  }) async {
    // 1. Playlist öğelerini al
    final playlistResponse = await http.get(
      Uri.parse(
        '$_baseUrl/playlistItems'
        '?part=snippet'
        '&playlistId=$playlistId'
        '&maxResults=$maxResults'
        '&key=$_apiKey',
      ),
    );

    if (playlistResponse.statusCode != 200) {
      throw Exception(
        'Playlist bilgisi alınamadı (${playlistResponse.statusCode})',
      );
    }

    final playlistData =
        json.decode(playlistResponse.body) as Map<String, dynamic>;
    final playlistItems = playlistData['items'] as List? ?? [];
    if (playlistItems.isEmpty) return [];

    // 2. Video ID'lerini topla
    final videoIds = playlistItems
        .map(
          (item) => (item['snippet']['resourceId']['videoId'] as String?) ?? '',
        )
        .where((id) => id.isNotEmpty)
        .join(',');

    if (videoIds.isEmpty) return [];

    // 3. Video detaylarını al
    final videosResponse = await http.get(
      Uri.parse(
        '$_baseUrl/videos'
        '?part=snippet,contentDetails,statistics'
        '&id=$videoIds'
        '&key=$_apiKey',
      ),
    );

    if (videosResponse.statusCode != 200) {
      throw Exception(
        'Video detayları alınamadı (${videosResponse.statusCode})',
      );
    }

    final videosData = json.decode(videosResponse.body) as Map<String, dynamic>;
    final videoItems = videosData['items'] as List? ?? [];

    return videoItems
        .map((item) => VideoModel.fromYouTubeApi(item as Map<String, dynamic>))
        .toList();
  }
}
