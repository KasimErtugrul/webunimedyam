// lib/presentation/screens/player/player_screen_widgets/suggested_videos_section_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/player/player_controller.dart';
import 'suggested_video_card_widget.dart';

class _Sizes {
  final double titleIconSize;
  final double titleIconSpacing;
  final double titleFontSize;
  final double titleBottomPadding;
  final double shimmerTitleWidth;
  final double shimmerTitleHeight;
  final double shimmerTitleRadius;
  final double shimmerTitleSpacing;
  final double shimmerListHeight;
  final double shimmerCardWidth;
  final double shimmerCardMarginRight;
  final double shimmerCardRadius;
  final int shimmerItemCount;
  final double listHeight;

  const _Sizes._({
    required this.titleIconSize,
    required this.titleIconSpacing,
    required this.titleFontSize,
    required this.titleBottomPadding,
    required this.shimmerTitleWidth,
    required this.shimmerTitleHeight,
    required this.shimmerTitleRadius,
    required this.shimmerTitleSpacing,
    required this.shimmerListHeight,
    required this.shimmerCardWidth,
    required this.shimmerCardMarginRight,
    required this.shimmerCardRadius,
    required this.shimmerItemCount,
    required this.listHeight,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        titleIconSize: 20,
        titleIconSpacing: 8,
        titleFontSize: 16,
        titleBottomPadding: 12,
        shimmerTitleWidth: 180,
        shimmerTitleHeight: 16,
        shimmerTitleRadius: 8,
        shimmerTitleSpacing: 12,
        shimmerListHeight: 220,
        shimmerCardWidth: 180,
        shimmerCardMarginRight: 14,
        shimmerCardRadius: 16,
        shimmerItemCount: 4,
        listHeight: 230,
      );
    }
    return const _Sizes._(
      titleIconSize: 16,
      titleIconSpacing: 6,
      titleFontSize: 13,
      titleBottomPadding: 10,
      shimmerTitleWidth: 140,
      shimmerTitleHeight: 14,
      shimmerTitleRadius: 6,
      shimmerTitleSpacing: 10,
      shimmerListHeight: 200,
      shimmerCardWidth: 160,
      shimmerCardMarginRight: 12,
      shimmerCardRadius: 14,
      shimmerItemCount: 5,
      listHeight: 200,
    );
  }
}

class SuggestedVideosSectionWidget extends StatelessWidget {
  const SuggestedVideosSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final controller = Get.find<PlayerController>(
      tag: Get.parameters['videoId'] ?? '123',
    );

    return Obx(() {
      if (controller.isSuggestedLoading.value) {
        return _buildShimmer(context, s);
      }
      if (controller.suggestedVideos.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: s.titleBottomPadding),
            child: Row(
              children: [
                Icon(
                  Icons.recommend_rounded,
                  size: s.titleIconSize,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: s.titleIconSpacing),
                Text(
                  'Önerilen Videolar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: s.titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: s.listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.suggestedVideos.length,
              itemBuilder: (_, i) =>
                  SuggestedVideoCard(video: controller.suggestedVideos[i]),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmer(BuildContext context, _Sizes s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: s.shimmerTitleWidth,
          height: s.shimmerTitleHeight,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(s.shimmerTitleRadius),
          ),
        ),
        SizedBox(height: s.shimmerTitleSpacing),
        SizedBox(
          height: s.shimmerListHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: s.shimmerItemCount,
            itemBuilder: (_, _) => Container(
              width: s.shimmerCardWidth,
              margin: EdgeInsets.only(right: s.shimmerCardMarginRight),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(s.shimmerCardRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
} 