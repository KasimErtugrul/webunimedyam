import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../util/video_section_detail_screen_sizes.dart';

/// Görsel yüklenemediğinde (fallback da başarısız olduğunda) gösterilen kutu.
/// Eskiden phone/tablet için ayrı ayrı yazılıyordu; artık `sizes` parametresi
/// hangi platformda olduğumuzu belirliyor, widget kodu tek.
class VideoSectionDetailScreenPlaceholder extends StatelessWidget {
  const VideoSectionDetailScreenPlaceholder({
    super.key,
    required this.sizes,
  });

  final VideoSectionDetailSizes sizes;

  @override
  Widget build(BuildContext context) => Container(
        width: sizes.thumbnailWidth,
        height: sizes.thumbnailHeight,
        color: AppTheme.surface(context),
        child: Icon(
          Icons.play_circle_outline_rounded,
          color: AppTheme.textSec(context),
          size: sizes.thumbnailIconSize,
        ),
      );
}
