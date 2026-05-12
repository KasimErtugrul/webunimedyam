class PlaylistModel {
  final String playlistId;
  final String title;
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

  factory PlaylistModel.fromYouTubeApi(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>? ?? {};
    final contentDetails =
        json['contentDetails'] as Map<String, dynamic>? ?? {};

    return PlaylistModel(
      playlistId: json['id'] as String? ?? '',
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      thumbnailUrl:
          (snippet['thumbnails'] as Map<String, dynamic>?)?['high']?['url']
              as String? ??
          (snippet['thumbnails'] as Map<String, dynamic>?)?['medium']?['url']
              as String? ??
          (snippet['thumbnails'] as Map<String, dynamic>?)?['default']?['url']
              as String? ??
          '',
      itemCount: contentDetails['itemCount'] as int? ?? 0,
    );
  }
}
