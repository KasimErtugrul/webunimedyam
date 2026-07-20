// lib/presentation/screens/followed_universities_list/followed_universities_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/university_model.dart';
import '../../controllers/followed_universities_list_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 18;

  // Loading
  static const double loadingStrokeWidth = 3;

  // Empty
  static const double emptyPaddingHorizontal = 32;
  static const double emptyIconSize = 56;
  static const double emptySpacingLarge = 16;
  static const double emptySpacingSmall = 6;
  static const double emptyTitleFontSize = 16;
  static const double emptySubtitleFontSize = 13;

  // List
  static const double listPaddingHorizontal = 14;
  static const double listPaddingVertical = 12;
  static const double listCardBottomMargin = 10;
  static const double listCardPaddingHorizontal = 12;
  static const double listCardPaddingVertical = 10;
  static const double listCardBorderRadius = 12;
  static const double listLogoSize = 52;
  static const double listLogoBorderRadius = 8;
  static const double listLogoSpacing = 12;
  static const double listTitleFontSize = 14;
  static const double listCityIconSize = 13;
  static const double listCityFontSize = 12;
  static const double listCitySpacing = 3;
  static const double listCityTopSpacing = 4;
  static const double listChevronSize = 20;
  static const double listPlaceholderIconSize = 28;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double appBarTitleSize = 22;

  // Loading - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;

  // Empty - tablet için daha büyük
  static const double emptyPaddingHorizontal = 40;
  static const double emptyIconSize = 64;
  static const double emptySpacingLarge = 20;
  static const double emptySpacingSmall = 8;
  static const double emptyTitleFontSize = 20;
  static const double emptySubtitleFontSize = 15;

  // List - tablet için daha büyük
  static const double listPaddingHorizontal = 20;
  static const double listPaddingVertical = 16;
  static const double listCardBottomMargin = 12;
  static const double listCardPaddingHorizontal = 16;
  static const double listCardPaddingVertical = 14;
  static const double listCardBorderRadius = 14;
  static const double listLogoSize = 60;
  static const double listLogoBorderRadius = 10;
  static const double listLogoSpacing = 14;
  static const double listTitleFontSize = 16;
  static const double listCityIconSize = 15;
  static const double listCityFontSize = 14;
  static const double listCitySpacing = 4;
  static const double listCityTopSpacing = 5;
  static const double listChevronSize = 24;
  static const double listPlaceholderIconSize = 32;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class FollowedUniversitiesListScreen extends StatelessWidget {
  const FollowedUniversitiesListScreen({super.key});

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
    final controller = Get.find<FollowedUniversitiesListController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Takip Edilen Üniversiteler'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
            ),
          );
        }

        if (controller.universities.isEmpty) {
          return _EmptyViewPhone(
            isOwnProfile: controller.isOwnProfile,
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.load,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: _PhoneSizes.listPaddingHorizontal.w,
              vertical: _PhoneSizes.listPaddingVertical.h,
            ),
            itemCount: controller.universities.length,
            itemBuilder: (context, index) =>
                _UniversityCardPhone(
                  university: controller.universities[index],
                ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<FollowedUniversitiesListController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Takip Edilen Üniversiteler'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: _TabletSizes.loadingStrokeWidth,
            ),
          );
        }

        if (controller.universities.isEmpty) {
          return _EmptyViewTablet(
            isOwnProfile: controller.isOwnProfile,
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.load,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: _TabletSizes.listPaddingHorizontal,
              vertical: _TabletSizes.listPaddingVertical,
            ),
            itemCount: controller.universities.length,
            itemBuilder: (context, index) =>
                _UniversityCardTablet(
                  university: controller.universities[index],
                ),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _EmptyViewPhone extends StatelessWidget {
  final bool isOwnProfile;

  const _EmptyViewPhone({required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _PhoneSizes.emptyPaddingHorizontal.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: AppTheme.textSec(context),
              size: _PhoneSizes.emptyIconSize.sp,
            ),
            SizedBox(height: _PhoneSizes.emptySpacingLarge.h),
            Text(
              isOwnProfile
                  ? 'Henüz üniversite takip etmedin'
                  : 'Takip edilen üniversite bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.emptyTitleFontSize.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _PhoneSizes.emptySpacingSmall.h),
            Text(
              isOwnProfile
                  ? 'Takip ettiğin üniversiteler burada görünür'
                  : 'Bu kullanıcının takip listesi gizli olabilir',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.emptySubtitleFontSize.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversityCardPhone extends StatelessWidget {
  final UniversityModel university;

  const _UniversityCardPhone({required this.university});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: university),
      child: Container(
        margin: EdgeInsets.only(bottom: _PhoneSizes.listCardBottomMargin.h),
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.listCardPaddingHorizontal.w,
          vertical: _PhoneSizes.listCardPaddingVertical.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.listCardBorderRadius.r),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_PhoneSizes.listLogoBorderRadius.r),
              child: university.logoUrl != null
                  ? Image.network(
                      university.logoUrl!,
                      width: _PhoneSizes.listLogoSize.w,
                      height: _PhoneSizes.listLogoSize.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _logoPlaceholderPhone(context),
                    )
                  : _logoPlaceholderPhone(context),
            ),
            SizedBox(width: _PhoneSizes.listLogoSpacing.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name ?? '',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _PhoneSizes.listTitleFontSize.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (university.city != null) ...[
                    SizedBox(height: _PhoneSizes.listCityTopSpacing.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: _PhoneSizes.listCityIconSize.sp,
                          color: AppTheme.textSec(context),
                        ),
                        SizedBox(width: _PhoneSizes.listCitySpacing.w),
                        Text(
                          university.city!,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _PhoneSizes.listCityFontSize.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: _PhoneSizes.listChevronSize.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholderPhone(BuildContext context) {
    return Container(
      width: _PhoneSizes.listLogoSize.w,
      height: _PhoneSizes.listLogoSize.w,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.listLogoBorderRadius.r),
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.listPlaceholderIconSize.sp,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _EmptyViewTablet extends StatelessWidget {
  final bool isOwnProfile;

  const _EmptyViewTablet({required this.isOwnProfile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _TabletSizes.emptyPaddingHorizontal),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_outlined,
              color: AppTheme.textSec(context),
              size: _TabletSizes.emptyIconSize,
            ),
            SizedBox(height: _TabletSizes.emptySpacingLarge),
            Text(
              isOwnProfile
                  ? 'Henüz üniversite takip etmedin'
                  : 'Takip edilen üniversite bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _TabletSizes.emptySpacingSmall),
            Text(
              isOwnProfile
                  ? 'Takip ettiğin üniversiteler burada görünür'
                  : 'Bu kullanıcının takip listesi gizli olabilir',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.emptySubtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversityCardTablet extends StatelessWidget {
  final UniversityModel university;

  const _UniversityCardTablet({required this.university});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.universityDetail, arguments: university),
      child: Container(
        margin: EdgeInsets.only(bottom: _TabletSizes.listCardBottomMargin),
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.listCardPaddingHorizontal,
          vertical: _TabletSizes.listCardPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.listCardBorderRadius),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(_TabletSizes.listLogoBorderRadius),
              child: university.logoUrl != null
                  ? Image.network(
                      university.logoUrl!,
                      width: _TabletSizes.listLogoSize,
                      height: _TabletSizes.listLogoSize,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _logoPlaceholderTablet(context),
                    )
                  : _logoPlaceholderTablet(context),
            ),
            SizedBox(width: _TabletSizes.listLogoSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    university.name ?? '',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: _TabletSizes.listTitleFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (university.city != null) ...[
                    SizedBox(height: _TabletSizes.listCityTopSpacing),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: _TabletSizes.listCityIconSize,
                          color: AppTheme.textSec(context),
                        ),
                        SizedBox(width: _TabletSizes.listCitySpacing),
                        Text(
                          university.city!,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _TabletSizes.listCityFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: _TabletSizes.listChevronSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoPlaceholderTablet(BuildContext context) {
    return Container(
      width: _TabletSizes.listLogoSize,
      height: _TabletSizes.listLogoSize,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(_TabletSizes.listLogoBorderRadius),
      ),
      child: Icon(
        Icons.account_balance_rounded,
        color: AppTheme.textSec(context),
        size: _TabletSizes.listPlaceholderIconSize,
      ),
    );
  }
}