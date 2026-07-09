/* // lib/presentation/screens/university_wheel/university_wheel_screen.dart
//
// "Üniversite Radarı" ekranı.
// Solda kocaman bir WheelSlider ile üniversite logoları arasında gezinilir,
// sağda ise o anda ortada/aktif olan üniversitenin videoları ("haberleri")
// listelenir. Eski ana sayfa akışına dokunmadan; HomeTab'daki AppBar'a
// eklenen bir butonla buraya geliniyor.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../../../app/themes/app_theme.dart';
import '../../../data/models/university_model.dart';
import '../../controllers/university_wheel_controller.dart';
import 'widgets/university_wheel_news_tile_widget.dart';

class UniversityWheelScreen extends StatelessWidget {
  const UniversityWheelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UniversityWheelController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: const Text('Üniversite Radarı'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingUniversities.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.universitiesError.value.isNotEmpty) {
            return _ErrorState(
              message: controller.universitiesError.value,
              onRetry: controller.retry,
            );
          }

          if (controller.universities.isEmpty) {
            return Center(
              child: Text(
                'Henüz üniversite bulunamadı.',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 14.sp,
                ),
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── SOL: Kocaman wheel slider ─────────────────────────────
              SizedBox(
                width: 0.4.sw,
                child: _UniversityLogoWheel(controller: controller),
              ),

              // ── Ayraç ──────────────────────────────────────────────────
              VerticalDivider(
                width: 1,
                thickness: 1,
                color: AppTheme.surface(context),
              ),

              // ── SAĞ: Aktif üniversitenin haberleri ────────────────────
              Expanded(
                child: _UniversityNewsPanel(controller: controller),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SOL PANEL — Dev Wheel Slider
// ═══════════════════════════════════════════════════════════════════════════

class _UniversityLogoWheel extends StatelessWidget {
  final UniversityWheelController controller;

  const _UniversityLogoWheel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final itemSize = 118.h;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Seçili öğeyi vurgulayan sabit orta şerit
              IgnorePointer(
                child: Container(
                  height: itemSize,
                  margin: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              Obx(() {
                final unis = controller.universities;
                final activeIndex = controller.selectedIndex.value;

                return WheelSlider.customWidget(
                  horizontal: false,
                  verticalListHeight: constraints.maxHeight,
                  totalCount: unis.length,
                  initValue: activeIndex,
                  isInfinite: false,
                  itemSize: itemSize,
                  squeeze: 1.05,
                  perspective: 0.0025,
                  scrollPhysics: const BouncingScrollPhysics(),
                  showPointer: false,
                  allowPointerTappable: false,
                  onValueChanged: (val) => controller.onWheelChanged(val),
                  children: List.generate(
                    unis.length,
                    (index) => _LogoItem(
                      university: unis[index],
                      isActive: index == activeIndex,
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _LogoItem extends StatelessWidget {
  final UniversityModel university;
  final bool isActive;

  const _LogoItem({required this.university, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final size = isActive ? 88.w : 60.w;
    final logoUrl = university.logoUrl;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isActive ? 1 : 0.45,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.isDark(context)
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F0F0),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor
                  : Colors.transparent,
              width: 2,
            ),
          ),
          padding: EdgeInsets.all(10.w),
          child: ClipOval(
            child: (logoUrl == null || logoUrl.isEmpty)
                ? Icon(
                    Icons.school_rounded,
                    color: AppTheme.textSec(context),
                  )
                : CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.contain,
                    errorWidget: (_, _, _) => Icon(
                      Icons.school_rounded,
                      color: AppTheme.textSec(context),
                    ),
                    placeholder: (_, _) => const SizedBox.shrink(),
                  ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SAĞ PANEL — Aktif üniversitenin haberleri
// ═══════════════════════════════════════════════════════════════════════════

class _UniversityNewsPanel extends StatelessWidget {
  final UniversityWheelController controller;

  const _UniversityNewsPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.selectedUniversity;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (uni != null) _NewsPanelHeader(university: uni),
          Expanded(child: _buildBody(context)),
        ],
      );
    });
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoadingVideos.value) {
      return _NewsShimmer();
    }

    if (controller.videosError.value.isNotEmpty) {
      return _ErrorState(
        message: controller.videosError.value,
        onRetry: controller.retry,
      );
    }

    final videos = controller.videos;
    if (videos.isEmpty) {
      return Center(
        child: Text(
          'Bu üniversite için henüz haber yok.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 16.h),
      itemCount: videos.length,
      itemBuilder: (context, index) =>
          UniversityWheelNewsTile(video: videos[index]),
    );
  }
}

class _NewsPanelHeader extends StatelessWidget {
  final UniversityModel university;

  const _NewsPanelHeader({required this.university});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 34.w,
              height: 34.w,
              child: (university.logoUrl == null || university.logoUrl!.isEmpty)
                  ? Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.school_rounded,
                        size: 18.sp,
                        color: AppTheme.textSec(context),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: university.logoUrl!,
                      fit: BoxFit.contain,
                      errorWidget: (_, _, _) => Container(
                        color: AppTheme.surface(context),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  university.name ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
                if ((university.city ?? '').isNotEmpty)
                  Text(
                    university.city!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 11.sp,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Ortak yardımcı widget'lar
// ═══════════════════════════════════════════════════════════════════════════

class _NewsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 16.h),
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(bottom: 10.h),
          height: 80.h,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppTheme.textSec(context),
              size: 40.sp,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSec(context), fontSize: 13.sp),
            ),
            SizedBox(height: 12.h),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }
}
 */