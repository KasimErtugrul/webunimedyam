// lib/presentation/screens/home/tabs/discovery_tab/discover_tab_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../data/models/university_stats_model.dart';
import '../../../../../data/models/video_engagement_model.dart';
import '../../../../controllers/home/home_controller.dart';
import '../home_tab/universities/university_sections_config.dart';
import '../home_tab/videos/video_sections_config.dart';

class DiscoverTabWidget extends StatefulWidget {
  const DiscoverTabWidget({super.key});

  @override
  State<DiscoverTabWidget> createState() => _DiscoverTabWidgetState();
}

class _DiscoverTabWidgetState extends State<DiscoverTabWidget> {
  final HomeController controller = Get.find<HomeController>();

  // 0: Videolar, 1: Kanallar
  int _selectedTabIndex = 0;
  // Kategori çipleri için aktif kategori
  /*  int _selectedCategoryIndex = 0; */

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.discovery.ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
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
              // ── 1. ÜST HEADER BAR artık burada değil ─────────────────────
              // "ÜniTV / KAMPÜS YAYINI" barı HomeScreen'in Scaffold.appBar'ına
              // taşındı (bkz. presentation/screens/home/widgets/unitv_app_bar.dart),
              // bottom navigation'daki tüm sekmelerde sabit kalıyor. Bu sekmede
              // ayrıca tekrar göstermeye gerek yok.

              // ── 2. DISCOVER HUB & SEARCH BANNER ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDiscoverHubCard(
                        context,
                        scheme,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: 14.h),
                      _buildSegmentSwitcher(
                        context,
                        scheme,
                        isTablet: isTablet,
                      ),
                      SizedBox(height: 14.h),
                    ],
                  ),
                ),
              ),

              // ── 3. SEKME İÇERİĞİ (Videolar veya Kanallar) ───────────────
              if (_selectedTabIndex == 0) ...[
                /*  // Kategori Çipleri
                SliverToBoxAdapter(
                  child: _buildCategoryChips(context, scheme, isTablet: isTablet),
                ), */
                SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                // Videolar Listesi
                _buildVideosSection(context, scheme, isTablet: isTablet),
              ] else ...[
                // Kanallar Listesi
                _buildChannelsSection(context, scheme, isTablet: isTablet),
              ],

              // Alt boşluk
              SliverToBoxAdapter(child: SizedBox(height: 32.h)),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. DISCOVER HUB CARD & QUICK SEARCH (Tasarım: Keşfet + CANLI 14 + Search)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDiscoverHubCard(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: [
            scheme.surfaceContainer,
            scheme.surfaceContainerHigh,
            scheme.surfaceContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sağ alt parıltı efekti (Blur glow)
          Positioned(
            right: -20.w,
            bottom: -20.h,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.12),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Başlık Satırı & CANLI 14 Rozeti
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isTablet ? 44.w : 38.w,
                          height: isTablet ? 44.w : 38.w,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(
                            Icons.explore_rounded,
                            color: scheme.primary,
                            size: isTablet ? 24.sp : 20.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Keşfet',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: isTablet ? 22.sp : 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Kampüsün nabzı ve güncel yayınlar',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: isTablet ? 13.sp : 11.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // CANLI 14 Rozeti
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: scheme.primary.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: scheme.primary,
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(
                                begin: const Offset(0.8, 0.8),
                                end: const Offset(1.4, 1.4),
                                duration: 800.ms,
                              ),
                          SizedBox(width: 5.w),
                          Text(
                            'CANLI 14',
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: isTablet ? 11.sp : 9.5.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h), */

                // Quick Search Bar
                GestureDetector(
                  onTap: () => controller.changeTab(3), // Arama sekmesine geç
                  child: Container(
                    height: isTablet ? 46.h : 42.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: scheme.outlineVariant.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: scheme.outline,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Seminer, robotik, konser veya kanal ara...',
                            style: TextStyle(
                              color: scheme.outline,
                              fontSize: isTablet ? 13.5.sp : 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 28.w,
                          height: 28.w,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: scheme.onSurfaceVariant,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SEGMENTED SWITCHER (Videolar / Kanallar)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSegmentSwitcher(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Videolar Butonu
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTabIndex != 0) {
                  setState(() => _selectedTabIndex = 0);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? scheme.surfaceContainerHigh
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9.r),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.smart_display_rounded,
                      size: isTablet ? 18.sp : 16.sp,
                      color: _selectedTabIndex == 0
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Videolar',
                      style: TextStyle(
                        color: _selectedTabIndex == 0
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontSize: isTablet ? 14.sp : 13.sp,
                        fontWeight: _selectedTabIndex == 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Kanallar Butonu
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTabIndex != 1) {
                  setState(() => _selectedTabIndex = 1);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 9.h),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? scheme.surfaceContainerHigh
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9.r),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.podcasts_rounded,
                      size: isTablet ? 18.sp : 16.sp,
                      color: _selectedTabIndex == 1
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Kanallar',
                      style: TextStyle(
                        color: _selectedTabIndex == 1
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontSize: isTablet ? 14.sp : 13.sp,
                        fontWeight: _selectedTabIndex == 1
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. CATEGORY CHIPS (Tümü, Teknoloji, Akademik, Sanat, Kampüs)
  // ═══════════════════════════════════════════════════════════════════════════
  /*  Widget _buildCategoryChips(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return SizedBox(
      height: isTablet ? 38.h : 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16.w : 13.w,
                vertical: 6.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? scheme.primary.withValues(alpha: 0.2)
                    : scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected
                      ? scheme.primary.withValues(alpha: 0.4)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index == 0) ...[
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: isTablet ? 16.sp : 14.sp,
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    _categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontSize: isTablet ? 12.5.sp : 11.5.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  } */

  // ═══════════════════════════════════════════════════════════════════════════
  // 5. VIDEOS VIEW (Tasarım: Trend Videolar + En Çok İzlenenler + Seksiyonlar)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVideosSection(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── BÖLÜM 1: Trend Videolar (Büyük Kartlar) ──
          Obx(() {
            final trendingList = controller.videosTrending.toList();
            final isLoading = controller.isVideoSectionsLoading.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  scheme,
                  title: 'Trend Videolar',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: AppTheme.darkTertiaryContainer,
                  isTablet: isTablet,
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.videoSectionDetail,
                    arguments: VideoSectionType.trending,
                  ),
                ),
                SizedBox(height: 10.h),
                if (isLoading)
                  _buildVideoCardShimmer(context, scheme, isTablet: isTablet)
                else if (trendingList.isEmpty)
                  const SizedBox.shrink()
                else ...[
                  // İlk 2 trend videoyu büyük vitrin kartı olarak göster
                  for (var i = 0; i < trendingList.take(2).length; i++) ...[
                    _buildLargeVideoCard(
                      context,
                      scheme,
                      video: trendingList[i],
                      badgeText:
                          '${trendingList[i].engagementScore} Etkileşim Puanı',
                      badgeIcon: Icons.bolt_rounded,
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ],
              ],
            );
          }),

          SizedBox(height: 16.h),

          // ── BÖLÜM 2: En Çok İzlenenler (Öne Çıkan Konser / Vitrin Kartı) ──
          Obx(() {
            final mostWatched = controller.videosMostWatched.toList();
            final isLoading = controller.isVideoSectionsLoading.value;

            if (mostWatched.isEmpty && !isLoading) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  scheme,
                  title: 'En Çok İzlenenler',
                  icon: Icons.visibility_rounded,
                  iconColor: scheme.primary,
                  trailingText: 'BU AY',
                  isTablet: isTablet,
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.videoSectionDetail,
                    arguments: VideoSectionType.mostWatched,
                  ),
                ),
                SizedBox(height: 10.h),
                if (isLoading)
                  _buildVideoCardShimmer(context, scheme, isTablet: isTablet)
                else if (mostWatched.isNotEmpty)
                  _buildLargeVideoCard(
                    context,
                    scheme,
                    video: mostWatched.first,
                    badgeText: 'Öne Çıkan',
                    badgeIcon: Icons.star_rounded,
                    isFeatured: true,
                    isTablet: isTablet,
                  ),
              ],
            );
          }),

          SizedBox(height: 20.h),

          // ── BÖLÜM 3: Diğer Video Kategorileri (Yatay Slider'lar) ──
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 6. CHANNELS VIEW (Tasarım: En Çok İzlenen Kanallar + Beğenilenler Sıralaması)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildChannelsSection(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // ── BÖLÜM 1: En Çok İzlenen Kanallar (Top 3) ──
          Obx(() {
            final topChannels = controller.statsMostWatched.toList();
            final isLoading = controller.isStatsLoading.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  scheme,
                  title: 'En Çok İzlenen Kanallar',
                  icon: Icons.tv_rounded,
                  iconColor: scheme.primary,
                  trailingBadge: 'Top 3',
                  isTablet: isTablet,
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.universityStatsSectionDetail,
                    arguments: UniversityStatsSectionType.mostWatched,
                  ),
                ),
                SizedBox(height: 10.h),
                if (isLoading)
                  _buildChannelCardShimmer(context, scheme, isTablet: isTablet)
                else if (topChannels.isEmpty)
                  const SizedBox.shrink()
                else
                  for (var i = 0; i < topChannels.take(3).length; i++) ...[
                    _buildTopChannelRow(
                      context,
                      scheme,
                      stats: topChannels[i],
                      isFollowed:
                          i == 1, // Tasarımdaki takipte durumu simülasyonu
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 8.h),
                  ],
              ],
            );
          }),

          SizedBox(height: 20.h),

          // ── BÖLÜM 2: En Çok Beğenilen Kanallar (Leaderboard Grid) ──
          Obx(() {
            final mostLiked = controller.statsMostLiked.toList();
            final isLoading = controller.isStatsLoading.value;

            if (mostLiked.isEmpty && !isLoading) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  context,
                  scheme,
                  title: 'En Çok Beğenilen Kanallar',
                  icon: Icons.thumb_up_rounded,
                  iconColor: AppTheme.darkTertiaryContainer,
                  trailingText: 'TOP SIRALAMA',
                  isTablet: isTablet,
                  onSeeAll: () => Get.toNamed(
                    AppRoutes.universityStatsSectionDetail,
                    arguments: UniversityStatsSectionType.mostLiked,
                  ),
                ),
                SizedBox(height: 10.h),
                if (isLoading)
                  _buildChannelCardShimmer(context, scheme, isTablet: isTablet)
                else
                  Row(
                    children: [
                      if (mostLiked.isNotEmpty)
                        Expanded(
                          child: _buildLeaderboardCard(
                            context,
                            scheme,
                            stats: mostLiked[0],
                            rank: '#1',
                            isTablet: isTablet,
                          ),
                        ),
                      SizedBox(width: 10.w),
                      if (mostLiked.length > 1)
                        Expanded(
                          child: _buildLeaderboardCard(
                            context,
                            scheme,
                            stats: mostLiked[1],
                            rank: '#2',
                            isTablet: isTablet,
                          ),
                        ),
                    ],
                  ),
              ],
            );
          }),

          SizedBox(height: 20.h),

          // ── BÖLÜM 3: Diğer Üniversite İstatistikleri (Yatay Slider'lar) ──
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

  // ═══════════════════════════════════════════════════════════════════════════
  // KART VE BİLEŞEN METODLARI
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
    BuildContext context,
    ColorScheme scheme, {
    required String title,
    required IconData icon,
    required Color iconColor,
    String? trailingText,
    String? trailingBadge,
    VoidCallback? onSeeAll,
    required bool isTablet,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: isTablet ? 22.sp : 18.sp),
            SizedBox(width: 6.w),
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: isTablet ? 17.sp : 15.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        if (trailingBadge != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              trailingBadge,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else if (trailingText != null)
          Text(
            trailingText,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          )
        else if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'Tümü',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: isTablet ? 13.sp : 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.primary,
                  size: 16.sp,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Büyük Vitrin Video Kartı (Tasarım: 16:9 görsel, Etkileşim rozeti, süre, kanal avatarı, onay rozeti)
  Widget _buildLargeVideoCard(
    BuildContext context,
    ColorScheme scheme, {
    required VideoEngagementModel video,
    required String badgeText,
    required IconData badgeIcon,
    bool isFeatured = false,
    required bool isTablet,
  }) {
    final initials = video.channelTitle.isNotEmpty
        ? video.channelTitle
              .substring(
                0,
                video.channelTitle.length > 3 ? 3 : video.channelTitle.length,
              )
              .toUpperCase()
        : 'ÜNİ';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video.toVideoModel(),
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 16:9 Thumbnail & Rozetler
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: scheme.surfaceContainerHighest),
                    errorWidget: (_, _, _) => CachedNetworkImage(
                      imageUrl: video.fallbackThumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient kaplama
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          scheme.surfaceContainerLowest.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Sol Üst Rozet (Etkileşim / Öne Çıkan)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: isFeatured
                            ? scheme.primary
                            : scheme.surfaceContainerLowest.withValues(
                                alpha: 0.85,
                              ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            badgeIcon,
                            color: isFeatured
                                ? scheme.onPrimary
                                : scheme.primary,
                            size: 13.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            badgeText,
                            style: TextStyle(
                              color: isFeatured
                                  ? scheme.onPrimary
                                  : scheme.primary,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Sağ Alt Süre
                  Positioned(
                    bottom: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLowest.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        video.duration.isNotEmpty ? video.duration : '18:42',
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Merkez Play Butonu İkonu
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primary.withValues(alpha: 0.85),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: scheme.onPrimary,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kart Alt Bilgileri
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isTablet ? 15.sp : 13.5.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // Kanal Avatarı / Kısaltması
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.surfaceContainerHighest,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                video.channelTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.verified_rounded,
                              color: scheme.primary,
                              size: 13.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '•',
                              style: TextStyle(
                                color: scheme.outline,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${video.ytViewCount.compact} İzlenme',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '•',
                              style: TextStyle(
                                color: scheme.outline,
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              timeAgoTr(video.publishedAt),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // En Çok İzlenen Kanal Satırı (Tasarım: OD/İTÜ/AU avatarı, doğrulanmış rozet, izlenme, takip butonu)
  Widget _buildTopChannelRow(
    BuildContext context,
    ColorScheme scheme, {
    required UniversityStatsModel stats,
    bool isFollowed = false,
    required bool isTablet,
  }) {
    final initials = stats.name.isNotEmpty
        ? stats.name
              .substring(0, stats.name.length > 2 ? 2 : stats.name.length)
              .toUpperCase()
        : 'ÜN';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.universityDetail,
        arguments: stats.universityId,
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Logo / İnisiyaller
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: isTablet ? 48.w : 42.w,
                  height: isTablet ? 48.w : 42.w,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  alignment: Alignment.center,
                  child: stats.logoUrl != null && stats.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: stats.logoUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Text(
                          initials,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: isTablet ? 16.sp : 14.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                Positioned(
                  bottom: -2.h,
                  right: -2.w,
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    ),
                    child: Icon(
                      Icons.check,
                      color: scheme.onPrimary,
                      size: 9.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: 12.w),

            // Kanal Bilgisi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stats.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: isTablet ? 14.5.sp : 13.5.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Text(
                        '${stats.totalYtViews.compact} İzlenme',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '•',
                        style: TextStyle(
                          color: scheme.outline,
                          fontSize: 11.sp,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '${stats.totalVideos} Video',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Takip Et / Takipte Butonu
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isFollowed
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFollowed ? Icons.check : Icons.add,
                    size: 14.sp,
                    color: isFollowed ? scheme.onPrimary : scheme.primary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isFollowed ? 'Takipte' : 'Takip Et',
                    style: TextStyle(
                      color: isFollowed ? scheme.onPrimary : scheme.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // En Çok Beğenilen Kanal Sıralaması Kartı (Tasarım: #1/#2, büyük avatar, % pozitif oy, beğeni hapı)
  Widget _buildLeaderboardCard(
    BuildContext context,
    ColorScheme scheme, {
    required UniversityStatsModel stats,
    required String rank,
    required bool isTablet,
  }) {
    final initials = stats.name.isNotEmpty
        ? stats.name
              .substring(0, stats.name.length > 2 ? 2 : stats.name.length)
              .toUpperCase()
        : 'ÜN';

    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.universityDetail,
        arguments: stats.universityId,
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Stack(
          children: [
            // Sıralama Rozeti (#1, #2)
            Positioned(
              top: 0,
              left: 0,
              child: Text(
                rank,
                style: TextStyle(
                  color: rank == '#1' ? scheme.primary : scheme.outline,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            Column(
              children: [
                SizedBox(height: 6.h),
                // Büyük Yuvarlak Avatar
                Container(
                  width: isTablet ? 54.w : 46.w,
                  height: isTablet ? 54.w : 46.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surfaceContainerHighest,
                  ),
                  alignment: Alignment.center,
                  child: stats.logoUrl != null && stats.logoUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: stats.logoUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Text(
                          initials,
                          style: TextStyle(
                            color: scheme.primary,
                            fontSize: isTablet ? 17.sp : 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
                SizedBox(height: 8.h),
                Text(
                  stats.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: isTablet ? 13.5.sp : 12.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${stats.subscriberCount.compact} Abone',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 10.5.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                // Beğeni Rozeti
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 5.h),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volunteer_activism_rounded,
                        color: scheme.primary,
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${stats.totalYtLikes.compact} Beğeni',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer Yükleme İskeletleri
  Widget _buildVideoCardShimmer(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14.r),
      ),
    );
  }

  Widget _buildChannelCardShimmer(
    BuildContext context,
    ColorScheme scheme, {
    required bool isTablet,
  }) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }

  List<VideoEngagementModel> _videoItemsFor(int i) {
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

  List<UniversityStatsModel> _uniItemsFor(int i) {
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
