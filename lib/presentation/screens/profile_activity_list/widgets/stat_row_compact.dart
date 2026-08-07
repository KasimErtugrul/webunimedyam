// ─── İstatistik Satırı – Liste ──────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../utils/sizes.dart';

class ProfileActivityListStatRowCompact extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final VideoModel video;
  const ProfileActivityListStatRowCompact({super.key, 
    required this.sizes,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_StatItem>[
      if (video.appViewCount > 0)
        _StatItem(icon: Icons.visibility_outlined, value: video.appViewCount),
      if (video.appLikeCount > 0)
        _StatItem(icon: Icons.thumb_up_outlined, value: video.appLikeCount),
      if (video.appCommentCount > 0)
        _StatItem(
          icon: Icons.chat_bubble_outline_rounded,
          value: video.appCommentCount,
        ),
      if (video.appFavoriteCount > 0)
        _StatItem(
          icon: Icons.favorite_outline_rounded,
          value: video.appFavoriteCount,
        ),
      if (video.appShareCount > 0)
        _StatItem(icon: Icons.share_outlined, value: video.appShareCount),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: sizes.listStatSpacing,
      runSpacing: sizes.dismissibleSpacing,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: sizes.listStatIconSize,
                  color: AppTheme.textSec(context),
                ),
                SizedBox(width: sizes.durationBadgePaddingHorizontal),
                Text(
                  _compactNumber(item.value),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.listStatFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════
// ORTAK YARDIMCI FONKSİYONLAR
// ═══════════════════════════════════════════════════════════════════════

// ─── İstatistik Veri Sınıfı ─────────────────────────────────────────────────

class _StatItem {
  final IconData icon;
  final int value;
  const _StatItem({required this.icon, required this.value});
}

// ─── Sayı Formatla ──────────────────────────────────────────────────────────

String _compactNumber(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1).replaceAllMapped(RegExp(r'\.0$'), (_) => '')}M';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1).replaceAllMapped(RegExp(r'\.0$'), (_) => '')}B';
  }
  return '$count';
}

// ─── Zaman ──────────────────────────────────────────────────────────────────

