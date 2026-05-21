// ── Liste kartı ──────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../app/routes/app_routes.dart';
import '../../../../../../../app/themes/app_theme.dart';
import '../../../../../../../data/models/playlist_model.dart';

class UniversityListCardWidget extends StatelessWidget {
  final PlaylistModel playlist;
  const UniversityListCardWidget({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final hasLogo = playlist.logoUrl != null && playlist.logoUrl!.isNotEmpty;
    final hasThumbnail = playlist.thumbnailUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: AppTheme.card(context),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              Get.toNamed(AppRoutes.playlistDetail, arguments: playlist),
          splashColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Logo ─────────────────────────────────────────────────
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.surface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.textSec(context).withValues(alpha: 0.1),
                    ),
                  ),
                  child: hasLogo
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: CachedNetworkImage(
                            imageUrl: playlist.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => const SizedBox.shrink(),
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.textSec(context),
                              size: 28,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.school_rounded,
                          color: AppTheme.textSec(context),
                          size: 28,
                        ),
                ),

                const SizedBox(width: 14),

                // ── Ad + video sayısı ─────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${playlist.itemCount} video',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ── Thumbnail önizleme ────────────────────────────────────
                if (hasThumbnail)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: playlist.thumbnailUrl,
                      width: 72,
                      height: 48,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        width: 72,
                        height: 48,
                        color: AppTheme.surface(context),
                      ),
                      errorWidget: (_, _, _) => const SizedBox.shrink(),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSec(context),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
