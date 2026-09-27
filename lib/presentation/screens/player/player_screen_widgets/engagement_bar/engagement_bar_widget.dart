// lib/presentation/screens/player/player_screen_widgets/engagement_bar/engagement_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/player/player_controller.dart';
import 'engagement_action_widget.dart';
import 'stat_badge_widget.dart';

class _Sizes {
  final double containerPaddingH;
  final double containerPaddingV;
  final double actionSpacing;
  final double dividerHorizontalMargin;
  final double rightSpacing;
  final double dividerWidth;
  final double dividerHeight;
  final double dividerOpacity;
  final double tappableRadius;

  const _Sizes._({
    required this.containerPaddingH,
    required this.containerPaddingV,
    required this.actionSpacing,
    required this.dividerHorizontalMargin,
    required this.rightSpacing,
    required this.dividerWidth,
    required this.dividerHeight,
    required this.dividerOpacity,
    required this.tappableRadius,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        containerPaddingH: 12,
        containerPaddingV: 8,
        actionSpacing: 10,
        dividerHorizontalMargin: 12,
        rightSpacing: 6,
        dividerWidth: 1.5,
        dividerHeight: 20,
        dividerOpacity: 0.15,
        tappableRadius: 20,
      );
    }
    return const _Sizes._(
      containerPaddingH: 8,
      containerPaddingV: 6,
      actionSpacing: 6,
      dividerHorizontalMargin: 8,
      rightSpacing: 4,
      dividerWidth: 1,
      dividerHeight: 16,
      dividerOpacity: 0.15,
      tappableRadius: 16,
    );
  }
}

class EngagementBarWidget extends StatelessWidget {
  final PlayerController controller;
  const EngagementBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: s.containerPaddingH,
        vertical: s.containerPaddingV,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => EngagementActionWidget(
                      icon: controller.isLiked.value
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_alt_outlined,
                      count: controller.appLikeCount.value,
                      active: controller.isLiked.value,
                      loading: controller.isLikeLoading.value,
                      onTap: controller.toggleLike,
                    ),
                  ),
                  SizedBox(width: s.actionSpacing),
                  Obx(
                    () => EngagementActionWidget(
                      icon: Icons.share_outlined,
                      count: controller.appShareCount.value,
                      active: false,
                      loading: controller.isShareLoading.value,
                      onTap: controller.shareVideo,
                    ),
                  ),
                  SizedBox(width: s.actionSpacing),
                  Obx(
                    () => EngagementActionWidget(
                      icon: controller.isFavorite.value
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      count: controller.appFavoriteCount.value,
                      active: controller.isFavorite.value,
                      loading: controller.isFavoriteLoading.value,
                      onTap: controller.toggleFavorite,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: s.dividerWidth,
            height: s.dividerHeight,
            margin: EdgeInsets.symmetric(
              horizontal: s.dividerHorizontalMargin,
            ),
            color:
                AppTheme.textSec(context).withValues(alpha: s.dividerOpacity),
          ),
          Obx(
            () => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.isInitialStatsLoading.value
                    ? null
                    : () => Get.toNamed(
                          AppRoutes.videoViewers,
                          arguments: {
                            'videoId':
                                controller.currentVideo.value?.videoId ?? '',
                            'totalViewCount': controller.appViewCount.value,
                          },
                        ),
                borderRadius: BorderRadius.circular(s.tappableRadius),
                child: StatBadgeWidget(
                  icon: Icons.visibility_outlined,
                  count: controller.appViewCount.value,
                  loading: controller.isInitialStatsLoading.value,
                  tappable: true,
                ),
              ),
            ),
          ),
          SizedBox(width: s.rightSpacing),
          Obx(
            () => StatBadgeWidget(
              icon: Icons.chat_bubble_outline_rounded,
              count: controller.appCommentCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),
          SizedBox(width: s.rightSpacing),
        ],
      ),
    );
  }
}