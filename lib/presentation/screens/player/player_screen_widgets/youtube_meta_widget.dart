// ═══════════════════════════════════════════════════════════════════════════
// YouTube meta satırı  (görüntülenme · tarih · süre · HD)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';

class YoutubeMetaWidget extends StatelessWidget {
  final VideoModel video;
  const YoutubeMetaWidget({super.key, required this.video});

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (video.viewCount > 0) {
      parts.add('${_fmtCount(video.viewCount)} görüntülenme');
    }
    if (video.formattedDuration.isNotEmpty) parts.add(video.formattedDuration);
    parts.add(_fmtDate(video.publishedAt));

    return Row(
      children: [
        Expanded(
          child: Text(
            parts.join('  ·  '),
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 12),
          ),
        ),
        if (video.isHd)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.textSec(context).withValues(alpha: 0.4),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'HD',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }
}