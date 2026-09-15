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
  final String? address; // ← YENİ
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
  final int? syncGroup;
  final String? universityType;

  const UniversityModel({
    this.id,
    this.createdAt,
    this.name,
    this.channelId,
    this.logoUrl,
    this.uploadsPlaylistId,
    this.description,
    this.city,
    this.address,
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
    this.syncGroup,
    this.universityType,
  });

  /// DB'de tutulan ham `university_type` değerini kullanıcıya
  /// gösterilecek biçime çevirir.
  ///
  ///   'devlet'      → 'Devlet'
  ///   'ozel'/'özel' → 'Vakıf'
  ///   'kktc'        → 'KKTC'
  ///   'vakif_myo'   → 'Vakıf MYO'
  ///   'kurum'       → 'Kurum'
  ///   diğer         → ilk harfi büyütülmüş hâli
  ///   null / boş    → null
  String? get displayUniversityType {
    final v = universityType?.trim();
    if (v == null || v.isEmpty) return null;
    switch (v.toLowerCase()) {
      case 'ozel':
      case 'özel':
        return 'Vakıf';
      case 'devlet':
        return 'Devlet';
      case 'kktc':
        return 'KKTC';
      case 'vakif_myo':
        return 'Vakıf MYO';
      case 'kurum':
        return 'Kurum';
      default:
        return v[0].toUpperCase() + v.substring(1);
    }
  }

  UniversityModel copyWith({
    int? id,
    String? createdAt,
    String? name,
    String? channelId,
    String? logoUrl,
    String? uploadsPlaylistId,
    String? description,
    String? city,
    String? address,
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
    int? syncGroup,
    String? universityType,
  }) => UniversityModel(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    name: name ?? this.name,
    channelId: channelId ?? this.channelId,
    logoUrl: logoUrl ?? this.logoUrl,
    uploadsPlaylistId: uploadsPlaylistId ?? this.uploadsPlaylistId,
    description: description ?? this.description,
    city: city ?? this.city,
    address: address ?? this.address,
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
    syncGroup: syncGroup ?? this.syncGroup,
    universityType: universityType ?? this.universityType,
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
        address: json["address"],
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
        syncGroup: json["sync_group"],
        universityType: json["university_type"],
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
    "address": address,
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
    "sync_group": syncGroup,
    "university_type": universityType,
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
    address,
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
    syncGroup,
    universityType,
  ];

  @override
  String toString() {
    return 'UniversityModel{id=$id, createdAt=$createdAt, name=$name, channelId=$channelId, logoUrl=$logoUrl, uploadsPlaylistId=$uploadsPlaylistId, description=$description, city=$city, address=$address, websiteUrl=$websiteUrl, foundedYear=$foundedYear, kgMid=$kgMid, kgSyncedAt=$kgSyncedAt, subscriberCount=$subscriberCount, viewCount=$viewCount, videoCount=$videoCount, customUrl=$customUrl, channelSyncedAt=$channelSyncedAt, radioLink=$radioLink, idx=$idx, syncGroup=$syncGroup, universityType=$universityType}';
  }
}
