// ─── Live Tab ──────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../../home/tabs/home_tab/widgets/video_card_widget.dart';
import '../../utils/university_detail_sizes.dart';
import '../videos_tab/empty_view.dart';
import '../videos_tab/error_view.dart';
import '../videos_tab/error_view_video_shimmer.dart';

class UniversityDetailLiveTab extends StatelessWidget {
  final UniversityDetailSizes sizes;
  final UniversityDetailController controller;
  const UniversityDetailLiveTab({
    super.key,
    required this.sizes,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingLive.value;
      final error = controller.liveErrorMessage.value;
      final liveList = controller.liveVideos;

      if (isLoading) {
        return _buildShimmer(context);
      }
      if (error.isNotEmpty) {
        return UniversityDetailVideosTabErrorView(
          sizes: sizes,
          error: error,
          onRetry: controller.loadLiveVideos,
        );
      }
      if (liveList.isEmpty) {
        return UniversityDetailVideosTabEmptyView(
          sizes: sizes,
          icon: Icons.sensors_off_rounded,
          title: 'Şu anda canlı yayın yok',
          subtitle: 'Bu üniversite şu anda canlı yayın yapmıyor.',
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadLiveVideos,
        child: sizes.isTablet
            ? _buildTabletGrid(context, liveList)
            : _buildPhoneList(context, liveList),
      );
    });
  }

  Widget _buildShimmer(BuildContext context) {
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
            itemCount: 4,
            itemBuilder: (_, __) =>
                UniversityDetailVideosTabErrorViewVideoShimmer(sizes: sizes),
          )
        : ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: 3,
            itemBuilder: (_, __) =>
                UniversityDetailVideosTabErrorViewVideoShimmer(sizes: sizes),
          );
  }

  Widget _buildPhoneList(BuildContext context, List<dynamic> liveList) {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8.h, bottom: 32.h),
      itemCount: liveList.length,
      itemBuilder: (_, i) => VideoCardWidget(video: liveList[i]),
    );
  }

  Widget _buildTabletGrid(BuildContext context, List<dynamic> liveList) {
    final crossAxisCount =
        MediaQuery.orientationOf(context) == Orientation.landscape ? 3 : 2;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(12, 10, 12, 40),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: liveList.length,
      itemBuilder: (_, i) => VideoCardWidget(video: liveList[i]),
    );
  }
}
