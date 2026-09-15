// lib/presentation/screens/home/widgets/tabs/universities_tab/universities_tab_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../app/utils/university_sort_util.dart'; // ← 6 üst dizin
import '../../../../../../data/models/university_model.dart';
import '../../../../controllers/home/home_controller.dart';
import '../../../../controllers/university_sort_controller.dart';
import 'universities_tab_layout_spec.dart';
import 'widgets/universities_alphabet_list.dart';
import 'widgets/universities_empty_view.dart';
import 'widgets/universities_hero_header.dart';
import 'widgets/universities_sort_sheet.dart';
import 'widgets/university_card_shimmer_widget.dart';
import 'widgets/university_list_card_widget.dart';

class UniversitiesTabWidget extends StatelessWidget {
  const UniversitiesTabWidget({super.key});

  static const _itemExtentPhone = 155.0;
  static const _itemExtentTablet = 130.0;

  bool _isAlphabetActive(UniversitySortController c) {
    final active = c.activeSorts;
    if (active.isEmpty) return true;
    return active.length == 1 && active.first.criteria == SortCriteria.name;
  }

  @override
  Widget build(BuildContext context) {
    final spec = UniversitiesTabLayoutSpec.of(context);
    final homeController = Get.find<HomeController>();
    final sortController = Get.find<UniversitySortController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: AppTheme.card(context),
        displacement: 40.h,
        onRefresh: homeController.loadUniversitiesAndPlaylists,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Hero + Search ────────────────────────────────
            // Sonrası:
            SliverToBoxAdapter(
              child: UniversitiesHeroHeader(
                spec: spec,
                sortController: sortController,
                onSortTap: () => showUniversitiesSortSheet(context, spec),
                activeSortCount: sortController.activeSorts.length,
              ),
            ),

            // ── Aktif chip'ler ────────────────────────────────
            Obx(() {
              if (sortController.activeSorts.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spec.contentHPadding.w,
                    0,
                    spec.contentHPadding.w,
                    8.h,
                  ),
                  child: Wrap(
                    spacing: spec.chipSpacing.w,
                    runSpacing: spec.chipRunSpacing.h,
                    children: sortController.activeSorts.map((sort) {
                      return _ActiveChip(
                        spec: spec,
                        label: sort.label,
                        icon: sort.icon,
                        onDelete: () =>
                            sortController.removeSort(sort.criteria),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),

            // ── İçerik ────────────────────────────────────────
            Obx(() {
              final isLoading = homeController.isUniversitiesLoading.value;
              final list = sortController.applySortAndFilter(
                homeController.universities,
              );

              return SliverMainAxisGroup(
                slivers: [
                  // Stats satırı
                  if (!isLoading && list.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          spec.contentHPadding.w,
                          4.h,
                          spec.contentHPadding.w,
                          10.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${list.length} üniversite',
                                style: TextStyle(
                                  fontSize: spec.statsFontSize.sp,
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () =>
                                  showUniversitiesSortSheet(context, spec),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.sort_rounded,
                                    size: spec.statsIconSize.sp,
                                    color: AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Sırala',
                                    style: TextStyle(
                                      fontSize: spec.statsFontSize.sp,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Shimmer
                  if (isLoading)
                    SliverToBoxAdapter(
                      child: UniversityCardShimmerList(spec: spec),
                    ),

                  // Boş durum
                  if (!isLoading && list.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: UniversitiesEmptyView(
                        spec: spec,
                        query: sortController.searchQuery.value,
                        onRetry: sortController.searchQuery.value.isNotEmpty
                            ? sortController.clearSearch
                            : homeController.loadUniversitiesAndPlaylists,
                      ),
                    ),

                  // Liste
                  if (!isLoading && list.isNotEmpty)
                    _buildList(context, spec, sortController, list),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    UniversitiesTabLayoutSpec spec,
    UniversitySortController sortController,
    List<UniversityModel> universities,
  ) {
    final alphabetActive = _isAlphabetActive(sortController);

    if (!alphabetActive) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(
          spec.contentHPadding.w,
          0,
          spec.contentHPadding.w,
          spec.listBottomPadding.h,
        ),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => UniversityListCardWidget(
              spec: spec,
              university: universities[i],
            ),
            childCount: universities.length,
          ),
        ),
      );
    }

    final extent = spec.isTablet ? _itemExtentTablet : _itemExtentPhone;
    return SliverFillRemaining(
      hasScrollBody: true, // ← false → true
      child: UniversitiesAlphabetList(
        spec: spec,
        universities: universities,
        itemExtent: extent.h,
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final String label;
  final IconData icon;
  final VoidCallback onDelete;

  const _ActiveChip({
    required this.spec,
    required this.label,
    required this.icon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(spec.chipRadius.r),
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(spec.chipRadius.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: spec.chipIconSize.sp,
                color: AppTheme.primaryColor,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: spec.chipFontSize.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.close_rounded,
                size: spec.chipIconSize.sp,
                color: AppTheme.primaryColor.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
