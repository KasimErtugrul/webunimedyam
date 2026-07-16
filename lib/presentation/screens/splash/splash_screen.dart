// lib/presentation/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/splash_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Logo
  static const double logoSize = 100;
  static const double logoBorderRadius = 20;
  static const double logoIconSize = 60;

  // Title
  static const double titleFontSize = 32;
  static const double titleLetterSpacing = 2;
  static const double titleSpacing = 24;

  // Subtitle
  static const double subtitleFontSize = 14;
  static const double subtitleSpacing = 8;

  // Loading indicator
  static const double loadingIndicatorSize = 40;
  static const double loadingStrokeWidth = 3;
  static const double loadingSpacing = 48;
}

class _TabletSizes {
  // Logo - tablet için daha büyük
  static const double logoSize = 140;
  static const double logoBorderRadius = 28;
  static const double logoIconSize = 84;

  // Title - tablet için daha büyük
  static const double titleFontSize = 44;
  static const double titleLetterSpacing = 3;
  static const double titleSpacing = 32;

  // Subtitle - tablet için daha büyük
  static const double subtitleFontSize = 18;
  static const double subtitleSpacing = 12;

  // Loading indicator - tablet için daha büyük
  static const double loadingIndicatorSize = 52;
  static const double loadingStrokeWidth = 3.5;
  static const double loadingSpacing = 56;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    Get.find<SplashController>();
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _PhoneSizes.logoSize.w,
              height: _PhoneSizes.logoSize.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(_PhoneSizes.logoBorderRadius.r),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: _PhoneSizes.logoIconSize.sp,
              ),
            ),
            SizedBox(height: _PhoneSizes.titleSpacing.h),
            Text(
              'ÜniTV',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.titleFontSize.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: _PhoneSizes.titleLetterSpacing.w,
              ),
            ),
            SizedBox(height: _PhoneSizes.subtitleSpacing.h),
            Text(
              'Üniversite Video Platformu',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.subtitleFontSize.sp,
              ),
            ),
            SizedBox(height: _PhoneSizes.loadingSpacing.h),
            SizedBox(
              width: _PhoneSizes.loadingIndicatorSize.r,
              height: _PhoneSizes.loadingIndicatorSize.r,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: _PhoneSizes.loadingStrokeWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: _TabletSizes.logoSize,
              height: _TabletSizes.logoSize,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(_TabletSizes.logoBorderRadius),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: _TabletSizes.logoIconSize,
              ),
            ),
            SizedBox(height: _TabletSizes.titleSpacing),
            Text(
              'ÜniTV',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: _TabletSizes.titleLetterSpacing,
              ),
            ),
            SizedBox(height: _TabletSizes.subtitleSpacing),
            Text(
              'Üniversite Video Platformu',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.subtitleFontSize,
              ),
            ),
            SizedBox(height: _TabletSizes.loadingSpacing),
            SizedBox(
              width: _TabletSizes.loadingIndicatorSize,
              height: _TabletSizes.loadingIndicatorSize,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: _TabletSizes.loadingStrokeWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}