// ── Video sonuç kartı ─────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import 'highlight_text_widget.dart';

class VideoResultCardWidget extends StatelessWidget {
  final VideoModel video;
  final String query;
  final VoidCallback onTap;

  const VideoResultCardWidget({super.key, 
    required this.video,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Thumbnail
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
                errorWidget: (_, _, _) => Container(
                  width: 120,
                  height: 80,
                  color: AppTheme.surface(context),
                  child: Icon(Icons.play_circle_outline_rounded,
                      color: AppTheme.textSec(context)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightTextWidget(
                      text: video.title,
                      highlight: query,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    if (video.universityName != null)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      video.formattedViewCount,
                      style: TextStyle(color: AppTheme.textSec(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}