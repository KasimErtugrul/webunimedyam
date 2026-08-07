// lib/presentation/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/splash_controller.dart';

// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

abstract class SplashSizes {
  const SplashSizes();

  bool get isTablet;

  // Logo
  double get logoSize;
  double get logoBorderRadius;
  double get logoIconSize;

  // Title
  double get titleFontSize;
  double get titleLetterSpacing;
  double get titleSpacing;

  // Subtitle
  double get subtitleFontSize;
  double get subtitleSpacing;

  // Loading indicator
  double get loadingIndicatorSize;
  double get loadingStrokeWidth;
  double get loadingSpacing;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class SplashPhoneSizes extends SplashSizes {
  const SplashPhoneSizes();

  @override bool get isTablet => false;

  @override double get logoSize => 100.w;
  @override double get logoBorderRadius => 20.r;
  @override double get logoIconSize => 60.sp;

  @override double get titleFontSize => 32.sp;
  @override double get titleLetterSpacing => 2.w;
  @override double get titleSpacing => 24.h;

  @override double get subtitleFontSize => 14.sp;
  @override double get subtitleSpacing => 8.h;

  @override double get loadingIndicatorSize => 40.r;
  @override double get loadingStrokeWidth => 3;
  @override double get loadingSpacing => 48.h;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class SplashTabletSizes extends SplashSizes {
  const SplashTabletSizes();

  @override bool get isTablet => true;

  @override double get logoSize => 140;
  @override double get logoBorderRadius => 28;
  @override double get logoIconSize => 84;

  @override double get titleFontSize => 44;
  @override double get titleLetterSpacing => 3;
  @override double get titleSpacing => 32;

  @override double get subtitleFontSize => 18;
  @override double get subtitleSpacing => 12;

  @override double get loadingIndicatorSize => 52;
  @override double get loadingStrokeWidth => 3.5;
  @override double get loadingSpacing => 56;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless — TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat (ilk Get.find çağrısıyla lazy init tetiklenir)
    Get.find<SplashController>();

    // TEK DALLANMA NOKTASI — phone/tablet ayrımı sadece burada
    final SplashSizes sizes = Responsive.isTablet(context)
        ? const SplashTabletSizes()
        : const SplashPhoneSizes();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: sizes.logoSize,
              height: sizes.logoSize,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(sizes.logoBorderRadius),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: sizes.logoIconSize,
              ),
            ),
            SizedBox(height: sizes.titleSpacing),
            Text(
              'ÜniTV',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: sizes.titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: sizes.titleLetterSpacing,
              ),
            ),
            SizedBox(height: sizes.subtitleSpacing),
            Text(
              'Üniversite Video Platformu',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: sizes.subtitleFontSize,
              ),
            ),
            SizedBox(height: sizes.loadingSpacing),
            SizedBox(
              width: sizes.loadingIndicatorSize,
              height: sizes.loadingIndicatorSize,
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: sizes.loadingStrokeWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}