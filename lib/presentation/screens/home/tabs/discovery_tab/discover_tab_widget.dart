// lib/presentation/screens/home/widgets/tabs/discover_tab/discover_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/home/home_controller.dart';
import 'discover_layout_spec.dart';
import 'widgets/channel_tab_widget.dart';
import 'widgets/video_tab_widget.dart';

class DiscoverTabWidget extends StatelessWidget {
  const DiscoverTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = DiscoverLayoutSpec.of(context);
    final controller = Get.find<HomeController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: Column(
          children: [
            _DiscoverHeader(spec: spec),
            Expanded(
              child: TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  VideoTabWidget(controller: controller),
                  ChannelTabWidget(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  final DiscoverLayoutSpec spec;
  const _DiscoverHeader({required this.spec});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final primary = AppTheme.primaryColor;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(spec.tabBarRadius.r * 2),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF0F5C2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50.w,
              top: -40.h,
              child: _Blob(size: 160.w, opacity: 0.10),
            ),
            Positioned(
              left: -40.w,
              bottom: -60.h,
              child: _Blob(size: 130.w, opacity: 0.08),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                spec.heroHPadding.w,
                topInset + spec.heroTopPadding.h,
                spec.heroHPadding.w,
                spec.heroBottomPadding.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: spec.heroIconSize.w,
                        height: spec.heroIconSize.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius:
                              BorderRadius.circular(spec.heroIconRadius.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.4,
                          ),
                        ),
                        child: Icon(
                          Icons.explore_rounded,
                          color: Colors.white,
                          size: spec.heroIconInner.sp,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scaleXY(
                            begin: 0.8,
                            end: 1,
                            curve: Curves.easeOutBack,
                          ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Keşfet',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: spec.heroTitleFontSize.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ).animate().fadeIn(
                                  delay: 100.ms,
                                  duration: 350.ms,
                                ),
                            SizedBox(height: spec.heroSubtitleSpacing.h),
                            Text(
                              'Popüler içerikleri keşfet',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: spec.heroSubtitleFontSize.sp,
                              ),
                            ).animate().fadeIn(
                                  delay: 180.ms,
                                  duration: 350.ms,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spec.heroTitleSpacing.h),
                  Container(
                    height: spec.tabBarHeight.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(spec.tabBarRadius.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          spec.tabBarRadius.r - 4,
                        ),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: primary,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
                      labelStyle: TextStyle(
                        fontSize: spec.tabBarFontSize.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: spec.tabBarFontSize.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      splashFactory: NoSplash.splashFactory,
                      tabs: const [
                        Tab(text: 'Videolar'),
                        Tab(text: 'Kanallar'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 250.ms, duration: 350.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}