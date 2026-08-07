// ─── Top University Card ─────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_stats_model.dart';
import '../utils/stats_sizes.dart';
import 'logo_fallback.dart';

class TopUniversityCard extends StatelessWidget {
  final StatsSizes sizes;
  final UserStatsModel stats;
  const TopUniversityCard({super.key, required this.sizes, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizes.topUniPadding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.topUniBorderRadius),
      ),
      child: Row(
        children: [
          if (stats.topUniversityLogo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(sizes.topUniLogoBorderRadius),
              child: CachedNetworkImage(
                imageUrl: stats.topUniversityLogo!,
                width: sizes.topUniLogoSize,
                height: sizes.topUniLogoSize,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => LogoFallback(sizes: sizes),
              ),
            )
          else
            LogoFallback(sizes: sizes),
          SizedBox(width: sizes.topUniLogoSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.topUniversityName!,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: sizes.topUniNameFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: sizes.topUniSubSpacing),
                Text(
                  '${stats.topUniversityWatchCount ?? 0} video izlendi',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.topUniSubFontSize,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: sizes.topUniStarSize,
          ),
        ],
      ),
    );
  }
}
