// ─── Hero Card ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_stats_model.dart';
import '../utils/stats_sizes.dart';
import 'hero_stat.dart';
import 'vert_divider.dart';

class HeroCard extends StatelessWidget {
  final StatsSizes sizes;
  final UserStatsModel stats;
  const HeroCard({super.key, required this.sizes, required this.stats});

  @override
  Widget build(BuildContext context) {
    final hours = stats.estimatedWatchMinutes ~/ 60;
    final mins = stats.estimatedWatchMinutes % 60;
    final watchTimeStr = hours > 0 ? '~$hours sa $mins dk' : '~$mins dk';

    return Container(
      padding: EdgeInsets.all(sizes.heroPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(sizes.heroBorderRadius),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: sizes.heroBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: sizes.heroAvatarSize,
                height: sizes.heroAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: sizes.heroAvatarIconSize,
                ),
              ),
              SizedBox(width: sizes.heroAvatarSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.username ?? stats.fullName ?? 'Kullanıcı',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: sizes.heroNameFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (stats.memberSince != null)
                      Text(
                        'Üye · ${_formatDate(stats.memberSince!)}',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: sizes.heroMemberFontSize,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    watchTimeStr,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: sizes.heroWatchTimeFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'izleme süresi',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: sizes.heroWatchTimeLabelFontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: sizes.heroDividerSpacing),
          Divider(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            height: sizes.heroDividerHeight,
          ),
          SizedBox(height: sizes.heroDividerSpacing),
          Row(
            children: [
              Expanded(
                child: HeroStat(
                  sizes: sizes,
                  value: stats.totalWatched.toString(),
                  label: 'İzlenen',
                ),
              ),
              VertDivider(sizes: sizes),
              Expanded(
                child: HeroStat(
                  sizes: sizes,
                  value: stats.totalLiked.toString(),
                  label: 'Beğenilen',
                ),
              ),
              VertDivider(sizes: sizes),
              Expanded(
                child: HeroStat(
                  sizes: sizes,
                  value: stats.totalFavorited.toString(),
                  label: 'Favori',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}