// lib/data/models/user_settings_model.dart

/// Aktivite ve profil görünürlük seçenekleri
enum VisibilityOption {
  /// Herkese açık
  public,
  /// Sadece takipçilere açık
  friends,
  /// Sadece sahibine açık
  private;

  String get label {
    switch (this) {
      case VisibilityOption.public:  return 'Herkese açık';
      case VisibilityOption.friends: return 'Arkadaşlara açık';
      case VisibilityOption.private: return 'Gizli';
    }
  }

  String get sublabel {
    switch (this) {
      case VisibilityOption.public:  return 'Herkes görebilir';
      case VisibilityOption.friends: return 'Sadece takipçilerin görebilir';
      case VisibilityOption.private: return 'Sadece sen görebilirsin';
    }
  }

  String get value {
    switch (this) {
      case VisibilityOption.public:  return 'public';
      case VisibilityOption.friends: return 'friends';
      case VisibilityOption.private: return 'private';
    }
  }

  static VisibilityOption fromString(String? s) {
    switch (s) {
      case 'friends': return VisibilityOption.friends;
      case 'private': return VisibilityOption.private;
      default:        return VisibilityOption.public;
    }
  }
}

class UserSettingsModel {
  final String userId;

  // ─── Görünüm ───────────────────────────────────────────────────────────────
  final String theme;            // 'dark' | 'light' | 'system'

  // ─── Oynatma ──────────────────────────────────────────────────────────────
  final bool autoplay;
  final bool showSubtitles;
  final String videoQuality;     // 'auto' | '1080p' | '720p' | '480p' | '360p'

  // ─── Bildirimler ──────────────────────────────────────────────────────────
  final bool notificationsEnabled;
  final bool notifyNewVideos;
  final bool notifyCommentReplies;
  final bool notifyFollowRequests; // YENİ: takip isteği bildirimi

  // ─── Gizlilik (Eski boolean alanlar — geriye uyumluluk için korundu) ──────
  final bool showWatchHistory;
  final bool showFavoritesPublic;

  // ─── Aktivite Görünürlüğü (YENİ) ──────────────────────────────────────────
  final VisibilityOption watchHistoryVisibility;
  final VisibilityOption likesVisibility;
  final VisibilityOption favoritesVisibility;
  final VisibilityOption commentsVisibility;

  // ─── Erişilebilirlik ──────────────────────────────────────────────────────
  final bool reducedMotion;
  final double textScaleFactor;  // 0.8 | 1.0 | 1.2 | 1.4

  const UserSettingsModel({
    required this.userId,
    this.theme = 'system',
    this.autoplay = true,
    this.showSubtitles = false,
    this.videoQuality = 'auto',
    this.notificationsEnabled = true,
    this.notifyNewVideos = true,
    this.notifyCommentReplies = true,
    this.notifyFollowRequests = true,
    this.showWatchHistory = true,
    this.showFavoritesPublic = false,
    this.watchHistoryVisibility = VisibilityOption.public,
    this.likesVisibility        = VisibilityOption.public,
    this.favoritesVisibility    = VisibilityOption.public,
    this.commentsVisibility     = VisibilityOption.public,
    this.reducedMotion = false,
    this.textScaleFactor = 1.0,
  });

  factory UserSettingsModel.fromSupabase(Map<String, dynamic> json) {
    return UserSettingsModel(
      userId: json['user_id'] ?? '',
      theme: json['theme'] ?? 'system',
      autoplay: json['autoplay'] ?? true,
      showSubtitles: json['show_subtitles'] ?? false,
      videoQuality: json['video_quality'] ?? 'auto',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      notifyNewVideos: json['notify_new_videos'] ?? true,
      notifyCommentReplies: json['notify_comment_replies'] ?? true,
      notifyFollowRequests: json['notify_follow_requests'] ?? true,
      showWatchHistory: json['show_watch_history'] ?? true,
      showFavoritesPublic: json['show_favorites_public'] ?? false,
      watchHistoryVisibility: VisibilityOption.fromString(json['watch_history_visibility']),
      likesVisibility:        VisibilityOption.fromString(json['likes_visibility']),
      favoritesVisibility:    VisibilityOption.fromString(json['favorites_visibility']),
      commentsVisibility:     VisibilityOption.fromString(json['comments_visibility']),
      reducedMotion: json['reduced_motion'] ?? false,
      textScaleFactor: (json['text_scale_factor'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'theme': theme,
      'autoplay': autoplay,
      'show_subtitles': showSubtitles,
      'video_quality': videoQuality,
      'notifications_enabled': notificationsEnabled,
      'notify_new_videos': notifyNewVideos,
      'notify_comment_replies': notifyCommentReplies,
      'notify_follow_requests': notifyFollowRequests,
      'show_watch_history': showWatchHistory,
      'show_favorites_public': showFavoritesPublic,
      'watch_history_visibility': watchHistoryVisibility.value,
      'likes_visibility': likesVisibility.value,
      'favorites_visibility': favoritesVisibility.value,
      'comments_visibility': commentsVisibility.value,
      'reduced_motion': reducedMotion,
      'text_scale_factor': textScaleFactor,
    };
  }

  UserSettingsModel copyWith({
    String? theme,
    bool? autoplay,
    bool? showSubtitles,
    String? videoQuality,
    bool? notificationsEnabled,
    bool? notifyNewVideos,
    bool? notifyCommentReplies,
    bool? notifyFollowRequests,
    bool? showWatchHistory,
    bool? showFavoritesPublic,
    VisibilityOption? watchHistoryVisibility,
    VisibilityOption? likesVisibility,
    VisibilityOption? favoritesVisibility,
    VisibilityOption? commentsVisibility,
    bool? reducedMotion,
    double? textScaleFactor,
  }) {
    return UserSettingsModel(
      userId: userId,
      theme: theme ?? this.theme,
      autoplay: autoplay ?? this.autoplay,
      showSubtitles: showSubtitles ?? this.showSubtitles,
      videoQuality: videoQuality ?? this.videoQuality,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notifyNewVideos: notifyNewVideos ?? this.notifyNewVideos,
      notifyCommentReplies: notifyCommentReplies ?? this.notifyCommentReplies,
      notifyFollowRequests: notifyFollowRequests ?? this.notifyFollowRequests,
      showWatchHistory: showWatchHistory ?? this.showWatchHistory,
      showFavoritesPublic: showFavoritesPublic ?? this.showFavoritesPublic,
      watchHistoryVisibility: watchHistoryVisibility ?? this.watchHistoryVisibility,
      likesVisibility: likesVisibility ?? this.likesVisibility,
      favoritesVisibility: favoritesVisibility ?? this.favoritesVisibility,
      commentsVisibility: commentsVisibility ?? this.commentsVisibility,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}