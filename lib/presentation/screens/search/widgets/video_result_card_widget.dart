// lib/presentation/screens/search/widgets/video_result_card_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../search_layout_spec.dart';
import 'highlight_text_widget.dart';

class VideoResultCardWidget extends StatelessWidget {
  final VideoModel video;
  final String query;
  final VoidCallback onTap;
  final SearchLayoutSpec spec;

  const VideoResultCardWidget({
    super.key,
    required this.video,
    required this.query,
    required this.onTap,
    required this.spec,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: spec.cardBottomMargin),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(spec.cardRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spec.cardRadius),
                bottomLeft: Radius.circular(spec.cardRadius),
              ),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: spec.cardThumbW,
                height: spec.cardThumbH,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  width: spec.cardThumbW,
                  height: spec.cardThumbH,
                  color: AppTheme.surface(context),
                ),
                errorWidget: (_, _, _) => Container(
                  width: spec.cardThumbW,
                  height: spec.cardThumbH,
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: spec.cardPlaceholderIconSize,
                  ),
                ),
              ),
            ),
            SizedBox(width: spec.cardThumbSpacing),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: spec.cardPaddingV),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HighlightTextWidget(
                      text: video.title,
                      highlight: query,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: spec.cardTitleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: spec.cardSpacingSm),
                    if (video.universityName != null)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: spec.cardUniFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: spec.cardSpacingMd),
                    Text(
                      video.formattedViewCount,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: spec.cardViewFontSize,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: spec.cardTrailingSpacing),
          ],
        ),
      ),
    );
  }
}