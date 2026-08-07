// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT
// ═══════════════════════════════════════════════════════════

import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class SignupPreferencesSizes {
  const SignupPreferencesSizes();

  bool get isTablet;

  double get skipFontSize;
  double get pagePadding;
  double get iconContainerSize;
  double get iconSize;
  double get iconSpacing;
  double get titleFontSize;
  double get titleSpacing;
  double get descriptionFontSize;
  double get descriptionSpacing;
  double get optionSpacing;
  double get optionPadding;
  double get optionRadius;
  double get optionIconSize;
  double get optionTitleFontSize;
  double get optionSubtitleFontSize;
  double get optionCheckIconSize;
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
// PHONE SIZES
// ═══════════════════════════════════════════════════════════

class SignupPreferencesPhoneSizes extends SignupPreferencesSizes {
  const SignupPreferencesPhoneSizes();

  @override bool get isTablet => false;

  @override double get skipFontSize => 14.sp;
  @override double get pagePadding => 32.w;
  @override double get iconContainerSize => 96.w;
  @override double get iconSize => 48.sp;
  @override double get iconSpacing => 28.h;
  @override double get titleFontSize => 22.sp;
  @override double get titleSpacing => 8.h;
  @override double get descriptionFontSize => 15.sp;
  @override double get descriptionSpacing => 28.h;
  @override double get optionSpacing => 12.h;
  @override double get optionPadding => 16.w;
  @override double get optionRadius => 14.r;
  @override double get optionIconSize => 24.sp;
  @override double get optionTitleFontSize => 15.sp;
  @override double get optionSubtitleFontSize => 12.sp;
  @override double get optionCheckIconSize => 24.sp;
  @override double get bottomPadding => 32.w;
  @override double get dotsSpacing => 4.w;
  @override double get dotActiveWidth => 24.w;
  @override double get dotInactiveWidth => 8.w;
  @override double get dotHeight => 8.h;
  @override double get dotBorderRadius => 4.r;
  @override double get dotsBottomSpacing => 24.h;
  @override double get buttonHeight => 48.h;
  @override double get buttonFontSize => 16.sp;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES
// ═══════════════════════════════════════════════════════════

class SignupPreferencesTabletSizes extends SignupPreferencesSizes {
  const SignupPreferencesTabletSizes();

  @override bool get isTablet => true;

  @override double get skipFontSize => 18;
  @override double get pagePadding => 64;
  @override double get iconContainerSize => 120;
  @override double get iconSize => 60;
  @override double get iconSpacing => 40;
  @override double get titleFontSize => 28;
  @override double get titleSpacing => 12;
  @override double get descriptionFontSize => 18;
  @override double get descriptionSpacing => 36;
  @override double get optionSpacing => 16;
  @override double get optionPadding => 24;
  @override double get optionRadius => 18;
  @override double get optionIconSize => 32;
  @override double get optionTitleFontSize => 20;
  @override double get optionSubtitleFontSize => 15;
  @override double get optionCheckIconSize => 28;
  @override double get bottomPadding => 40;
  @override double get dotsSpacing => 6;
  @override double get dotActiveWidth => 32;
  @override double get dotInactiveWidth => 10;
  @override double get dotHeight => 10;
  @override double get dotBorderRadius => 5;
  @override double get dotsBottomSpacing => 32;
  @override double get buttonHeight => 56;
  @override double get buttonFontSize => 18;
}
