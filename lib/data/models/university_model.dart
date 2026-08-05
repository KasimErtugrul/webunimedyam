import 'package:equatable/equatable.dart';

class UniversityModel extends Equatable {
  final int? id;
  final String? createdAt;
  final String? name;
  final String? channelId;
  final String? logoUrl;
  final String? uploadsPlaylistId;
  final String? description;
  final String? city;
  final String? websiteUrl;
  final int? foundedYear;
  final String? kgMid;
  final String? kgSyncedAt;
  final int? subscriberCount;
  final int? viewCount;
  final int? videoCount;
  final String? customUrl;
  final String? channelSyncedAt;
  final String? radioLink;
  final int? idx;

  const UniversityModel({
    this.id,
    this.createdAt,
    this.name,
    this.channelId,
    this.logoUrl,
    this.uploadsPlaylistId,
    this.description,
    this.city,
    this.websiteUrl,
    this.foundedYear,
    this.kgMid,
    this.kgSyncedAt,
    this.subscriberCount,
    this.viewCount,
    this.videoCount,
    this.customUrl,
    this.channelSyncedAt,
    this.radioLink,
    this.idx,
  });

  UniversityModel copyWith({
    int? id,
    String? createdAt,
    String? name,
    String? channelId,
    String? logoUrl,
    String? uploadsPlaylistId,
    String? description,
    String? city,
    String? websiteUrl,
    int? foundedYear,
    String? kgMid,
    String? kgSyncedAt,
    int? subscriberCount,
    int? viewCount,
    int? videoCount,
    String? customUrl,
    String? channelSyncedAt,
    String? radioLink,
    int? idx,
  }) => UniversityModel(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    channelId: channelId ?? this.channelId,
    logoUrl: logoUrl ?? this.logoUrl,
    uploadsPlaylistId: uploadsPlaylistId ?? this.uploadsPlaylistId,
    description: description ?? this.description,
    city: city ?? this.city,
    websiteUrl: websiteUrl ?? this.websiteUrl,
    foundedYear: foundedYear ?? this.foundedYear,
    kgMid: kgMid ?? this.kgMid,
    kgSyncedAt: kgSyncedAt ?? this.kgSyncedAt,
    subscriberCount: subscriberCount ?? this.subscriberCount,
    viewCount: viewCount ?? this.viewCount,
    videoCount: videoCount ?? this.videoCount,
    customUrl: customUrl ?? this.customUrl,
    channelSyncedAt: channelSyncedAt ?? this.channelSyncedAt,
    radioLink: radioLink ?? this.radioLink,
    idx: idx ?? this.idx,
  );

  factory UniversityModel.fromSupabase(Map<String, dynamic> json) =>
      UniversityModel(
        id: json["id"],
        createdAt: json["created_at"],
        name: json["name"],
        channelId: json["channel_id"],
        logoUrl: json["logo_url"],
        uploadsPlaylistId: json["uploads_playlist_id"],
        description: json["description"],
        city: json["city"],
        websiteUrl: json["website_url"],
        foundedYear: json["founded_year"],
        kgMid: json["kg_mid"],
        kgSyncedAt: json["kg_synced_at"],
        subscriberCount: json["subscriber_count"],
        viewCount: json["view_count"],
        videoCount: json["video_count"],
        customUrl: json["custom_url"],
        channelSyncedAt: json["channel_synced_at"],
        radioLink: json["radio_link"],
        idx: json["idx"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "created_at": createdAt,
    "name": name,
    "channel_id": channelId,
    "logo_url": logoUrl,
    "uploads_playlist_id": uploadsPlaylistId,
    "description": description,
    "city": city,
    "website_url": websiteUrl,
    "founded_year": foundedYear,
    "kg_mid": kgMid,
    "kg_synced_at": kgSyncedAt,
    "subscriber_count": subscriberCount,
    "view_count": viewCount,
    "video_count": videoCount,
    "custom_url": customUrl,
    "channel_synced_at": channelSyncedAt,
    "radio_link": radioLink,
    "idx": idx,
  };

  @override
  List<Object?> get props => [
    id,
    createdAt,
    name,
    channelId,
    logoUrl,
    uploadsPlaylistId,
    description,
    city,
    websiteUrl,
    foundedYear,
    kgMid,
    kgSyncedAt,
    subscriberCount,
    viewCount,
    videoCount,
    customUrl,
    channelSyncedAt,
    radioLink,
    idx,
  ];

  @override
  String toString() {
    return 'UniversityModel{id=$id, createdAt=$createdAt, name=$name, channelId=$channelId, logoUrl=$logoUrl, uploadsPlaylistId=$uploadsPlaylistId, description=$description, city=$city, websiteUrl=$websiteUrl, foundedYear=$foundedYear, kgMid=$kgMid, kgSyncedAt=$kgSyncedAt, subscriberCount=$subscriberCount, viewCount=$viewCount, videoCount=$videoCount, customUrl=$customUrl, channelSyncedAt=$channelSyncedAt, radioLink=$radioLink, idx=$idx}';
  }
}
