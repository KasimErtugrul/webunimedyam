// lib/presentation/screens/player/player_screen_widgets/suggested_videos_section_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../controllers/player_controller.dart';
import 'suggested_video_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Başlık
  static const double titleIconSize = 16;
  static const double titleIconSpacing = 6;
  static const double titleFontSize = 13;
  static const double titleBottomPadding = 10;

  // Shimmer
  static const double shimmerTitleWidth = 140;
  static const double shimmerTitleHeight = 14;
  static const double shimmerTitleRadius = 6;
  static const double shimmerTitleSpacing = 10;
  static const double shimmerListHeight = 200;
  static const double shimmerCardWidth = 160;
  static const double shimmerCardMarginRight = 12;
  static const double shimmerCardBorderRadius = 14;
  static const int shimmerItemCount = 5;

  // Liste
  static const double listHeight = 200;
}

class _TabletSizes {
  // Başlık - tablet için daha büyük
  static const double titleIconSize = 20;
  static const double titleIconSpacing = 8;
  static const double titleFontSize = 16;
  static const double titleBottomPadding = 12;

  // Shimmer - tablet için daha büyük
  static const double shimmerTitleWidth = 180;
  static const double shimmerTitleHeight = 16;
  static const double shimmerTitleRadius = 8;
  static const double shimmerTitleSpacing = 12;
  static const double shimmerListHeight = 220;
  static const double shimmerCardWidth = 180;
  static const double shimmerCardMarginRight = 14;
  static const double shimmerCardBorderRadius = 16;
  static const int shimmerItemCount = 4;

  // Liste - tablet için daha büyük
  static const double listHeight = 230;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class SuggestedVideosSectionWidget extends StatelessWidget {
  const SuggestedVideosSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final controller = Get.find<PlayerController>(
      tag: Get.parameters['videoId'] ?? '123',
    );

    return Obx(() {
      if (controller.isSuggestedLoading.value) {
        return _buildShimmerPhone(context);
      }

      if (controller.suggestedVideos.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _PhoneSizes.titleBottomPadding.h),
            child: Row(
              children: [
                Icon(
                  Icons.recommend_rounded,
                  size: _PhoneSizes.titleIconSize.sp,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: _PhoneSizes.titleIconSpacing.w),
                Text(
                  'Önerilen Videolar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.titleFontSize.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _PhoneSizes.listHeight.h,
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

  Widget _buildShimmerPhone(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _PhoneSizes.shimmerTitleWidth.w,
          height: _PhoneSizes.shimmerTitleHeight.h,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(
              _PhoneSizes.shimmerTitleRadius.r,
            ),
          ),
        ),
        SizedBox(height: _PhoneSizes.shimmerTitleSpacing.h),
        SizedBox(
          height: _PhoneSizes.shimmerListHeight.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _PhoneSizes.shimmerItemCount,
            itemBuilder: (_, _) => Container(
              width: _PhoneSizes.shimmerCardWidth.w,
              margin: EdgeInsets.only(
                right: _PhoneSizes.shimmerCardMarginRight.w,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.shimmerCardBorderRadius.r,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<PlayerController>(
      tag: Get.parameters['videoId'] ?? '123',
    );

    return Obx(() {
      if (controller.isSuggestedLoading.value) {
        return _buildShimmerTablet(context);
      }

      if (controller.suggestedVideos.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _TabletSizes.titleBottomPadding),
            child: Row(
              children: [
                Icon(
                  Icons.recommend_rounded,
                  size: _TabletSizes.titleIconSize,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: _TabletSizes.titleIconSpacing),
                Text(
                  'Önerilen Videolar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.titleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _TabletSizes.listHeight,
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

  Widget _buildShimmerTablet(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: _TabletSizes.shimmerTitleWidth,
          height: _TabletSizes.shimmerTitleHeight,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(
              _TabletSizes.shimmerTitleRadius,
            ),
          ),
        ),
        SizedBox(height: _TabletSizes.shimmerTitleSpacing),
        SizedBox(
          height: _TabletSizes.shimmerListHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _TabletSizes.shimmerItemCount,
            itemBuilder: (_, _) => Container(
              width: _TabletSizes.shimmerCardWidth,
              margin: EdgeInsets.only(
                right: _TabletSizes.shimmerCardMarginRight,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.shimmerCardBorderRadius,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
