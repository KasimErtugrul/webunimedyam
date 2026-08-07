// ─── Shorts Tab ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_model.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../utils/university_detail_sizes.dart';
import '../videos_tab/empty_view.dart';
import '../videos_tab/error_view.dart';
import 'shorts_card.dart';

class UniversityDetailShortsTab extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityDetailController controller;
  const UniversityDetailShortsTab({
    super.key,
    required this.sizes,
    required this.controller,
  });

  void _openShortsPlayer(List<VideoModel> shorts, int initialIndex) {
    Get.toNamed(
      AppRoutes.simpleShortsPlayer,
      arguments: {'shorts': shorts, 'initialIndex': initialIndex},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final error = controller.errorMessage.value;
      final shortsList = controller.shortsOnly;
      final isLoadingMore = controller.isLoadingMore.value;
      final hasMore = controller.hasMoreVideos.value;

      if (isLoading) {
        return _buildShimmer(context);
      }
      if (error.isNotEmpty) {
        return UniversityDetailVideosTabErrorView(
          sizes: sizes,
          error: error,
          onRetry: controller.loadVideos,
        );
      }
      if (shortsList.isEmpty) {
        return UniversityDetailVideosTabEmptyView(
          sizes: sizes,
          icon: Icons.movie_filter_outlined,
          title: 'Henüz Shorts yok',
          subtitle: 'Bu üniversiteye ait shorts video bulunamadı.',
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
              ? _buildTabletGrid(context, shortsList, hasMore)
              : _buildPhoneGrid(context, shortsList, hasMore),
        ),
      );
    });
  }

  Widget _buildShimmer(BuildContext context) {
    final crossAxisCount =
        MediaQuery.orientationOf(context) == Orientation.landscape ? 3 : 2;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: sizes.isTablet
            ? sizes.shortsCardHeight
            : sizes.shortsCardHeight,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(sizes.shortsCardRadius),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneGrid(
    BuildContext context,
    List<VideoModel> shortsList,
    bool hasMore,
  ) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, hasMore ? 0 : 32.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: sizes.shortsCardHeight,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => UniversityDetailShortsCard(
                sizes: sizes,
                video: shortsList[i],
                onTap: () => _openShortsPlayer(shortsList, i),
              ),
              childCount: shortsList.length,
            ),
          ),
        ),
        if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<VideoModel> shortsList,
    bool hasMore,
  ) {
    final crossAxisCount =
        MediaQuery.orientationOf(context) == Orientation.landscape ? 3 : 2;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, hasMore ? 0 : 40),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisExtent: sizes.shortsCardHeight,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => UniversityDetailShortsCard(
                sizes: sizes,
                video: shortsList[i],
                onTap: () => _openShortsPlayer(shortsList, i),
              ),
              childCount: shortsList.length,
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
}