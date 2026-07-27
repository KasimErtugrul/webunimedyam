// lib/presentation/screens/video_section_detail/video_section_detail_screen.dart

import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';
import 'util/video_section_detail_screen_sizes.dart';
import 'widgets/video_section_detail_screen_build.dart';

class VideoSectionDetailScreen extends StatelessWidget {
  const VideoSectionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    // Phone/tablet ayrımı SADECE burada yapılır; widget kodu artık tek.
    final VideoSectionDetailSizes sizes = Responsive.isTablet(context)
        ? const VideoSectionDetailTabletSizes()
        : const VideoSectionDetailPhoneSizes();

    return VideoSectionDetailScreenBuild(sizes: sizes);
  }
}
