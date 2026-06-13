// lib/presentation/screens/player/player_screen_widgets/engagement_bar/engagement_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/player_controller.dart';
import 'engagement_action_widget.dart';
import 'stat_badge_widget.dart';

class EngagementBarWidget extends StatelessWidget {
  final PlayerController controller;
  const EngagementBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─── Etkileşim Butonları ─────────────────────────────────
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

          SizedBox(width: 6.w),

          Obx(
            () => EngagementActionWidget(
              icon: Icons.share_outlined,
              count: controller.appShareCount.value,
              active: false,
              loading: controller.isShareLoading.value,
              onTap: controller.shareVideo,
            ),
          ),

          SizedBox(width: 6.w),

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

          // ─── Ayırıcı ────────────────────────────────────────────
          const Spacer(),

          // Sol taraf eylem, sağ taraf bilgi olduğunu ayırıcı ile vurgula
          Container(
            width: 1.w,
            height: 16.h,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            color: AppTheme.textSec(context).withOpacity(0.15),
          ),

          // ─── Bilgi Rozetleri ─────────────────────────────────────

          // İzlenme — tıklanabilir (InkWell ile ripple efekti)
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
                ), // StatBadge şekline uygun ripple
                child: StatBadgeWidget(
                  icon: Icons.visibility_outlined,
                  count: controller.appViewCount.value,
                  loading: controller.isInitialStatsLoading.value,
                  tappable: true,
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          // Yorum sayısı (tıklanamaz)
          Obx(
            () => StatBadgeWidget(
              icon: Icons.chat_bubble_outline_rounded,
              count: controller.appCommentCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),

          SizedBox(width: 4.w), // Sağ kenar için nefes alanı
        ],
      ),
    );
  }
}
