// lib/data/models/profile_model.dart
import 'package:equatable/equatable.dart';

import 'user_settings_model.dart';

class ProfileModel extends Equatable {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime?
  updatedAt; // BUG FIX: DB'de updated_at var ama model okumuyordu

  /// Profilin kim tarafından görülebileceğini belirler.
  /// 'public' → herkes, 'friends' → takipçiler, 'private' → sadece sahip
  ///
  /// BUG FIX: Bu alan DB'de profile_visibility kolonu olarak saklanır.
  /// Önceki kodda kolon DB'de yoktu; fromSupabase() null okuyup varsayılan
  /// 'public' veriyordu, toSupabase() ise kolona yazmaya çalışıyordu fakat
  /// Supabase sessizce ignore ediyordu. Migration ile kolon eklendi.
  final VisibilityOption profileVisibility;

  const ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.profileVisibility = VisibilityOption.public,
  });

  factory ProfileModel.fromSupabase(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      // BUG FIX: updated_at artık okunuyor
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      // BUG FIX: Kolon artık DB'de mevcut; null gelirse güvenli varsayılan
      profileVisibility: VisibilityOption.fromString(
        json['profile_visibility'] as String?,
      ),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      // BUG FIX: profile_visibility artık DB'ye yazılıyor
      'profile_visibility': profileVisibility.value,
      // updated_at — DB trigger'ı (trg_profiles_updated_at) otomatik günceller,
      // buradan göndermemize gerek yok; gereksiz alan yazmaktan kaçınıyoruz.
    };
  }

  ProfileModel copyWith({
    String? username,
    String? fullName,
    String? avatarUrl,
    VisibilityOption? profileVisibility,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }

  @override
  String toString() {
    return 'ProfileModel{id=$id, username=$username, fullName=$fullName, avatarUrl=$avatarUrl, createdAt=$createdAt, updatedAt=$updatedAt, profileVisibility=$profileVisibility}';
  }

  @override
  List<Object?> get props => [
    id,
    username,
    fullName,
    avatarUrl,
    createdAt,
    updatedAt,
    profileVisibility,
  ];
}
