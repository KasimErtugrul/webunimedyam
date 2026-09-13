// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/universities_hero_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/university_sort_controller.dart';
import '../universities_tab_layout_spec.dart';

class UniversitiesHeroHeader extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversitySortController sortController;
  final VoidCallback onSortTap;
  final int activeSortCount;

  const UniversitiesHeroHeader({
    super.key,
    required this.spec,
    required this.sortController,
    required this.onSortTap,
    required this.activeSortCount,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, Color(0xFF0F5C2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Ambient blobs (arka plan) ──
            Positioned(
              right: -50.w,
              top: -40.h,
              child: _Blob(size: 160.w, opacity: 0.10),
            ),
            Positioned(
              left: -40.w,
              bottom: -60.h,
              child: _Blob(size: 130.w, opacity: 0.08),
            ),

            // ── İçerik ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                spec.heroHPadding.w,
                topInset + spec.heroTopPadding.h,
                spec.heroHPadding.w,
                spec.heroBottomPadding.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Üst satır: icon + başlık + sıralama
                  Row(
                    children: [
                      Container(
                            width: spec.heroIconSize.w,
                            height: spec.heroIconSize.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                spec.heroIconRadius.r,
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.4,
                              ),
                            ),
                            child: Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: spec.heroIconInner.sp,
                            ),
                          )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scaleXY(
                            begin: 0.8,
                            end: 1,
                            curve: Curves.easeOutBack,
                          ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Üniversiteler',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: spec.heroTitleFontSize.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ).animate().fadeIn(delay: 100.ms, duration: 350.ms),
                            SizedBox(height: 2.h),
                            Text(
                              'Keşfet, sırala, takip et',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: spec.heroSubtitleFontSize.sp,
                              ),
                            ).animate().fadeIn(delay: 180.ms, duration: 350.ms),
                          ],
                        ),
                      ),
                      _HeroSortButton(
                        activeCount: activeSortCount,
                        onTap: onSortTap,
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Arama çubuğu — hero'nun İÇİNDE, alt kısımda
                  _SearchBar(
                        spec: spec,
                        controller: sortController.searchController,
                        searchQuery: sortController.searchQuery,
                        onChanged: sortController.updateSearchQuery,
                        onClear: sortController.clearSearch,
                      )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 350.ms)
                      .slideY(begin: 0.15, end: 0, curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Hero sort button ───────────────────────────────────────────────────────

class _HeroSortButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _HeroSortButton({required this.activeCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
              if (activeCount > 0)
                Positioned(
                  right: -4.w,
                  top: -4.w,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Search bar — hero gradient'inin üstünde, yarı saydam ───────────────────

class _SearchBar extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final TextEditingController controller;
  final RxString searchQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.spec,
    required this.controller,
    required this.searchQuery,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: spec.searchHeight.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(spec.searchRadius.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: spec.searchFontSize.sp,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: spec.searchIconSize.sp,
          ),
          suffixIcon: Obx(
            () => searchQuery.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: spec.searchIconSize.sp,
                    ),
                    onPressed: onClear,
                  ),
          ),
          hintText: 'Üniversite veya şehir ara...',
          hintStyle: TextStyle(
            fontSize: spec.searchFontSize.sp,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(spec.searchRadius.r),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: spec.searchHPadding.w,
            vertical: 12.h,
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
