import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../../home/tabs/home_tab/widgets/video_card_widget.dart';
import '../../utils/university_detail_sizes.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'error_view_video_shimmer.dart';

class UniversityDetailVideosTab extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityDetailController controller;
  const UniversityDetailVideosTab({
    super.key,
    required this.sizes,
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
        return _buildShimmerLoading(context);
      }
      if (error.isNotEmpty) {
        return UniversityDetailVideosTabErrorView(
          sizes: sizes,
          error: error,
          onRetry: controller.loadVideos,
        );
      }
      if (videoList.isEmpty) {
        return UniversityDetailVideosTabEmptyView(
          sizes: sizes,
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
          onNotification: (notification) {
            if (hasMore &&
                !isLoadingMore &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 400) {
              controller.loadMoreVideos();
            }
            return false;
          },
          child: sizes.isTablet
              ? _buildTabletGrid(context, videoList, hasMore)
              : _buildPhoneList(context, videoList, hasMore),
        ),
      );
    });
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return sizes.isTablet
        ? GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.orientationOf(context) == Orientation.landscape
                  ? 3
                  : 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => UniversityDetailVideosTabErrorViewVideoShimmer(sizes: sizes),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: 6,
            itemBuilder: (_, __) => UniversityDetailVideosTabErrorViewVideoShimmer(sizes: sizes),
          );
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<dynamic> videoList,
    bool hasMore,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, hasMore ? 0 : 40),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.orientationOf(context) == Orientation.landscape
                  ? 3
                  : 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => VideoCardWidget(video: videoList[i]),
              childCount: videoList.length,
            ),
          ),
        ),
        if (hasMore)
          SliverToBoxAdapter(
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
    bool hasMore,
  ) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
      itemCount: videoList.length + (hasMore ? 1 : 0),
      itemBuilder: (_, i) {
        if (i >= videoList.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
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