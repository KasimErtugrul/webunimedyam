// ═══════════════════════════════════════════════════════════════════════════
// Video kartı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_model.dart';

class ActivityVideoCardWidget extends StatelessWidget {
  final VideoModel video;
  const ActivityVideoCardWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.player, arguments: video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: 118,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 118, height: 72, color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 118,
                      height: 72,
                      color: AppTheme.surface(context),
                      child: Icon(Icons.play_circle_outline_rounded,
                          color: AppTheme.textSec(context), size: 28),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: const TextStyle(
                          color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(color: AppTheme.textSec(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right_rounded, color: AppTheme.textSec(context), size: 18),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
    if (diff.inDays > 0) return '${diff.inDays} gün önce';
    if (diff.inHours > 0) return '${diff.inHours} saat önce';
    return '${diff.inMinutes} dakika önce';
  }
}