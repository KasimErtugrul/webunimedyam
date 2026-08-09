// lib/presentation/screens/home/widgets/tabs/discover_tab/discover_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/home_controller.dart';

import 'widgets/channel_tab_widget.dart';
import 'widgets/video_tab_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar icon
  static const double iconSize = 32;
  static const double iconBorderRadius = 8;
  static const double iconInnerSize = 18;
  static const double iconSpacing = 10;

  // TabBar
  static const double labelFontSize = 14;
  static const double unselectedLabelFontSize = 14;
}

class _TabletSizes {
  // AppBar icon - tablet için daha büyük
  static const double iconSize = 38;
  static const double iconBorderRadius = 10;
  static const double iconInnerSize = 22;
  static const double iconSpacing = 12;

  // TabBar - tablet için daha büyük
  static const double labelFontSize = 16;
  static const double unselectedLabelFontSize = 16;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class DiscoverTabWidget extends StatelessWidget {
  const DiscoverTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final controller = Get.find<HomeController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: true,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Container(
                      width: _PhoneSizes.iconSize.w,
                      height: _PhoneSizes.iconSize.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          _PhoneSizes.iconBorderRadius.r,
                        ),
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: _PhoneSizes.iconInnerSize.sp,
                      ),
                    ),
                    SizedBox(width: _PhoneSizes.iconSpacing.w),
                    Text('Keşfet', style: TextStyle(color: AppTheme.textPri(context))),
                  ],
                ),
                bottom: TabBar(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: AppTheme.textSec(context),
                  labelStyle: TextStyle(
                    fontSize: _PhoneSizes.labelFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: _PhoneSizes.unselectedLabelFontSize.sp,
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
                VideoTabWidget(controller: controller),
                ChannelTabWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<HomeController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.bg(context),
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: true,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Container(
                      width: _TabletSizes.iconSize,
                      height: _TabletSizes.iconSize,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.iconBorderRadius,
                        ),
                      ),
                      child: Icon(
                        Icons.explore_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: _TabletSizes.iconInnerSize,
                      ),
                    ),
                    SizedBox(width: _TabletSizes.iconSpacing),
                    Text('Keşfet'),
                  ],
                ),
                bottom: TabBar(
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: AppTheme.textSec(context),
                  labelStyle: TextStyle(
                    fontSize: _TabletSizes.labelFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: _TabletSizes.unselectedLabelFontSize,
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
                VideoTabWidget(controller: controller),
                ChannelTabWidget(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
