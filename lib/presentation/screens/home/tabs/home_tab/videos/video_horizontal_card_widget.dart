// lib/presentation/screens/home/widgets/tabs/home_tab/videos/video_horizontal_card_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../core/utils/formatters.dart';
import '../../../../../../data/models/video_engagement_model.dart';

class _Sizes {
  final bool isTablet;
  final double cardWidth;
  final double cardHeight;
  final double cardRadius;
  final double gradientHeight;
  final double durationBottom;
  final double durationRight;
  final double durationPaddingH;
  final double durationPaddingV;
  final double durationRadius;
  final double durationFontSize;
  final double contentPaddingH;
  final double contentPaddingV;
  final double titleFontSize;
  final double titleLineHeight;
  final double channelFontSize;
  final double statSpacing;
  final double statPaddingH;
  final double statPaddingV;
  final double statRadius;
  final double statIconSize;
  final double statFontSize;
  final double placeholderIconSize;

  const _Sizes._({
    required this.isTablet,
    required this.cardWidth,
    required this.cardHeight,
    required this.cardRadius,
    required this.gradientHeight,
    required this.durationBottom,
    required this.durationRight,
    required this.durationPaddingH,
    required this.durationPaddingV,
    required this.durationRadius,
    required this.durationFontSize,
    required this.contentPaddingH,
    required this.contentPaddingV,
    required this.titleFontSize,
    required this.titleLineHeight,
    required this.channelFontSize,
    required this.statSpacing,
    required this.statPaddingH,
    required this.statPaddingV,
    required this.statRadius,
    required this.statIconSize,
    required this.statFontSize,
    required this.placeholderIconSize,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        cardWidth: 180,
        cardHeight: 220,
        cardRadius: 16,
        gradientHeight: 40,
        durationBottom: 8,
        durationRight: 8,
        durationPaddingH: 6,
        durationPaddingV: 3,
        durationRadius: 6,
        durationFontSize: 10,
        contentPaddingH: 10,
        contentPaddingV: 8,
        titleFontSize: 12.5,
        titleLineHeight: 1.3,
        channelFontSize: 10.5,
        statSpacing: 4,
        statPaddingH: 6,
        statPaddingV: 3,
        statRadius: 7,
        statIconSize: 10,
        statFontSize: 9.5,
        placeholderIconSize: 36,
      );
    }
    return const _Sizes._(
      isTablet: false,
      cardWidth: 160,
      cardHeight: 200,
      cardRadius: 14,
      gradientHeight: 36,
      durationBottom: 6,
      durationRight: 6,
      durationPaddingH: 5,
      durationPaddingV: 2,
      durationRadius: 5,
      durationFontSize: 9,
      contentPaddingH: 8,
      contentPaddingV: 6,
      titleFontSize: 11,
      titleLineHeight: 1.25,
      channelFontSize: 9.5,
      statSpacing: 3,
      statPaddingH: 5,
      statPaddingV: 2,
      statRadius: 6,
      statIconSize: 9,
      statFontSize: 8.5,
      placeholderIconSize: 32,
    );
  }
}

class VideoHorizontalCard extends StatelessWidget {
  final VideoEngagementModel video;
  final String Function(VideoEngagementModel) statLabelBuilder;
  final IconData statIcon;

  const VideoHorizontalCard({
    super.key,
    required this.video,
    required this.statLabelBuilder,
    required this.statIcon,
  });

  @override
  Widget build(BuildContext context) {
    final spec = _Sizes.of(context);
    final vm = video.toVideoModel();

    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(spec.cardRadius),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.player,
          arguments: vm,
          parameters: {'videoId': vm.videoId},
        ),
        child: SizedBox(
          width: spec.cardWidth,
          height: spec.cardHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Thumbnail ──
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => CachedNetworkImage(
                        imageUrl: video.fallbackThumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => _placeholder(context, spec),
                        placeholder: (_, _) => _shimmerBox(context),
                      ),
                      placeholder: (_, _) => _shimmerBox(context),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: spec.gradientHeight,
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
                    if (video.duration.isNotEmpty)
                      Positioned(
                        bottom: spec.durationBottom,
                        right: spec.durationRight,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: spec.durationPaddingH,
                            vertical: spec.durationPaddingV,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius:
                                BorderRadius.circular(spec.durationRadius),
                          ),
                          child: Text(
                            formatIsoDuration(video.duration),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: spec.durationFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Alt içerik ──
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spec.contentPaddingH,
                    vertical: spec.contentPaddingV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: spec.titleFontSize,
                            fontWeight: FontWeight.w700,
                            height: spec.titleLineHeight,
                          ),
                        ),
                      ),
                      Text(
                        video.channelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: spec.channelFontSize,
                        ),
                      ),
                      SizedBox(height: spec.statSpacing),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: spec.statPaddingH,
                          vertical: spec.statPaddingV,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppTheme.primaryColor.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(spec.statRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statIcon,
                              size: spec.statIconSize,
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(width: spec.statSpacing),
                            Flexible(
                              child: Text(
                                statLabelBuilder(video),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: spec.statFontSize,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, _Sizes spec) => Container(
    color: AppTheme.surface(context),
    child: Icon(
      Icons.play_circle_outline_rounded,
      color: AppTheme.textSec(context),
      size: spec.placeholderIconSize,
    ),
  );

  Widget _shimmerBox(BuildContext context) =>
      Container(color: AppTheme.surface(context));
}