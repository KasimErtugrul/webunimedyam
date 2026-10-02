// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT
// ═══════════════════════════════════════════════════════════


abstract class InterestSelectionSizes {
  const InterestSelectionSizes();

  bool get isTablet;

  /// WEB ölçeği bayrağı — yalnızca InterestSelectionWebSizes true döner.
  bool get isWeb => false;

  // Header
  double get headerPaddingLeft;
  double get headerPaddingTop;
  double get headerPaddingRight;
  double get headerPaddingBottom;
  double get headerTitleFontSize;
  double get headerSkipFontSize;
  double get headerDescriptionSpacing;
  double get headerDescriptionFontSize;
  double get headerDescriptionLineHeight;
  double get headerSearchSpacing;
  double get headerSearchFontSize;
  double get headerSearchHintFontSize;
  double get headerSearchContentPaddingVertical;
  double get headerSearchBorderRadius;

  // Grid
  double get gridPaddingLeft;
  double get gridPaddingTop;
  double get gridPaddingRight;
  double get gridPaddingBottom;
  double get gridMainAxisSpacing;
  double get gridCrossAxisSpacing;
  double get gridChildAspectRatio;

  // University chip
  double get chipPaddingHorizontal;
  double get chipPaddingVertical;
  double get chipBorderRadius;
  double get chipBorderWidth;
  double get chipAvatarRadius;
  double get chipAvatarIconSize;
  double get chipAvatarSpacing;
  double get chipTitleFontSize;
  double get chipCheckIconSize;

  // Bottom bar
  double get bottomBarPaddingLeft;
  double get bottomBarPaddingTop;
  double get bottomBarPaddingRight;
  double get bottomBarPaddingBottom;
  double get bottomBarButtonHeight;
  double get bottomBarButtonFontSize;
  double get bottomBarLoaderSize;
  double get bottomBarLoaderStrokeWidth;

  // Error state
  double get errorPaddingHorizontal;
  double get errorFontSize;
  double get errorSpacing;

  // Empty state
  double get emptyFontSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class InterestSelectionPhoneSizes extends InterestSelectionSizes {
  const InterestSelectionPhoneSizes();

  @override bool get isTablet => false;

  @override double get headerPaddingLeft => 20;
  @override double get headerPaddingTop => 12;
  @override double get headerPaddingRight => 20;
  @override double get headerPaddingBottom => 8;
  @override double get headerTitleFontSize => 22;
  @override double get headerSkipFontSize => 14;
  @override double get headerDescriptionSpacing => 6;
  @override double get headerDescriptionFontSize => 13;
  @override double get headerDescriptionLineHeight => 1.4;
  @override double get headerSearchSpacing => 14;
  @override double get headerSearchFontSize => 14;
  @override double get headerSearchHintFontSize => 14;
  @override double get headerSearchContentPaddingVertical => 10;
  @override double get headerSearchBorderRadius => 12;

  @override double get gridPaddingLeft => 20;
  @override double get gridPaddingTop => 8;
  @override double get gridPaddingRight => 20;
  @override double get gridPaddingBottom => 16;
  @override double get gridMainAxisSpacing => 12;
  @override double get gridCrossAxisSpacing => 12;
  @override double get gridChildAspectRatio => 2.6;

  @override double get chipPaddingHorizontal => 12;
  @override double get chipPaddingVertical => 10;
  @override double get chipBorderRadius => 14;
  @override double get chipBorderWidth => 1.5;
  @override double get chipAvatarRadius => 16;
  @override double get chipAvatarIconSize => 16;
  @override double get chipAvatarSpacing => 8;
  @override double get chipTitleFontSize => 12.5;
  @override double get chipCheckIconSize => 18;

  @override double get bottomBarPaddingLeft => 20;
  @override double get bottomBarPaddingTop => 8;
  @override double get bottomBarPaddingRight => 20;
  @override double get bottomBarPaddingBottom => 20;
  @override double get bottomBarButtonHeight => 48;
  @override double get bottomBarButtonFontSize => 16;
  @override double get bottomBarLoaderSize => 20;
  @override double get bottomBarLoaderStrokeWidth => 2;

  @override double get errorPaddingHorizontal => 32;
  @override double get errorFontSize => 14;
  @override double get errorSpacing => 12;

  @override double get emptyFontSize => 14;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class InterestSelectionTabletSizes extends InterestSelectionSizes {
  const InterestSelectionTabletSizes();

  @override bool get isTablet => true;

  @override double get headerPaddingLeft => 32;
  @override double get headerPaddingTop => 20;
  @override double get headerPaddingRight => 32;
  @override double get headerPaddingBottom => 12;
  @override double get headerTitleFontSize => 28;
  @override double get headerSkipFontSize => 18;
  @override double get headerDescriptionSpacing => 10;
  @override double get headerDescriptionFontSize => 16;
  @override double get headerDescriptionLineHeight => 1.5;
  @override double get headerSearchSpacing => 20;
  @override double get headerSearchFontSize => 16;
  @override double get headerSearchHintFontSize => 16;
  @override double get headerSearchContentPaddingVertical => 14;
  @override double get headerSearchBorderRadius => 16;

  @override double get gridPaddingLeft => 32;
  @override double get gridPaddingTop => 12;
  @override double get gridPaddingRight => 32;
  @override double get gridPaddingBottom => 24;
  @override double get gridMainAxisSpacing => 16;
  @override double get gridCrossAxisSpacing => 16;
  @override double get gridChildAspectRatio => 3.2;

  @override double get chipPaddingHorizontal => 16;
  @override double get chipPaddingVertical => 14;
  @override double get chipBorderRadius => 18;
  @override double get chipBorderWidth => 2;
  @override double get chipAvatarRadius => 20;
  @override double get chipAvatarIconSize => 20;
  @override double get chipAvatarSpacing => 12;
  @override double get chipTitleFontSize => 15;
  @override double get chipCheckIconSize => 22;

  @override double get bottomBarPaddingLeft => 32;
  @override double get bottomBarPaddingTop => 12;
  @override double get bottomBarPaddingRight => 32;
  @override double get bottomBarPaddingBottom => 28;
  @override double get bottomBarButtonHeight => 56;
  @override double get bottomBarButtonFontSize => 18;
  @override double get bottomBarLoaderSize => 24;
  @override double get bottomBarLoaderStrokeWidth => 2.5;

  @override double get errorPaddingHorizontal => 40;
  @override double get errorFontSize => 16;
  @override double get errorSpacing => 16;

  @override double get emptyFontSize => 16;
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet ölçülerini temel alır; ızgara zaten max-w-[1100px] ile
/// ortalandığı için yalnızca sayfa kenar boşlukları masaüstüne göre
/// büyütülür.
class InterestSelectionWebSizes extends InterestSelectionTabletSizes {
  const InterestSelectionWebSizes();

  @override
  bool get isWeb => true;

  @override
  double get gridPaddingLeft => 28;
  @override
  double get gridPaddingRight => 28;
}
