// lib/presentation/screens/home/widgets/tabs/channel_tab/channel_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../controllers/home_controller.dart';
import '../../home_tab/universities/university_sections_config.dart';

class ChannelTabWidget extends StatelessWidget {
  final HomeController controller;
  const ChannelTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // ── Rx Listeleri bir diziye alıyoruz ki index üzerinden eşleşebilsin ──
    final statsRxLists = [
      controller.statsMostWatched,
      controller.statsMostLiked,
      controller.statsPopularInApp,
      controller.statsMostFavorited,
      controller.statsActiveLast30,
      controller.statsBiggestChannels,
      controller.statsRichestArchive,
      controller.statsNewlyDiscovered,
    ];

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      onRefresh: () async {
        await controller.loadUniversityStats();
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // ── Her section için ayrı Obx ──────────────────────────
                children: List.generate(statsRxLists.length, (index) {
                  return Obx(() {
                    final widgets = buildUniversitySections(
                      configs: [uniSectionConfigs[index]],
                      allItems: [statsRxLists[index].toList()],
                      isLoading: controller.isStatsLoading.value,
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