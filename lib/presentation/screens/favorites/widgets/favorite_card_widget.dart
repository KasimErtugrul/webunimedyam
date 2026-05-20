import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../../../controllers/favorites_controller.dart';

class FavoriteCardWidget extends StatelessWidget {
  final VideoModel video;

  const FavoriteCardWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Dismissible(
      key: Key(video.videoId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => controller.removeFavorite(video.videoId),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.player, arguments: video),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 120,
                    height: 80,
                    color: AppTheme.surface(context),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${video.viewCount} görüntülenme',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
