class UniversityModel {
  final int id;
  final String name;
  final String channelId;
  final DateTime createdAt;

  UniversityModel({
    required this.id,
    required this.name,
    required this.channelId,
    required this.createdAt,
  });

  factory UniversityModel.fromSupabase(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      channelId: json['channel_id'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}