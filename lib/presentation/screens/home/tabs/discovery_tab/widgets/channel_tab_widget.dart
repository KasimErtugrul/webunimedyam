// lib/presentation/screens/home/widgets/tabs/channel_tab/channel_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_stats_model.dart';
import '../../../../../controllers/home/home_controller.dart';
import '../../home_tab/universities/university_sections_config.dart';
import '../discover_layout_spec.dart';

class ChannelTabWidget extends StatelessWidget {
  final HomeController controller;
  const ChannelTabWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final spec = DiscoverLayoutSpec.of(context);

    return RefreshIndicator(
      color: AppTheme.primaryColor,
      backgroundColor: AppTheme.card(context),
      onRefresh: controller.loadUniversityStats,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        // FIX: .h kaldırıldı — çifte ölçek (bkz. video_tab_widget.dart).
        padding: EdgeInsets.only(
          top: spec.contentTopPadding,
          bottom: spec.contentBottomPadding,
        ),
        children: [
          for (var i = 0; i < uniSectionConfigs.length; i++)
            Obx(() {
              final items = _itemsFor(i);
              return buildUniversitySections(
                configs: [uniSectionConfigs[i]],
                allItems: [items],
                isLoading: controller.isStatsLoading.value,
              ).first;
            }),
        ],
      ),
    );
  }

  List<UniversityStatsModel> _itemsFor(int i) {
    switch (i) {
      case 0:
        return controller.statsMostWatched.toList();
      case 1:
        return controller.statsMostLiked.toList();
      case 2:
        return controller.statsPopularInApp.toList();
      case 3:
        return controller.statsMostFavorited.toList();
      case 4:
        return controller.statsActiveLast30.toList();
      case 5:
        return controller.statsBiggestChannels.toList();
      case 6:
        return controller.statsRichestArchive.toList();
      case 7:
        return controller.statsNewlyDiscovered.toList();
      default:
        return const [];
    }
  }
}