// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class PlaylistModel extends Equatable {
  final String playlistId; // university_id (string'e çevrilmiş)
  final String title; // university name
  final String description;
  final String thumbnailUrl;
  final int itemCount;
  final String? logoUrl; // üniversite logosu

  const PlaylistModel({
    required this.playlistId,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.itemCount,
    this.logoUrl,
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
      logoUrl: json['logo_url'] as String?,
    );
  }

  @override
  String toString() {
    return 'PlaylistModel(playlistId: $playlistId, title: $title, description: $description, thumbnailUrl: $thumbnailUrl, itemCount: $itemCount, logoUrl: $logoUrl)';
  }

  @override
  List<Object?> get props {
    return [
      playlistId,
      title,
      description,
      thumbnailUrl,
      itemCount,
      logoUrl,
    ];
  }
}
