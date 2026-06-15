class VideoModel {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String maxresThumbnailUrl;
  final String duration;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final List<String> tags;
  final bool isHd;
  final bool isShorts;
  final String channelTitle;
  final DateTime publishedAt;
  final int? universityId;
  final String? universityName;
  final String liveBroadcastContent;

  // Uygulama istatistikleri (video_engagement_stats view'inden)
  final int appViewCount;
  final int appLikeCount;
  final int appFavoriteCount;
  final int appShareCount;
  final int appCommentCount;

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
    this.isShorts = false,
    this.channelTitle = 'ÇOMÜ TV',
    required this.publishedAt,
    this.liveBroadcastContent = '',
    this.universityId,
    this.universityName,
    this.appViewCount = 0,
    this.appLikeCount = 0,
    this.appFavoriteCount = 0,
    this.appShareCount = 0,
    this.appCommentCount = 0,
  });

  // ─── copyWith ─────────────────────────────────────────────────────────────

  VideoModel copyWith({
    String? videoId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? maxresThumbnailUrl,
    String? duration,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    List<String>? tags,
    bool? isHd,
    bool? isShorts,
    String? channelTitle,
    DateTime? publishedAt,
    int? universityId,
    String? universityName,
    int? appViewCount,
    int? appLikeCount,
    int? appFavoriteCount,
    int? appShareCount,
    int? appCommentCount,
    String? liveBroadcastContent,
  }) {
    return VideoModel(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      maxresThumbnailUrl: maxresThumbnailUrl ?? this.maxresThumbnailUrl,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      tags: tags ?? this.tags,
      isHd: isHd ?? this.isHd,
      isShorts: isShorts ?? this.isShorts,
      channelTitle: channelTitle ?? this.channelTitle,
      publishedAt: publishedAt ?? this.publishedAt,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      appViewCount: appViewCount ?? this.appViewCount,
      appLikeCount: appLikeCount ?? this.appLikeCount,
      appFavoriteCount: appFavoriteCount ?? this.appFavoriteCount,
      appShareCount: appShareCount ?? this.appShareCount,
      appCommentCount: appCommentCount ?? this.appCommentCount,
      liveBroadcastContent: liveBroadcastContent ?? this.liveBroadcastContent,
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
      isShorts: json['is_shorts'] ?? false,
      channelTitle: json['channel_title'] ?? 'ÇOMÜ TV',
      publishedAt:
          DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      universityId: json['university_id'] as int?,
      universityName: json['university_name'] as String?,
      // ── Bunları ekle ──
      appViewCount: (json['app_view_count'] as num?)?.toInt() ?? 0,
      appLikeCount: (json['app_like_count'] as num?)?.toInt() ?? 0,
      appFavoriteCount: (json['app_favorite_count'] as num?)?.toInt() ?? 0,
      appShareCount: (json['app_share_count'] as num?)?.toInt() ?? 0,
      appCommentCount: (json['app_comment_count'] as num?)?.toInt() ?? 0,
      liveBroadcastContent: json['live_broadcast_content'] ?? '',
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
      'is_shorts': isShorts,
      'channel_title': channelTitle,
      'published_at': publishedAt.toIso8601String(),
      'cached_at': DateTime.now().toIso8601String(),
      'live_broadcast_content': liveBroadcastContent, // ← BU SATIRI EKLE
      if (universityId != null) 'university_id': universityId,
      if (universityName != null) 'university_name': universityName,
      'app_view_count': appViewCount,
      'app_like_count': appLikeCount,
      'app_favorite_count': appFavoriteCount,
      'app_share_count': appShareCount,
      'app_comment_count': appCommentCount,
    };
  }

  // ─── Yardımcılar ─────────────────────────────────────────────────────────

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

  bool get isLiveBroadcast => liveBroadcastContent == 'live';
  bool get isUpcoming => liveBroadcastContent == 'upcoming';

  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M görüntülenme';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}B görüntülenme';
    }
    return '$viewCount görüntülenme';
  }

  String get bestThumbnail =>
      maxresThumbnailUrl.isNotEmpty ? maxresThumbnailUrl : thumbnailUrl;

  @override
  String toString() {
    return 'VideoModel{videoId=$videoId, title=$title, description=$description, thumbnailUrl=$thumbnailUrl, maxresThumbnailUrl=$maxresThumbnailUrl, duration=$duration, viewCount=$viewCount, likeCount=$likeCount, commentCount=$commentCount, tags=$tags, isHd=$isHd, isShorts=$isShorts, channelTitle=$channelTitle, publishedAt=$publishedAt, universityId=$universityId, universityName=$universityName, appViewCount=$appViewCount, appLikeCount=$appLikeCount, appFavoriteCount=$appFavoriteCount, appShareCount=$appShareCount, appCommentCount=$appCommentCount, liveBroadcastContent=$liveBroadcastContent}';
  }
}
