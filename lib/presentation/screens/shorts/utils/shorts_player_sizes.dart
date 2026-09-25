// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

abstract class ShortsPlayerSizes {
  const ShortsPlayerSizes();

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

  // Üniversite logo wheel
  double get wheelHeight;
  double get wheelItemExtent;
  double get wheelActiveLogoSize;
  double get wheelInactiveLogoSize;
  double get wheelLogoPadding;
  double get wheelDiameterRatio;
  double get wheelPerspective;

  // Bottom content
  double get bottomPaddingHorizontal;
  double get bottomPaddingVertical;
  double get logoContainerSize;
  double get logoSpacing;
  double get titleFontSize;
  double get subtitleFontSize;
  double get subtitleLineHeight;

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

  // Play icon (pause overlay)
  double get playIconSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class ShortsPlayerPhoneSizes extends ShortsPlayerSizes {
  const ShortsPlayerPhoneSizes();

  @override
  bool get isTablet => false;

  @override
  double get topBarPaddingHorizontal => 4;
  @override
  double get topBarPaddingVertical => 2;
  @override
  double get backIconSize => 20;
  @override
  double get shortsBadgePaddingHorizontal => 8;
  @override
  double get shortsBadgePaddingVertical => 3;
  @override
  double get shortsBadgeBorderRadius => 5;
  @override
  double get shortsBadgeFontSize => 10;
  @override
  double get shortsBadgeLetterSpacing => 1.2;
  @override
  double get counterFontSize => 12;
  @override
  double get counterSpacing => 8;
  @override
  double get muteButtonSize => 34;
  @override
  double get muteIconSize => 16;

  @override
  double get wheelHeight => 96;
  @override
  double get wheelItemExtent => 68;
  @override
  double get wheelActiveLogoSize => 54;
  @override
  double get wheelInactiveLogoSize => 38;
  @override
  double get wheelLogoPadding => 6;
  @override
  double get wheelDiameterRatio => 2.0;
  @override
  double get wheelPerspective => 0.0022;

  @override
  double get bottomPaddingHorizontal => 16;
  @override
  double get bottomPaddingVertical => 10;
  @override
  double get logoContainerSize => 30;
  @override
  double get logoSpacing => 8;
  @override
  double get titleFontSize => 13;
  @override
  double get subtitleFontSize => 12;
  @override
  double get subtitleLineHeight => 1.35;

  @override
  double get progressBarHeight => 4;
  @override
  double get progressBarRadius => 2;

  @override
  double get textBtnPaddingVertical => 8;
  @override
  double get textBtnBorderRadius => 8;
  @override
  double get textBtnBorderWidth => 1;
  @override
  double get textBtnIconSize => 16;
  @override
  double get textBtnLabelFontSize => 12;
  @override
  double get textBtnSpacing => 5;

  @override
  double get playIconSize => 64;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class ShortsPlayerTabletSizes extends ShortsPlayerSizes {
  const ShortsPlayerTabletSizes();

  @override
  bool get isTablet => true;

  @override
  double get topBarPaddingHorizontal => 6;
  @override
  double get topBarPaddingVertical => 4;
  @override
  double get backIconSize => 24;
  @override
  double get shortsBadgePaddingHorizontal => 10;
  @override
  double get shortsBadgePaddingVertical => 4;
  @override
  double get shortsBadgeBorderRadius => 6;
  @override
  double get shortsBadgeFontSize => 12;
  @override
  double get shortsBadgeLetterSpacing => 1.4;
  @override
  double get counterFontSize => 14;
  @override
  double get counterSpacing => 10;
  @override
  double get muteButtonSize => 40;
  @override
  double get muteIconSize => 20;

  @override
  double get wheelHeight => 116;
  @override
  double get wheelItemExtent => 84;
  @override
  double get wheelActiveLogoSize => 68;
  @override
  double get wheelInactiveLogoSize => 46;
  @override
  double get wheelLogoPadding => 8;
  @override
  double get wheelDiameterRatio => 2.2;
  @override
  double get wheelPerspective => 0.0020;

  @override
  double get bottomPaddingHorizontal => 20;
  @override
  double get bottomPaddingVertical => 14;
  @override
  double get logoContainerSize => 36;
  @override
  double get logoSpacing => 10;
  @override
  double get titleFontSize => 16;
  @override
  double get subtitleFontSize => 14;
  @override
  double get subtitleLineHeight => 1.4;

  @override
  double get progressBarHeight => 5;
  @override
  double get progressBarRadius => 3;

  @override
  double get textBtnPaddingVertical => 10;
  @override
  double get textBtnBorderRadius => 10;
  @override
  double get textBtnBorderWidth => 1.2;
  @override
  double get textBtnIconSize => 20;
  @override
  double get textBtnLabelFontSize => 14;
  @override
  double get textBtnSpacing => 6;

  @override
  double get playIconSize => 80;
}
