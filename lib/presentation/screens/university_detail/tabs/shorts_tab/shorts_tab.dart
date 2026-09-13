// lib/presentation/screens/university_detail/tabs/shorts_tab/shorts_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_model.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../university_detail_layout_spec.dart';
import '../../widgets/tab_state_views.dart';
import 'shorts_card.dart';

class UniversityDetailShortsTab extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityDetailController controller;

  const UniversityDetailShortsTab({
    super.key,
    required this.spec,
    required this.controller,
  });

  void _openShorts(List<VideoModel> shorts, int index) {
    Get.toNamed(
      AppRoutes.simpleShortsPlayer,
      arguments: {'shorts': shorts, 'initialIndex': index},
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
        return UniversityTabSkeleton(child: _buildSkeletonGrid(context));
      }
      if (error.isNotEmpty) {
        return UniversityTabErrorView(
          spec: spec,
          message: error,
          onRetry: controller.loadVideos,
        );
      }
      if (shortsList.isEmpty) {
        return UniversityTabEmptyView(
          spec: spec,
          icon: Icons.bolt_rounded,
          title: 'Henüz Shorts yok',
          subtitle: 'Bu üniversiteye ait shorts video bulunamadı.',
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
          child: _buildGrid(context, shortsList, hasMore),
        ),
      );
    });
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    final cols = MediaQuery.orientationOf(context) == Orientation.landscape
        ? 3
        : 2;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisExtent: spec.shortsGridExtent.h,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(spec.shortsCardRadius.r),
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<VideoModel> shortsList,
    bool hasMore,
  ) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final cols = spec.isTablet ? (landscape ? 3 : 2) : 2;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            12.w,
            10.h,
            12.w,
            hasMore ? 0 : 32.h,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisExtent: spec.shortsGridExtent.h,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => UniversityDetailShortsCard(
                spec: spec,
                video: shortsList[i],
                onTap: () => _openShorts(shortsList, i),
              ),
              childCount: shortsList.length,
            ),
          ),
        ),
        if (hasMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
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
            ),
          ),
      ],
    );
  }
}