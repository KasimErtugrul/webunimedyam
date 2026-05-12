class ProfileModel {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final DateTime createdAt;

  ProfileModel({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory ProfileModel.fromSupabase(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      username: json['username'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }
}