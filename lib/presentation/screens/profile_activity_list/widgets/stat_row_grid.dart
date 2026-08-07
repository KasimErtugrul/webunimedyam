

// ─── İstatistik Satırı – Izgara ────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../utils/sizes.dart';

class ProfileActivityListStatRowGrid extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final VideoModel video;
  const ProfileActivityListStatRowGrid({super.key, 
    required this.sizes,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    final row1 = <_StatItem>[];
    final row2 = <_StatItem>[];

    if (video.appViewCount > 0) {
      row1.add(
        _StatItem(icon: Icons.visibility_outlined, value: video.appViewCount),
      );
    }
    if (video.appLikeCount > 0) {
      row1.add(
        _StatItem(icon: Icons.thumb_up_outlined, value: video.appLikeCount),
      );
    }
    if (video.appFavoriteCount > 0) {
      row1.add(
        _StatItem(
          icon: Icons.favorite_outline_rounded,
          value: video.appFavoriteCount,
        ),
      );
    }
    if (video.appCommentCount > 0) {
      row2.add(
        _StatItem(
          icon: Icons.chat_bubble_outline_rounded,
          value: video.appCommentCount,
        ),
      );
    }
    if (video.appShareCount > 0) {
      row2.add(
        _StatItem(icon: Icons.share_outlined, value: video.appShareCount),
      );
    }

    if (row1.isEmpty && row2.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (row1.isNotEmpty) _buildGridStatLine(context, row1),
        if (row1.isNotEmpty && row2.isNotEmpty)
          SizedBox(height: sizes.gridStatLineSpacing),
        if (row2.isNotEmpty) _buildGridStatLine(context, row2),
      ],
    );
  }

  Widget _buildGridStatLine(BuildContext context, List<_StatItem> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: sizes.gridStatSpacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                items[i].icon,
                size: sizes.gridStatIconSize,
                color: AppTheme.textSec(context),
              ),
              SizedBox(width: sizes.durationBadgePaddingHorizontal),
              Text(
                _compactNumber(items[i].value),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: sizes.gridStatFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const Spacer(),
      ],
    );
  }
}


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