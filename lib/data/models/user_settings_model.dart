class UserSettingsModel {
  final String userId;

  // ─── Görünüm ───────────────────────────────────────────────────────────────
  final String theme;            // 'dark' | 'light' | 'system'

  // ─── Oynatma ──────────────────────────────────────────────────────────────
  final bool autoplay;
  final bool showSubtitles;       // Altyazı varsayılanı
  final String videoQuality;      // 'auto' | '1080p' | '720p' | '480p' | '360p'

  // ─── Bildirimler ──────────────────────────────────────────────────────────
  final bool notificationsEnabled;
  final bool notifyNewVideos;     // Yeni video bildirimi
  final bool notifyCommentReplies; // Yorum cevap bildirimi

  // ─── Gizlilik ─────────────────────────────────────────────────────────────
  final bool showWatchHistory;    // İzleme geçmişini göster
  final bool showFavoritesPublic; // Favorileri herkese açık göster

  // ─── Erişilebilirlik ──────────────────────────────────────────────────────
  final bool reducedMotion;       // Animasyonları azalt
  final double textScaleFactor;   // 0.8 | 1.0 | 1.2 | 1.4

  UserSettingsModel({
    required this.userId,
    this.theme = 'system',
    this.autoplay = true,
    this.showSubtitles = false,
    this.videoQuality = 'auto',
    this.notificationsEnabled = true,
    this.notifyNewVideos = true,
    this.notifyCommentReplies = true,
    this.showWatchHistory = true,
    this.showFavoritesPublic = false,
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
      showWatchHistory: json['show_watch_history'] ?? true,
      showFavoritesPublic: json['show_favorites_public'] ?? false,
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
      'show_watch_history': showWatchHistory,
      'show_favorites_public': showFavoritesPublic,
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
    bool? showWatchHistory,
    bool? showFavoritesPublic,
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
      showWatchHistory: showWatchHistory ?? this.showWatchHistory,
      showFavoritesPublic: showFavoritesPublic ?? this.showFavoritesPublic,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }
}