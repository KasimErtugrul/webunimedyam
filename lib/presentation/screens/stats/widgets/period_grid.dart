// ─── Period Grid ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../data/models/user_stats_model.dart';
import '../utils/stats_sizes.dart';
import 'metric_card.dart';

class PeriodGrid extends StatelessWidget {
  final StatsSizes sizes;
  final UserStatsModel stats;
  const PeriodGrid({super.key, required this.sizes, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MetricCard(
            sizes: sizes,
            icon: Icons.today_rounded,
            label: 'Bu hafta',
            value: stats.watchedThisWeek.toString(),
            sub: 'video izlendi',
          ),
        ),
        SizedBox(width: sizes.metricRowSpacing),
        Expanded(
          child: MetricCard(
            sizes: sizes,
            icon: Icons.calendar_month_rounded,
            label: 'Bu ay',
            value: stats.watchedThisMonth.toString(),
            sub: 'video izlendi',
          ),
        ),
      ],
    );
  }
}