// lib/presentation/screens/university_detail/tabs/videos_tab/videos_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../../home/tabs/home_tab/widgets/video_card_widget.dart';
import '../../university_detail_layout_spec.dart';
import '../../widgets/tab_state_views.dart';

class UniversityDetailVideosTab extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityDetailController controller;

  const UniversityDetailVideosTab({
    super.key,
    required this.spec,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final videoList = controller.videoOnly;
      final isLoadingMore = controller.isLoadingMore.value;
      final hasMore = controller.hasMoreVideos.value;

      if (isLoading) {
        return UniversityTabSkeleton(
          child: spec.isTablet
              ? _buildTabletGrid(context, const [], false, skeleton: true)
              : _buildPhoneList(context, const [], false, skeleton: true),
        );
      }
      if (error.isNotEmpty) {
        return UniversityTabErrorView(
          spec: spec,
          message: error,
          onRetry: controller.loadVideos,
        );
      }
      if (videoList.isEmpty) {
        return UniversityTabEmptyView(
          spec: spec,
          icon: Icons.videocam_off_rounded,
          title: 'Henüz video yok',
          subtitle: 'Bu üniversiteye ait video bulunamadı.',
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadVideos,
        child: NotificationListener<ScrollNotification>(
          onNotification: (n) {
            if (hasMore &&
                !isLoadingMore &&
                n.metrics.pixels >= n.metrics.maxScrollExtent - 400) {
              controller.loadMoreVideos();
            }
            return false;
          },
          child: spec.isTablet
              ? _buildTabletGrid(context, videoList, hasMore)
              : _buildPhoneList(context, videoList, hasMore),
        ),
      );
    });
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<dynamic> videoList,
    bool hasMore, {
    bool skeleton = false,
  }) {
    final count = skeleton ? 6 : videoList.length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            spec.gridPaddingH,
            spec.gridPaddingV,
            spec.gridPaddingH,
            hasMore ? 0 : 40,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450,
              childAspectRatio: spec.gridAspectRatio,
              crossAxisSpacing: spec.gridSpacing,
              mainAxisSpacing: spec.gridSpacing,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => skeleton
                  ? const SizedBox.shrink()
                  : VideoCardWidget(video: videoList[i]),
              childCount: count,
            ),
          ),
        ),
        if (hasMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhoneList(
    BuildContext context,
    List<dynamic> videoList,
    bool hasMore, {
    bool skeleton = false,
  }) {
    if (skeleton) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 6,
        itemBuilder: (_, _) => UniversityVideoSkeletonCard(spec: spec),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: videoList.length + (hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= videoList.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          );
        }
        return VideoCardWidget(video: videoList[i]);
      },
    );
  }
}