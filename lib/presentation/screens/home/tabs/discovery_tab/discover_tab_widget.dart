// lib/presentation/screens/home/tabs/discovery_tab/discover_tab_widget.dart
//
// Discover tab — ana iskelet. Ortak widget'lar discover_widgets.dart'ta,
// ölçüler DiscoverLayoutSpec'te. Bu dosyada yalnızca sekme state'i ve
// bölüm kompozisyonu kaldı.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/home/home_controller.dart';
import '../home_tab/universities/university_sections_config.dart';
import '../home_tab/videos/video_sections_config.dart';
import 'discover_layout_spec.dart';
import 'widgets/discover_widgets.dart';

class DiscoverTabWidget extends StatefulWidget {
  const DiscoverTabWidget({super.key});

  @override
  State<DiscoverTabWidget> createState() => _DiscoverTabWidgetState();
}

class _DiscoverTabWidgetState extends State<DiscoverTabWidget> {
  final HomeController controller = Get.find<HomeController>();

  // 0: Videolar, 1: Kanallar
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.discovery.ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final spec = DiscoverLayoutSpec.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: scheme.primary,
          backgroundColor: scheme.surfaceContainerHigh,
          onRefresh: () async {
            await Future.wait([
              controller.loadVideoSections(),
              controller.loadUniversityStats(),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Hub kartı + segment switcher ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: spec.listPadH),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DiscoverHubCard(
                        spec: spec,
                        onSearchTap: () => controller.changeTab(3),
                      ),
                      SizedBox(height: spec.hubSegmentGap),
                      DiscoverSegmentSwitcher(
                        spec: spec,
                        selectedIndex: _selectedTabIndex,
                        onChanged: (i) {
                          if (_selectedTabIndex != i) {
                            setState(() => _selectedTabIndex = i);
                          }
                        },
                      ),
                      SizedBox(height: spec.hubSegmentGap),
                    ],
                  ),
                ),
              ),

              // ── Sekme içeriği ──────────────────────────────────────────
              if (_selectedTabIndex == 0) ...[
                SliverToBoxAdapter(child: SizedBox(height: spec.videosTopGap)),
                _buildVideosSection(context, spec),
              ] else
                _buildChannelsSection(context, spec),

              SliverToBoxAdapter(child: SizedBox(height: spec.bottomGap)),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // VIDEOS
  // ═══════════════════════════════════════════════════════════

  Widget _buildVideosSection(BuildContext context, DiscoverLayoutSpec spec) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: spec.listPadH),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── Trend Videolar (büyük kartlar) ──
          Obx(() {
            final trendingList = controller.videosTrending.toList();
            final isLoading = controller.isVideoSectionsLoading.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscoverSectionHeader(
                  spec: spec,
                  title: 'Trend Videolar',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppTheme.darkTertiaryContainer,
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.videoSectionDetail,
                    arguments: VideoSectionType.trending,
                  ),
                ),
                SizedBox(height: spec.headerContentGap),
                if (isLoading)
                  const DiscoverVideoCardShimmer()
                else if (trendingList.isEmpty)
                  const SizedBox.shrink()
                else
                  for (var i = 0; i < trendingList.take(2).length; i++) ...[
                    DiscoverLargeVideoCard(
                      spec: spec,
                      video: trendingList[i],
                      badgeText:
                          '${trendingList[i].engagementScore} Etkileşim Puanı',
                      badgeIcon: Icons.bolt_rounded,
                    ),
                    SizedBox(height: spec.largeCardGap),
                  ],
              ],
            );
          }),

          SizedBox(height: spec.sectionGapMedium),

          // ── En Çok İzlenenler (vitrin kartı) ──
          Obx(() {
            final mostWatched = controller.videosMostWatched.toList();
            final isLoading = controller.isVideoSectionsLoading.value;

            if (mostWatched.isEmpty && !isLoading) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscoverSectionHeader(
                  spec: spec,
                  title: 'En Çok İzlenenler',
                  icon: Icons.visibility_rounded,
                  iconColor: Theme.of(context).colorScheme.primary,
                  trailingText: 'BU AY',
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.videoSectionDetail,
                    arguments: VideoSectionType.mostWatched,
                  ),
                ),
                SizedBox(height: spec.headerContentGap),
                if (isLoading)
                  const DiscoverVideoCardShimmer()
                else if (mostWatched.isNotEmpty)
                  DiscoverLargeVideoCard(
                    spec: spec,
                    video: mostWatched.first,
                    badgeText: 'Öne Çıkan',
                    badgeIcon: Icons.star_rounded,
                    isFeatured: true,
                  ),
              ],
            );
          }),

          SizedBox(height: spec.sectionGapLarge),

          // ── Diğer video bölümleri (yatay slider'lar) ──
          for (var i = 2; i < videoSectionConfigs.length; i++)
            Obx(() {
              final items = _videoItemsFor(i);
              return buildVideoSections(
                configs: [videoSectionConfigs[i]],
                allVideoItems: [items],
                isLoading: controller.isVideoSectionsLoading.value,
              ).first;
            }),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CHANNELS
  // ═══════════════════════════════════════════════════════════

  Widget _buildChannelsSection(BuildContext context, DiscoverLayoutSpec spec) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: spec.listPadH),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── En Çok İzlenen Kanallar (Top 3) ──
          Obx(() {
            final topChannels = controller.statsMostWatched.toList();
            final isLoading = controller.isStatsLoading.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscoverSectionHeader(
                  spec: spec,
                  title: 'En Çok İzlenen Kanallar',
                  icon: Icons.tv_rounded,
                  iconColor: Theme.of(context).colorScheme.primary,
                  trailingBadge: 'Top 3',
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.universityStatsSectionDetail,
                    arguments: UniversityStatsSectionType.mostWatched,
                  ),
                ),
                SizedBox(height: spec.headerContentGap),
                if (isLoading)
                  const DiscoverChannelCardShimmer()
                else if (topChannels.isEmpty)
                  const SizedBox.shrink()
                else
                  for (var i = 0; i < topChannels.take(3).length; i++) ...[
                    // NOT: isFollowed: i == 1 orijinaldeki simülasyondur
                    // (tasarımdaki "takipte" durumunu göstermek için).
                    // Gerçek takip verisi bağlanınca kaldırılmalı.
                    DiscoverTopChannelRow(
                      spec: spec,
                      stats: topChannels[i],
                      isFollowed: i == 1,
                    ),
                    SizedBox(height: spec.channelRowVGap),
                  ],
              ],
            );
          }),

          SizedBox(height: spec.sectionGapLarge),

          // ── En Çok Beğenilen Kanallar (#1 / #2) ──
          Obx(() {
            final mostLiked = controller.statsMostLiked.toList();
            final isLoading = controller.isStatsLoading.value;

            if (mostLiked.isEmpty && !isLoading) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiscoverSectionHeader(
                  spec: spec,
                  title: 'En Çok Beğenilen Kanallar',
                  icon: Icons.thumb_up_rounded,
                  iconColor: AppTheme.darkTertiaryContainer,
                  trailingText: 'TOP SIRALAMA',
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.universityStatsSectionDetail,
                    arguments: UniversityStatsSectionType.mostLiked,
                  ),
                ),
                SizedBox(height: spec.headerContentGap),
                if (isLoading)
                  const DiscoverChannelCardShimmer()
                else
                  Row(
                    children: [
                      if (mostLiked.isNotEmpty)
                        Expanded(
                          child: DiscoverLeaderboardCard(
                            spec: spec,
                            stats: mostLiked[0],
                            rank: '#1',
                          ),
                        ),
                      SizedBox(width: spec.leaderboardColumnGap),
                      if (mostLiked.length > 1)
                        Expanded(
                          child: DiscoverLeaderboardCard(
                            spec: spec,
                            stats: mostLiked[1],
                            rank: '#2',
                          ),
                        ),
                    ],
                  ),
              ],
            );
          }),

          SizedBox(height: spec.sectionGapLarge),

          // ── Diğer üniversite istatistikleri (yatay slider'lar) ──
          for (var i = 2; i < uniSectionConfigs.length; i++)
            Obx(() {
              final items = _uniItemsFor(i);
              return buildUniversitySections(
                configs: [uniSectionConfigs[i]],
                allItems: [items],
                isLoading: controller.isStatsLoading.value,
              ).first;
            }),
        ]),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Veri eşleme (orijinal switch'ler, video/channel tab ile aynı)
  // ═══════════════════════════════════════════════════════════

  dynamic _videoItemsFor(int i) {
    switch (i) {
      case 0:
        return controller.videosTrending.toList();
      case 1:
        return controller.videosMostWatched.toList();
      case 2:
        return controller.videosMostLiked.toList();
      case 3:
        return controller.videosMostFavorited.toList();
      case 4:
        return controller.videosMostCommented.toList();
      case 5:
        return controller.videosNewUndiscovered.toList();
      default:
        return const [];
    }
  }

  dynamic _uniItemsFor(int i) {
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