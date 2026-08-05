// lib/data/models/shorts_model.dart

import 'package:equatable/equatable.dart';

class ShortsModel extends Equatable {
  final String videoId;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String maxresThumbnailUrl;
  final String duration;
  final DateTime publishedAt;
  final int universityId;
  final String universityName;
  final String? logoUrl;

  const ShortsModel({
    required this.videoId,
    required this.title,
    this.description = '',
    required this.thumbnailUrl,
    this.maxresThumbnailUrl = '',
    this.duration = '',
    required this.publishedAt,
    required this.universityId,
    required this.universityName,
    this.logoUrl,
  });

  String get bestThumbnail =>
      maxresThumbnailUrl.isNotEmpty ? maxresThumbnailUrl : thumbnailUrl;

  factory ShortsModel.fromMap(Map<String, dynamic> map) {
    return ShortsModel(
      videoId: map['video_id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      maxresThumbnailUrl: map['maxres_thumbnail_url'] as String? ?? '',
      duration: map['duration'] as String? ?? '',
      publishedAt:
          DateTime.tryParse(map['published_at'] as String? ?? '') ??
          DateTime.now(),
      universityId: (map['university_id'] as num?)?.toInt() ?? 0,
      universityName: map['university_name'] as String? ?? '',
      logoUrl: map['logo_url'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    videoId,
    title,
    description,
    thumbnailUrl,
    maxresThumbnailUrl,
    duration,
    publishedAt,
    universityId,
    universityName,
    logoUrl,
  ];

  @override
  String toString() {
    return 'ShortsModel{videoId=$videoId, title=$title, description=$description, thumbnailUrl=$thumbnailUrl, maxresThumbnailUrl=$maxresThumbnailUrl, duration=$duration, publishedAt=$publishedAt, universityId=$universityId, universityName=$universityName, logoUrl=$logoUrl}';
  }
}
