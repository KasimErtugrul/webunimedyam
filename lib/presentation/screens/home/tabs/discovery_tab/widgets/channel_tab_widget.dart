// lib/presentation/screens/home/widgets/tabs/channel_tab/channel_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


import '../../../../../../core/responsive.dart';
import '../../../../../controllers/home_controller.dart';
import '../../home_tab/universities/university_sections_config.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double topPadding = 16;
  static const double bottomPadding = 24;
 // static const double sectionSpacing = 24;
}

class _TabletSizes {
  static const double topPadding = 20;
  static const double bottomPadding = 30;
 // static const double sectionSpacing = 28;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class ChannelTabWidget extends StatelessWidget {
  final HomeController controller;
  const ChannelTabWidget({super.key, required this.controller});

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
              padding: EdgeInsets.only(
                top: _PhoneSizes.topPadding.h,
                bottom: _PhoneSizes.bottomPadding.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
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
              padding: EdgeInsets.only(
                top: _TabletSizes.topPadding,
                bottom: _TabletSizes.bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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