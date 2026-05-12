import 'profile_model.dart';

class CommentModel {
  final String id;
  final String userId;
  final String videoId;
  final String content;
  final DateTime createdAt;
  final ProfileModel? profile;

  CommentModel({
    required this.id,
    required this.userId,
    required this.videoId,
    required this.content,
    required this.createdAt,
    this.profile,
  });

  factory CommentModel.fromSupabase(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      videoId: json['video_id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      profile: json['profiles'] != null
          ? ProfileModel.fromSupabase(json['profiles'])
          : null,
    );
  }
}