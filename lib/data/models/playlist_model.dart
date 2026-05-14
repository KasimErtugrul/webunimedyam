class PlaylistModel {
  final String playlistId; // university_id (string'e çevrilmiş)
  final String title;      // university name
  final String description;
  final String thumbnailUrl;
  final int itemCount;

  PlaylistModel({
    required this.playlistId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.itemCount,
  });

  /// Supabase `universities` tablosundan oluşturur.
  /// [videoCount]: o üniversiteye ait video sayısı (opsiyonel)
  factory PlaylistModel.fromUniversity(
    Map<String, dynamic> json, {
    int videoCount = 0,
    String thumbnailUrl = '',
  }) {
    return PlaylistModel(
      playlistId: json['id'].toString(),
      title: json['name'] as String? ?? '',
      description: '',
      thumbnailUrl: thumbnailUrl,
      itemCount: videoCount,
    );
  }
}
