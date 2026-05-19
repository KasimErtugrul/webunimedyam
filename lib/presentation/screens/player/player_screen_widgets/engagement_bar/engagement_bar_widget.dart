// ═══════════════════════════════════════════════════════════════════════════
// Engagement bar — aksiyonlar + uygulama istatistikleri TEK SATIRDA
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

          const SizedBox(width: 4),

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

          const SizedBox(width: 4),

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

          const SizedBox(width: 10),

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