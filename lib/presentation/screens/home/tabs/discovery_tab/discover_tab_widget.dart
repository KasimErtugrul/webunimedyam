// lib/presentation/screens/home/widgets/tabs/discover_tab/discover_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/home_controller.dart';

import 'widgets/channel_tab_widget.dart';
import 'widgets/video_tab_widget.dart';

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
                VideoTabWidget(controller: controller),

                // ── Kanal Sekmesi ─────────────────────────────────────
                ChannelTabWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
