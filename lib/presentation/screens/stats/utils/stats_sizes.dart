// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

abstract class StatsSizes {
  const StatsSizes();

  bool get isTablet;

  /// WEB ölçeği bayrağı — yalnızca StatsWebSizes true döner.
  bool get isWeb => false;

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

  @override
  bool get isTablet => false;

  @override
  double get appBarTitleSize => 18;
  @override
  double get backIconSize => 20;
  @override
  double get refreshIconSize => 22;

  @override
  double get loadingStrokeWidth => 3;

  @override
  double get errorIconSize => 56;
  @override
  double get errorSpacingLarge => 16;
  @override
  double get errorSpacingSmall => 8;
  @override
  double get errorSpacingButton => 24;
  @override
  double get errorTitleFontSize => 16;
  @override
  double get errorSubtitleFontSize => 13;
  @override
  double get errorButtonFontSize => 14;

  @override
  double get bodyPaddingLeft => 16;
  @override
  double get bodyPaddingTop => 8;
  @override
  double get bodyPaddingRight => 16;
  @override
  double get bodyPaddingBottom => 32;
  @override
  double get bodySectionSpacing => 20;
  @override
  double get bodySectionTitleSpacing => 10;

  @override
  double get heroPadding => 18;
  @override
  double get heroBorderRadius => 16;
  @override
  double get heroBorderWidth => 1;
  @override
  double get heroAvatarSize => 46;
  @override
  double get heroAvatarIconSize => 26;
  @override
  double get heroAvatarSpacing => 12;
  @override
  double get heroNameFontSize => 15;
  @override
  double get heroMemberFontSize => 11;
  @override
  double get heroWatchTimeFontSize => 13;
  @override
  double get heroWatchTimeLabelFontSize => 10;
  @override
  double get heroDividerSpacing => 16;
  @override
  double get heroDividerHeight => 1;
  @override
  double get heroStatValueFontSize => 22;
  @override
  double get heroStatLabelFontSize => 11;
  @override
  double get heroDividerWidth => 1;
  @override
  double get heroDividerHeightVert => 32;

  @override
  double get streakPaddingHorizontal => 18;
  @override
  double get streakPaddingVertical => 14;
  @override
  double get streakBorderRadius => 14;
  @override
  double get streakBorderWidth => 1;
  @override
  double get streakIconSize => 44;
  @override
  double get streakIconInnerSize => 24;
  @override
  double get streakIconSpacing => 14;
  @override
  double get streakTitleFontSize => 14;
  @override
  double get streakSubtitleFontSize => 12;
  @override
  double get streakEmojiFontSize => 22;

  @override
  double get metricPaddingHorizontal => 14;
  @override
  double get metricPaddingVertical => 14;
  @override
  double get metricBorderRadius => 12;
  @override
  double get metricIconSize => 16;
  @override
  double get metricIconSpacing => 6;
  @override
  double get metricLabelFontSize => 11;
  @override
  double get metricValueFontSize => 24;
  @override
  double get metricSubFontSize => 10;
  @override
  double get metricSpacingSmall => 8;
  @override
  double get metricSpacingMedium => 2;
  @override
  double get metricRowSpacing => 10;

  @override
  double get topUniPadding => 14;
  @override
  double get topUniBorderRadius => 14;
  @override
  double get topUniLogoSize => 48;
  @override
  double get topUniLogoBorderRadius => 8;
  @override
  double get topUniLogoSpacing => 14;
  @override
  double get topUniNameFontSize => 14;
  @override
  double get topUniSubFontSize => 12;
  @override
  double get topUniStarSize => 22;
  @override
  double get topUniSubSpacing => 4;

  @override
  double get videoPadding => 12;
  @override
  double get videoBorderRadius => 14;
  @override
  double get videoThumbnailWidth => 72;
  @override
  double get videoThumbnailHeight => 52;
  @override
  double get videoThumbnailBorderRadius => 8;
  @override
  double get videoTitleFontSize => 12;
  @override
  double get videoTitleLineHeight => 1.4;
  @override
  double get videoDateFontSize => 11;
  @override
  double get videoIconSize => 20;
  @override
  double get videoSpacing => 12;
  @override
  double get videoSpacingSmall => 8;
  @override
  double get videoSpacingDate => 4;

  @override
  double get thumbFallbackIconSize => 24;

  @override
  double get sectionTitleFontSize => 12;
  @override
  double get sectionTitleLetterSpacing => 0.4;

  @override
  double get logoFallbackSize => 24;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class StatsTabletSizes extends StatsSizes {
  const StatsTabletSizes();

  @override
  bool get isTablet => true;

  @override
  double get appBarTitleSize => 22;
  @override
  double get backIconSize => 24;
  @override
  double get refreshIconSize => 26;

  @override
  double get loadingStrokeWidth => 3.5;

  @override
  double get errorIconSize => 68;
  @override
  double get errorSpacingLarge => 20;
  @override
  double get errorSpacingSmall => 10;
  @override
  double get errorSpacingButton => 28;
  @override
  double get errorTitleFontSize => 20;
  @override
  double get errorSubtitleFontSize => 16;
  @override
  double get errorButtonFontSize => 16;

  @override
  double get bodyPaddingLeft => 24;
  @override
  double get bodyPaddingTop => 12;
  @override
  double get bodyPaddingRight => 24;
  @override
  double get bodyPaddingBottom => 40;
  @override
  double get bodySectionSpacing => 24;
  @override
  double get bodySectionTitleSpacing => 14;

  @override
  double get heroPadding => 24;
  @override
  double get heroBorderRadius => 20;
  @override
  double get heroBorderWidth => 1.2;
  @override
  double get heroAvatarSize => 56;
  @override
  double get heroAvatarIconSize => 32;
  @override
  double get heroAvatarSpacing => 16;
  @override
  double get heroNameFontSize => 18;
  @override
  double get heroMemberFontSize => 13;
  @override
  double get heroWatchTimeFontSize => 16;
  @override
  double get heroWatchTimeLabelFontSize => 12;
  @override
  double get heroDividerSpacing => 20;
  @override
  double get heroDividerHeight => 1.2;
  @override
  double get heroStatValueFontSize => 28;
  @override
  double get heroStatLabelFontSize => 13;
  @override
  double get heroDividerWidth => 1.2;
  @override
  double get heroDividerHeightVert => 40;

  @override
  double get streakPaddingHorizontal => 24;
  @override
  double get streakPaddingVertical => 18;
  @override
  double get streakBorderRadius => 18;
  @override
  double get streakBorderWidth => 1.2;
  @override
  double get streakIconSize => 52;
  @override
  double get streakIconInnerSize => 28;
  @override
  double get streakIconSpacing => 18;
  @override
  double get streakTitleFontSize => 16;
  @override
  double get streakSubtitleFontSize => 14;
  @override
  double get streakEmojiFontSize => 26;

  @override
  double get metricPaddingHorizontal => 18;
  @override
  double get metricPaddingVertical => 18;
  @override
  double get metricBorderRadius => 14;
  @override
  double get metricIconSize => 20;
  @override
  double get metricIconSpacing => 8;
  @override
  double get metricLabelFontSize => 13;
  @override
  double get metricValueFontSize => 30;
  @override
  double get metricSubFontSize => 12;
  @override
  double get metricSpacingSmall => 10;
  @override
  double get metricSpacingMedium => 3;
  @override
  double get metricRowSpacing => 14;

  @override
  double get topUniPadding => 18;
  @override
  double get topUniBorderRadius => 18;
  @override
  double get topUniLogoSize => 56;
  @override
  double get topUniLogoBorderRadius => 10;
  @override
  double get topUniLogoSpacing => 18;
  @override
  double get topUniNameFontSize => 16;
  @override
  double get topUniSubFontSize => 14;
  @override
  double get topUniStarSize => 26;
  @override
  double get topUniSubSpacing => 6;

  @override
  double get videoPadding => 16;
  @override
  double get videoBorderRadius => 16;
  @override
  double get videoThumbnailWidth => 88;
  @override
  double get videoThumbnailHeight => 62;
  @override
  double get videoThumbnailBorderRadius => 10;
  @override
  double get videoTitleFontSize => 14;
  @override
  double get videoTitleLineHeight => 1.45;
  @override
  double get videoDateFontSize => 13;
  @override
  double get videoIconSize => 24;
  @override
  double get videoSpacing => 16;
  @override
  double get videoSpacingSmall => 10;
  @override
  double get videoSpacingDate => 6;

  @override
  double get thumbFallbackIconSize => 30;

  @override
  double get sectionTitleFontSize => 14;
  @override
  double get sectionTitleLetterSpacing => 0.5;

  @override
  double get logoFallbackSize => 28;
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet ölçülerini temel alır; gövde zaten max-w-[1100px] ile
/// ortalandığı için yalnızca sayfa kenar boşlukları ve bölüm
/// nefesi masaüstüne göre büyütülür.
class StatsWebSizes extends StatsTabletSizes {
  const StatsWebSizes();

  @override
  bool get isWeb => true;

  @override
  double get bodyPaddingLeft => 32;
  @override
  double get bodyPaddingRight => 32;
  @override
  double get bodyPaddingBottom => 48;
  @override
  double get bodySectionSpacing => 28;
}
