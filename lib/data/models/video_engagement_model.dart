// lib/data/models/video_engagement_model.dart

import 'video_model.dart';

class VideoEngagementModel {
  final String videoId;
  final String title;
  final String channelTitle;
  final int? universityId;
  final DateTime publishedAt;
  final String duration;
  final bool isHd;
  final bool isLive;
  final int ytViewCount;
  final int ytLikeCount;
  final int appViewCount;
  final int appLikeCount;
  final int appFavoriteCount;
  final int appShareCount;
  final int appCommentCount;
  final int engagementScore;
  final double likeRatePct;
  final double commentRatePct;
  final DateTime? firstViewedAt;
  final DateTime? lastViewedAt;

  const VideoEngagementModel({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    this.universityId,
    required this.publishedAt,
    required this.duration,
    required this.isHd,
    required this.isLive,
    required this.ytViewCount,
    required this.ytLikeCount,
    required this.appViewCount,
    required this.appLikeCount,
    required this.appFavoriteCount,
    required this.appShareCount,
    required this.appCommentCount,
    required this.engagementScore,
    required this.likeRatePct,
    required this.commentRatePct,
    this.firstViewedAt,
    this.lastViewedAt,
  });

  String get thumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/maxresdefault.jpg';

  String get fallbackThumbnailUrl =>
      'https://img.youtube.com/vi/$videoId/hqdefault.jpg';

  /// Player'a geçmek için VideoModel'e dönüştür
  VideoModel toVideoModel() => VideoModel(
        videoId: videoId,
        title: title,
        description: '',
        thumbnailUrl: fallbackThumbnailUrl,
        maxresThumbnailUrl: thumbnailUrl,
        duration: duration,
        viewCount: ytViewCount,
        likeCount: ytLikeCount,
        commentCount: 0,
        tags: const [],
        isHd: isHd,
        channelTitle: channelTitle,
        publishedAt: publishedAt,
        universityId: universityId,
      );

  factory VideoEngagementModel.fromMap(Map<String, dynamic> map) {
    return VideoEngagementModel(
      videoId: map['video_id'] as String,
      title: map['title'] as String? ?? '',
      channelTitle: map['channel_title'] as String? ?? '',
      universityId: map['university_id'] as int?,
      publishedAt:
          DateTime.tryParse(map['published_at'] as String? ?? '') ??
              DateTime.now(),
      duration: map['duration'] as String? ?? '',
      isHd: map['is_hd'] as bool? ?? false,
      isLive: map['is_live'] as bool? ?? false,
      ytViewCount: (map['yt_view_count'] as num?)?.toInt() ?? 0,
      ytLikeCount: (map['yt_like_count'] as num?)?.toInt() ?? 0,
      appViewCount: (map['app_view_count'] as num?)?.toInt() ?? 0,
      appLikeCount: (map['app_like_count'] as num?)?.toInt() ?? 0,
      appFavoriteCount: (map['app_favorite_count'] as num?)?.toInt() ?? 0,
      appShareCount: (map['app_share_count'] as num?)?.toInt() ?? 0,
      appCommentCount: (map['app_comment_count'] as num?)?.toInt() ?? 0,
      engagementScore: (map['engagement_score'] as num?)?.toInt() ?? 0,
      likeRatePct: (map['like_rate_pct'] as num?)?.toDouble() ?? 0.0,
      commentRatePct: (map['comment_rate_pct'] as num?)?.toDouble() ?? 0.0,
      firstViewedAt: map['first_viewed_at'] != null
          ? DateTime.tryParse(map['first_viewed_at'] as String)
          : null,
      lastViewedAt: map['last_viewed_at'] != null
          ? DateTime.tryParse(map['last_viewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'video_id': videoId,
    'title': title,
    'channel_title': channelTitle,
    'university_id': universityId,
    'published_at': publishedAt.toIso8601String(),
    'duration': duration,
    'is_hd': isHd,
    'is_live': isLive,
    'yt_view_count': ytViewCount,
    'yt_like_count': ytLikeCount,
    'app_view_count': appViewCount,
    'app_like_count': appLikeCount,
    'app_favorite_count': appFavoriteCount,
    'app_share_count': appShareCount,
    'app_comment_count': appCommentCount,
    'engagement_score': engagementScore,
    'like_rate_pct': likeRatePct,
    'comment_rate_pct': commentRatePct,
    'first_viewed_at': firstViewedAt?.toIso8601String(),
    'last_viewed_at': lastViewedAt?.toIso8601String(),
  };


@override
String toString() {
    return 'VideoEngagementModel{videoId=$videoId, title=$title, channelTitle=$channelTitle, universityId=$universityId, publishedAt=$publishedAt, duration=$duration, isHd=$isHd, isLive=$isLive, ytViewCount=$ytViewCount, ytLikeCount=$ytLikeCount, appViewCount=$appViewCount, appLikeCount=$appLikeCount, appFavoriteCount=$appFavoriteCount, appShareCount=$appShareCount, appCommentCount=$appCommentCount, engagementScore=$engagementScore, likeRatePct=$likeRatePct, commentRatePct=$commentRatePct, firstViewedAt=$firstViewedAt, lastViewedAt=$lastViewedAt}';
  }
}
