// lib/presentation/screens/home/widgets/tabs/discover_tab/discover_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/home_controller.dart';
import '../home_tab/videos/video_sections_config.dart';
import '../home_tab/universities/university_sections_config.dart';

class DiscoverTabWidget extends StatelessWidget {
  const DiscoverTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // ── AppBar ───────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: true,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Keşfet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                bottom: TabBar(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: AppTheme.textSec(context),
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Video'),
                    Tab(text: 'Kanal'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              children: [
                // ── Video Sekmesi ─────────────────────────────────────
                _VideoTab(controller: controller),

                // ── Kanal Sekmesi ─────────────────────────────────────
                _ChannelTab(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Video Sekmesi ────────────────────────────────────────────────────────────

class _VideoTab extends StatelessWidget {
  final HomeController controller;
  const _VideoTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: controller.loadVideoSections,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: buildVideoSections(
                    configs: videoSectionConfigs,
                    allVideoItems: [
                      controller.videosTrending.toList(),
                      controller.videosMostWatched.toList(),
                      controller.videosMostLiked.toList(),
                      controller.videosMostFavorited.toList(),
                      controller.videosMostCommented.toList(),
                      controller.videosNewUndiscovered.toList(),
                    ],
                    isLoading: controller.isVideoSectionsLoading.value,
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

// ─── Kanal Sekmesi ────────────────────────────────────────────────────────────

class _ChannelTab extends StatelessWidget {
  final HomeController controller;
  const _ChannelTab({required this.controller});

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
