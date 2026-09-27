// ─── Streak Card ───────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_stats_model.dart';
import '../utils/stats_sizes.dart';

class StreakCard extends StatelessWidget {
  final StatsSizes sizes;
  final UserStatsModel stats;
  const StreakCard({super.key, required this.sizes, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.streakPaddingHorizontal,
        vertical: sizes.streakPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.streakBorderRadius),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: sizes.streakBorderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: sizes.streakIconSize,
            height: sizes.streakIconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: sizes.streakIconInnerSize,
            ),
          ),
          SizedBox(width: sizes.streakIconSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreakDays} günlük seri 🔥',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: sizes.streakTitleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: sizes.metricSpacingMedium),
                Text(
                  'En uzun serin: ${stats.longestStreakDays} gün',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.streakSubtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '🏆',
            style: TextStyle(fontSize: sizes.streakEmojiFontSize),
          ),
        ],
      ),
    );
  }
}