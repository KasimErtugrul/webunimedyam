// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════


abstract class ProfileActivityListSizes {
  const ProfileActivityListSizes();

  bool get isTablet;

  // AppBar
  double get appBarTitleSize;
  double get appBarIconSize;
  double get appBarIconPadding;

  // Loading
  double get loadingStrokeWidth;

  // Grid
  double get gridPaddingHorizontal;
  double get gridPaddingVertical;
  double get gridMainSpacing;
  double get gridCrossSpacing;
  double get gridChildAspectRatio;

  // List
  double get listPaddingHorizontal;
  double get listPaddingVertical;
  double get listCardBottomMargin;
  double get listCardBorderRadius;
  double get listThumbnailWidth;
  double get listThumbnailHeight;
  double get listThumbnailRadius;
  double get listThumbnailIconSize;
  double get listContentPaddingLeft;
  double get listContentPaddingTop;
  double get listContentPaddingRight;
  double get listContentPaddingBottom;
  double get listTitleFontSize;
  double get listTitleLineHeight;
  double get listUniFontSize;
  double get listDateFontSize;
  double get listStatSpacing;
  double get listStatIconSize;
  double get listStatFontSize;
  double get listChevronRight;
  double get listChevronTop;
  double get listChevronSize;

  // Grid Card
  double get gridCardBorderRadius;
  double get gridCardPaddingLeft;
  double get gridCardPaddingTop;
  double get gridCardPaddingRight;
  double get gridCardPaddingBottom;
  double get gridTitleFontSize;
  double get gridTitleLineHeight;
  double get gridUniFontSize;
  double get gridUniPaddingTop;
  double get gridStatIconSize;
  double get gridStatFontSize;
  double get gridStatSpacing;
  double get gridStatLineSpacing;

  // Duration Badge
  double get durationBadgePaddingHorizontal;
  double get durationBadgePaddingVertical;
  double get durationBadgeBorderRadius;
  double get durationBadgeFontSize;
  double get durationBadgeGridFontSize;

  // Dismissible
  double get dismissibleMarginBottom;
  double get dismissibleBorderRadius;
  double get dismissiblePaddingRight;
  double get dismissibleIconSize;
  double get dismissibleTextFontSize;
  double get dismissibleSpacing;

  // Confirm Dialog
  double get dialogBorderRadius;
  double get dialogTitleFontSize;
  double get dialogContentFontSize;
  double get dialogButtonWidth;
  double get dialogButtonHeight;
  double get dialogButtonFontSize;

  // Empty View
  double get emptyPaddingHorizontal;
  double get emptyIconSize;
  double get emptySpacingLarge;
  double get emptySpacingSmall;
  double get emptyTitleFontSize;
  double get emptySubtitleFontSize;

  // No Search Results
  double get noResultPaddingHorizontal;
  double get noResultIconSize;
  double get noResultSpacingLarge;
  double get noResultSpacingSmall;
  double get noResultTitleFontSize;
  double get noResultSubtitleFontSize;

  // Load More
  double get loadMorePaddingVertical;
  double get loadMoreStrokeWidth;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class ProfileActivityListPhoneSizes extends ProfileActivityListSizes {
  const ProfileActivityListPhoneSizes();

  @override bool get isTablet => false;

  @override double get appBarTitleSize => 18;
  @override double get appBarIconSize => 22;
  @override double get appBarIconPadding => 4;

  @override double get loadingStrokeWidth => 3;

  @override double get gridPaddingHorizontal => 14;
  @override double get gridPaddingVertical => 12;
  @override double get gridMainSpacing => 10;
  @override double get gridCrossSpacing => 10;
  @override double get gridChildAspectRatio => 0.68;

  @override double get listPaddingHorizontal => 14;
  @override double get listPaddingVertical => 12;
  @override double get listCardBottomMargin => 10;
  @override double get listCardBorderRadius => 14;
  @override double get listThumbnailWidth => 140;
  @override double get listThumbnailHeight => 84;
  @override double get listThumbnailRadius => 14;
  @override double get listThumbnailIconSize => 28;
  @override double get listContentPaddingLeft => 12;
  @override double get listContentPaddingTop => 10;
  @override double get listContentPaddingRight => 8;
  @override double get listContentPaddingBottom => 10;
  @override double get listTitleFontSize => 13;
  @override double get listTitleLineHeight => 1.35;
  @override double get listUniFontSize => 11;
  @override double get listDateFontSize => 11;
  @override double get listStatSpacing => 10;
  @override double get listStatIconSize => 13;
  @override double get listStatFontSize => 11;
  @override double get listChevronRight => 8;
  @override double get listChevronTop => 36;
  @override double get listChevronSize => 18;

  @override double get gridCardBorderRadius => 14;
  @override double get gridCardPaddingLeft => 8;
  @override double get gridCardPaddingTop => 8;
  @override double get gridCardPaddingRight => 8;
  @override double get gridCardPaddingBottom => 6;
  @override double get gridTitleFontSize => 12;
  @override double get gridTitleLineHeight => 1.3;
  @override double get gridUniFontSize => 10;
  @override double get gridUniPaddingTop => 4;
  @override double get gridStatIconSize => 11;
  @override double get gridStatFontSize => 10;
  @override double get gridStatSpacing => 8;
  @override double get gridStatLineSpacing => 3;

  @override double get durationBadgePaddingHorizontal => 5;
  @override double get durationBadgePaddingVertical => 2;
  @override double get durationBadgeBorderRadius => 4;
  @override double get durationBadgeFontSize => 10;
  @override double get durationBadgeGridFontSize => 9;

  @override double get dismissibleMarginBottom => 10;
  @override double get dismissibleBorderRadius => 14;
  @override double get dismissiblePaddingRight => 20;
  @override double get dismissibleIconSize => 24;
  @override double get dismissibleTextFontSize => 12;
  @override double get dismissibleSpacing => 4;

  @override double get dialogBorderRadius => 16;
  @override double get dialogTitleFontSize => 17;
  @override double get dialogContentFontSize => 14;
  @override double get dialogButtonWidth => 72;
  @override double get dialogButtonHeight => 36;
  @override double get dialogButtonFontSize => 14;

  @override double get emptyPaddingHorizontal => 32;
  @override double get emptyIconSize => 56;
  @override double get emptySpacingLarge => 16;
  @override double get emptySpacingSmall => 6;
  @override double get emptyTitleFontSize => 16;
  @override double get emptySubtitleFontSize => 13;

  @override double get noResultPaddingHorizontal => 32;
  @override double get noResultIconSize => 48;
  @override double get noResultSpacingLarge => 14;
  @override double get noResultSpacingSmall => 6;
  @override double get noResultTitleFontSize => 15;
  @override double get noResultSubtitleFontSize => 13;

  @override double get loadMorePaddingVertical => 20;
  @override double get loadMoreStrokeWidth => 2.5;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class ProfileActivityListTabletSizes extends ProfileActivityListSizes {
  const ProfileActivityListTabletSizes();

  @override bool get isTablet => true;

  @override double get appBarTitleSize => 22;
  @override double get appBarIconSize => 26;
  @override double get appBarIconPadding => 6;

  @override double get loadingStrokeWidth => 3.5;

  @override double get gridPaddingHorizontal => 20;
  @override double get gridPaddingVertical => 16;
  @override double get gridMainSpacing => 14;
  @override double get gridCrossSpacing => 14;
  @override double get gridChildAspectRatio => 0.7;

  @override double get listPaddingHorizontal => 20;
  @override double get listPaddingVertical => 16;
  @override double get listCardBottomMargin => 14;
  @override double get listCardBorderRadius => 16;
  @override double get listThumbnailWidth => 180;
  @override double get listThumbnailHeight => 100;
  @override double get listThumbnailRadius => 16;
  @override double get listThumbnailIconSize => 34;
  @override double get listContentPaddingLeft => 16;
  @override double get listContentPaddingTop => 12;
  @override double get listContentPaddingRight => 10;
  @override double get listContentPaddingBottom => 12;
  @override double get listTitleFontSize => 15;
  @override double get listTitleLineHeight => 1.4;
  @override double get listUniFontSize => 13;
  @override double get listDateFontSize => 13;
  @override double get listStatSpacing => 12;
  @override double get listStatIconSize => 15;
  @override double get listStatFontSize => 13;
  @override double get listChevronRight => 10;
  @override double get listChevronTop => 40;
  @override double get listChevronSize => 22;

  @override double get gridCardBorderRadius => 16;
  @override double get gridCardPaddingLeft => 10;
  @override double get gridCardPaddingTop => 10;
  @override double get gridCardPaddingRight => 10;
  @override double get gridCardPaddingBottom => 8;
  @override double get gridTitleFontSize => 14;
  @override double get gridTitleLineHeight => 1.35;
  @override double get gridUniFontSize => 12;
  @override double get gridUniPaddingTop => 5;
  @override double get gridStatIconSize => 13;
  @override double get gridStatFontSize => 12;
  @override double get gridStatSpacing => 10;
  @override double get gridStatLineSpacing => 4;

  @override double get durationBadgePaddingHorizontal => 6;
  @override double get durationBadgePaddingVertical => 3;
  @override double get durationBadgeBorderRadius => 5;
  @override double get durationBadgeFontSize => 12;
  @override double get durationBadgeGridFontSize => 10;

  @override double get dismissibleMarginBottom => 14;
  @override double get dismissibleBorderRadius => 16;
  @override double get dismissiblePaddingRight => 24;
  @override double get dismissibleIconSize => 28;
  @override double get dismissibleTextFontSize => 14;
  @override double get dismissibleSpacing => 5;

  @override double get dialogBorderRadius => 20;
  @override double get dialogTitleFontSize => 20;
  @override double get dialogContentFontSize => 16;
  @override double get dialogButtonWidth => 80;
  @override double get dialogButtonHeight => 40;
  @override double get dialogButtonFontSize => 16;

  @override double get emptyPaddingHorizontal => 40;
  @override double get emptyIconSize => 64;
  @override double get emptySpacingLarge => 20;
  @override double get emptySpacingSmall => 8;
  @override double get emptyTitleFontSize => 20;
  @override double get emptySubtitleFontSize => 15;

  @override double get noResultPaddingHorizontal => 40;
  @override double get noResultIconSize => 56;
  @override double get noResultSpacingLarge => 16;
  @override double get noResultSpacingSmall => 8;
  @override double get noResultTitleFontSize => 18;
  @override double get noResultSubtitleFontSize => 15;

  @override double get loadMorePaddingVertical => 24;
  @override double get loadMoreStrokeWidth => 3;
}
