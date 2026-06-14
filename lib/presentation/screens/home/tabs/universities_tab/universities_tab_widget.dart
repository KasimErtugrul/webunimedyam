// lib/presentation/screens/home/widgets/tabs/universities_tab/universities_tab_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../app/utils/university_sort_util.dart';
import '../../../../controllers/home_controller.dart';
import '../../../../controllers/university_sort_controller.dart';
import 'widgets/university_card_shimmer_widget.dart';
import 'widgets/university_list_card_widget.dart';

class UniversitiesTabWidget extends StatelessWidget {
  const UniversitiesTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final sortController = Get.find<UniversitySortController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primaryColor,
          backgroundColor: AppTheme.card(context),
          displacement: 40.h,
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
                toolbarHeight: 64.h,
                title: Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Üniversiteler',
                      style: TextStyle(
                        fontSize: 22.sp,
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
                  padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(12.r),
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
                        fontSize: 14.sp,
                        color: AppTheme.textPri(context),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.textSec(context),
                          size: 22.sp,
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
                                        size: 20.sp,
                                      ),
                                      onPressed: sortController.clearSearch,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                        hintText: 'Üniversite veya şehir ara...',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.textSec(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Aktif Sıralama Chip'leri ───────────────────────────────
              Obx(() {
                if (sortController.activeSorts.isEmpty)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: sortController.activeSorts
                          .map(
                            (sort) => Chip(
                              avatar: Icon(
                                sort.icon,
                                size: 14.sp,
                                color: AppTheme.primaryColor,
                              ),
                              label: Text(
                                sort.label,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              deleteIcon: Icon(
                                Icons.close_rounded,
                                size: 16.sp,
                                color: AppTheme.primaryColor,
                              ),
                              onDeleted: () =>
                                  sortController.removeSort(sort.criteria),
                              backgroundColor: AppTheme.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 0,
                              ),
                              labelPadding: EdgeInsets.only(left: 2.w),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }),

              // ── İstatistik Satırı ────────────────────────────────────
              Obx(() {
                final universities = sortController.applySortAndFilter(
                  homeController.universities,
                );
                if (homeController.isUniversitiesLoading.value ||
                    universities.isEmpty)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                    child: Row(
                      children: [
                        Text(
                          '${universities.length} üniversite',
                          style: TextStyle(
                            fontSize: 13.sp,
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
                                size: 18.sp,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Sırala',
                                style: TextStyle(
                                  fontSize: 13.sp,
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
                );
              }),

              // ── Shimmer Yükleniyor ───────────────────────────────────
              Obx(() {
                if (!homeController.isUniversitiesLoading.value)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const UniversityCardShimmerWidget(),
                      childCount: 6,
                    ),
                  ),
                );
              }),

              // ── Boş Durum ────────────────────────────────────────────
              Obx(() {
                final universities = sortController.applySortAndFilter(
                  homeController.universities,
                );
                final isEmpty =
                    !homeController.isUniversitiesLoading.value &&
                    universities.isEmpty;
                if (!isEmpty)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: AppTheme.card(context),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.search_off_rounded,
                              size: 40.sp,
                              color: AppTheme.textSec(context),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            'Üniversite bulunamadı',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPri(context),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            sortController.searchQuery.value.isNotEmpty
                                ? '"${sortController.searchQuery.value}" için sonuç bulunamadı.'
                                : 'Şu anda listelenecek üniversite mevcut değil.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.textSec(context),
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 24.h),
                          SizedBox(
                            height: 44.h,
                            child: ElevatedButton.icon(
                              onPressed:
                                  sortController.searchQuery.value.isNotEmpty
                                  ? sortController.clearSearch
                                  : homeController.loadUniversitiesAndPlaylists,
                              icon: Icon(Icons.refresh_rounded, size: 20.sp),
                              label: Text(
                                'Tekrar Dene',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              // ── Üniversite Listesi ───────────────────────────────────
              Obx(() {
                final universities = sortController.applySortAndFilter(
                  homeController.universities,
                );
                if (homeController.isUniversitiesLoading.value ||
                    universities.isEmpty)
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 32.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) =>
                          UniversityListCardWidget(university: universities[i]),
                      childCount: universities.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sıralama BottomSheet ──────────────────────────────────────────────
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppTheme.textSec(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 0),
                child: Row(
                  children: [
                    Text(
                      'Sıralama Kriterleri',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: sortController.reset,
                      icon: Icon(Icons.refresh_rounded, size: 16.sp),
                      label: Text('Sıfırla', style: TextStyle(fontSize: 13.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Birden fazla kriter seçebilirsiniz. Seçim sırası önceliği belirler.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textSec(context),
                  ),
                ),
              ),
              Divider(height: 20.h, thickness: 1),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(bottom: 24.h),
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
            size: 20.sp,
            color: isActive ? AppTheme.primaryColor : AppTheme.textSec(context),
          ),
          title: Text(
            _title,
            style: TextStyle(
              color: isActive
                  ? AppTheme.primaryColor
                  : AppTheme.textPri(context),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14.sp,
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
                    size: 20.sp,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => sortController.toggleDirection(criteria),
                ),
                SizedBox(width: 4.w),
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
