
// ─── Video Card ───────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';
import 'thumb_fallback.dart';

class StatsVideoCard extends StatelessWidget {
  final StatsSizes sizes;
  final String title;
  final String? thumbnail;
  final DateTime? date;
  final IconData icon;
  final Color? iconColor;

  const StatsVideoCard({super.key, 
    required this.sizes,
    required this.title,
    this.thumbnail,
    this.date,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(sizes.videoPadding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.videoBorderRadius),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(sizes.videoThumbnailBorderRadius),
            child: thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: thumbnail!,
                    width: sizes.videoThumbnailWidth,
                    height: sizes.videoThumbnailHeight,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => ThumbFallback(sizes: sizes),
                  )
                : ThumbFallback(sizes: sizes),
          ),
          SizedBox(width: sizes.videoSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: sizes.videoTitleFontSize,
                    fontWeight: FontWeight.w600,
                    height: sizes.videoTitleLineHeight,
                  ),
                ),
                if (date != null) ...[
                  SizedBox(height: sizes.videoSpacingDate),
                  Text(
                    _formatRelative(date!),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: sizes.videoDateFontSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: sizes.videoSpacingSmall),
          Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: sizes.videoIconSize,
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}
