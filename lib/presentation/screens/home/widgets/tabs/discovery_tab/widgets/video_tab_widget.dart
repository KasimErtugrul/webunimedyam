// lib/presentation/screens/home/widgets/tabs/video_tab/video_tab_widget.dart

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
    // ── Rx Listeleri bir diziye alıyoruz ki index üzerinden eşleşebilsin ──
    final videoRxLists = [
      controller.videosTrending,
      controller.videosMostWatched,
      controller.videosMostLiked,
      controller.videosMostFavorited,
      controller.videosMostCommented,
      controller.videosNewUndiscovered,
    ];

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
                // ── Her section için ayrı Obx ──────────────────────────
                // Sadece ilgili RxList değişirse o section rebuild olur.
                children: List.generate(videoRxLists.length, (index) {
                  return Obx(() {
                    final widgets = buildVideoSections(
                      configs: [videoSectionConfigs[index]],
                      allVideoItems: [videoRxLists[index].toList()],
                      isLoading: controller.isVideoSectionsLoading.value,
                    );
                    
                    // buildVideoSections List<Widget> döndürür.
                    // Column içinde children doğrudan yayılmalıdır.
                    if (widgets.length == 1) return widgets.first;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets,
                    );
                  });
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}