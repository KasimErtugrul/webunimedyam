// lib/core/utils/formatters.dart

/// Sayı formatlama: 1500 → "1.5B", 15000 → "15B", 1500000 → "1.5M"
extension CompactNumberX on int {
  String get compact {
    if (this >= 1000000) {
      final v = this / 1000000;
      return v >= 10 ? '${v.toStringAsFixed(0)}M' : '${v.toStringAsFixed(1)}M';
    }
    if (this >= 1000) {
      final v = this / 1000;
      return v >= 10 ? '${v.toStringAsFixed(0)}B' : '${v.toStringAsFixed(1)}B';
    }
    return '$this';
  }
}

/// ISO 8601 süre → "MM:SS" veya "H:MM:SS"
String formatIsoDuration(String iso) {
  final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
  final m = regex.firstMatch(iso);
  if (m == null) return '';
  final h = int.tryParse(m.group(1) ?? '') ?? 0;
  final mi = int.tryParse(m.group(2) ?? '') ?? 0;
  final s = int.tryParse(m.group(3) ?? '') ?? 0;
  if (h > 0) {
    return '$h:${mi.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$mi:${s.toString().padLeft(2, '0')}';
}

/// "5 dakika önce", "2 saat önce" gibi Türkçe göreli zaman.
String timeAgoTr(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays >= 365) {
    final y = diff.inDays ~/ 365;
    return '$y yıl önce';
  }
  if (diff.inDays >= 30) {
    final m = diff.inDays ~/ 30;
    return '$m ay önce';
  }
  if (diff.inDays >= 1) return '${diff.inDays} gün önce';
  if (diff.inHours >= 1) return '${diff.inHours} saat önce';
  if (diff.inMinutes >= 1) return '${diff.inMinutes} dakika önce';
  return 'az önce';
}

/// Süre (saniye) → "5 s" veya "1.5k s"
String formatDurationShort(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  if (h >= 1000) return '${(h / 1000).toStringAsFixed(1)}k s';
  return '$h s';
}