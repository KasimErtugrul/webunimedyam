// lib/presentation/screens/university_detail/tabs/live_tab/live_tab.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/university_detail_controller.dart';
import '../../../home/tabs/home_tab/widgets/video_card_widget.dart';
import '../../university_detail_layout_spec.dart';
import '../../widgets/tab_state_views.dart';

class UniversityDetailLiveTab extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityDetailController controller;

  const UniversityDetailLiveTab({
    super.key,
    required this.spec,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoadingLive.value;
      final error = controller.liveErrorMessage.value;
      final liveList = controller.liveVideos;

      if (isLoading) {
        return UniversityTabSkeleton(
          child: spec.isTablet
              ? _buildTabletGrid(context, const [], skeleton: true)
              : _buildPhoneList(context, const [], skeleton: true),
        );
      }
      if (error.isNotEmpty) {
        return UniversityTabErrorView(
          spec: spec,
          message: error,
          onRetry: controller.loadLiveVideos,
        );
      }
      if (liveList.isEmpty) {
        return UniversityTabEmptyView(
          spec: spec,
          icon: Icons.sensors_off_rounded,
          title: 'Şu anda canlı yayın yok',
          subtitle: 'Bu üniversite şu anda canlı yayın yapmıyor.',
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        onRefresh: controller.loadLiveVideos,
        child: spec.isTablet
            ? _buildTabletGrid(context, liveList)
            : _buildPhoneList(context, liveList),
      );
    });
  }

  Widget _buildPhoneList(
    BuildContext context,
    List<dynamic> liveList, {
    bool skeleton = false,
  }) {
    if (skeleton) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 3,
        itemBuilder: (_, _) => UniversityVideoSkeletonCard(spec: spec),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 32),
      itemCount: liveList.length,
      itemBuilder: (_, i) => VideoCardWidget(video: liveList[i]),
    );
  }

  Widget _buildTabletGrid(
    BuildContext context,
    List<dynamic> liveList, {
    bool skeleton = false,
  }) {
    final count = skeleton ? 4 : liveList.length;

    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: spec.gridPaddingH,
        vertical: spec.gridPaddingV,
      ),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 450,
        childAspectRatio: spec.gridAspectRatio,
        crossAxisSpacing: spec.gridSpacing,
        mainAxisSpacing: spec.gridSpacing,
      ),
      itemCount: count,
      itemBuilder: (_, i) => skeleton
          ? const SizedBox.shrink()
          : VideoCardWidget(video: liveList[i]),
    );
  }
}