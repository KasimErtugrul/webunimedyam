// lib/data/models/university_stats_model.dart

/*  UniversityStatsModel
Kaynak: university_stats view'i — 7 tablodan hesaplanan sonuç
%100 view
universities'den gelenler
university_id, name, logo_url, city, subscriber_count
Hesaplanan / birleşik kolonlar
total_videos, total_yt_views, total_yt_likes, 
videos_last_30_days, total_duration_sec, app_total_views, 
app_total_likes, most_viewed_title, latest_video_title, 
app_top_video_title...
 */

import 'package:equatable/equatable.dart';

class UniversityStatsModel extends Equatable {
  final int universityId;
  final String name;
  final String? logoUrl;
  final String? city;
  final int subscriberCount;

  final int totalVideos;
  final int totalYtViews;
  final int totalYtLikes;
  final int totalYtComments;

  final int appTotalViewers;
  final int appTotalViews;
  final int appTotalLikes;
  final int appTotalFavorites;
  final int appTotalShares;

  final int videosLast30Days;
  final int videosLast7Days;

  final int totalDurationSec;
  final int avgDurationSec;

  final String? mostViewedTitle;
  final String? mostViewedThumbnail;
  final int mostViewedViewCount;

  final String? latestVideoTitle;
  final String? latestVideoThumbnail;
  final DateTime? latestVideoPublishedAt;

  final String? appTopVideoTitle;
  final String? appTopVideoThumbnail;
  final int appTopVideoViews;

  const UniversityStatsModel({
    required this.universityId,
    required this.name,
    this.logoUrl,
    this.city,
    required this.subscriberCount,
    required this.totalVideos,
    required this.totalYtViews,
    required this.totalYtLikes,
    required this.totalYtComments,
    required this.appTotalViewers,
    required this.appTotalViews,
    required this.appTotalLikes,
    required this.appTotalFavorites,
    required this.appTotalShares,
    required this.videosLast30Days,
    required this.videosLast7Days,
    required this.totalDurationSec,
    required this.avgDurationSec,
    this.mostViewedTitle,
    this.mostViewedThumbnail,
    required this.mostViewedViewCount,
    this.latestVideoTitle,
    this.latestVideoThumbnail,
    this.latestVideoPublishedAt,
    this.appTopVideoTitle,
    this.appTopVideoThumbnail,
    required this.appTopVideoViews,
  });

  factory UniversityStatsModel.fromMap(Map<String, dynamic> map) {
    return UniversityStatsModel(
      universityId: _toInt(map['university_id']),
      name: map['name'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
      city: map['city'] as String?,
      subscriberCount: _toInt(map['subscriber_count']),
      totalVideos: _toInt(map['total_videos']),
      totalYtViews: _toInt(map['total_yt_views']),
      totalYtLikes: _toInt(map['total_yt_likes']),
      totalYtComments: _toInt(map['total_yt_comments']),
      appTotalViewers: _toInt(map['app_total_viewers']),
      appTotalViews: _toInt(map['app_total_views']),
      appTotalLikes: _toInt(map['app_total_likes']),
      appTotalFavorites: _toInt(map['app_total_favorites']),
      appTotalShares: _toInt(map['app_total_shares']),
      videosLast30Days: _toInt(map['videos_last_30_days']),
      videosLast7Days: _toInt(map['videos_last_7_days']),
      totalDurationSec: _toInt(map['total_duration_sec']),
      avgDurationSec: _toInt(map['avg_duration_sec']),
      mostViewedTitle: map['most_viewed_title'] as String?,
      mostViewedThumbnail: map['most_viewed_thumbnail'] as String?,
      mostViewedViewCount: _toInt(map['most_viewed_view_count']),
      latestVideoTitle: map['latest_video_title'] as String?,
      latestVideoThumbnail: map['latest_video_thumbnail'] as String?,
      latestVideoPublishedAt: map['latest_video_published_at'] != null
          ? DateTime.tryParse(map['latest_video_published_at'] as String)
          : null,
      appTopVideoTitle: map['app_top_video_title'] as String?,
      appTopVideoThumbnail: map['app_top_video_thumbnail'] as String?,
      appTopVideoViews: _toInt(map['app_top_video_views']),
    );
  }

  Map<String, dynamic> toMap() => {
    'university_id': universityId,
    'name': name,
    'logo_url': logoUrl,
    'city': city,
    'subscriber_count': subscriberCount,
    'total_videos': totalVideos,
    'total_yt_views': totalYtViews,
    'total_yt_likes': totalYtLikes,
    'total_yt_comments': totalYtComments,
    'app_total_viewers': appTotalViewers,
    'app_total_views': appTotalViews,
    'app_total_likes': appTotalLikes,
    'app_total_favorites': appTotalFavorites,
    'app_total_shares': appTotalShares,
    'videos_last_30_days': videosLast30Days,
    'videos_last_7_days': videosLast7Days,
    'total_duration_sec': totalDurationSec,
    'avg_duration_sec': avgDurationSec,
    'most_viewed_title': mostViewedTitle,
    'most_viewed_thumbnail': mostViewedThumbnail,
    'most_viewed_view_count': mostViewedViewCount,
    'latest_video_title': latestVideoTitle,
    'latest_video_thumbnail': latestVideoThumbnail,
    'latest_video_published_at': latestVideoPublishedAt?.toIso8601String(),
    'app_top_video_title': appTopVideoTitle,
    'app_top_video_thumbnail': appTopVideoThumbnail,
    'app_top_video_views': appTopVideoViews,
  };

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  String toString() {
    return 'UniversityStatsModel{universityId=$universityId, name=$name, logoUrl=$logoUrl, city=$city, subscriberCount=$subscriberCount, totalVideos=$totalVideos, totalYtViews=$totalYtViews, totalYtLikes=$totalYtLikes, totalYtComments=$totalYtComments, appTotalViewers=$appTotalViewers, appTotalViews=$appTotalViews, appTotalLikes=$appTotalLikes, appTotalFavorites=$appTotalFavorites, appTotalShares=$appTotalShares, videosLast30Days=$videosLast30Days, videosLast7Days=$videosLast7Days, totalDurationSec=$totalDurationSec, avgDurationSec=$avgDurationSec, mostViewedTitle=$mostViewedTitle, mostViewedThumbnail=$mostViewedThumbnail, mostViewedViewCount=$mostViewedViewCount, latestVideoTitle=$latestVideoTitle, latestVideoThumbnail=$latestVideoThumbnail, latestVideoPublishedAt=$latestVideoPublishedAt, appTopVideoTitle=$appTopVideoTitle, appTopVideoThumbnail=$appTopVideoThumbnail, appTopVideoViews=$appTopVideoViews}';
  }

  @override
  List<Object?> get props => [
    universityId,
    name,
    logoUrl,
    city,
    subscriberCount,
    totalVideos,
    totalYtViews,
    totalYtLikes,
    totalYtComments,
    appTotalViewers,
    appTotalViews,
    appTotalLikes,
    appTotalFavorites,
    appTotalShares,
    videosLast30Days,
    videosLast7Days,
    totalDurationSec,
    avgDurationSec,
    mostViewedTitle,
    mostViewedThumbnail,
    mostViewedViewCount,
    latestVideoTitle,
    latestVideoThumbnail,
    latestVideoPublishedAt,
    appTopVideoTitle,
    appTopVideoThumbnail,
    appTopVideoViews,
  ];
}
