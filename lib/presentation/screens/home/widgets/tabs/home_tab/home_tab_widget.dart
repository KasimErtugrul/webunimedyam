
// ═══════════════════════════════════════════════════════════════════════════
// Ana Sekme
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/datasources/remote/supabase_datasource.dart';
import '../../../../../controllers/home_controller.dart';
import 'widgets/video_card_widget.dart';

class HomeTabWiget extends StatelessWidget {
  const HomeTabWiget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: () async {
              await controller.refreshVideos();
              await controller.loadPlaylists();
            },
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
                          Icons.play_arrow_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(() => Text(controller.appBarTitle)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () => Get.toNamed(AppRoutes.search),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline_rounded),
                      onPressed: () {
                        final supabase = SupabaseDataSource();
                        if (supabase.currentUser != null) {
                          Get.toNamed(AppRoutes.profile);
                        } else {
                          Get.toNamed(AppRoutes.login);
                        }
                      },
                    ),
                  ],
                ),

                // ── Video Listesi Başlığı ───────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'Son Videolar',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ── Video Listesi ─────────────────────────────────────────
                if (controller.isLoading.value)
                  SliverToBoxAdapter(child: buildVideoShimmer(context))
                else if (controller.errorMessage.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.textSec(context),
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: TextStyle(color: AppTheme.textSec(context)),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.loadVideos,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (controller.videos.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Henüz video yok.',
                          style: TextStyle(color: AppTheme.textSec(context)),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          VideoCardWidget(video: controller.videos[index]),
                      childCount: controller.videos.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget buildVideoShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail placeholder
                  Container(
                    height: 196,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                  ),
                  // Bilgi alanı placeholder
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                color: AppTheme.surface(context),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 14,
                                width: 160,
                                color: AppTheme.surface(context),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 11,
                                width: 100,
                                color: AppTheme.surface(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}