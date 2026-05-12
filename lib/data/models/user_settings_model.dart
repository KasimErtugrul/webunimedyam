class UserSettingsModel {
  final String userId;
  final bool notificationsEnabled;
  final String theme;
  final String language;
  final bool autoplay;

  UserSettingsModel({
    required this.userId,
    this.notificationsEnabled = true,
    this.theme = 'dark',
    this.language = 'tr',
    this.autoplay = true,
  });

  factory UserSettingsModel.fromSupabase(Map<String, dynamic> json) {
    return UserSettingsModel(
      userId: json['user_id'] ?? '',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      theme: json['theme'] ?? 'dark',
      language: json['language'] ?? 'tr',
      autoplay: json['autoplay'] ?? true,
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'user_id': userId,
      'notifications_enabled': notificationsEnabled,
      'theme': theme,
      'language': language,
      'autoplay': autoplay,
    };
  }

  UserSettingsModel copyWith({
    bool? notificationsEnabled,
    String? theme,
    String? language,
    bool? autoplay,
  }) {
    return UserSettingsModel(
      userId: userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      autoplay: autoplay ?? this.autoplay,
    );
  }
}