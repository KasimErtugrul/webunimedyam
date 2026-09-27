// ─── Düz Liste / Izgara ─────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../data/models/video_model.dart';
import '../../../controllers/profile_activity_list_controller.dart';
import '../utils/sizes.dart';
import 'dismissible_video.dart';
import 'load_more.dart';
import 'video_card.dart';
import 'video_grid_view.dart';

class ProfileActivityListFlatContent extends StatelessWidget {
  final ProfileActivityListSizes sizes;
  final ProfileActivityListController controller;
  final List<VideoModel> videos;
  final ScrollController scrollController;
  final bool isGrid;

  const ProfileActivityListFlatContent({
    super.key,
    required this.sizes,
    required this.controller,
    required this.videos,
    required this.scrollController,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    final extraCount =
        controller.hasMore.value && controller.searchQuery.value.isEmpty
        ? 1
        : 0;

    if (isGrid) {
      return GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: sizes.gridPaddingHorizontal,
          vertical: sizes.gridPaddingVertical,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: sizes.isTablet ? 3 : 2,
          mainAxisSpacing: sizes.gridMainSpacing,
          crossAxisSpacing: sizes.gridCrossSpacing,
          childAspectRatio: sizes.gridChildAspectRatio,
        ),
        itemCount: videos.length + extraCount,
        itemBuilder: (context, index) {
          if (index == videos.length) {
            return ProfileActivityListLoadMore(sizes: sizes);
          }
          final video = videos[index];
          return _buildItem(context, video, isGrid: true);
        },
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: sizes.listPaddingHorizontal,
        vertical: sizes.listPaddingVertical,
      ),
      itemCount: videos.length + extraCount,
      itemBuilder: (context, index) {
        if (index == videos.length) {
          return ProfileActivityListLoadMore(sizes: sizes);
        }
        final video = videos[index];
        return _buildItem(context, video, isGrid: false);
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    VideoModel video, {
    required bool isGrid,
  }) {
    final child = isGrid
        ? ProfileActivityListVideoGridCard(sizes: sizes, video: video)
        : ProfileActivityListVideoCard(sizes: sizes, video: video);

    if (!controller.isOwnProfile) {
      return child;
    }
    return ProfileActivityListDismissibleVideo(
      sizes: sizes,
      controller: controller,
      video: video,
      child: child,
    );
  }
}