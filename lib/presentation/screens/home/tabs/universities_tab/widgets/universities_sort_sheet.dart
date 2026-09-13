// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/universities_sort_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../app/utils/university_sort_util.dart';
import '../../../../../controllers/university_sort_controller.dart';
import '../universities_tab_layout_spec.dart';

Future<void> showUniversitiesSortSheet(
  BuildContext context,
  UniversitiesTabLayoutSpec spec,
) {
  final sortController = Get.find<UniversitySortController>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SortSheet(spec: spec, sortController: sortController),
  );
}

class _SortSheet extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversitySortController sortController;

  const _SortSheet({required this.spec, required this.sortController});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 0.82.sh),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(spec.sheetRadius.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          // Handle
          Container(
            width: spec.sheetHandleW.w,
            height: spec.sheetHandleH.h,
            decoration: BoxDecoration(
              color: AppTheme.textSec(context).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(spec.sheetHandleH.r),
            ),
          ),
          SizedBox(height: 14.h),

          // Başlık + Sıfırla
          Padding(
            padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding.w),
            child: Row(
              children: [
                Text(
                  'Sıralama Kriterleri',
                  style: TextStyle(
                    fontSize: spec.sheetTitleFontSize.sp,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPri(context),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
onPressed: sortController.resetSorts,
                  icon: Icon(Icons.refresh_rounded, size: 18.sp),
                  label: Text(
                    'Sıfırla',
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding.w),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14.sp,
                  color: AppTheme.textSec(context).withValues(alpha: 0.7),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    'İsim sıralaması seçildiğinde hızlı A-Z navigasyonu açılır.',
                    style: TextStyle(
                      fontSize: spec.sheetSubtitleFontSize.sp,
                      color: AppTheme.textSec(context).withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          // Opsiyonlar
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                spec.sheetHPadding.w,
                0,
                spec.sheetHPadding.w,
                20.h,
              ),
              itemCount: SortCriteria.values.length,
              itemBuilder: (_, i) {
                final c = SortCriteria.values[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: spec.sheetOptionSpacing.h),
                  child: _SortOptionTile(
                    spec: spec,
                    criteria: c,
                    sortController: sortController,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final SortCriteria criteria;
  final UniversitySortController sortController;

  const _SortOptionTile({
    required this.spec,
    required this.criteria,
    required this.sortController,
  });

  String get _title => switch (criteria) {
        SortCriteria.name => 'İsim',
        SortCriteria.city => 'Şehir',
        SortCriteria.foundedYear => 'Kuruluş Yılı',
        SortCriteria.subscriberCount => 'Takipçi Sayısı',
        SortCriteria.viewCount => 'Görüntülenme Sayısı',
        SortCriteria.videoCount => 'İçerik Sayısı',
      };

  IconData get _icon => switch (criteria) {
        SortCriteria.name => Icons.text_fields_rounded,
        SortCriteria.city => Icons.location_on_rounded,
        SortCriteria.foundedYear => Icons.calendar_today_rounded,
        SortCriteria.subscriberCount => Icons.people_rounded,
        SortCriteria.viewCount => Icons.visibility_rounded,
        SortCriteria.videoCount => Icons.play_circle_fill_rounded,
      };

  Color get _color => switch (criteria) {
        SortCriteria.name => const Color(0xFF8B5CF6),
        SortCriteria.city => const Color(0xFF3B82F6),
        SortCriteria.foundedYear => const Color(0xFFF59E0B),
        SortCriteria.subscriberCount => const Color(0xFFEC4899),
        SortCriteria.viewCount => const Color(0xFF06B6D4),
        SortCriteria.videoCount => const Color(0xFF10B981),
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = sortController.activeSorts.any(
        (s) => s.criteria == criteria,
      );
      final sortOption = sortController.activeSorts.firstWhereOrNull(
        (s) => s.criteria == criteria,
      );
      final isAscending =
          sortOption?.direction == SortDirection.ascending;

      return Material(
        color: isActive
            ? _color.withValues(alpha: 0.10)
            : AppTheme.surface(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: () => sortController.addOrRemoveSort(criteria),
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            child: Row(
              children: [
                // İkon kutusu
                Container(
                  width: spec.sheetOptionIconBox.w,
                  height: spec.sheetOptionIconBox.w,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(spec.sheetOptionIconBoxRadius.r),
                  ),
                  child: Icon(
                    _icon,
                    size: spec.sheetOptionIconSize.sp,
                    color: _color,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _title,
                    style: TextStyle(
                      fontSize: spec.sheetOptionFontSize.sp,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive
                          ? _color
                          : AppTheme.textPri(context),
                    ),
                  ),
                ),
                // Yön (aktifse)
                if (isActive)
                  IconButton(
                    icon: Icon(
                      isAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: _color,
                      size: 20.sp,
                    ),
                    tooltip: isAscending
                        ? 'Artan → Azalan'
                        : 'Azalan → Artan',
                    onPressed: () =>
                        sortController.toggleDirection(criteria),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                // Check
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? _color : Colors.transparent,
                    border: Border.all(
                      color: isActive
                          ? _color
                          : AppTheme.textSec(context)
                              .withValues(alpha: 0.35),
                      width: 1.8,
                    ),
                  ),
                  child: isActive
                      ? Icon(
                          Icons.check_rounded,
                          size: 14.sp,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}