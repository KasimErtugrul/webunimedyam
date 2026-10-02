// ─── Video Kartı (Liste) ────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../../../../core/widgets/hover_tap.dart';
import '../utils/sizes.dart';
import 'stat_row_compact.dart';

class ProfileActivityListVideoCard extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final VideoModel video;
  const ProfileActivityListVideoCard({
    super.key,
    required this.sizes,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return TapCursor(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: sizes.listCardBottomMargin),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.listCardBorderRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(sizes.listThumbnailRadius),
                bottomLeft: Radius.circular(sizes.listThumbnailRadius),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: sizes.listThumbnailWidth,
                    height: sizes.listThumbnailHeight,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: sizes.listThumbnailWidth,
                      height: sizes.listThumbnailHeight,
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: sizes.listThumbnailWidth,
                      height: sizes.listThumbnailHeight,
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: sizes.listThumbnailIconSize,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: sizes.durationBadgePaddingVertical,
                      right: sizes.durationBadgePaddingHorizontal,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: sizes.durationBadgePaddingHorizontal,
                          vertical: sizes.durationBadgePaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(
                            sizes.durationBadgeBorderRadius,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: sizes.durationBadgeFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  sizes.listContentPaddingLeft,
                  sizes.listContentPaddingTop,
                  sizes.listContentPaddingRight,
                  sizes.listContentPaddingBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: sizes.listTitleFontSize,
                        fontWeight: FontWeight.w600,
                        height: sizes.listTitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: sizes.durationBadgePaddingVertical),
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: sizes.listUniFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((video.universityName ?? '').isNotEmpty)
                      SizedBox(height: sizes.durationBadgePaddingVertical),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: sizes.listDateFontSize,
                      ),
                    ),
                    SizedBox(height: sizes.dismissibleSpacing),
                    ProfileActivityListStatRowCompact(
                      sizes: sizes,
                      video: video,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: sizes.listChevronRight,
                top: sizes.listChevronTop,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: sizes.listChevronSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
  if (diff.inDays > 0) return '${diff.inDays} gün önce';
  if (diff.inHours > 0) return '${diff.inHours} saat önce';
  return '${diff.inMinutes} dakika önce';
}
