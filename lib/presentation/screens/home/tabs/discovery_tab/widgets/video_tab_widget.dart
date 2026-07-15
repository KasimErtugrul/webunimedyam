// lib/presentation/screens/home/widgets/tabs/video_tab/video_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../core/responsive.dart';

import '../../../../../controllers/home_controller.dart';
import '../../home_tab/videos/video_sections_config.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double topPadding = 16;
  static const double bottomPadding = 24;
}

class _TabletSizes {
  static const double topPadding = 20;
  static const double bottomPadding = 30;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class VideoTabWidget extends StatelessWidget {
  final HomeController controller;
  const VideoTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
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
              padding: EdgeInsets.only(
                top: _PhoneSizes.topPadding.h,
                bottom: _PhoneSizes.bottomPadding.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(videoRxLists.length, (index) {
                  return Obx(() {
                    final widgets = buildVideoSections(
                      configs: [videoSectionConfigs[index]],
                      allVideoItems: [videoRxLists[index].toList()],
                      isLoading: controller.isVideoSectionsLoading.value,
                    );
                    
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

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
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
              padding: EdgeInsets.only(
                top: _TabletSizes.topPadding,
                bottom: _TabletSizes.bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(videoRxLists.length, (index) {
                  return Obx(() {
                    final widgets = buildVideoSections(
                      configs: [videoSectionConfigs[index]],
                      allVideoItems: [videoRxLists[index].toList()],
                      isLoading: controller.isVideoSectionsLoading.value,
                    );
                    
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