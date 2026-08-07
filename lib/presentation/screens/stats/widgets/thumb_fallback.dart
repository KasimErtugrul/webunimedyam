import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class ThumbFallback extends StatelessWidget {
  final StatsSizes sizes;
  const ThumbFallback({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes.videoThumbnailWidth,
      height: sizes.videoThumbnailHeight,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(sizes.videoThumbnailBorderRadius),
      ),
      child: Icon(
        Icons.play_circle_outline_rounded,
        color: AppTheme.textSec(context),
        size: sizes.thumbFallbackIconSize,
      ),
    );
  }
}
