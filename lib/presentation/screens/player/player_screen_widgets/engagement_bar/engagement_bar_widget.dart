// lib/presentation/screens/player/player_screen_widgets/engagement_bar/engagement_bar_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/responsive.dart';
import '../../../../controllers/player/player_controller.dart';
import '../comments_sheet_widget.dart';
import 'engagement_action_widget.dart';

class _Sizes {
  final double containerPaddingH;
  final double containerPaddingV;
  final double actionSpacing;
  final double maxWidth;

  const _Sizes._({
    required this.containerPaddingH,
    required this.containerPaddingV,
    required this.actionSpacing,
    required this.maxWidth,
  });

  factory _Sizes.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, >=1024px): tablet ölçekleri + web ince ayarları.
    if (Responsive.isWeb(context)) {
      return const _Sizes._(
        containerPaddingH: 12,
        containerPaddingV: 8,
        actionSpacing: 12,
        maxWidth: 560,
      );
    }
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        containerPaddingH: 12,
        containerPaddingV: 8,
        actionSpacing: 12,
        maxWidth: 560,
      );
    }
    return const _Sizes._(
      containerPaddingH: 8,
      containerPaddingV: 6,
      actionSpacing: 8,
      maxWidth: double.infinity,
    );
  }
}

/// Beğen · Yorum · Paylaş · Kaydet — tek satırda, eşit genişlikte 4 buton.
/// (İzlenme sayısı artık tarih satırında; bkz. ViewCountMetaWidget.)
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
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: s.maxWidth),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => EngagementActionWidget(
                    icon: controller.isLiked.value
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_up_alt_outlined,
                    count: controller.appLikeCount.value,
                    active: controller.isLiked.value,
                    loading: controller.isLikeLoading.value,
                    onTap: controller.toggleLike,
                    semanticLabel: 'Beğen',
                  ),
                ),
              ),
              SizedBox(width: s.actionSpacing),
              Expanded(
                child: Obx(
                  () => EngagementActionWidget(
                    icon: Icons.chat_bubble_outline_rounded,
                    count: controller.appCommentCount.value,
                    active: false,
                    loading: false,
                    onTap: () => showCommentsSheet(context, controller),
                    semanticLabel: 'Yorumlar',
                  ),
                ),
              ),
              SizedBox(width: s.actionSpacing),
              Expanded(
                child: Obx(
                  () => EngagementActionWidget(
                    icon: Icons.share_outlined,
                    count: controller.appShareCount.value,
                    active: false,
                    loading: controller.isShareLoading.value,
                    onTap: controller.shareVideo,
                    semanticLabel: 'Paylaş',
                  ),
                ),
              ),
              SizedBox(width: s.actionSpacing),
              Expanded(
                child: Obx(
                  () => EngagementActionWidget(
                    icon: controller.isFavorite.value
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    count: controller.appFavoriteCount.value,
                    active: controller.isFavorite.value,
                    loading: controller.isFavoriteLoading.value,
                    onTap: controller.toggleFavorite,
                    semanticLabel: 'Favorilere ekle',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
