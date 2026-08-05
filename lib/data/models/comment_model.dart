// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

import 'profile_model.dart';

class CommentModel extends Equatable {
  final String id;
  final String userId;
  final String videoId;
  final String content;
  final DateTime createdAt;
  final ProfileModel? profile;

  const CommentModel({
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

  @override
  String toString() {
    return 'CommentModel(id: $id, userId: $userId, videoId: $videoId, content: $content, createdAt: $createdAt, profile: $profile)';
  }

  @override
  List<Object?> get props => [id, userId, videoId, content, createdAt, profile];
}
