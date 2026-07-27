import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_engagement_model.dart';
import '../util/video_section_detail_screen_functions.dart';
import '../util/video_section_detail_screen_sizes.dart';
import 'video_section_detail_screen_placeholder.dart';
import 'video_section_detail_screen_shimmer_box.dart';
import 'video_section_detail_screen_stat_chip.dart';

/// Tek video kartı. Eskiden phone/tablet için satır satır aynı ağacı iki kez
/// içeren iki ayrı dosya vardı; artık tek widget + `sizes` parametresi.
class VideoSectionDetailScreenCard extends StatelessWidget {
  const VideoSectionDetailScreenCard({
    super.key,
    required this.item,
    required this.sizes,
  });

  final VideoEngagementModel item;
  final VideoSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: item.toVideoModel(),
        parameters: {'videoId': item.toVideoModel().videoId},
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: sizes.cardMarginHorizontal,
          vertical: sizes.cardMarginVertical,
        ),
        padding: EdgeInsets.all(sizes.cardPadding),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.cardBorderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(sizes.thumbnailBorderRadius),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: item.thumbnailUrl,
                    width: sizes.thumbnailWidth,
                    height: sizes.thumbnailHeight,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: item.fallbackThumbnailUrl,
                      width: sizes.thumbnailWidth,
                      height: sizes.thumbnailHeight,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) =>
                          VideoSectionDetailScreenPlaceholder(sizes: sizes),
                    ),
                    placeholder: (_, _) =>
                        VideoSectionDetailScreenShimmerBox(sizes: sizes),
                  ),
                  if (item.duration.isNotEmpty)
                    Positioned(
                      bottom: sizes.durationBadgeBottom,
                      right: sizes.durationBadgeRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sizes.durationBadgePaddingHorizontal,
                          vertical: sizes.durationBadgePaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(
                            sizes.durationBadgeBorderRadius,
                          ),
                        ),
                        child: Text(
                          VideoSectionDetailScreenFunctions.formatDuration(
                            item.duration,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizes.durationBadgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: sizes.thumbnailSpacing),
            // ── Meta ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: sizes.titleFontSize,
                      fontWeight: FontWeight.w600,
                      height: sizes.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: sizes.titleSpacing),
                  Text(
                    item.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: sizes.channelFontSize,
                    ),
                  ),
                  SizedBox(height: sizes.metaSpacing),
                  Wrap(
                    spacing: sizes.statSpacing,
                    runSpacing: sizes.statRunSpacing,
                    children: [
                      VideoSectionDetailScreenStatChip(
                        sizes: sizes,
                        icon: Icons.play_circle_outline_rounded,
                        label: VideoSectionDetailScreenFunctions.formatNum(
                          item.ytViewCount,
                        ),
                      ),
                      VideoSectionDetailScreenStatChip(
                        sizes: sizes,
                        icon: Icons.trending_up_rounded,
                        label: '${item.engagementScore} etkileşim puanı',
                        highlight: true,
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.titleSpacing),
                  Text(
                    VideoSectionDetailScreenFunctions.timeAgo(
                      item.publishedAt,
                    ),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: sizes.dateFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
