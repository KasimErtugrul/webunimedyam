// ─── Video Sekmesi ────────────────────────────────────────────────────────────


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/home_controller.dart';
import '../../home_tab/videos/video_sections_config.dart';

class VideoTabWidget extends StatelessWidget {
  final HomeController controller;
  const VideoTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: controller.loadVideoSections,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildVideoSections(
                    configs: videoSectionConfigs,
                    allVideoItems: [
                      controller.videosTrending.toList(),
                      controller.videosMostWatched.toList(),
                      controller.videosMostLiked.toList(),
                      controller.videosMostFavorited.toList(),
                      controller.videosMostCommented.toList(),
                      controller.videosNewUndiscovered.toList(),
                    ],
                    isLoading: controller.isVideoSectionsLoading.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}