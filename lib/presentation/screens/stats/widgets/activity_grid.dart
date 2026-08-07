// ─── Activity Grid ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../data/models/user_stats_model.dart';
import '../utils/stats_sizes.dart';
import 'metric_card.dart';

class ActivityGrid extends StatelessWidget {
  final StatsSizes sizes;
  final UserStatsModel stats;
  const ActivityGrid({super.key, required this.sizes, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                sizes: sizes,
                icon: Icons.chat_bubble_rounded,
                label: 'Yorum',
                value: stats.totalCommented.toString(),
                sub: 'yapıldı',
              ),
            ),
            SizedBox(width: sizes.metricRowSpacing),
            Expanded(
              child: MetricCard(
                sizes: sizes,
                icon: Icons.share_rounded,
                label: 'Paylaşım',
                value: stats.totalShared.toString(),
                sub: 'yapıldı',
              ),
            ),
          ],
        ),
        SizedBox(height: sizes.metricRowSpacing),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                sizes: sizes,
                icon: Icons.school_rounded,
                label: 'Üniversite',
                value: stats.uniqueUniversitiesWatched.toString(),
                sub: 'farklı keşfedildi',
              ),
            ),
            SizedBox(width: sizes.metricRowSpacing),
            Expanded(
              child: MetricCard(
                sizes: sizes,
                icon: Icons.play_circle_fill_rounded,
                label: 'Toplam',
                value: stats.totalWatched.toString(),
                sub: 'video izlendi',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
