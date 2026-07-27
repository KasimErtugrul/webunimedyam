import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../util/video_section_detail_screen_sizes.dart';

/// Görsel yüklenirken gösterilen shimmer kutusu. Phone/tablet için ayrı
/// dosyalar yerine tek widget + `sizes` parametresi.
class VideoSectionDetailScreenShimmerBox extends StatelessWidget {
  const VideoSectionDetailScreenShimmerBox({
    super.key,
    required this.sizes,
  });

  final VideoSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) => Container(
        width: sizes.thumbnailWidth,
        height: sizes.thumbnailHeight,
        color: AppTheme.surface(context),
      );
}
