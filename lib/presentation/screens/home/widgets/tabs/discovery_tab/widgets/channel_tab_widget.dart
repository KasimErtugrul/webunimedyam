// ─── Kanal Sekmesi ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../controllers/home_controller.dart';
import '../../home_tab/universities/university_sections_config.dart';

class ChannelTabWidget extends StatelessWidget {
  final HomeController controller;
  const ChannelTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                  children: buildUniversitySections(
                    configs: uniSectionConfigs,
                    allItems: [
                      controller.statsMostWatched.toList(),
                      controller.statsMostLiked.toList(),
                      controller.statsPopularInApp.toList(),
                      controller.statsMostFavorited.toList(),
                      controller.statsActiveLast30.toList(),
                      controller.statsBiggestChannels.toList(),
                      controller.statsRichestArchive.toList(),
                      controller.statsNewlyDiscovered.toList(),
                    ],
                    isLoading: controller.isStatsLoading.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}