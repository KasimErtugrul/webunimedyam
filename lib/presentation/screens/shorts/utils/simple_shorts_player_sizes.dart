// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class SimpleShortsPlayerSizes {
  const SimpleShortsPlayerSizes();

  bool get isTablet;

  // Top bar
  double get topBarPaddingHorizontal;
  double get topBarPaddingVertical;
  double get backIconSize;
  double get shortsBadgePaddingHorizontal;
  double get shortsBadgePaddingVertical;
  double get shortsBadgeBorderRadius;
  double get shortsBadgeFontSize;
  double get shortsBadgeLetterSpacing;
  double get counterFontSize;
  double get counterSpacing;
  double get muteButtonSize;
  double get muteIconSize;

  // Chip row
  double get chipRowHeight;
  double get chipPaddingHorizontal;
  double get chipMarginRight;
  double get chipPaddingHorizontalInner;
  double get chipPaddingVertical;
  double get chipBorderRadius;
  double get chipBorderWidth;
  double get chipThumbnailSize;
  double get chipThumbnailBorderRadius;
  double get chipThumbnailSpacing;
  double get chipTitleMaxWidth;
  double get chipFontSize;

  // Bottom content
  double get bottomPaddingHorizontal;
  double get bottomPaddingVertical;
  double get titleFontSize;
  double get titleLineHeight;
  double get viewCountFontSize;
  double get viewCountSpacing;

  // Progress bar
  double get progressBarHeight;
  double get progressBarRadius;

  // Text buttons
  double get textBtnPaddingVertical;
  double get textBtnBorderRadius;
  double get textBtnBorderWidth;
  double get textBtnIconSize;
  double get textBtnLabelFontSize;
  double get textBtnSpacing;
  double get textBtnSpacingHorizontal;

  // Play icon (pause overlay)
  double get playIconSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class SimpleShortsPlayerPhoneSizes extends SimpleShortsPlayerSizes {
  const SimpleShortsPlayerPhoneSizes();

  @override bool get isTablet => false;

  @override double get topBarPaddingHorizontal => 4.w;
  @override double get topBarPaddingVertical => 2.h;
  @override double get backIconSize => 20.sp;
  @override double get shortsBadgePaddingHorizontal => 8.w;
  @override double get shortsBadgePaddingVertical => 3.h;
  @override double get shortsBadgeBorderRadius => 5.r;
  @override double get shortsBadgeFontSize => 10.sp;
  @override double get shortsBadgeLetterSpacing => 1.2;
  @override double get counterFontSize => 12.sp;
  @override double get counterSpacing => 8.w;
  @override double get muteButtonSize => 34.w;
  @override double get muteIconSize => 16.sp;

  @override double get chipRowHeight => 38.h;
  @override double get chipPaddingHorizontal => 12.w;
  @override double get chipMarginRight => 8.w;
  @override double get chipPaddingHorizontalInner => 6.w;
  @override double get chipPaddingVertical => 4.h;
  @override double get chipBorderRadius => 20.r;
  @override double get chipBorderWidth => 1;
  @override double get chipThumbnailSize => 24.w;
  @override double get chipThumbnailBorderRadius => 4.r;
  @override double get chipThumbnailSpacing => 6.w;
  @override double get chipTitleMaxWidth => 80.w;
  @override double get chipFontSize => 10.sp;

  @override double get bottomPaddingHorizontal => 16.w;
  @override double get bottomPaddingVertical => 10.h;
  @override double get titleFontSize => 13.sp;
  @override double get titleLineHeight => 1.35;
  @override double get viewCountFontSize => 11.sp;
  @override double get viewCountSpacing => 4.h;

  @override double get progressBarHeight => 4.h;
  @override double get progressBarRadius => 2.r;

  @override double get textBtnPaddingVertical => 8.h;
  @override double get textBtnBorderRadius => 8.r;
  @override double get textBtnBorderWidth => 1;
  @override double get textBtnIconSize => 16.sp;
  @override double get textBtnLabelFontSize => 12.sp;
  @override double get textBtnSpacing => 5.w;
  @override double get textBtnSpacingHorizontal => 10.w;

  @override double get playIconSize => 64.sp;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class SimpleShortsPlayerTabletSizes extends SimpleShortsPlayerSizes {
  const SimpleShortsPlayerTabletSizes();

  @override bool get isTablet => true;

  @override double get topBarPaddingHorizontal => 6;
  @override double get topBarPaddingVertical => 4;
  @override double get backIconSize => 24;
  @override double get shortsBadgePaddingHorizontal => 10;
  @override double get shortsBadgePaddingVertical => 4;
  @override double get shortsBadgeBorderRadius => 6;
  @override double get shortsBadgeFontSize => 12;
  @override double get shortsBadgeLetterSpacing => 1.4;
  @override double get counterFontSize => 14;
  @override double get counterSpacing => 10;
  @override double get muteButtonSize => 40;
  @override double get muteIconSize => 20;

  @override double get chipRowHeight => 44;
  @override double get chipPaddingHorizontal => 16;
  @override double get chipMarginRight => 10;
  @override double get chipPaddingHorizontalInner => 8;
  @override double get chipPaddingVertical => 5;
  @override double get chipBorderRadius => 24;
  @override double get chipBorderWidth => 1.2;
  @override double get chipThumbnailSize => 30;
  @override double get chipThumbnailBorderRadius => 5;
  @override double get chipThumbnailSpacing => 8;
  @override double get chipTitleMaxWidth => 100;
  @override double get chipFontSize => 12;

  @override double get bottomPaddingHorizontal => 20;
  @override double get bottomPaddingVertical => 14;
  @override double get titleFontSize => 16;
  @override double get titleLineHeight => 1.4;
  @override double get viewCountFontSize => 13;
  @override double get viewCountSpacing => 6;

  @override double get progressBarHeight => 5;
  @override double get progressBarRadius => 3;

  @override double get textBtnPaddingVertical => 10;
  @override double get textBtnBorderRadius => 10;
  @override double get textBtnBorderWidth => 1.2;
  @override double get textBtnIconSize => 20;
  @override double get textBtnLabelFontSize => 14;
  @override double get textBtnSpacing => 6;
  @override double get textBtnSpacingHorizontal => 12;

  @override double get playIconSize => 76;
}
