// ════════════════════════════════════════════════════════════════════════════════
// Üniversiteler Sekmesi
// ════════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/home_controller.dart';
import 'widgets/university_card_shimmer_widget.dart';
import 'widgets/university_list_card_widget.dart';

class UniversitiesTabWidget extends StatelessWidget {
  const UniversitiesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: controller.loadPlaylists,
            child: CustomScrollView(
              slivers: [
                // ── AppBar ───────────────────────────────────────────────
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppTheme.bg(context),
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Üniversiteler',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── İçerik ───────────────────────────────────────────────
                if (controller.isPlaylistsLoading.value)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _) => UniversityCardShimmerWidget(),
                        childCount: 6,
                      ),
                    ),
                  )
                else if (controller.playlists.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Üniversite bulunamadı.',
                        style: TextStyle(color: AppTheme.textSec(context)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => UniversityListCardWidget(
                          playlist: controller.playlists[i],
                        ),
                        childCount: controller.playlists.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
