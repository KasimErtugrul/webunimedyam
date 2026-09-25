/* // ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════


abstract class SettingsSizes {
  const SettingsSizes();

  bool get isTablet;

  // Padding
  double get listBottomPadding;
  double get sectionHeaderPaddingLeft;
  double get sectionHeaderPaddingTop;
  double get sectionHeaderPaddingRight;
  double get sectionHeaderPaddingBottom;
  double get sectionHeaderFontSize;
  double get sectionHeaderLetterSpacing;
  double get tileContentPaddingHorizontal;

  // Divider
  double get dividerHeight;
  double get dividerThickness;

  // Settings Tile
  double get tileIconSize;
  double get tileTitleFontSize;
  double get tileSubtitleFontSize;
  double get tileTrailingIconSize;

  // SwitchListTile
  double get switchTitleFontSize;
  double get switchSubtitleFontSize;
  double get switchIconSize;

  // Visibility Tile
  double get visIconSize;
  double get visTitleFontSize;
  double get visSubtitleFontSize;
  double get visBadgePaddingHorizontal;
  double get visBadgePaddingVertical;
  double get visBadgeBorderRadius;
  double get visBadgeBorderWidth;
  double get visBadgeIconSize;
  double get visBadgeFontSize;
  double get visTrailingChevronSize;
  double get visTrailingSpacing;

  // Visibility Bottom Sheet
  double get sheetBorderRadius;
  double get sheetHandleWidth;
  double get sheetHandleHeight;
  double get sheetHandleBorderRadius;
  double get sheetHandleSpacing;
  double get sheetTitleFontSize;
  double get sheetSubtitleFontSize;
  double get sheetOptionSpacing;
  double get sheetBottomPadding;
  double get sheetOptionLeadingContainerSize;
  double get sheetOptionLeadingBorderRadius;
  double get sheetOptionLeadingIconSize;
  double get sheetOptionTitleFontSize;
  double get sheetOptionSubtitleFontSize;
  double get sheetOptionTrailingIconSize;
  double get sheetOptionTrailingLockSize;

  // Visibility Option Row (disabled)
  double get disabledOpacity;

  // Ceiling Note
  double get noteMarginLeft;
  double get noteMarginTop;
  double get noteMarginRight;
  double get noteMarginBottom;
  double get notePaddingHorizontal;
  double get notePaddingVertical;
  double get noteBorderRadius;
  double get noteBorderWidth;
  double get noteIconSize;
  double get noteIconSpacing;
  double get noteFontSize;
  double get noteLineHeight;

  // Theme Dialog
  double get dialogTitleFontSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class SettingsPhoneSizes extends SettingsSizes {
  const SettingsPhoneSizes();

  @override
  bool get isTablet => false;

  @override double get listBottomPadding => 32.h;
  @override double get sectionHeaderPaddingLeft => 16.w;
  @override double get sectionHeaderPaddingTop => 16.h;
  @override double get sectionHeaderPaddingRight => 16.w;
  @override double get sectionHeaderPaddingBottom => 4.h;
  @override double get sectionHeaderFontSize => 11.sp;
  @override double get sectionHeaderLetterSpacing => 1.2;
  @override double get tileContentPaddingHorizontal => 16.w;

  @override double get dividerHeight => 8.h;
  @override double get dividerThickness => 0.5;

  @override double get tileIconSize => 24.sp;
  @override double get tileTitleFontSize => 16.sp;
  @override double get tileSubtitleFontSize => 13.sp;
  @override double get tileTrailingIconSize => 20.sp;

  @override double get switchTitleFontSize => 16.sp;
  @override double get switchSubtitleFontSize => 13.sp;
  @override double get switchIconSize => 24.sp;

  @override double get visIconSize => 24.sp;
  @override double get visTitleFontSize => 16.sp;
  @override double get visSubtitleFontSize => 13.sp;
  @override double get visBadgePaddingHorizontal => 8.w;
  @override double get visBadgePaddingVertical => 4.h;
  @override double get visBadgeBorderRadius => 12.r;
  @override double get visBadgeBorderWidth => 0.5;
  @override double get visBadgeIconSize => 12.sp;
  @override double get visBadgeFontSize => 11.sp;
  @override double get visTrailingChevronSize => 20.sp;
  @override double get visTrailingSpacing => 4.w;

  @override double get sheetBorderRadius => 16.r;
  @override double get sheetHandleWidth => 40.w;
  @override double get sheetHandleHeight => 4.h;
  @override double get sheetHandleBorderRadius => 2.r;
  @override double get sheetHandleSpacing => 8.h;
  @override double get sheetTitleFontSize => 17.sp;
  @override double get sheetSubtitleFontSize => 13.sp;
  @override double get sheetOptionSpacing => 12.h;
  @override double get sheetBottomPadding => 16.h;
  @override double get sheetOptionLeadingContainerSize => 36.w;
  @override double get sheetOptionLeadingBorderRadius => 8.r;
  @override double get sheetOptionLeadingIconSize => 20.sp;
  @override double get sheetOptionTitleFontSize => 15.sp;
  @override double get sheetOptionSubtitleFontSize => 12.sp;
  @override double get sheetOptionTrailingIconSize => 20.sp;
  @override double get sheetOptionTrailingLockSize => 16.sp;

  @override double get disabledOpacity => 0.35;

  @override double get noteMarginLeft => 16.w;
  @override double get noteMarginTop => 6.h;
  @override double get noteMarginRight => 16.w;
  @override double get noteMarginBottom => 2.h;
  @override double get notePaddingHorizontal => 12.w;
  @override double get notePaddingVertical => 9.h;
  @override double get noteBorderRadius => 10.r;
  @override double get noteBorderWidth => 0.8;
  @override double get noteIconSize => 15.sp;
  @override double get noteIconSpacing => 8.w;
  @override double get noteFontSize => 12.sp;
  @override double get noteLineHeight => 1.45;

  @override double get dialogTitleFontSize => 16.sp;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class SettingsTabletSizes extends SettingsSizes {
  const SettingsTabletSizes();

  @override
  bool get isTablet => true;

  @override double get listBottomPadding => 40;
  @override double get sectionHeaderPaddingLeft => 24;
  @override double get sectionHeaderPaddingTop => 20;
  @override double get sectionHeaderPaddingRight => 24;
  @override double get sectionHeaderPaddingBottom => 6;
  @override double get sectionHeaderFontSize => 14;
  @override double get sectionHeaderLetterSpacing => 1.4;
  @override double get tileContentPaddingHorizontal => 24;

  @override double get dividerHeight => 10;
  @override double get dividerThickness => 0.6;

  @override double get tileIconSize => 28;
  @override double get tileTitleFontSize => 18;
  @override double get tileSubtitleFontSize => 15;
  @override double get tileTrailingIconSize => 24;

  @override double get switchTitleFontSize => 18;
  @override double get switchSubtitleFontSize => 15;
  @override double get switchIconSize => 28;

  @override double get visIconSize => 28;
  @override double get visTitleFontSize => 18;
  @override double get visSubtitleFontSize => 15;
  @override double get visBadgePaddingHorizontal => 10;
  @override double get visBadgePaddingVertical => 5;
  @override double get visBadgeBorderRadius => 14;
  @override double get visBadgeBorderWidth => 0.6;
  @override double get visBadgeIconSize => 14;
  @override double get visBadgeFontSize => 13;
  @override double get visTrailingChevronSize => 24;
  @override double get visTrailingSpacing => 6;

  @override double get sheetBorderRadius => 20;
  @override double get sheetHandleWidth => 48;
  @override double get sheetHandleHeight => 5;
  @override double get sheetHandleBorderRadius => 3;
  @override double get sheetHandleSpacing => 10;
  @override double get sheetTitleFontSize => 20;
  @override double get sheetSubtitleFontSize => 15;
  @override double get sheetOptionSpacing => 14;
  @override double get sheetBottomPadding => 20;
  @override double get sheetOptionLeadingContainerSize => 44;
  @override double get sheetOptionLeadingBorderRadius => 10;
  @override double get sheetOptionLeadingIconSize => 24;
  @override double get sheetOptionTitleFontSize => 17;
  @override double get sheetOptionSubtitleFontSize => 14;
  @override double get sheetOptionTrailingIconSize => 24;
  @override double get sheetOptionTrailingLockSize => 18;

  @override double get disabledOpacity => 0.35;

  @override double get noteMarginLeft => 24;
  @override double get noteMarginTop => 8;
  @override double get noteMarginRight => 24;
  @override double get noteMarginBottom => 4;
  @override double get notePaddingHorizontal => 16;
  @override double get notePaddingVertical => 12;
  @override double get noteBorderRadius => 12;
  @override double get noteBorderWidth => 1;
  @override double get noteIconSize => 18;
  @override double get noteIconSpacing => 10;
  @override double get noteFontSize => 14;
  @override double get noteLineHeight => 1.5;

  @override double get dialogTitleFontSize => 18;
} */