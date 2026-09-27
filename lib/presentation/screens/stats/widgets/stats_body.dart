// ─── Stats Body ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_stats_model.dart';
import '../../../controllers/stats_controller.dart';
import '../utils/stats_sizes.dart';
import 'activity_grid.dart';
import 'hero_card.dart';
import 'period_grid.dart';
import 'stats_section_title.dart';
import 'streak_card.dart';
import 'top_university_card.dart';
import 'video_card.dart';

class StatsBody extends StatelessWidget {
  final StatsSizes sizes;
  final UserStatsModel stats;
  const StatsBody({super.key, required this.sizes, required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => Get.find<StatsController>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          sizes.bodyPaddingLeft,
          sizes.bodyPaddingTop,
          sizes.bodyPaddingRight,
          sizes.bodyPaddingBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroCard(sizes: sizes, stats: stats),
            SizedBox(height: sizes.bodySectionSpacing),
            if (stats.currentStreakDays > 0 || stats.longestStreakDays > 0) ...[
              StreakCard(sizes: sizes, stats: stats),
              SizedBox(height: sizes.bodySectionSpacing),
            ],
            StatsSectionTitle(sizes: sizes, title: 'Dönem aktivitesi'),
            SizedBox(height: sizes.bodySectionTitleSpacing),
            PeriodGrid(sizes: sizes, stats: stats),
            SizedBox(height: sizes.bodySectionSpacing),
            StatsSectionTitle(sizes: sizes, title: 'Genel aktivite'),
            SizedBox(height: sizes.bodySectionTitleSpacing),
            ActivityGrid(sizes: sizes, stats: stats),
            SizedBox(height: sizes.bodySectionSpacing),
            if (stats.topUniversityName != null) ...[
              StatsSectionTitle(sizes: sizes, title: 'En çok izlediğin üniversite'),
              SizedBox(height: sizes.bodySectionTitleSpacing),
              TopUniversityCard(sizes: sizes, stats: stats),
              SizedBox(height: sizes.bodySectionSpacing),
            ],
            if (stats.lastWatchedTitle != null) ...[
              StatsSectionTitle(sizes: sizes, title: 'Son izlediğin video'),
              SizedBox(height: sizes.bodySectionTitleSpacing),
              StatsVideoCard(
                sizes: sizes,
                title: stats.lastWatchedTitle!,
                thumbnail: stats.lastWatchedThumbnail,
                date: stats.lastWatchedAt,
                icon: Icons.play_circle_rounded,
              ),
              SizedBox(height: sizes.bodySectionSpacing),
            ],
            if (stats.lastLikedTitle != null) ...[
              StatsSectionTitle(sizes: sizes, title: 'Son beğendiğin video'),
              SizedBox(height: sizes.bodySectionTitleSpacing),
              StatsVideoCard(
                sizes: sizes,
                title: stats.lastLikedTitle!,
                thumbnail: stats.lastLikedThumbnail,
                date: stats.lastLikedAt,
                icon: Icons.favorite_rounded,
                iconColor: Colors.redAccent,
              ),
              SizedBox(height: sizes.bodyPaddingBottom),
            ],
          ],
        ),
      ),
    );
  }
}