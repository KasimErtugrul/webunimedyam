// lib/presentation/screens/home/widgets/tabs/video_tab/video_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/video_engagement_model.dart';
import '../../../../../controllers/home/home_controller.dart';
import '../../home_tab/videos/video_sections_config.dart';
import '../discover_layout_spec.dart';   // ← EKLE

class VideoTabWidget extends StatelessWidget {
  final HomeController controller;
  const VideoTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final spec = DiscoverLayoutSpec.of(context);

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.card(context),
      onRefresh: controller.loadVideoSections,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(
          top: spec.contentTopPadding.h,
          bottom: spec.contentBottomPadding.h,
        ),
        children: [
          for (var i = 0; i < videoSectionConfigs.length; i++)
            Obx(() {
              final items = _itemsFor(i);
              return buildVideoSections(
                configs: [videoSectionConfigs[i]],
                allVideoItems: [items],
                isLoading: controller.isVideoSectionsLoading.value,
              ).first;
            }),
        ],
      ),
    );
  }

  List<VideoEngagementModel> _itemsFor(int i) {
    switch (i) {
      case 0:
        return controller.videosTrending.toList();
      case 1:
        return controller.videosMostWatched.toList();
      case 2:
        return controller.videosMostLiked.toList();
      case 3:
        return controller.videosMostFavorited.toList();
      case 4:
        return controller.videosMostCommented.toList();
      case 5:
        return controller.videosNewUndiscovered.toList();
      default:
        return const [];
    }
  }
}