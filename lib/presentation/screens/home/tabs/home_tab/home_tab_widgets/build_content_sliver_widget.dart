import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../controllers/home_controller.dart';
import '../widgets/video_card_widget.dart';
import 'build_empty_widget.dart';
import 'build_error_widget.dart';
import 'build_video_shimmer_widget.dart';

// GetView kullanımı ile controller'a erişim kolaylaşır
class HomeTabWidgetBuildContentSliverWidget extends GetView<HomeController> {
  const HomeTabWidgetBuildContentSliverWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Obx burada, build metodu içerisinde olmalı.
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverToBoxAdapter(child: HomeTabWidgetBuildVideoShimmerWidget(context: context));
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return SliverToBoxAdapter(child: HomeTabWidgetBuildErrorWidget(controller: controller, context: context));
      }

      final nonShorts = controller.videos.where((v) => !v.isShorts).toList();

      if (nonShorts.isEmpty) {
        return SliverToBoxAdapter(child: HomeTabWidgetBuildEmptyWidget(context: context));
      }

      final showLoader = controller.hasMoreVideos.value;

      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= nonShorts.length) {
            return controller.isLoadingMore.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink();
          }
          return VideoCardWidget(video: nonShorts[index]);
        }, childCount: nonShorts.length + (showLoader ? 1 : 0)),
      );
    });
  }
}