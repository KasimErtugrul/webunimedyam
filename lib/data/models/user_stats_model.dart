/*UserStatsModel
Kaynak: user_stats view'i — 6 tablodan hesaplanan sonuç
%100 view
userId, username, fullName, avatarUrl — profiles tablosundan
totalWatched, totalLiked, currentStreakDays, topUniversityName, 
lastWatchedTitle... — hesaplanan
Bu model da tamamen user_stats view'ini temsil ediyor. 
profiles tablosunun tüm kolonları değil, sadece özet birkaç alan burada var.
*/

import 'package:equatable/equatable.dart';

class UserStatsModel extends Equatable {
  final String userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? memberSince;

  // Sayımlar
  final int totalWatched;
  final int totalLiked;
  final int totalFavorited;
  final int totalCommented;
  final int totalShared;
  final int uniqueUniversitiesWatched;
  final int watchedThisWeek;
  final int watchedThisMonth;
  final int estimatedWatchMinutes;

  final DateTime? firstWatchAt;
  final DateTime? lastWatchAt;

  // Seri
  final int currentStreakDays;
  final int longestStreakDays;

  // En çok izlenen üniversite (null olabilir)
  final String? topUniversityName;
  final String? topUniversityLogo;
  final int? topUniversityWatchCount;

  // Son izlenen video (null olabilir)
  final String? lastWatchedTitle;
  final String? lastWatchedThumbnail;
  final DateTime? lastWatchedAt;

  // Son beğenilen video (null olabilir)
  final String? lastLikedTitle;
  final String? lastLikedThumbnail;
  final DateTime? lastLikedAt;

  const UserStatsModel({
    required this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.memberSince,
    this.totalWatched = 0,
    this.totalLiked = 0,
    this.totalFavorited = 0,
    this.totalCommented = 0,
    this.totalShared = 0,
    this.uniqueUniversitiesWatched = 0,
    this.watchedThisWeek = 0,
    this.watchedThisMonth = 0,
    this.estimatedWatchMinutes = 0,
    this.firstWatchAt,
    this.lastWatchAt,
    this.currentStreakDays = 0,
    this.longestStreakDays = 0,
    this.topUniversityName,
    this.topUniversityLogo,
    this.topUniversityWatchCount,
    this.lastWatchedTitle,
    this.lastWatchedThumbnail,
    this.lastWatchedAt,
    this.lastLikedTitle,
    this.lastLikedThumbnail,
    this.lastLikedAt,
  });

  factory UserStatsModel.fromMap(Map<String, dynamic> map) {
    return UserStatsModel(
      userId: map['user_id'] as String,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      memberSince: map['member_since'] != null
          ? DateTime.tryParse(map['member_since'].toString())
          : null,
      totalWatched: (map['total_watched'] as num?)?.toInt() ?? 0,
      totalLiked: (map['total_liked'] as num?)?.toInt() ?? 0,
      totalFavorited: (map['total_favorited'] as num?)?.toInt() ?? 0,
      totalCommented: (map['total_commented'] as num?)?.toInt() ?? 0,
      totalShared: (map['total_shared'] as num?)?.toInt() ?? 0,
      uniqueUniversitiesWatched:
          (map['unique_universities_watched'] as num?)?.toInt() ?? 0,
      watchedThisWeek: (map['watched_this_week'] as num?)?.toInt() ?? 0,
      watchedThisMonth: (map['watched_this_month'] as num?)?.toInt() ?? 0,
      estimatedWatchMinutes:
          (map['estimated_watch_minutes'] as num?)?.toInt() ?? 0,
      firstWatchAt: map['first_watch_at'] != null
          ? DateTime.tryParse(map['first_watch_at'].toString())
          : null,
      lastWatchAt: map['last_watch_at'] != null
          ? DateTime.tryParse(map['last_watch_at'].toString())
          : null,
      currentStreakDays: (map['current_streak_days'] as num?)?.toInt() ?? 0,
      longestStreakDays: (map['longest_streak_days'] as num?)?.toInt() ?? 0,
      topUniversityName: map['top_university_name'] as String?,
      topUniversityLogo: map['top_university_logo'] as String?,
      topUniversityWatchCount: (map['top_university_watch_count'] as num?)
          ?.toInt(),
      lastWatchedTitle: map['last_watched_title'] as String?,
      lastWatchedThumbnail: map['last_watched_thumbnail'] as String?,
      lastWatchedAt: map['last_watched_at'] != null
          ? DateTime.tryParse(map['last_watched_at'].toString())
          : null,
      lastLikedTitle: map['last_liked_title'] as String?,
      lastLikedThumbnail: map['last_liked_thumbnail'] as String?,
      lastLikedAt: map['last_liked_at'] != null
          ? DateTime.tryParse(map['last_liked_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'username': username,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'member_since': memberSince?.toIso8601String(),
    'total_watched': totalWatched,
    'total_liked': totalLiked,
    'total_favorited': totalFavorited,
    'total_commented': totalCommented,
    'total_shared': totalShared,
    'unique_universities_watched': uniqueUniversitiesWatched,
    'watched_this_week': watchedThisWeek,
    'watched_this_month': watchedThisMonth,
    'estimated_watch_minutes': estimatedWatchMinutes,
    'first_watch_at': firstWatchAt?.toIso8601String(),
    'last_watch_at': lastWatchAt?.toIso8601String(),
    'current_streak_days': currentStreakDays,
    'longest_streak_days': longestStreakDays,
    'top_university_name': topUniversityName,
    'top_university_logo': topUniversityLogo,
    'top_university_watch_count': topUniversityWatchCount,
    'last_watched_title': lastWatchedTitle,
    'last_watched_thumbnail': lastWatchedThumbnail,
    'last_watched_at': lastWatchedAt?.toIso8601String(),
    'last_liked_title': lastLikedTitle,
    'last_liked_thumbnail': lastLikedThumbnail,
    'last_liked_at': lastLikedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return 'UserStatsModel{userId=$userId, username=$username, fullName=$fullName, avatarUrl=$avatarUrl, memberSince=$memberSince, totalWatched=$totalWatched, totalLiked=$totalLiked, totalFavorited=$totalFavorited, totalCommented=$totalCommented, totalShared=$totalShared, uniqueUniversitiesWatched=$uniqueUniversitiesWatched, watchedThisWeek=$watchedThisWeek, watchedThisMonth=$watchedThisMonth, estimatedWatchMinutes=$estimatedWatchMinutes, firstWatchAt=$firstWatchAt, lastWatchAt=$lastWatchAt, currentStreakDays=$currentStreakDays, longestStreakDays=$longestStreakDays, topUniversityName=$topUniversityName, topUniversityLogo=$topUniversityLogo, topUniversityWatchCount=$topUniversityWatchCount, lastWatchedTitle=$lastWatchedTitle, lastWatchedThumbnail=$lastWatchedThumbnail, lastWatchedAt=$lastWatchedAt, lastLikedTitle=$lastLikedTitle, lastLikedThumbnail=$lastLikedThumbnail, lastLikedAt=$lastLikedAt}';
  }

  /// YENİ: Uygulama içi aksiyonlardan (izleme/beğeni/favori/yorum/paylaşım)
  /// sonra istatistikleri Supabase'e tekrar sormadan yerelde güncelleyebilmek
  /// için eklendi (bkz. LocalDataSource.recordLocal*** metodları).
  UserStatsModel copyWith({
    String? userId,
    String? username,
    String? fullName,
    String? avatarUrl,
    DateTime? memberSince,
    int? totalWatched,
    int? totalLiked,
    int? totalFavorited,
    int? totalCommented,
    int? totalShared,
    int? uniqueUniversitiesWatched,
    int? watchedThisWeek,
    int? watchedThisMonth,
    int? estimatedWatchMinutes,
    DateTime? firstWatchAt,
    DateTime? lastWatchAt,
    int? currentStreakDays,
    int? longestStreakDays,
    String? topUniversityName,
    String? topUniversityLogo,
    int? topUniversityWatchCount,
    String? lastWatchedTitle,
    String? lastWatchedThumbnail,
    DateTime? lastWatchedAt,
    String? lastLikedTitle,
    String? lastLikedThumbnail,
    DateTime? lastLikedAt,
  }) {
    return UserStatsModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberSince: memberSince ?? this.memberSince,
      totalWatched: totalWatched ?? this.totalWatched,
      totalLiked: totalLiked ?? this.totalLiked,
      totalFavorited: totalFavorited ?? this.totalFavorited,
      totalCommented: totalCommented ?? this.totalCommented,
      totalShared: totalShared ?? this.totalShared,
      uniqueUniversitiesWatched:
          uniqueUniversitiesWatched ?? this.uniqueUniversitiesWatched,
      watchedThisWeek: watchedThisWeek ?? this.watchedThisWeek,
      watchedThisMonth: watchedThisMonth ?? this.watchedThisMonth,
      estimatedWatchMinutes:
          estimatedWatchMinutes ?? this.estimatedWatchMinutes,
      firstWatchAt: firstWatchAt ?? this.firstWatchAt,
      lastWatchAt: lastWatchAt ?? this.lastWatchAt,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      longestStreakDays: longestStreakDays ?? this.longestStreakDays,
      topUniversityName: topUniversityName ?? this.topUniversityName,
      topUniversityLogo: topUniversityLogo ?? this.topUniversityLogo,
      topUniversityWatchCount:
          topUniversityWatchCount ?? this.topUniversityWatchCount,
      lastWatchedTitle: lastWatchedTitle ?? this.lastWatchedTitle,
      lastWatchedThumbnail: lastWatchedThumbnail ?? this.lastWatchedThumbnail,
      lastWatchedAt: lastWatchedAt ?? this.lastWatchedAt,
      lastLikedTitle: lastLikedTitle ?? this.lastLikedTitle,
      lastLikedThumbnail: lastLikedThumbnail ?? this.lastLikedThumbnail,
      lastLikedAt: lastLikedAt ?? this.lastLikedAt,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    username,
    fullName,
    avatarUrl,
    memberSince,
    totalWatched,
    totalLiked,
    totalFavorited,
    totalCommented,
    totalShared,
    uniqueUniversitiesWatched,
    watchedThisWeek,
    watchedThisMonth,
    estimatedWatchMinutes,
    firstWatchAt,
    lastWatchAt,
    currentStreakDays,
    longestStreakDays,
    topUniversityName,
    topUniversityLogo,
    topUniversityWatchCount,
    lastWatchedTitle,
    lastWatchedThumbnail,
    lastWatchedAt,
    lastLikedTitle,
    lastLikedThumbnail,
    lastLikedAt,
  ];
}
