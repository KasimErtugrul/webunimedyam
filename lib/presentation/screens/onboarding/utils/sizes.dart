// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class OnboardingSizes {
  const OnboardingSizes();

  bool get isTablet;

  // Skip button
  double get skipFontSize;

  // Page content
  double get pagePadding;
  double get iconContainerSize;
  double get iconSize;
  double get iconSpacing;
  double get titleFontSize;
  double get titleSpacing;
  double get descriptionFontSize;
  double get descriptionLineHeight;

  // Bottom
  double get bottomPadding;
  double get dotsSpacing;
  double get dotActiveWidth;
  double get dotInactiveWidth;
  double get dotHeight;
  double get dotBorderRadius;
  double get dotsBottomSpacing;
  double get buttonHeight;
  double get buttonFontSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class OnboardingPhoneSizes extends OnboardingSizes {
  const OnboardingPhoneSizes();

  @override bool get isTablet => false;

  @override double get skipFontSize => 14.sp;

  @override double get pagePadding => 32.w;
  @override double get iconContainerSize => 120.w;
  @override double get iconSize => 60.sp;
  @override double get iconSpacing => 40.h;
  @override double get titleFontSize => 24.sp;
  @override double get titleSpacing => 16.h;
  @override double get descriptionFontSize => 16.sp;
  @override double get descriptionLineHeight => 1.6;

  @override double get bottomPadding => 32.w;
  @override double get dotsSpacing => 4.w;
  @override double get dotActiveWidth => 24.w;
  @override double get dotInactiveWidth => 8.w;
  @override double get dotHeight => 8.h;
  @override double get dotBorderRadius => 4.r;
  @override double get dotsBottomSpacing => 32.h;
  @override double get buttonHeight => 48.h;
  @override double get buttonFontSize => 16.sp;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class OnboardingTabletSizes extends OnboardingSizes {
  const OnboardingTabletSizes();

  @override bool get isTablet => true;

  @override double get skipFontSize => 16;

  @override double get pagePadding => 48;
  @override double get iconContainerSize => 160;
  @override double get iconSize => 80;
  @override double get iconSpacing => 48;
  @override double get titleFontSize => 32;
  @override double get titleSpacing => 20;
  @override double get descriptionFontSize => 20;
  @override double get descriptionLineHeight => 1.7;

  @override double get bottomPadding => 40;
  @override double get dotsSpacing => 6;
  @override double get dotActiveWidth => 32;
  @override double get dotInactiveWidth => 10;
  @override double get dotHeight => 10;
  @override double get dotBorderRadius => 5;
  @override double get dotsBottomSpacing => 40;
  @override double get buttonHeight => 56;
  @override double get buttonFontSize => 18;
}
