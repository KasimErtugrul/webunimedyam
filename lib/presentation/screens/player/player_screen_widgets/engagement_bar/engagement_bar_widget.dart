// lib/presentation/screens/player/player_screen_widgets/engagement_bar/engagement_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/player_controller.dart';
import 'engagement_action_widget.dart';
import 'stat_badge_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Container padding
  static const double containerPaddingHorizontal = 8;
  static const double containerPaddingVertical = 6;

  // Spacing
  static const double actionSpacing = 6;
  static const double dividerHorizontalMargin = 8;
  static const double rightSpacing = 4;

  // Divider
  static const double dividerWidth = 1;
  static const double dividerHeight = 16;
  static const double dividerOpacity = 0.15;
}

class _TabletSizes {
  // Container padding - tablet için daha büyük
  static const double containerPaddingHorizontal = 12;
  static const double containerPaddingVertical = 8;

  // Spacing - tablet için daha geniş
  static const double actionSpacing = 10;
  static const double dividerHorizontalMargin = 12;
  static const double rightSpacing = 6;

  // Divider - tablet için daha büyük
  static const double dividerWidth = 1.5;
  static const double dividerHeight = 20;
  static const double dividerOpacity = 0.15;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class EngagementBarWidget extends StatelessWidget {
  final PlayerController controller;
  const EngagementBarWidget({super.key, required this.controller});

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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.containerPaddingHorizontal.w,
        vertical: _PhoneSizes.containerPaddingVertical.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          SizedBox(width: _PhoneSizes.actionSpacing.w),
          Obx(
            () => EngagementActionWidget(
              icon: Icons.share_outlined,
              count: controller.appShareCount.value,
              active: false,
              loading: controller.isShareLoading.value,
              onTap: controller.shareVideo,
            ),
          ),
          SizedBox(width: _PhoneSizes.actionSpacing.w),
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
          const Spacer(),
          Container(
            width: _PhoneSizes.dividerWidth.w,
            height: _PhoneSizes.dividerHeight.h,
            margin: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.dividerHorizontalMargin.w,
            ),
            color: AppTheme.textSec(context).withOpacity(
              _PhoneSizes.dividerOpacity,
            ),
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
                borderRadius: BorderRadius.circular(
                  16.r,
                ),
                child: StatBadgeWidget(
                  icon: Icons.visibility_outlined,
                  count: controller.appViewCount.value,
                  loading: controller.isInitialStatsLoading.value,
                  tappable: true,
                ),
              ),
            ),
          ),
          SizedBox(width: _PhoneSizes.rightSpacing.w),
          Obx(
            () => StatBadgeWidget(
              icon: Icons.chat_bubble_outline_rounded,
              count: controller.appCommentCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),
          SizedBox(width: _PhoneSizes.rightSpacing.w),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.containerPaddingHorizontal,
        vertical: _TabletSizes.containerPaddingVertical,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          SizedBox(width: _TabletSizes.actionSpacing),
          Obx(
            () => EngagementActionWidget(
              icon: Icons.share_outlined,
              count: controller.appShareCount.value,
              active: false,
              loading: controller.isShareLoading.value,
              onTap: controller.shareVideo,
            ),
          ),
          SizedBox(width: _TabletSizes.actionSpacing),
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
          const Spacer(),
          Container(
            width: _TabletSizes.dividerWidth,
            height: _TabletSizes.dividerHeight,
            margin: EdgeInsets.symmetric(
              horizontal: _TabletSizes.dividerHorizontalMargin,
            ),
            color: AppTheme.textSec(context).withOpacity(
              _TabletSizes.dividerOpacity,
            ),
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
                borderRadius: BorderRadius.circular(
                  20,
                ),
                child: StatBadgeWidget(
                  icon: Icons.visibility_outlined,
                  count: controller.appViewCount.value,
                  loading: controller.isInitialStatsLoading.value,
                  tappable: true,
                ),
              ),
            ),
          ),
          SizedBox(width: _TabletSizes.rightSpacing),
          Obx(
            () => StatBadgeWidget(
              icon: Icons.chat_bubble_outline_rounded,
              count: controller.appCommentCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),
          SizedBox(width: _TabletSizes.rightSpacing),
        ],
      ),
    );
  }
}