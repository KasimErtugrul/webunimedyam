// lib/data/models/video_viewer_model.dart

class VideoViewerModel {
  final String userId;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime viewedAt;
  final int totalCount;

  const VideoViewerModel({
    required this.userId,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.viewedAt,
    required this.totalCount,
  });

  String get displayName => fullName ?? username ?? 'Kullanıcı';

  factory VideoViewerModel.fromMap(Map<String, dynamic> map) {
    return VideoViewerModel(
      userId: map['user_id'] as String,
      username: map['username'] as String?,
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      viewedAt:
          DateTime.tryParse(map['viewed_at'] as String? ?? '') ?? DateTime.now(),
      totalCount: (map['total_count'] as num?)?.toInt() ?? 0,
    );
  }
}