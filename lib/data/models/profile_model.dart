// lib/data/models/profile_model.dart
import 'user_settings_model.dart';

class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  /// Profilin kim tarafından görülebileceğini belirler.
  /// 'public' → herkes, 'friends' → takipçiler, 'private' → sadece sahip
  final VisibilityOption profileVisibility;

  ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    this.profileVisibility = VisibilityOption.public,
  });

  factory ProfileModel.fromSupabase(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      profileVisibility: VisibilityOption.fromString(json['profile_visibility']),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'profile_visibility': profileVisibility.value,
    };
  }

  ProfileModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    VisibilityOption? profileVisibility,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }
}