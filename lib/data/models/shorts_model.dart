// lib/data/models/shorts_model.dart

class ShortsModel {
  final String videoId;
  final String title;
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
}