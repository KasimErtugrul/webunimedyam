// lib/data/models/watch_progress_model.dart
//
// "İzlemeye Devam Et" (Continue Watching) özelliği için, bir kullanıcının
// bir videoyu nereye kadar izlediğini TAMAMEN LOCAL (Hive) olarak saklayan
// model. Sunucuya hiçbir şey gönderilmez — tamamen cihaz üzerinde tutulur.

import 'video_model.dart';

class WatchProgressModel {
  /// İzlenen videonun tüm bilgileri (kart gösterimi için gerekli).
  final VideoModel video;

  /// Kullanıcının videoda en son bıraktığı saniye.
  final int positionSeconds;

  /// Videonun toplam süresi (saniye). 0 ise bilinmiyor demektir.
  final int durationSeconds;

  /// Bu ilerlemenin en son ne zaman güncellendiği.
  final DateTime updatedAt;

  WatchProgressModel({
    required this.video,
    required this.positionSeconds,
    required this.durationSeconds,
    required this.updatedAt,
  });

  /// 0.0 - 1.0 arası izlenme oranı.
  double get progressFraction {
    if (durationSeconds <= 0) return 0;
    return (positionSeconds / durationSeconds).clamp(0.0, 1.0);
  }

  /// Kalan süre (saniye). Negatif olamaz.
  int get remainingSeconds {
    final remaining = durationSeconds - positionSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  /// Video, "izlendi" sayılacak kadar sona yaklaşmış mı?
  /// (Son 5 saniye veya %95 üzeri izlenmişse tamamlanmış kabul edilir.)
  bool get isNearlyFinished {
    if (durationSeconds <= 0) return false;
    if (remainingSeconds <= 5) return true;
    return progressFraction >= 0.95;
  }

  String get formattedPosition => _formatSeconds(positionSeconds);
  String get formattedDuration => _formatSeconds(durationSeconds);
  String get formattedRemaining => _formatSeconds(remainingSeconds);

  static String _formatSeconds(int totalSeconds) {
    final s = totalSeconds < 0 ? 0 : totalSeconds;
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    return '$m:${sec.toString().padLeft(2, '0')}';
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
