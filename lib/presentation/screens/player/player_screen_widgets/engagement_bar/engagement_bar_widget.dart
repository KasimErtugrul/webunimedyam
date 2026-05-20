// ═══════════════════════════════════════════════════════════════════════════
// Engagement bar — aksiyonlar + uygulama istatistikleri TEK SATIRDA
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../controllers/player_controller.dart';
import 'engagement_action_widget.dart';
import 'stat_badge_widget.dart';

class EngagementBarWidget extends StatelessWidget {
  final PlayerController controller;
  const EngagementBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Beğen
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

          SizedBox(width: 4.w),

          // Paylaş
          Obx(
            () => EngagementActionWidget(
              icon: Icons.share_outlined,
              count: controller.appShareCount.value,
              active: false,
              loading: controller.isShareLoading.value,
              onTap: controller.shareVideo,
            ),
          ),

          SizedBox(width: 4.w),

          // Favori
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

          // İzlenme (sadece gösterim, tıklanamaz)
          Obx(
            () => StatBadgeWidget(
              icon: Icons.visibility_outlined,
              count: controller.appViewCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),

          SizedBox(width: 10.w),

          // Yorum sayısı
          Obx(
            () => StatBadgeWidget(
              icon: Icons.chat_bubble_outline_rounded,
              count: controller.appCommentCount.value,
              loading: controller.isInitialStatsLoading.value,
            ),
          ),
        ],
      ),
    );
  }
}