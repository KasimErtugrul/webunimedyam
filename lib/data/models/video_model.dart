
class VideoModel {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl; // high kalite
  final String maxresThumbnailUrl; // maxres (varsa)
  final String duration; // ISO 8601 — PT1M57S gibi
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final List<String> tags;
  final bool isHd; // definition == "hd"
  final String channelTitle;
  final DateTime publishedAt;

  VideoModel({
    required this.videoId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    this.maxresThumbnailUrl = '',
    required this.duration,
    required this.viewCount,
    this.likeCount = 0,
    this.commentCount = 0,
    this.tags = const [],
    this.isHd = false,
    this.channelTitle = 'ÇOMÜ TV',
    required this.publishedAt,
  });

  // ─── YouTube API ──────────────────────────────────────────────────────────

  factory VideoModel.fromYouTubeApi(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final contentDetails =
        json['contentDetails'] as Map<String, dynamic>? ?? {};
    final statistics = json['statistics'] as Map<String, dynamic>? ?? {};
    final thumbs = snippet['thumbnails'] as Map<String, dynamic>? ?? {};
    return VideoModel(
      videoId: json['id'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',

      thumbnailUrl:
          (thumbs['high']?['url'] as String?) ??
          (thumbs['medium']?['url'] as String?) ??
          (thumbs['default']?['url'] as String?) ??
          '',

      maxresThumbnailUrl:
          (thumbs['maxres']?['url'] as String?) ??
          (thumbs['standard']?['url'] as String?) ??
          '',

      duration: contentDetails['duration'] as String? ?? '',

      viewCount: int.tryParse(statistics['viewCount'] as String? ?? '0') ?? 0,
      likeCount: int.tryParse(statistics['likeCount'] as String? ?? '0') ?? 0,
      commentCount:
          int.tryParse(statistics['commentCount'] as String? ?? '0') ?? 0,

      tags:
          (snippet['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],

      isHd: (contentDetails['definition'] as String?) == 'hd',

      channelTitle: snippet['channelTitle'] as String? ?? 'ÇOMÜ TV',

      publishedAt:
          DateTime.tryParse(snippet['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ─── Supabase ─────────────────────────────────────────────────────────────

  factory VideoModel.fromSupabase(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['video_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      maxresThumbnailUrl: json['maxres_thumbnail_url'] ?? '',
      duration: json['duration'] ?? '',
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
          [],
      isHd: json['is_hd'] ?? false,
      channelTitle: json['channel_title'] ?? 'ÇOMÜ TV',
      publishedAt:
          DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'video_id': videoId,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'maxres_thumbnail_url': maxresThumbnailUrl,
      'duration': duration,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'tags': tags,
      'is_hd': isHd,
      'channel_title': channelTitle,
      'published_at': publishedAt.toIso8601String(),
      'cached_at': DateTime.now().toIso8601String(),
    };
  }

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

  /// ISO 8601 süreyi "1:57" veya "19:45" formatına çevirir.
  String get formattedDuration {
    final match = RegExp(
      r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
    ).firstMatch(duration);
    if (match == null) return '';
    final h = int.tryParse(match.group(1) ?? '0') ?? 0;
    final m = int.tryParse(match.group(2) ?? '0') ?? 0;
    final s = int.tryParse(match.group(3) ?? '0') ?? 0;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// Görüntülenme sayısını kısaltır: 1.2B, 45B, 1.3M gibi.
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M görüntülenme';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}B görüntülenme';
    }
    return '$viewCount görüntülenme';
  }

  /// En iyi mevcut thumbnail URL'ini döner (maxres > high).
  String get bestThumbnail =>
      maxresThumbnailUrl.isNotEmpty ? maxresThumbnailUrl : thumbnailUrl;
}
