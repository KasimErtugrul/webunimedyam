// lib/presentation/screens/player/player_screen_widgets/suggested_video_card_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/video_model.dart';

class _Sizes {
  final double cardWidth;
  final double cardMarginRight;
  final double cardRadius;
  final double cardShadowBlur;
  final double cardShadowOffsetY;
  final double gradientHeight;
  final double durationBadgeBottom;
  final double durationBadgeRight;
  final double durationBadgePaddingH;
  final double durationBadgePaddingV;
  final double durationBadgeRadius;
  final double durationBadgeFontSize;
  final double hdBadgeTop;
  final double hdBadgeRight;
  final double hdBadgePaddingH;
  final double hdBadgePaddingV;
  final double hdBadgeRadius;
  final double hdBadgeFontSize;
  final double errorIconSize;
  final double contentPaddingLeft;
  final double contentPaddingTop;
  final double contentPaddingRight;
  final double contentPaddingBottom;
  final double titleFontSize;
  final double titleLineHeight;
  final double titleSpacing;
  final double channelFontSize;
  final double channelSpacing;
  final double statSpacing;
  final double statRunSpacing;
  final double statPaddingH;
  final double statPaddingV;
  final double statRadius;
  final double statIconSize;
  final double statFontSize;
  final double statSpacingSmall;
  final double statLikeIconSize;
  final double statLikeFontSize;
  final double statUniversityIconSize;
  final double statUniversityFontSize;
  final double statUniversitySpacing;
  final double timeFontSize;
  final double timeSpacing;
  final double schoolIconSize;
  final double schoolIconSpacing;

  const _Sizes._({
    required this.cardWidth,
    required this.cardMarginRight,
    required this.cardRadius,
    required this.cardShadowBlur,
    required this.cardShadowOffsetY,
    required this.gradientHeight,
    required this.durationBadgeBottom,
    required this.durationBadgeRight,
    required this.durationBadgePaddingH,
    required this.durationBadgePaddingV,
    required this.durationBadgeRadius,
    required this.durationBadgeFontSize,
    required this.hdBadgeTop,
    required this.hdBadgeRight,
    required this.hdBadgePaddingH,
    required this.hdBadgePaddingV,
    required this.hdBadgeRadius,
    required this.hdBadgeFontSize,
    required this.errorIconSize,
    required this.contentPaddingLeft,
    required this.contentPaddingTop,
    required this.contentPaddingRight,
    required this.contentPaddingBottom,
    required this.titleFontSize,
    required this.titleLineHeight,
    required this.titleSpacing,
    required this.channelFontSize,
    required this.channelSpacing,
    required this.statSpacing,
    required this.statRunSpacing,
    required this.statPaddingH,
    required this.statPaddingV,
    required this.statRadius,
    required this.statIconSize,
    required this.statFontSize,
    required this.statSpacingSmall,
    required this.statLikeIconSize,
    required this.statLikeFontSize,
    required this.statUniversityIconSize,
    required this.statUniversityFontSize,
    required this.statUniversitySpacing,
    required this.timeFontSize,
    required this.timeSpacing,
    required this.schoolIconSize,
    required this.schoolIconSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        cardWidth: 200,
        cardMarginRight: 14,
        cardRadius: 16,
        cardShadowBlur: 6,
        cardShadowOffsetY: 2,
        gradientHeight: 36,
        durationBadgeBottom: 6,
        durationBadgeRight: 6,
        durationBadgePaddingH: 6,
        durationBadgePaddingV: 3,
        durationBadgeRadius: 5,
        durationBadgeFontSize: 11,
        hdBadgeTop: 6,
        hdBadgeRight: 6,
        hdBadgePaddingH: 5,
        hdBadgePaddingV: 3,
        hdBadgeRadius: 5,
        hdBadgeFontSize: 9,
        errorIconSize: 40,
        contentPaddingLeft: 10,
        contentPaddingTop: 8,
        contentPaddingRight: 10,
        contentPaddingBottom: 10,
        titleFontSize: 13,
        titleLineHeight: 1.3,
        titleSpacing: 6,
        channelFontSize: 11,
        channelSpacing: 5,
        statSpacing: 8,
        statRunSpacing: 5,
        statPaddingH: 6,
        statPaddingV: 3,
        statRadius: 7,
        statIconSize: 11,
        statFontSize: 10,
        statSpacingSmall: 4,
        statLikeIconSize: 10,
        statLikeFontSize: 9,
        statUniversityIconSize: 10,
        statUniversityFontSize: 9,
        statUniversitySpacing: 3,
        timeFontSize: 9,
        timeSpacing: 5,
        schoolIconSize: 12,
        schoolIconSpacing: 5,
      );
    }
    return const _Sizes._(
      cardWidth: 160,
      cardMarginRight: 12,
      cardRadius: 14,
      cardShadowBlur: 4,
      cardShadowOffsetY: 1,
      gradientHeight: 32,
      durationBadgeBottom: 5,
      durationBadgeRight: 5,
      durationBadgePaddingH: 5,
      durationBadgePaddingV: 2,
      durationBadgeRadius: 4,
      durationBadgeFontSize: 9,
      hdBadgeTop: 5,
      hdBadgeRight: 5,
      hdBadgePaddingH: 4,
      hdBadgePaddingV: 2,
      hdBadgeRadius: 4,
      hdBadgeFontSize: 8,
      errorIconSize: 32,
      contentPaddingLeft: 8,
      contentPaddingTop: 7,
      contentPaddingRight: 8,
      contentPaddingBottom: 8,
      titleFontSize: 10.5,
      titleLineHeight: 1.25,
      titleSpacing: 4,
      channelFontSize: 9,
      channelSpacing: 4,
      statSpacing: 6,
      statRunSpacing: 4,
      statPaddingH: 5,
      statPaddingV: 2,
      statRadius: 6,
      statIconSize: 9,
      statFontSize: 8.5,
      statSpacingSmall: 3,
      statLikeIconSize: 8,
      statLikeFontSize: 8,
      statUniversityIconSize: 8,
      statUniversityFontSize: 7.5,
      statUniversitySpacing: 2,
      timeFontSize: 7.5,
      timeSpacing: 4,
      schoolIconSize: 10,
      schoolIconSpacing: 4,
    );
  }
}

class SuggestedVideoCard extends StatelessWidget {
  final VideoModel video;
  const SuggestedVideoCard({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => Get.offNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        width: s.cardWidth,
        margin: EdgeInsets.only(right: s.cardMarginRight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(s.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: s.cardShadowBlur,
              offset: Offset(0, s.cardShadowOffsetY),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.bestThumbnail,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, _, _) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: s.errorIconSize,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: s.gradientHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: s.durationBadgeBottom,
                      right: s.durationBadgeRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: s.durationBadgePaddingH,
                          vertical: s.durationBadgePaddingV,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(
                            s.durationBadgeRadius,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: s.durationBadgeFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (video.isHd)
                    Positioned(
                      top: s.hdBadgeTop,
                      right: s.hdBadgeRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: s.hdBadgePaddingH,
                          vertical: s.hdBadgePaddingV,
                        ),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius:
                              BorderRadius.circular(s.hdBadgeRadius),
                        ),
                        child: Text(
                          'HD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: s.hdBadgeFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Alt bilgi ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                s.contentPaddingLeft,
                s.contentPaddingTop,
                s.contentPaddingRight,
                s.contentPaddingBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: s.titleFontSize,
                      fontWeight: FontWeight.w700,
                      height: s.titleLineHeight,
                    ),
                  ),
                  SizedBox(height: s.titleSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: s.channelFontSize,
                          ),
                        ),
                      ),
                      if (video.universityId != null)
                        Padding(
                          padding:
                              EdgeInsets.only(left: s.schoolIconSpacing),
                          child: Icon(
                            Icons.school_rounded,
                            size: s.schoolIconSize,
                            color: primary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: s.channelSpacing),
                  Wrap(
                    spacing: s.statSpacing,
                    runSpacing: s.statRunSpacing,
                    children: [
                      _Stat(
                        bgColor: primary.withValues(alpha: 0.15),
                        fgColor: primary,
                        icon: Icons.remove_red_eye_outlined,
                        iconSize: s.statIconSize,
                        text: video.formattedViewCount,
                        fontSize: s.statFontSize,
                        paddingH: s.statPaddingH,
                        paddingV: s.statPaddingV,
                        radius: s.statRadius,
                        spacing: s.statSpacingSmall,
                      ),
                      if (video.likeCount > 0)
                        _Stat(
                          bgColor:
                              AppTheme.textSec(context).withValues(alpha: 0.1),
                          fgColor: AppTheme.textSec(context),
                          icon: Icons.thumb_up_alt_outlined,
                          iconSize: s.statLikeIconSize,
                          text: _formatCompact(video.likeCount),
                          fontSize: s.statLikeFontSize,
                          paddingH: s.statPaddingH,
                          paddingV: s.statPaddingV,
                          radius: s.statRadius,
                          spacing: s.statSpacingSmall,
                        ),
                      if (video.universityName != null &&
                          video.universityName!.isNotEmpty)
                        _Stat(
                          bgColor: primary.withValues(alpha: 0.1),
                          fgColor: primary,
                          icon: Icons.school_rounded,
                          iconSize: s.statUniversityIconSize,
                          text: video.universityName!,
                          fontSize: s.statUniversityFontSize,
                          paddingH: s.statPaddingH,
                          paddingV: s.statPaddingV,
                          radius: s.statRadius,
                          spacing: s.statUniversitySpacing,
                        ),
                    ],
                  ),
                  SizedBox(height: s.timeSpacing),
                  Text(
                    _relativeTime(video.publishedAt),
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.8),
                      fontSize: s.timeFontSize,
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

  String _formatCompact(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
    return count.toString();
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) return 'Şimdi';
        return '${diff.inMinutes} dk önce';
      }
      return '${diff.inHours} sa önce';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} g önce';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} hf önce';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()} ay önce';
    } else {
      return '${(diff.inDays / 365).floor()} y önce';
    }
  }
}

// Aynı görsel yapı üç kez tekrar etmesin diye küçük ortak kart.
class _Stat extends StatelessWidget {
  final Color bgColor;
  final Color fgColor;
  final IconData icon;
  final double iconSize;
  final String text;
  final double fontSize;
  final double paddingH;
  final double paddingV;
  final double radius;
  final double spacing;

  const _Stat({
    required this.bgColor,
    required this.fgColor,
    required this.icon,
    required this.iconSize,
    required this.text,
    required this.fontSize,
    required this.paddingH,
    required this.paddingV,
    required this.radius,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: fgColor),
          SizedBox(width: spacing),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fgColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}