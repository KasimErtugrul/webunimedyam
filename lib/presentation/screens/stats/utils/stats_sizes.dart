// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class StatsSizes {
  const StatsSizes();

  bool get isTablet;

  // AppBar
  double get appBarTitleSize;
  double get backIconSize;
  double get refreshIconSize;

  // Loading
  double get loadingStrokeWidth;

  // Error view
  double get errorIconSize;
  double get errorSpacingLarge;
  double get errorSpacingSmall;
  double get errorSpacingButton;
  double get errorTitleFontSize;
  double get errorSubtitleFontSize;
  double get errorButtonFontSize;

  // Body padding
  double get bodyPaddingLeft;
  double get bodyPaddingTop;
  double get bodyPaddingRight;
  double get bodyPaddingBottom;
  double get bodySectionSpacing;
  double get bodySectionTitleSpacing;

  // Hero card
  double get heroPadding;
  double get heroBorderRadius;
  double get heroBorderWidth;
  double get heroAvatarSize;
  double get heroAvatarIconSize;
  double get heroAvatarSpacing;
  double get heroNameFontSize;
  double get heroMemberFontSize;
  double get heroWatchTimeFontSize;
  double get heroWatchTimeLabelFontSize;
  double get heroDividerSpacing;
  double get heroDividerHeight;
  double get heroStatValueFontSize;
  double get heroStatLabelFontSize;
  double get heroDividerWidth;
  double get heroDividerHeightVert;

  // Streak card
  double get streakPaddingHorizontal;
  double get streakPaddingVertical;
  double get streakBorderRadius;
  double get streakBorderWidth;
  double get streakIconSize;
  double get streakIconInnerSize;
  double get streakIconSpacing;
  double get streakTitleFontSize;
  double get streakSubtitleFontSize;
  double get streakEmojiFontSize;

  // Metric card
  double get metricPaddingHorizontal;
  double get metricPaddingVertical;
  double get metricBorderRadius;
  double get metricIconSize;
  double get metricIconSpacing;
  double get metricLabelFontSize;
  double get metricValueFontSize;
  double get metricSubFontSize;
  double get metricSpacingSmall;
  double get metricSpacingMedium;
  double get metricRowSpacing;

  // Top university card
  double get topUniPadding;
  double get topUniBorderRadius;
  double get topUniLogoSize;
  double get topUniLogoBorderRadius;
  double get topUniLogoSpacing;
  double get topUniNameFontSize;
  double get topUniSubFontSize;
  double get topUniStarSize;
  double get topUniSubSpacing;

  // Video card
  double get videoPadding;
  double get videoBorderRadius;
  double get videoThumbnailWidth;
  double get videoThumbnailHeight;
  double get videoThumbnailBorderRadius;
  double get videoTitleFontSize;
  double get videoTitleLineHeight;
  double get videoDateFontSize;
  double get videoIconSize;
  double get videoSpacing;
  double get videoSpacingSmall;
  double get videoSpacingDate;

  // Thumb fallback
  double get thumbFallbackIconSize;

  // Section title
  double get sectionTitleFontSize;
  double get sectionTitleLetterSpacing;

  // Logo fallback
  double get logoFallbackSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class StatsPhoneSizes extends StatsSizes {
  const StatsPhoneSizes();

  @override bool get isTablet => false;

  @override double get appBarTitleSize => 18.sp;
  @override double get backIconSize => 20.sp;
  @override double get refreshIconSize => 22.sp;

  @override double get loadingStrokeWidth => 3.w;

  @override double get errorIconSize => 56.sp;
  @override double get errorSpacingLarge => 16.h;
  @override double get errorSpacingSmall => 8.h;
  @override double get errorSpacingButton => 24.h;
  @override double get errorTitleFontSize => 16.sp;
  @override double get errorSubtitleFontSize => 13.sp;
  @override double get errorButtonFontSize => 14.sp;

  @override double get bodyPaddingLeft => 16.w;
  @override double get bodyPaddingTop => 8.h;
  @override double get bodyPaddingRight => 16.w;
  @override double get bodyPaddingBottom => 32.h;
  @override double get bodySectionSpacing => 20.h;
  @override double get bodySectionTitleSpacing => 10.h;

  @override double get heroPadding => 18.w;
  @override double get heroBorderRadius => 16.r;
  @override double get heroBorderWidth => 1.w;
  @override double get heroAvatarSize => 46.w;
  @override double get heroAvatarIconSize => 26.sp;
  @override double get heroAvatarSpacing => 12.w;
  @override double get heroNameFontSize => 15.sp;
  @override double get heroMemberFontSize => 11.sp;
  @override double get heroWatchTimeFontSize => 13.sp;
  @override double get heroWatchTimeLabelFontSize => 10.sp;
  @override double get heroDividerSpacing => 16.h;
  @override double get heroDividerHeight => 1;
  @override double get heroStatValueFontSize => 22.sp;
  @override double get heroStatLabelFontSize => 11.sp;
  @override double get heroDividerWidth => 1.w;
  @override double get heroDividerHeightVert => 32.h;

  @override double get streakPaddingHorizontal => 18.w;
  @override double get streakPaddingVertical => 14.h;
  @override double get streakBorderRadius => 14.r;
  @override double get streakBorderWidth => 1.w;
  @override double get streakIconSize => 44.w;
  @override double get streakIconInnerSize => 24.sp;
  @override double get streakIconSpacing => 14.w;
  @override double get streakTitleFontSize => 14.sp;
  @override double get streakSubtitleFontSize => 12.sp;
  @override double get streakEmojiFontSize => 22.sp;

  @override double get metricPaddingHorizontal => 14.w;
  @override double get metricPaddingVertical => 14.h;
  @override double get metricBorderRadius => 12.r;
  @override double get metricIconSize => 16.sp;
  @override double get metricIconSpacing => 6.w;
  @override double get metricLabelFontSize => 11.sp;
  @override double get metricValueFontSize => 24.sp;
  @override double get metricSubFontSize => 10.sp;
  @override double get metricSpacingSmall => 8.h;
  @override double get metricSpacingMedium => 2.h;
  @override double get metricRowSpacing => 10.w;

  @override double get topUniPadding => 14.w;
  @override double get topUniBorderRadius => 14.r;
  @override double get topUniLogoSize => 48.w;
  @override double get topUniLogoBorderRadius => 8.r;
  @override double get topUniLogoSpacing => 14.w;
  @override double get topUniNameFontSize => 14.sp;
  @override double get topUniSubFontSize => 12.sp;
  @override double get topUniStarSize => 22.sp;
  @override double get topUniSubSpacing => 4.h;

  @override double get videoPadding => 12.w;
  @override double get videoBorderRadius => 14.r;
  @override double get videoThumbnailWidth => 72.w;
  @override double get videoThumbnailHeight => 52.h;
  @override double get videoThumbnailBorderRadius => 8.r;
  @override double get videoTitleFontSize => 12.sp;
  @override double get videoTitleLineHeight => 1.4;
  @override double get videoDateFontSize => 11.sp;
  @override double get videoIconSize => 20.sp;
  @override double get videoSpacing => 12.w;
  @override double get videoSpacingSmall => 8.w;
  @override double get videoSpacingDate => 4.h;

  @override double get thumbFallbackIconSize => 24.sp;

  @override double get sectionTitleFontSize => 12.sp;
  @override double get sectionTitleLetterSpacing => 0.4;

  @override double get logoFallbackSize => 24.sp;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class StatsTabletSizes extends StatsSizes {
  const StatsTabletSizes();

  @override bool get isTablet => true;

  @override double get appBarTitleSize => 22;
  @override double get backIconSize => 24;
  @override double get refreshIconSize => 26;

  @override double get loadingStrokeWidth => 3.5;

  @override double get errorIconSize => 68;
  @override double get errorSpacingLarge => 20;
  @override double get errorSpacingSmall => 10;
  @override double get errorSpacingButton => 28;
  @override double get errorTitleFontSize => 20;
  @override double get errorSubtitleFontSize => 16;
  @override double get errorButtonFontSize => 16;

  @override double get bodyPaddingLeft => 24;
  @override double get bodyPaddingTop => 12;
  @override double get bodyPaddingRight => 24;
  @override double get bodyPaddingBottom => 40;
  @override double get bodySectionSpacing => 24;
  @override double get bodySectionTitleSpacing => 14;

  @override double get heroPadding => 24;
  @override double get heroBorderRadius => 20;
  @override double get heroBorderWidth => 1.2;
  @override double get heroAvatarSize => 56;
  @override double get heroAvatarIconSize => 32;
  @override double get heroAvatarSpacing => 16;
  @override double get heroNameFontSize => 18;
  @override double get heroMemberFontSize => 13;
  @override double get heroWatchTimeFontSize => 16;
  @override double get heroWatchTimeLabelFontSize => 12;
  @override double get heroDividerSpacing => 20;
  @override double get heroDividerHeight => 1.2;
  @override double get heroStatValueFontSize => 28;
  @override double get heroStatLabelFontSize => 13;
  @override double get heroDividerWidth => 1.2;
  @override double get heroDividerHeightVert => 40;

  @override double get streakPaddingHorizontal => 24;
  @override double get streakPaddingVertical => 18;
  @override double get streakBorderRadius => 18;
  @override double get streakBorderWidth => 1.2;
  @override double get streakIconSize => 52;
  @override double get streakIconInnerSize => 28;
  @override double get streakIconSpacing => 18;
  @override double get streakTitleFontSize => 16;
  @override double get streakSubtitleFontSize => 14;
  @override double get streakEmojiFontSize => 26;

  @override double get metricPaddingHorizontal => 18;
  @override double get metricPaddingVertical => 18;
  @override double get metricBorderRadius => 14;
  @override double get metricIconSize => 20;
  @override double get metricIconSpacing => 8;
  @override double get metricLabelFontSize => 13;
  @override double get metricValueFontSize => 30;
  @override double get metricSubFontSize => 12;
  @override double get metricSpacingSmall => 10;
  @override double get metricSpacingMedium => 3;
  @override double get metricRowSpacing => 14;

  @override double get topUniPadding => 18;
  @override double get topUniBorderRadius => 18;
  @override double get topUniLogoSize => 56;
  @override double get topUniLogoBorderRadius => 10;
  @override double get topUniLogoSpacing => 18;
  @override double get topUniNameFontSize => 16;
  @override double get topUniSubFontSize => 14;
  @override double get topUniStarSize => 26;
  @override double get topUniSubSpacing => 6;

  @override double get videoPadding => 16;
  @override double get videoBorderRadius => 16;
  @override double get videoThumbnailWidth => 88;
  @override double get videoThumbnailHeight => 62;
  @override double get videoThumbnailBorderRadius => 10;
  @override double get videoTitleFontSize => 14;
  @override double get videoTitleLineHeight => 1.45;
  @override double get videoDateFontSize => 13;
  @override double get videoIconSize => 24;
  @override double get videoSpacing => 16;
  @override double get videoSpacingSmall => 10;
  @override double get videoSpacingDate => 6;

  @override double get thumbFallbackIconSize => 30;

  @override double get sectionTitleFontSize => 14;
  @override double get sectionTitleLetterSpacing => 0.5;

  @override double get logoFallbackSize => 28;
}
