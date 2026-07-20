// lib/presentation/screens/home/widgets/tabs/universities_tab/universities_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../app/utils/university_sort_util.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../controllers/home_controller.dart';
import '../../../../controllers/university_alphabet_controller.dart';
import '../../../../controllers/university_sort_controller.dart';
import 'widgets/university_card_shimmer_widget.dart';
import 'widgets/university_list_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double toolbarHeight = 64;
  static const double iconSize = 36;
  static const double iconBorderRadius = 10;
  static const double iconInnerSize = 20;
  static const double iconSpacing = 12;
  static const double titleFontSize = 22;
  static const double shadowBlurRadius = 8;
  static const double shadowOffsetY = 2;
  
  // Search
  static const double searchHeight = 48;
  static const double searchBorderRadius = 12;
  static const double searchFontSize = 14;
  static const double searchIconSize = 22;
  static const double searchClearIconSize = 20;
  static const double searchPaddingHorizontal = 16;
  static const double searchPaddingVertical = 14;
  static const double searchPaddingTop = 4;
  static const double searchPaddingBottom = 8;
  
  // Sort Chips
  static const double chipSpacing = 8;
  static const double chipRunSpacing = 6;
  static const double chipIconSize = 14;
  static const double chipFontSize = 12;
  static const double chipDeleteIconSize = 16;
  static const double chipBorderRadius = 8;
  static const double chipPaddingHorizontal = 4;
  static const double chipLabelPaddingLeft = 2;
  
  // Stats
  static const double statsPaddingTop = 4;
  static const double statsPaddingBottom = 4;
  static const double statsPaddingHorizontal = 16;
  static const double statsFontSize = 13;
  static const double sortIconSize = 18;
  static const double sortFontSize = 13;
  static const double sortSpacing = 4;
  
  // Empty
  static const double emptyIconSize = 80;
  static const double emptyInnerIconSize = 40;
  static const double emptySpacingLarge = 20;
  static const double emptySpacingMedium = 8;
  static const double emptySpacingSmall = 24;
  static const double emptyTitleFontSize = 18;
  static const double emptySubtitleFontSize = 14;
  static const double emptyButtonHeight = 44;
  static const double emptyButtonFontSize = 14;
  static const double emptyButtonBorderRadius = 12;
  static const double emptyPaddingHorizontal = 40;
  
  // Bottom Sheet
  static const double sheetBorderRadius = 24;
  static const double sheetHandleWidth = 40;
  static const double sheetHandleHeight = 4;
  static const double sheetHandlePaddingTop = 12;
  static const double sheetHandlePaddingBottom = 4;
  static const double sheetHandleBorderRadius = 2;
  static const double sheetTitlePaddingLeft = 20;
  static const double sheetTitlePaddingRight = 16;
  static const double sheetTitlePaddingTop = 12;
  static const double sheetTitleFontSize = 18;
  static const double sheetSubtitleFontSize = 12;
  static const double sheetDividerHeight = 20;
  static const double sheetListPaddingBottom = 24;
  static const double sheetResetIconSize = 16;
  static const double sheetResetFontSize = 13;
  
  // Sort Option Tile
  static const double sortTileIconSize = 20;
  static const double sortTileFontSize = 14;
  static const double sortTileToggleIconSize = 20;
  static const double sortTileCheckboxSpacing = 4;
  
  // Alphabet Sidebar
  static const double sidebarWidth = 22;
  static const double sidebarActiveFontSize = 12;
  static const double sidebarInactiveFontSize = 10;
  
  // Refresh Indicator
  static const double refreshDisplacement = 40;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double toolbarHeight = 72;
  static const double iconSize = 42;
  static const double iconBorderRadius = 12;
  static const double iconInnerSize = 24;
  static const double iconSpacing = 14;
  static const double titleFontSize = 26;
  static const double shadowBlurRadius = 10;
  static const double shadowOffsetY = 3;
  
  // Search - tablet için daha büyük
  static const double searchHeight = 52;
  static const double searchBorderRadius = 14;
  static const double searchFontSize = 16;
  static const double searchIconSize = 24;
  static const double searchClearIconSize = 22;
  static const double searchPaddingHorizontal = 20;
  static const double searchPaddingVertical = 16;
  static const double searchPaddingTop = 6;
  static const double searchPaddingBottom = 10;
  
  // Sort Chips - tablet için daha büyük
  static const double chipSpacing = 10;
  static const double chipRunSpacing = 8;
  static const double chipIconSize = 16;
  static const double chipFontSize = 14;
  static const double chipDeleteIconSize = 18;
  static const double chipBorderRadius = 10;
  static const double chipPaddingHorizontal = 6;
  static const double chipLabelPaddingLeft = 4;
  
  // Stats - tablet için daha büyük
  static const double statsPaddingTop = 6;
  static const double statsPaddingBottom = 6;
  static const double statsPaddingHorizontal = 20;
  static const double statsFontSize = 15;
  static const double sortIconSize = 20;
  static const double sortFontSize = 15;
  static const double sortSpacing = 6;
  
  // Empty - tablet için daha büyük
  static const double emptyIconSize = 100;
  static const double emptyInnerIconSize = 48;
  static const double emptySpacingLarge = 24;
  static const double emptySpacingMedium = 10;
  static const double emptySpacingSmall = 28;
  static const double emptyTitleFontSize = 22;
  static const double emptySubtitleFontSize = 16;
  static const double emptyButtonHeight = 50;
  static const double emptyButtonFontSize = 16;
  static const double emptyButtonBorderRadius = 14;
  static const double emptyPaddingHorizontal = 48;
  
  // Bottom Sheet - tablet için daha büyük
  static const double sheetBorderRadius = 28;
  static const double sheetHandleWidth = 48;
  static const double sheetHandleHeight = 5;
  static const double sheetHandlePaddingTop = 14;
  static const double sheetHandlePaddingBottom = 6;
  static const double sheetHandleBorderRadius = 3;
  static const double sheetTitlePaddingLeft = 24;
  static const double sheetTitlePaddingRight = 20;
  static const double sheetTitlePaddingTop = 14;
  static const double sheetTitleFontSize = 22;
  static const double sheetSubtitleFontSize = 14;
  static const double sheetDividerHeight = 24;
  static const double sheetListPaddingBottom = 28;
  static const double sheetResetIconSize = 18;
  static const double sheetResetFontSize = 15;
  
  // Sort Option Tile - tablet için daha büyük
  static const double sortTileIconSize = 22;
  static const double sortTileFontSize = 16;
  static const double sortTileToggleIconSize = 22;
  static const double sortTileCheckboxSpacing = 6;
  
  // Alphabet Sidebar - tablet için daha büyük
  static const double sidebarWidth = 26;
  static const double sidebarActiveFontSize = 14;
  static const double sidebarInactiveFontSize = 12;
  
  // Refresh Indicator
  static const double refreshDisplacement = 48;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversitiesTabWidget extends StatelessWidget {
  const UniversitiesTabWidget({super.key});

  bool _isAlphabetSortActive(UniversitySortController sortController) {
    final activeSorts = sortController.activeSorts;
    if (activeSorts.isEmpty) return true;
    if (activeSorts.length == 1 &&
        activeSorts.first.criteria == SortCriteria.name) {
      return true;
    }
    return false;
  }

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
    final homeController = Get.find<HomeController>();
    final sortController = Get.find<UniversitySortController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.card(context),
          displacement: _PhoneSizes.refreshDisplacement.h,
          onRefresh: homeController.loadUniversitiesAndPlaylists,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── AppBar ───────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                toolbarHeight: _PhoneSizes.toolbarHeight.h,
                title: Row(
                  children: [
                    Container(
                      width: _PhoneSizes.iconSize.w,
                      height: _PhoneSizes.iconSize.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          _PhoneSizes.iconBorderRadius.r,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: _PhoneSizes.shadowBlurRadius.r,
                            offset: Offset(0, _PhoneSizes.shadowOffsetY.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: _PhoneSizes.iconInnerSize.sp,
                      ),
                    ),
                    SizedBox(width: _PhoneSizes.iconSpacing.w),
                    Text(
                      'Üniversiteler',
                      style: TextStyle(
                        fontSize: _PhoneSizes.titleFontSize.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Arama Çubuğu ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    _PhoneSizes.searchPaddingHorizontal.w,
                    _PhoneSizes.searchPaddingTop.h,
                    _PhoneSizes.searchPaddingHorizontal.w,
                    _PhoneSizes.searchPaddingBottom.h,
                  ),
                  child: Container(
                    height: _PhoneSizes.searchHeight.h,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(
                        _PhoneSizes.searchBorderRadius.r,
                      ),
                      border: Border.all(
                        color: AppTheme.isDark(context)
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: TextField(
                      controller: sortController.searchController,
                      onChanged: sortController.updateSearchQuery,
                      style: TextStyle(
                        fontSize: _PhoneSizes.searchFontSize.sp,
                        color: AppTheme.textPri(context),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.textSec(context),
                          size: _PhoneSizes.searchIconSize.sp,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => sortController.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: AppTheme.textSec(context),
                                        size: _PhoneSizes.searchClearIconSize.sp,
                                      ),
                                      onPressed: sortController.clearSearch,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        hintText: 'Üniversite veya şehir ara...',
                        hintStyle: TextStyle(
                          fontSize: _PhoneSizes.searchFontSize.sp,
                          color: AppTheme.textSec(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: _PhoneSizes.searchPaddingHorizontal.w,
                          vertical: _PhoneSizes.searchPaddingVertical.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Aktif Sıralama Chip'leri ─────────────────────────────
              Obx(() {
                if (sortController.activeSorts.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _PhoneSizes.searchPaddingHorizontal.w,
                      0,
                      _PhoneSizes.searchPaddingHorizontal.w,
                      _PhoneSizes.chipRunSpacing.h,
                    ),
                    child: Wrap(
                      spacing: _PhoneSizes.chipSpacing.w,
                      runSpacing: _PhoneSizes.chipRunSpacing.h,
                      children: sortController.activeSorts.map((sort) {
                        return Chip(
                          avatar: Icon(
                            sort.icon,
                            size: _PhoneSizes.chipIconSize.sp,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            sort.label,
                            style: TextStyle(
                              fontSize: _PhoneSizes.chipFontSize.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close_rounded,
                            size: _PhoneSizes.chipDeleteIconSize.sp,
                            color: AppTheme.primaryColor,
                          ),
                          onDeleted: () =>
                              sortController.removeSort(sort.criteria),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              _PhoneSizes.chipBorderRadius.r,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: _PhoneSizes.chipPaddingHorizontal.w,
                            vertical: 0,
                          ),
                          labelPadding: EdgeInsets.only(
                            left: _PhoneSizes.chipLabelPaddingLeft.w,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),

              // ── İstatistik + Shimmer + Boş Durum + Liste ─────────────
              Obx(() {
                final isLoading = homeController.isUniversitiesLoading.value;
                final universities = sortController.applySortAndFilter(
                  homeController.universities,
                );

                return SliverMainAxisGroup(
                  slivers: [
                    // ── İstatistik Satırı ───────────────────────────
                    if (!isLoading && universities.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            _PhoneSizes.statsPaddingHorizontal.w,
                            _PhoneSizes.statsPaddingTop.h,
                            _PhoneSizes.statsPaddingHorizontal.w,
                            _PhoneSizes.statsPaddingBottom.h,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${universities.length} üniversite',
                                style: TextStyle(
                                  fontSize: _PhoneSizes.statsFontSize.sp,
                                  color: AppTheme.textSec(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showSortBottomSheet(context),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_rounded,
                                      size: _PhoneSizes.sortIconSize.sp,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: _PhoneSizes.sortSpacing.w),
                                    Text(
                                      'Sırala',
                                      style: TextStyle(
                                        fontSize: _PhoneSizes.sortFontSize.sp,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ── Shimmer Yükleniyor ───────────────────────────
                    if (isLoading)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, _) => const UniversityCardShimmerWidget(),
                            childCount: 6,
                          ),
                        ),
                      ),

                    // ── Boş Durum ─────────────────────────────────────
                    if (!isLoading && universities.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _PhoneSizes.emptyPaddingHorizontal.w,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: _PhoneSizes.emptyIconSize.w,
                                  height: _PhoneSizes.emptyIconSize.w,
                                  decoration: BoxDecoration(
                                    color: AppTheme.card(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: _PhoneSizes.emptyInnerIconSize.sp,
                                    color: AppTheme.textSec(context),
                                  ),
                                ),
                                SizedBox(
                                  height: _PhoneSizes.emptySpacingLarge.h,
                                ),
                                Text(
                                  'Üniversite bulunamadı',
                                  style: TextStyle(
                                    fontSize: _PhoneSizes.emptyTitleFontSize.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPri(context),
                                  ),
                                ),
                                SizedBox(
                                  height: _PhoneSizes.emptySpacingMedium.h,
                                ),
                                Text(
                                  sortController.searchQuery.value.isNotEmpty
                                      ? '"${sortController.searchQuery.value}" için sonuç bulunamadı.'
                                      : 'Şu anda listelenecek üniversite mevcut değil.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: _PhoneSizes.emptySubtitleFontSize.sp,
                                    color: AppTheme.textSec(context),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(
                                  height: _PhoneSizes.emptySpacingSmall.h,
                                ),
                                SizedBox(
                                  height: _PhoneSizes.emptyButtonHeight.h,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        sortController
                                            .searchQuery
                                            .value
                                            .isNotEmpty
                                        ? sortController.clearSearch
                                        : homeController
                                              .loadUniversitiesAndPlaylists,
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      size: _PhoneSizes.emptyButtonFontSize.sp,
                                    ),
                                    label: Text(
                                      'Tekrar Dene',
                                      style: TextStyle(
                                        fontSize: _PhoneSizes.emptyButtonFontSize.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          _PhoneSizes.emptyButtonBorderRadius.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // ── Üniversite Listesi ──────────────────────────────
                    if (!isLoading && universities.isNotEmpty)
                      _buildUniversitiesSliver(
                        context,
                        sortController,
                        universities,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversitiesSliver(
    BuildContext context,
    UniversitySortController sortController,
    List<UniversityModel> universities,
  ) {
    if (!_isAlphabetSortActive(sortController)) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 32.h),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => UniversityListCardWidget(university: universities[i]),
            childCount: universities.length,
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: _UniversityAlphabetListView(
        universities: universities,
        height: MediaQuery.of(context).size.height -
            (_PhoneSizes.toolbarHeight +
                _PhoneSizes.searchHeight +
                _PhoneSizes.searchPaddingTop +
                _PhoneSizes.searchPaddingBottom +
                _PhoneSizes.chipRunSpacing +
                _PhoneSizes.statsPaddingTop +
                _PhoneSizes.statsPaddingBottom +
                120).h,
        itemExtent: 168.h,
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final sortController = Get.find<UniversitySortController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(maxHeight: 0.85.sh),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_PhoneSizes.sheetBorderRadius.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: _PhoneSizes.sheetHandlePaddingTop.h,
                  bottom: _PhoneSizes.sheetHandlePaddingBottom.h,
                ),
                child: Container(
                  width: _PhoneSizes.sheetHandleWidth.w,
                  height: _PhoneSizes.sheetHandleHeight.h,
                  decoration: BoxDecoration(
                    color: AppTheme.textSec(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(
                      _PhoneSizes.sheetHandleBorderRadius.r,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _PhoneSizes.sheetTitlePaddingLeft.w,
                  _PhoneSizes.sheetTitlePaddingTop.h,
                  _PhoneSizes.sheetTitlePaddingRight.w,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Sıralama Kriterleri',
                      style: TextStyle(
                        fontSize: _PhoneSizes.sheetTitleFontSize.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: sortController.reset,
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: _PhoneSizes.sheetResetIconSize.sp,
                      ),
                      label: Text(
                        'Sıfırla',
                        style: TextStyle(
                          fontSize: _PhoneSizes.sheetResetFontSize.sp,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.sheetTitlePaddingLeft.w,
                ),
                child: Text(
                  'İsim sıralaması seçildiğinde hızlı A-Z navigasyonu açılır.',
                  style: TextStyle(
                    fontSize: _PhoneSizes.sheetSubtitleFontSize.sp,
                    color: AppTheme.textSec(context),
                  ),
                ),
              ),
              Divider(
                height: _PhoneSizes.sheetDividerHeight.h,
                thickness: 1,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: _PhoneSizes.sheetListPaddingBottom.h,
                  ),
                  children: SortCriteria.values
                      .map((criteria) => _SortOptionTile(criteria: criteria))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final sortController = Get.find<UniversitySortController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.card(context),
          displacement: _TabletSizes.refreshDisplacement,
          onRefresh: homeController.loadUniversitiesAndPlaylists,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.bg(context),
                automaticallyImplyLeading: false,
                toolbarHeight: _TabletSizes.toolbarHeight,
                title: Row(
                  children: [
                    Container(
                      width: _TabletSizes.iconSize,
                      height: _TabletSizes.iconSize,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.iconBorderRadius,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: _TabletSizes.shadowBlurRadius,
                            offset: Offset(0, _TabletSizes.shadowOffsetY),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: _TabletSizes.iconInnerSize,
                      ),
                    ),
                    SizedBox(width: _TabletSizes.iconSpacing),
                    Text(
                      'Üniversiteler',
                      style: TextStyle(
                        fontSize: _TabletSizes.titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    _TabletSizes.searchPaddingHorizontal,
                    _TabletSizes.searchPaddingTop,
                    _TabletSizes.searchPaddingHorizontal,
                    _TabletSizes.searchPaddingBottom,
                  ),
                  child: Container(
                    height: _TabletSizes.searchHeight,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(
                        _TabletSizes.searchBorderRadius,
                      ),
                      border: Border.all(
                        color: AppTheme.isDark(context)
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: TextField(
                      controller: sortController.searchController,
                      onChanged: sortController.updateSearchQuery,
                      style: TextStyle(
                        fontSize: _TabletSizes.searchFontSize,
                        color: AppTheme.textPri(context),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.textSec(context),
                          size: _TabletSizes.searchIconSize,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => sortController.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: AppTheme.textSec(context),
                                        size: _TabletSizes.searchClearIconSize,
                                      ),
                                      onPressed: sortController.clearSearch,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        hintText: 'Üniversite veya şehir ara...',
                        hintStyle: TextStyle(
                          fontSize: _TabletSizes.searchFontSize,
                          color: AppTheme.textSec(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: _TabletSizes.searchPaddingHorizontal,
                          vertical: _TabletSizes.searchPaddingVertical,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Obx(() {
                if (sortController.activeSorts.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _TabletSizes.searchPaddingHorizontal,
                      0,
                      _TabletSizes.searchPaddingHorizontal,
                      _TabletSizes.chipRunSpacing,
                    ),
                    child: Wrap(
                      spacing: _TabletSizes.chipSpacing,
                      runSpacing: _TabletSizes.chipRunSpacing,
                      children: sortController.activeSorts.map((sort) {
                        return Chip(
                          avatar: Icon(
                            sort.icon,
                            size: _TabletSizes.chipIconSize,
                            color: AppTheme.primaryColor,
                          ),
                          label: Text(
                            sort.label,
                            style: TextStyle(
                              fontSize: _TabletSizes.chipFontSize,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          deleteIcon: Icon(
                            Icons.close_rounded,
                            size: _TabletSizes.chipDeleteIconSize,
                            color: AppTheme.primaryColor,
                          ),
                          onDeleted: () =>
                              sortController.removeSort(sort.criteria),
                          backgroundColor: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              _TabletSizes.chipBorderRadius,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: _TabletSizes.chipPaddingHorizontal,
                            vertical: 0,
                          ),
                          labelPadding: EdgeInsets.only(
                            left: _TabletSizes.chipLabelPaddingLeft,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),

              Obx(() {
                final isLoading = homeController.isUniversitiesLoading.value;
                final universities = sortController.applySortAndFilter(
                  homeController.universities,
                );

                return SliverMainAxisGroup(
                  slivers: [
                    if (!isLoading && universities.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            _TabletSizes.statsPaddingHorizontal,
                            _TabletSizes.statsPaddingTop,
                            _TabletSizes.statsPaddingHorizontal,
                            _TabletSizes.statsPaddingBottom,
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${universities.length} üniversite',
                                style: TextStyle(
                                  fontSize: _TabletSizes.statsFontSize,
                                  color: AppTheme.textSec(context),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showSortBottomSheetTablet(context),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.sort_rounded,
                                      size: _TabletSizes.sortIconSize,
                                      color: AppTheme.primaryColor,
                                    ),
                                    SizedBox(width: _TabletSizes.sortSpacing),
                                    Text(
                                      'Sırala',
                                      style: TextStyle(
                                        fontSize: _TabletSizes.sortFontSize,
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (isLoading)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, _) => const UniversityCardShimmerWidget(),
                            childCount: 6,
                          ),
                        ),
                      ),

                    if (!isLoading && universities.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: _TabletSizes.emptyPaddingHorizontal,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: _TabletSizes.emptyIconSize,
                                  height: _TabletSizes.emptyIconSize,
                                  decoration: BoxDecoration(
                                    color: AppTheme.card(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_off_rounded,
                                    size: _TabletSizes.emptyInnerIconSize,
                                    color: AppTheme.textSec(context),
                                  ),
                                ),
                                SizedBox(
                                  height: _TabletSizes.emptySpacingLarge,
                                ),
                                Text(
                                  'Üniversite bulunamadı',
                                  style: TextStyle(
                                    fontSize: _TabletSizes.emptyTitleFontSize,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPri(context),
                                  ),
                                ),
                                SizedBox(
                                  height: _TabletSizes.emptySpacingMedium,
                                ),
                                Text(
                                  sortController.searchQuery.value.isNotEmpty
                                      ? '"${sortController.searchQuery.value}" için sonuç bulunamadı.'
                                      : 'Şu anda listelenecek üniversite mevcut değil.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: _TabletSizes.emptySubtitleFontSize,
                                    color: AppTheme.textSec(context),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(
                                  height: _TabletSizes.emptySpacingSmall,
                                ),
                                SizedBox(
                                  height: _TabletSizes.emptyButtonHeight,
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        sortController
                                            .searchQuery
                                            .value
                                            .isNotEmpty
                                        ? sortController.clearSearch
                                        : homeController
                                              .loadUniversitiesAndPlaylists,
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      size: _TabletSizes.emptyButtonFontSize,
                                    ),
                                    label: Text(
                                      'Tekrar Dene',
                                      style: TextStyle(
                                        fontSize: _TabletSizes.emptyButtonFontSize,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          _TabletSizes.emptyButtonBorderRadius,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (!isLoading && universities.isNotEmpty)
                      _buildUniversitiesSliverTablet(
                        context,
                        sortController,
                        universities,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversitiesSliverTablet(
    BuildContext context,
    UniversitySortController sortController,
    List<UniversityModel> universities,
  ) {
    if (!_isAlphabetSortActive(sortController)) {
      return SliverPadding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 36),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => UniversityListCardWidget(university: universities[i]),
            childCount: universities.length,
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: _UniversityAlphabetListView(
        universities: universities,
        height: MediaQuery.of(context).size.height -
            (_TabletSizes.toolbarHeight +
                _TabletSizes.searchHeight +
                _TabletSizes.searchPaddingTop +
                _TabletSizes.searchPaddingBottom +
                _TabletSizes.chipRunSpacing +
                _TabletSizes.statsPaddingTop +
                _TabletSizes.statsPaddingBottom +
                140),
        itemExtent: 180,
      ),
    );
  }

  void _showSortBottomSheetTablet(BuildContext context) {
    final sortController = Get.find<UniversitySortController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          constraints: BoxConstraints(maxHeight: 0.82.sh),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(_TabletSizes.sheetBorderRadius),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: _TabletSizes.sheetHandlePaddingTop,
                  bottom: _TabletSizes.sheetHandlePaddingBottom,
                ),
                child: Container(
                  width: _TabletSizes.sheetHandleWidth,
                  height: _TabletSizes.sheetHandleHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.textSec(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(
                      _TabletSizes.sheetHandleBorderRadius,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _TabletSizes.sheetTitlePaddingLeft,
                  _TabletSizes.sheetTitlePaddingTop,
                  _TabletSizes.sheetTitlePaddingRight,
                  0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Sıralama Kriterleri',
                      style: TextStyle(
                        fontSize: _TabletSizes.sheetTitleFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: sortController.reset,
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: _TabletSizes.sheetResetIconSize,
                      ),
                      label: Text(
                        'Sıfırla',
                        style: TextStyle(
                          fontSize: _TabletSizes.sheetResetFontSize,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.sheetTitlePaddingLeft,
                ),
                child: Text(
                  'İsim sıralaması seçildiğinde hızlı A-Z navigasyonu açılır.',
                  style: TextStyle(
                    fontSize: _TabletSizes.sheetSubtitleFontSize,
                    color: AppTheme.textSec(context),
                  ),
                ),
              ),
              Divider(
                height: _TabletSizes.sheetDividerHeight,
                thickness: 1,
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(
                    bottom: _TabletSizes.sheetListPaddingBottom,
                  ),
                  children: SortCriteria.values
                      .map((criteria) => _SortOptionTile(criteria: criteria))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sıralama Seçim Satırı ────────────────────────────────────────────────────

class _SortOptionTile extends StatelessWidget {
  final SortCriteria criteria;
  const _SortOptionTile({required this.criteria});

  String get _title {
    switch (criteria) {
      case SortCriteria.name:
        return 'İsim';
      case SortCriteria.city:
        return 'Şehir';
      case SortCriteria.foundedYear:
        return 'Kuruluş Yılı';
      case SortCriteria.subscriberCount:
        return 'Takipçi Sayısı';
      case SortCriteria.viewCount:
        return 'Görüntülenme Sayısı';
      case SortCriteria.videoCount:
        return 'İçerik Sayısı';
    }
  }

  IconData get _icon {
    switch (criteria) {
      case SortCriteria.name:
        return Icons.text_fields_rounded;
      case SortCriteria.city:
        return Icons.location_on_rounded;
      case SortCriteria.foundedYear:
        return Icons.calendar_today_rounded;
      case SortCriteria.subscriberCount:
        return Icons.people_rounded;
      case SortCriteria.viewCount:
        return Icons.visibility_rounded;
      case SortCriteria.videoCount:
        return Icons.play_circle_fill_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
   // final sizes = isTablet ? _TabletSizes() : _PhoneSizes();
    
    final sortController = Get.find<UniversitySortController>();

    return Obx(() {
      final isActive = sortController.activeSorts.any(
        (s) => s.criteria == criteria,
      );
      final sortOption = sortController.activeSorts.firstWhereOrNull(
        (s) => s.criteria == criteria,
      );

      return Material(
        color: Colors.transparent,
        child: ListTile(
          dense: true,
          leading: Icon(
            _icon,
            size: isTablet ? _TabletSizes.sortTileIconSize : _PhoneSizes.sortTileIconSize.sp,
            color: isActive ? AppTheme.primaryColor : AppTheme.textSec(context),
          ),
          title: Text(
            _title,
            style: TextStyle(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textPri(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: isTablet ? _TabletSizes.sortTileFontSize : _PhoneSizes.sortTileFontSize.sp,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive) ...[
                IconButton(
                  icon: Icon(
                    sortOption!.direction == SortDirection.ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: isTablet ? _TabletSizes.sortTileToggleIconSize : _PhoneSizes.sortTileToggleIconSize.sp,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => sortController.toggleDirection(criteria),
                ),
                SizedBox(width: isTablet ? _TabletSizes.sortTileCheckboxSpacing : _PhoneSizes.sortTileCheckboxSpacing.w),
              ],
              Checkbox(
                value: isActive,
                onChanged: (val) => sortController.addOrRemoveSort(criteria),
                activeColor: AppTheme.primaryColor,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          onTap: () => sortController.addOrRemoveSort(criteria),
        ),
      );
    });
  }
}

// ── A-Z Hızlı Navigasyonlu Üniversite Listesi ───────────────────────────────

class _UniversityAlphabetListView extends StatefulWidget {
  final List<UniversityModel> universities;
  final double height;
  final double itemExtent;

  const _UniversityAlphabetListView({
    required this.universities,
    required this.height,
    required this.itemExtent,
  });

  @override
  State<_UniversityAlphabetListView> createState() =>
      _UniversityAlphabetListViewState();
}

class _UniversityAlphabetListViewState
    extends State<_UniversityAlphabetListView> {
  late final String _tag;
  late final UniversityAlphabetController _controller;

  @override
  void initState() {
    super.initState();
    _tag = 'uni_alpha_${identityHashCode(this)}';
    _controller = Get.put(UniversityAlphabetController(), tag: _tag);
    _controller.setData(widget.universities, widget.itemExtent);
  }

  @override
  void didUpdateWidget(covariant _UniversityAlphabetListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.universities, widget.universities)) {
      _controller.setData(widget.universities, widget.itemExtent);
    }
  }

  @override
  void dispose() {
    Get.delete<UniversityAlphabetController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   // final isTablet = Responsive.isTablet(context);
    
    return SizedBox(
      height: widget.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller.scrollController,
              padding: EdgeInsets.zero,
              itemExtent: widget.itemExtent,
              itemCount: widget.universities.length,
              itemBuilder: (context, index) => UniversityListCardWidget(
                university: widget.universities[index],
              ),
            ),
          ),
          Obx(() {
            final letters = _controller.availableLetters;
            if (letters.isEmpty) return const SizedBox.shrink();
            return _AlphabetSidebar(
              letters: letters,
              currentLetter: _controller.currentLetter.value,
              onTapLetter: _controller.jumpToLetter,
              onDragLetter: _controller.dragToLetter,
            );
          }),
        ],
      ),
    );
  }
}

class _AlphabetSidebar extends StatelessWidget {
  final List<String> letters;
  final String currentLetter;
  final ValueChanged<String> onTapLetter;
  final ValueChanged<String> onDragLetter;

  const _AlphabetSidebar({
    required this.letters,
    required this.currentLetter,
    required this.onTapLetter,
    required this.onDragLetter,
  });

  void _handlePosition(
    Offset localPosition,
    double height,
    ValueChanged<String> callback,
  ) {
    if (letters.isEmpty || height <= 0) return;
    final itemHeight = height / letters.length;
    final index = (localPosition.dy / itemHeight).floor().clamp(
      0,
      letters.length - 1,
    );
    callback(letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
   // final sizes = isTablet ? _TabletSizes() : _PhoneSizes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) =>
              _handlePosition(d.localPosition, height, onTapLetter),
          onVerticalDragUpdate: (d) =>
              _handlePosition(d.localPosition, height, onDragLetter),
          child: Container(
            width: isTablet ? _TabletSizes.sidebarWidth : _PhoneSizes.sidebarWidth.w,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters.map((letter) {
                final isActive = letter == currentLetter;
                return Expanded(
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: isActive
                            ? (isTablet ? _TabletSizes.sidebarActiveFontSize : _PhoneSizes.sidebarActiveFontSize.sp)
                            : (isTablet ? _TabletSizes.sidebarInactiveFontSize : _PhoneSizes.sidebarInactiveFontSize.sp),
                        fontWeight: isActive
                            ? FontWeight.w800
                            : FontWeight.w500,
                        color: isActive
                            ? AppTheme.primaryColor
                            : AppTheme.textSec(context).withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}