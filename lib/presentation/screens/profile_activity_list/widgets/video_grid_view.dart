// ─── Video Kartı (Izgara) ───────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../utils/sizes.dart';
import 'stat_row_grid.dart';

class ProfileActivityListVideoGridCard extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final VideoModel video;
  const ProfileActivityListVideoGridCard({super.key, 
    required this.sizes,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(sizes.gridCardBorderRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, _, _) => Container(
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
                            fontSize: sizes.durationBadgeGridFontSize,
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
                  sizes.gridCardPaddingLeft,
                  sizes.gridCardPaddingTop,
                  sizes.gridCardPaddingRight,
                  sizes.gridCardPaddingBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: sizes.gridTitleFontSize,
                        fontWeight: FontWeight.w600,
                        height: sizes.gridTitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((video.universityName ?? '').isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: sizes.gridUniPaddingTop),
                        child: Text(
                          video.universityName!,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: sizes.gridUniFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    Flexible(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: ProfileActivityListStatRowGrid(
                            sizes: sizes,
                            video: video,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}