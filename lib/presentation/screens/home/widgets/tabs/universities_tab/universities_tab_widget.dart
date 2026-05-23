// ════════════════════════════════════════════════════════════════════════════════
// Üniversiteler Sekmesi
// ════════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          final isLoading = controller.isPlaylistsLoading.value;
          final playlists = controller.playlists;
          final isEmpty = !isLoading && playlists.isEmpty;

          return RefreshIndicator(
            color: AppTheme.primaryColor,
            backgroundColor: AppTheme.card(context),
            displacement: 40.h,
            onRefresh: controller.loadPlaylists,
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
                          suffixIcon: Icon(
                            Icons.tune_rounded,
                            color: AppTheme.textSec(context),
                            size: 20.sp,
                          ),
                          hintText: 'Üniversite ara...',
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
                if (!isLoading && playlists.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
                      child: Row(
                        children: [
                          Text(
                            '${playlists.length} üniversite',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppTheme.textSec(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.sort_rounded,
                            size: 18.sp,
                            color: AppTheme.textSec(context),
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
                                Icons.school_outlined,
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
                              'Şu anda listelenecek üniversite\nmevcut değil.',
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
                                onPressed: controller.loadPlaylists,
                                icon: Icon(
                                  Icons.refresh_rounded,
                                  size: 20.sp,
                                ),
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
                if (!isLoading && playlists.isNotEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 32.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: UniversityListCardWidget(
                              playlist: playlists[i],
                            ),
                          );
                        },
                        childCount: playlists.length,
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