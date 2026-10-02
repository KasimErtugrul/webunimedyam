// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

abstract class UniversityStatsSectionDetailSizes {
  const UniversityStatsSectionDetailSizes();

  bool get isTablet;

  /// WEB ölçeği bayrağı — yalnızca UniversityStatsSectionDetailWebSizes
  /// true döner. (Masaüstünde isTablet da true kalır: web, tablet
  /// ölçeklerini temel alır, yalnızca farklılaşanları ezer.)
  bool get isWeb => false;

  // AppBar
  double get appBarIconSize;
  double get appBarTitleSize;

  // Scroll / list
  double get scrollLoadThreshold;
  double get listVerticalPadding;

  // Footer (loading / end)
  double get footerPaddingVertical;
  double get footerLoaderWidth;
  double get footerLoaderHeight;
  double get footerLoaderStrokeWidth;
  double get footerTextFontSize;

  // Card
  double get cardMarginHorizontal;
  double get cardMarginVertical;
  double get cardPadding;
  double get cardBorderRadius;

  // Logo
  double get logoSize;
  double get logoBorderRadius;
  double get logoSpacing;

  // Title
  double get titleFontSize;

  // City
  double get citySpacing;
  double get citySpacingTop;
  double get cityIconSize;
  double get cityFontSize;

  // Stat
  double get statSpacing;
  double get statIconSize;
  double get statFontSize;

  // Placeholder
  double get placeholderIconSize;

  // Error view
  double get errorIconSize;
  double get errorTextSpacing;
  double get errorButtonSpacing;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class UniversityStatsSectionDetailPhoneSizes
    extends UniversityStatsSectionDetailSizes {
  const UniversityStatsSectionDetailPhoneSizes();

  @override
  bool get isTablet => false;

  @override
  double get appBarIconSize => 24;
  @override
  double get appBarTitleSize => 18;

  @override
  double get scrollLoadThreshold => 400;
  @override
  double get listVerticalPadding => 12;

  @override
  double get footerPaddingVertical => 20;
  @override
  double get footerLoaderWidth => 24;
  @override
  double get footerLoaderHeight => 24;
  @override
  double get footerLoaderStrokeWidth => 2.5;
  @override
  double get footerTextFontSize => 13;

  @override
  double get cardMarginHorizontal => 16;
  @override
  double get cardMarginVertical => 6;
  @override
  double get cardPadding => 12;
  @override
  double get cardBorderRadius => 14;

  @override
  double get logoSize => 56;
  @override
  double get logoBorderRadius => 10;
  @override
  double get logoSpacing => 12;

  @override
  double get titleFontSize => 14;

  @override
  double get citySpacing => 3;
  @override
  double get citySpacingTop => 4;
  @override
  double get cityIconSize => 13;
  @override
  double get cityFontSize => 12;

  @override
  double get statSpacing => 4;
  @override
  double get statIconSize => 14;
  @override
  double get statFontSize => 12.5;

  @override
  double get placeholderIconSize => 26;

  @override
  double get errorIconSize => 48;
  @override
  double get errorTextSpacing => 12;
  @override
  double get errorButtonSpacing => 16;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class UniversityStatsSectionDetailTabletSizes
    extends UniversityStatsSectionDetailSizes {
  const UniversityStatsSectionDetailTabletSizes();

  @override
  bool get isTablet => true;

  @override
  double get appBarIconSize => 28;
  @override
  double get appBarTitleSize => 22;

  @override
  double get scrollLoadThreshold => 500;
  @override
  double get listVerticalPadding => 16;

  @override
  double get footerPaddingVertical => 24;
  @override
  double get footerLoaderWidth => 28;
  @override
  double get footerLoaderHeight => 28;
  @override
  double get footerLoaderStrokeWidth => 3;
  @override
  double get footerTextFontSize => 15;

  @override
  double get cardMarginHorizontal => 20;
  @override
  double get cardMarginVertical => 8;
  @override
  double get cardPadding => 16;
  @override
  double get cardBorderRadius => 16;

  @override
  double get logoSize => 64;
  @override
  double get logoBorderRadius => 12;
  @override
  double get logoSpacing => 14;

  @override
  double get titleFontSize => 16;

  @override
  double get citySpacing => 4;
  @override
  double get citySpacingTop => 5;
  @override
  double get cityIconSize => 15;
  @override
  double get cityFontSize => 14;

  @override
  double get statSpacing => 5;
  @override
  double get statIconSize => 16;
  @override
  double get statFontSize => 14;

  @override
  double get placeholderIconSize => 30;

  @override
  double get errorIconSize => 56;
  @override
  double get errorTextSpacing => 14;
  @override
  double get errorButtonSpacing => 18;
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet ölçülerini temel alır; ızgara gövdesi zaten max-w-[1140px]
/// ile ortalandığı için yalnızca kanal kartı tipografisini masaüstü
/// yoğunluğuna göre büyütür.
class UniversityStatsSectionDetailWebSizes
    extends UniversityStatsSectionDetailTabletSizes {
  const UniversityStatsSectionDetailWebSizes();

  @override
  bool get isWeb => true;

  @override
  double get appBarTitleSize => 21;
}
