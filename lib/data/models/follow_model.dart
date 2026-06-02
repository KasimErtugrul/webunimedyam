// lib/data/models/follow_model.dart

enum FollowStatus {
  pending,
  accepted;

  static FollowStatus fromString(String? s) {
    if (s == 'pending') return FollowStatus.pending;
    return FollowStatus.accepted;
  }

  String get value => name; // 'pending' | 'accepted'
}

class FollowModel {
  final String id;
  final String followerId;
  final String followingId;
  final FollowStatus status;
  final DateTime createdAt;

  /// Kullanıcı bilgileri (JOIN ile gelir — opsiyonel)
  final String? followerUsername;
  final String? followerAvatarUrl;
  final String? followingUsername;
  final String? followingAvatarUrl;

  const FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
    this.followerUsername,
    this.followerAvatarUrl,
    this.followingUsername,
    this.followingAvatarUrl,
  });

  factory FollowModel.fromSupabase(Map<String, dynamic> json) {
    // JOIN ile gelen iç içe profil objelerini parse et
    final followerProfile  = json['follower_profile']  as Map<String, dynamic>?;
    final followingProfile = json['following_profile'] as Map<String, dynamic>?;

    return FollowModel(
      id:          json['id'] ?? '',
      followerId:  json['follower_id'] ?? '',
      followingId: json['following_id'] ?? '',
      status:      FollowStatus.fromString(json['status']),
      createdAt:   DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      followerUsername:  followerProfile?['username'],
      followerAvatarUrl: followerProfile?['avatar_url'],
      followingUsername:  followingProfile?['username'],
      followingAvatarUrl: followingProfile?['avatar_url'],
    );
  }

  Map<String, dynamic> toSupabase() => {
    'id': id,
    'follower_id': followerId,
    'following_id': followingId,
    'status': status.value,
  };
}

/// Bir kullanıcının takip istatistiklerini tutar
class FollowCounts {
  final String userId;
  final int followersCount;
  final int followingCount;

  const FollowCounts({
    required this.userId,
    required this.followersCount,
    required this.followingCount,
  });

  factory FollowCounts.fromSupabase(Map<String, dynamic> json) {
    return FollowCounts(
      userId:         json['user_id'] ?? '',
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = FollowCounts(
    userId: '',
    followersCount: 0,
    followingCount: 0,
  );
}