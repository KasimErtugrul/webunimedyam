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
        child: Obx(() {
          final isLoading = homeController.isUniversitiesLoading.value;
          final originalUniversities = homeController.universities;

          // Sıralama, filtreleme ve arama burada uygulanıyor
          final universities = sortController.applySortAndFilter(
            originalUniversities,
          );
          final isEmpty = !isLoading && universities.isEmpty;

          return RefreshIndicator(
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
                              color: AppTheme.primaryColor.withValues(
                                alpha: 0.3,
                              ),
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
                        controller: sortController.searchController, // ← YENİ
                        onChanged: sortController.updateSearchQuery, // ← YENİ
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
                              // ← YENİ: Arama yapılıyorsa temizle butonu
                              Obx(
                                () =>
                                    sortController.searchQuery.value.isNotEmpty
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

                              /*   // Filtre/Sırala butonu
                              IconButton(
                                icon: Icon(
                                  Icons.tune_rounded,
                                  color:
                                      sortController.hasRadioFilter.value ||
                                          sortController.sortCriteria.value !=
                                              SortCriteria.name
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSec(context),
                                  size: 22.sp,
                                ),
                                onPressed: () => _showSortBottomSheet(context),
                              ), */
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

                // ── İstatistik Satırı ────────────────────────────────────
                if (!isLoading && universities.isNotEmpty)
                  SliverToBoxAdapter(
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
                  ),

                // ── Shimmer Yükleniyor ───────────────────────────────────
                if (isLoading)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 14.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const UniversityCardShimmerWidget(),
                        childCount: 6,
                      ),
                    ),
                  ),

                // ── Boş Durum ────────────────────────────────────────────
                if (isEmpty)
                  SliverFillRemaining(
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
                                Icons.search_off_rounded, // ← Arama yok ikonu
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
                                  : sortController.hasRadioFilter.value
                                  ? 'Radyo kanalı olan üniversite bulunamadı.'
                                  : 'Şu anda listelenecek üniversite\nmevcut değil.',
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
                                    : sortController.hasRadioFilter.value
                                    ? () => sortController.toggleRadioFilter()
                                    : homeController
                                          .loadUniversitiesAndPlaylists,
                                icon: Icon(
                                  sortController.searchQuery.value.isNotEmpty
                                      ? Icons.clear_rounded
                                      : sortController.hasRadioFilter.value
                                      ? Icons.filter_alt_off_rounded
                                      : Icons.refresh_rounded,
                                  size: 20.sp,
                                ),
                                label: Text(
                                  sortController.searchQuery.value.isNotEmpty
                                      ? 'Aramayı Temizle'
                                      : sortController.hasRadioFilter.value
                                      ? 'Filtreyi Kaldır'
                                      : 'Tekrar Dene',
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24.w,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Üniversite Listesi ───────────────────────────────────
                if (!isLoading && universities.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 32.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => UniversityListCardWidget(
                          university: universities[i],
                        ),
                        childCount: universities.length,
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

  // ── Sıralama ve Filtreleme BottomSheet ─────────────────────────────────
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
                      'Sırala ve Filtrele',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        sortController.reset();
                      },
                      icon: Icon(Icons.refresh_rounded, size: 16.sp),
                      label: Text('Sıfırla', style: TextStyle(fontSize: 13.sp)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 20.h, thickness: 1),

              // Content
              Expanded(
                child: Obx(
                  () => ListView(
                    padding: EdgeInsets.only(bottom: 24.h),
                    children: [
                      _SectionTitle(title: 'Sıralama Kriteri'),
                      _CriteriaTile(
                        title: 'İsim',
                        icon: Icons.text_fields_rounded,
                        selectedCriteria: SortCriteria.name,
                        groupValue: sortController.sortCriteria.value,
                        onTap: () =>
                            sortController.setCriteria(SortCriteria.name),
                      ),
                      _CriteriaTile(
                        title: 'Şehir',
                        icon: Icons.location_on_rounded,
                        selectedCriteria: SortCriteria.city,
                        groupValue: sortController.sortCriteria.value,
                        onTap: () =>
                            sortController.setCriteria(SortCriteria.city),
                      ),
                      _CriteriaTile(
                        title: 'Kuruluş Yılı',
                        icon: Icons.calendar_today_rounded,
                        selectedCriteria: SortCriteria.foundedYear,
                        groupValue: sortController.sortCriteria.value,
                        onTap: () => sortController.setCriteria(
                          SortCriteria.foundedYear,
                        ),
                      ),
                      _CriteriaTile(
                        title: 'Takipçi Sayısı',
                        icon: Icons.people_rounded,
                        selectedCriteria: SortCriteria.subscriberCount,
                        groupValue: sortController.sortCriteria.value,
                        onTap: () => sortController.setCriteria(
                          SortCriteria.subscriberCount,
                        ),
                      ),
                      _CriteriaTile(
                        title: 'Görüntülenme Sayısı',
                        icon: Icons.visibility_rounded,
                        selectedCriteria: SortCriteria.viewCount,
                        groupValue: sortController.sortCriteria.value,
                        onTap: () =>
                            sortController.setCriteria(SortCriteria.viewCount),
                      ),
                      _CriteriaTile(
                        title: 'İçerik (Video) Sayısı',
                        icon: Icons.play_circle_fill_rounded,
                        selectedCriteria: SortCriteria.videoCount,
                        groupValue: sortController.sortCriteria.value,
                        onTap: () =>
                            sortController.setCriteria(SortCriteria.videoCount),
                      ),

                      SizedBox(height: 10.h),
                      _SectionTitle(title: 'Sıralama Yönü'),
                      _DirectionChipRow(
                        direction: sortController.sortDirection.value,
                        onAscending: () => sortController.setDirection(
                          SortDirection.ascending,
                        ),
                        onDescending: () => sortController.setDirection(
                          SortDirection.descending,
                        ),
                      ),

                      SizedBox(height: 10.h),
                      _SectionTitle(title: 'Filtreler'),
                      SwitchListTile(
                        secondary: Icon(
                          Icons.radio_rounded,
                          color: sortController.hasRadioFilter.value
                              ? AppTheme.primaryColor
                              : AppTheme.textSec(context),
                        ),
                        title: Text(
                          'Radyo Kanalı Olanlar',
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                        activeColor: AppTheme.primaryColor,
                        value: sortController.hasRadioFilter.value,
                        onChanged: (val) => sortController.toggleRadioFilter(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── BottomSheet Yardımcı Widget'ları ────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSec(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _CriteriaTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final SortCriteria selectedCriteria;
  final SortCriteria groupValue;
  final VoidCallback onTap;

  const _CriteriaTile({
    required this.title,
    required this.icon,
    required this.selectedCriteria,
    required this.groupValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedCriteria == groupValue;
    return ListTile(
      dense: true,
      leading: Icon(
        icon,
        size: 20.sp,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSec(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPri(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14.sp,
        ),
      ),
      trailing: Radio<SortCriteria>(
        value: selectedCriteria,
        groupValue: groupValue,
        activeColor: AppTheme.primaryColor,
        onChanged: (_) => onTap(),
      ),
      onTap: onTap,
    );
  }
}

class _DirectionChipRow extends StatelessWidget {
  final SortDirection direction;
  final VoidCallback onAscending;
  final VoidCallback onDescending;

  const _DirectionChipRow({
    required this.direction,
    required this.onAscending,
    required this.onDescending,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          ChoiceChip(
            label: Text('A-Z / Artan'),
            selected: direction == SortDirection.ascending,
            onSelected: (_) => onAscending(),
            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: direction == SortDirection.ascending
                  ? AppTheme.primaryColor
                  : AppTheme.textSec(context),
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(width: 10.w),
          ChoiceChip(
            label: Text('Z-A / Azalan'),
            selected: direction == SortDirection.descending,
            onSelected: (_) => onDescending(),
            selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: direction == SortDirection.descending
                  ? AppTheme.primaryColor
                  : AppTheme.textSec(context),
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
