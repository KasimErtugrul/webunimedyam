class UniversityModel {
  final int id;
  final String name;
  final String channelId;
  final DateTime createdAt;
  final String? logoUrl;
  final String? uploadsPlaylistId;

  UniversityModel({
    required this.id,
    required this.name,
    required this.channelId,
    required this.createdAt,
    this.logoUrl,
    this.uploadsPlaylistId,
  });

  factory UniversityModel.fromSupabase(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      channelId: json['channel_id'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      uploadsPlaylistId: json['uploads_playlist_id'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
