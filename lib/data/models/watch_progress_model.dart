// lib/data/models/watch_progress_model.dart
//
// Kullanıcının yarım bıraktığı bir videonun yerel (Hive) izleme ilerlemesini
// temsil eder. Tamamen cihaz-içi (local-only) tutulur, Supabase'e yazılmaz.

import 'video_model.dart';

class WatchProgressModel {
  final VideoModel video;
  final int positionSeconds; // videonun bırakıldığı saniye (ör. 12. dk -> 720)
  final int durationSeconds; // videonun toplam süresi (saniye)
  final DateTime updatedAt; // en son ne zaman güncellendi

  const WatchProgressModel({
    required this.video,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.updatedAt,
  });

  String get videoId => video.videoId;

  /// 0.0 - 1.0 arası izlenme oranı
  double get progressRatio {
    if (durationSeconds <= 0) return 0;
    final ratio = positionSeconds / durationSeconds;
    if (ratio.isNaN || ratio.isInfinite) return 0;
    return ratio.clamp(0.0, 1.0);
  }

  int get remainingSeconds {
    final remaining = durationSeconds - positionSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  /// "12 dk kaldı" gibi kısa, kullanıcıya gösterilecek kalan süre metni
  String get remainingLabel {
    final remaining = remainingSeconds;
    if (remaining <= 0) return '';
    final minutes = (remaining / 60).ceil();
    if (minutes < 1) return '1 dk kaldı';
    return '$minutes dk kaldı';
  }

  WatchProgressModel copyWith({
    VideoModel? video,
    int? positionSeconds,
    int? durationSeconds,
    DateTime? updatedAt,
  }) {
    return WatchProgressModel(
      video: video ?? this.video,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'video': video.toSupabase(),
      'position_seconds': positionSeconds,
      'duration_seconds': durationSeconds,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory WatchProgressModel.fromMap(Map<String, dynamic> map) {
    return WatchProgressModel(
      video: VideoModel.fromSupabase(
        Map<String, dynamic>.from(map['video'] as Map),
      ),
      positionSeconds: (map['position_seconds'] as num?)?.toInt() ?? 0,
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 0,
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// Video modelinin ISO 8601 `duration` alanını (ör. "PT12M34S") saniyeye çevirir.
int parseIsoDurationToSeconds(String iso) {
  final match = RegExp(
    r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?',
  ).firstMatch(iso);
  if (match == null) return 0;
  final h = int.tryParse(match.group(1) ?? '') ?? 0;
  final m = int.tryParse(match.group(2) ?? '') ?? 0;
  final s = int.tryParse(match.group(3) ?? '') ?? 0;
  return h * 3600 + m * 60 + s;
}
