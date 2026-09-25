abstract class UniversityDetailSizes {
  const UniversityDetailSizes();
  double get appBarExpandedHeight;
  double get appBarTitleSize;
  double get appBarLogoSize;
  double get appBarLogoIconSize;
  double get appBarActionIconSize;
  double get appBarActionPaddingRight;
  double get appBarLeadingIconSize;

  // Header
  double get headerTopPadding;
  double get headerLogoOuterSize;
  double get headerLogoInnerSize;
  double get headerLogoPadding;
  double get headerLogoBorderWidth;
  double get headerLogoShadowBlur;
  double get headerLogoShadowSpread;
  double get headerNameFontSize;
  double get headerNameLineHeight;
  double get headerCitySpacing;
  double get headerCityFontSize;
  double get headerCityIconSize;
  double get headerCityIconSpacing;
  double get headerBadgeSpacing;
  double get headerBadgePaddingHorizontal;
  double get headerBadgePaddingVertical;
  double get headerBadgeBorderRadius;
  double get headerBadgeIconSize;
  double get headerBadgeFontSize;
  double get headerPaddingHorizontal;

  // TabBar
  double get tabBarHeight;
  double get tabBarIndicatorWeight;
  double get tabBarLabelFontSize;
  double get tabBarUnselectedLabelFontSize;

  // About Tab
  double get aboutPaddingHorizontal;
  double get aboutPaddingTop;
  double get aboutPaddingBottom;
  double get aboutSectionSpacing;
  double get aboutSectionTitleSpacing;
  double get aboutDescriptionFontSize;
  double get aboutDescriptionLineHeight;
  double get aboutCardPadding;
  double get aboutCardBorderRadius;

  // Info Row
  double get infoRowPaddingHorizontal;
  double get infoRowPaddingVertical;
  double get infoRowIconSize;
  double get infoRowIconRadius;
  double get infoRowIconInnerSize;
  double get infoRowIconSpacing;
  double get infoRowLabelFontSize;
  double get infoRowValueFontSize;
  double get infoRowValueSpacing;

  // Link Button
  double get linkButtonPaddingHorizontal;
  double get linkButtonPaddingVertical;
  double get linkButtonIconSize;
  double get linkButtonIconRadius;
  double get linkButtonIconInnerSize;
  double get linkButtonIconSpacing;
  double get linkButtonLabelFontSize;
  double get linkButtonTrailingIconSize;

  // Radio Inline Card
  double get radioCardPadding;
  double get radioCardBorderRadius;
  double get radioIconContainerSize;
  double get radioIconContainerRadius;
  double get radioIconSize;
  double get radioIconSpacing;
  double get radioTitleFontSize;
  double get radioSubtitleFontSize;
  double get radioPlayButtonSize;
  double get radioPlayButtonRadius;
  double get radioPlayIconSize;
  double get radioWaveBarWidth;
  double get radioWaveBarSpacing;
  double get radioWaveBarBorderRadius;
  double get radioWaveBarMaxHeight;
  double get radioWaveBarMinHeight;
  double get radioWaveBarAlpha;

  // Mini Player
  double get miniPlayerPaddingHorizontal;
  double get miniPlayerPaddingVertical;
  double get miniPlayerLogoSize;
  double get miniPlayerLogoRadius;
  double get miniPlayerLogoSpacing;
  double get miniPlayerTitleFontSize;
  double get miniPlayerSubtitleFontSize;
  double get miniPlayerPlayIconSize;
  double get miniPlayerStopIconSize;
  double get miniPlayerLoadingSize;

  // Shorts Grid Card (yeni tasarım)
  double get shortsCardHeight;
  double get shortsCardRadius;
  double get shortsTitleSize;
  double get shortsDescSize;
  double get shortsMetaSize;

  // Error View
  double get errorIconSize;
  double get errorSpacingLarge;
  double get errorSpacingSmall;
  double get errorFontSize;

  // Empty View
  double get emptyIconContainerSize;
  double get emptyIconSize;
  double get emptySpacingLarge;
  double get emptySpacingSmall;
  double get emptyTitleFontSize;
  double get emptySubtitleFontSize;

  // Shimmer
  double get shimmerVideoHeight;
  double get shimmerVideoBorderRadius;

  // Section Title
  double get sectionTitleFontSize;

  // Favorite Button
  double get favButtonPaddingVertical;
  double get favButtonBorderRadius;
  double get favButtonIconSize;
  double get favButtonFontSize;
  double get favButtonLoadingSize;
}

// ==================== PHONE IMPLEMENTATION ====================
class UniversityDetailPhoneSizes extends UniversityDetailSizes {
  const UniversityDetailPhoneSizes();

  @override
  double get appBarExpandedHeight => 240;
  @override
  double get appBarTitleSize => 16;
  @override
  double get appBarLogoSize => 30;
  @override
  double get appBarLogoIconSize => 18;
  @override
  double get appBarActionIconSize => 26;
  @override
  double get appBarActionPaddingRight => 8;
  @override
  double get appBarLeadingIconSize => 22;

  @override
  double get headerTopPadding => 56;
  @override
  double get headerLogoOuterSize => 100;
  @override
  double get headerLogoInnerSize => 78;
  @override
  double get headerLogoPadding => 6;
  @override
  double get headerLogoBorderWidth => 2;
  @override
  double get headerLogoShadowBlur => 24;
  @override
  double get headerLogoShadowSpread => 2;
  @override
  double get headerNameFontSize => 19;
  @override
  double get headerNameLineHeight => 1.3;
  @override
  double get headerCitySpacing => 6;
  @override
  double get headerCityFontSize => 13;
  @override
  double get headerCityIconSize => 14;
  @override
  double get headerCityIconSpacing => 3;
  @override
  double get headerBadgeSpacing => 10;
  @override
  double get headerBadgePaddingHorizontal => 12;
  @override
  double get headerBadgePaddingVertical => 4;
  @override
  double get headerBadgeBorderRadius => 20;
  @override
  double get headerBadgeIconSize => 12;
  @override
  double get headerBadgeFontSize => 11;
  @override
  double get headerPaddingHorizontal => 32;

  @override
  double get tabBarHeight => 48;
  @override
  double get tabBarIndicatorWeight => 2.5;
  @override
  double get tabBarLabelFontSize => 14;
  @override
  double get tabBarUnselectedLabelFontSize => 14;

  @override
  double get aboutPaddingHorizontal => 16;
  @override
  double get aboutPaddingTop => 20;
  @override
  double get aboutPaddingBottom => 32;
  @override
  double get aboutSectionSpacing => 20;
  @override
  double get aboutSectionTitleSpacing => 8;
  @override
  double get aboutDescriptionFontSize => 13;
  @override
  double get aboutDescriptionLineHeight => 1.6;
  @override
  double get aboutCardPadding => 14;
  @override
  double get aboutCardBorderRadius => 14;

  @override
  double get infoRowPaddingHorizontal => 14;
  @override
  double get infoRowPaddingVertical => 12;
  @override
  double get infoRowIconSize => 34;
  @override
  double get infoRowIconRadius => 9;
  @override
  double get infoRowIconInnerSize => 17;
  @override
  double get infoRowIconSpacing => 12;
  @override
  double get infoRowLabelFontSize => 11;
  @override
  double get infoRowValueFontSize => 13;
  @override
  double get infoRowValueSpacing => 2;

  @override
  double get linkButtonPaddingHorizontal => 14;
  @override
  double get linkButtonPaddingVertical => 12;
  @override
  double get linkButtonIconSize => 34;
  @override
  double get linkButtonIconRadius => 9;
  @override
  double get linkButtonIconInnerSize => 17;
  @override
  double get linkButtonIconSpacing => 12;
  @override
  double get linkButtonLabelFontSize => 13;
  @override
  double get linkButtonTrailingIconSize => 16;

  @override
  double get radioCardPadding => 14;
  @override
  double get radioCardBorderRadius => 14;
  @override
  double get radioIconContainerSize => 46;
  @override
  double get radioIconContainerRadius => 12;
  @override
  double get radioIconSize => 22;
  @override
  double get radioIconSpacing => 14;
  @override
  double get radioTitleFontSize => 14;
  @override
  double get radioSubtitleFontSize => 11.5;
  @override
  double get radioPlayButtonSize => 44;
  @override
  double get radioPlayButtonRadius => 24;
  @override
  double get radioPlayIconSize => 24;
  @override
  double get radioWaveBarWidth => 3;
  @override
  double get radioWaveBarSpacing => 1.5;
  @override
  double get radioWaveBarBorderRadius => 2;
  @override
  double get radioWaveBarMaxHeight => 20;
  @override
  double get radioWaveBarMinHeight => 6;
  @override
  double get radioWaveBarAlpha => 0.3; // birimsiz

  @override
  double get miniPlayerPaddingHorizontal => 16;
  @override
  double get miniPlayerPaddingVertical => 10;
  @override
  double get miniPlayerLogoSize => 42;
  @override
  double get miniPlayerLogoRadius => 10;
  @override
  double get miniPlayerLogoSpacing => 12;
  @override
  double get miniPlayerTitleFontSize => 13;
  @override
  double get miniPlayerSubtitleFontSize => 11;
  @override
  double get miniPlayerPlayIconSize => 36;
  @override
  double get miniPlayerStopIconSize => 28;
  @override
  double get miniPlayerLoadingSize => 20;

  @override
  double get shortsCardHeight => 280;
  @override
  double get shortsCardRadius => 14;
  @override
  double get shortsTitleSize => 12.5;
  @override
  double get shortsDescSize => 11;
  @override
  double get shortsMetaSize => 10;

  @override
  double get errorIconSize => 48;
  @override
  double get errorSpacingLarge => 16;
  @override
  double get errorSpacingSmall => 16;
  @override
  double get errorFontSize => 14;

  @override
  double get emptyIconContainerSize => 72;
  @override
  double get emptyIconSize => 36;
  @override
  double get emptySpacingLarge => 16;
  @override
  double get emptySpacingSmall => 6;
  @override
  double get emptyTitleFontSize => 16;
  @override
  double get emptySubtitleFontSize => 13;

  @override
  double get shimmerVideoHeight => 100;
  @override
  double get shimmerVideoBorderRadius => 16;

  @override
  double get sectionTitleFontSize => 15;

  @override
  double get favButtonPaddingVertical => 13;
  @override
  double get favButtonBorderRadius => 14;
  @override
  double get favButtonIconSize => 18;
  @override
  double get favButtonFontSize => 14;
  @override
  double get favButtonLoadingSize => 16;
}

// ==================== TABLET IMPLEMENTATION ====================
class UniversityDetailTabletSizes extends UniversityDetailSizes {
  const UniversityDetailTabletSizes();

  // ----- AppBar -----
  @override
  double get appBarExpandedHeight => 300;
  @override
  double get appBarTitleSize => 20;
  @override
  double get appBarLogoSize => 36;
  @override
  double get appBarLogoIconSize => 22;
  @override
  double get appBarActionIconSize => 30;
  @override
  double get appBarActionPaddingRight => 12;
  @override
  double get appBarLeadingIconSize => 26;

  // ----- Header -----
  @override
  double get headerTopPadding => 70;
  @override
  double get headerLogoOuterSize => 130;
  @override
  double get headerLogoInnerSize => 100;
  @override
  double get headerLogoPadding => 8;
  @override
  double get headerLogoBorderWidth => 2.5;
  @override
  double get headerLogoShadowBlur => 30;
  @override
  double get headerLogoShadowSpread => 3;
  @override
  double get headerNameFontSize => 24;
  @override
  double get headerNameLineHeight => 1.35;
  @override
  double get headerCitySpacing => 8;
  @override
  double get headerCityFontSize => 16;
  @override
  double get headerCityIconSize => 18;
  @override
  double get headerCityIconSpacing => 4;
  @override
  double get headerBadgeSpacing => 14;
  @override
  double get headerBadgePaddingHorizontal => 16;
  @override
  double get headerBadgePaddingVertical => 6;
  @override
  double get headerBadgeBorderRadius => 24;
  @override
  double get headerBadgeIconSize => 14;
  @override
  double get headerBadgeFontSize => 13;
  @override
  double get headerPaddingHorizontal => 48;

  // ----- TabBar -----
  @override
  double get tabBarHeight => 56;
  @override
  double get tabBarIndicatorWeight => 3;
  @override
  double get tabBarLabelFontSize => 16;
  @override
  double get tabBarUnselectedLabelFontSize => 16;

  // ----- About Tab -----
  @override
  double get aboutPaddingHorizontal => 24;
  @override
  double get aboutPaddingTop => 28;
  @override
  double get aboutPaddingBottom => 40;
  @override
  double get aboutSectionSpacing => 24;
  @override
  double get aboutSectionTitleSpacing => 10;
  @override
  double get aboutDescriptionFontSize => 16;
  @override
  double get aboutDescriptionLineHeight => 1.7;
  @override
  double get aboutCardPadding => 18;
  @override
  double get aboutCardBorderRadius => 16;

  // ----- Info Row -----
  @override
  double get infoRowPaddingHorizontal => 18;
  @override
  double get infoRowPaddingVertical => 16;
  @override
  double get infoRowIconSize => 42;
  @override
  double get infoRowIconRadius => 11;
  @override
  double get infoRowIconInnerSize => 21;
  @override
  double get infoRowIconSpacing => 16;
  @override
  double get infoRowLabelFontSize => 13;
  @override
  double get infoRowValueFontSize => 16;
  @override
  double get infoRowValueSpacing => 3;

  // ----- Link Button -----
  @override
  double get linkButtonPaddingHorizontal => 18;
  @override
  double get linkButtonPaddingVertical => 16;
  @override
  double get linkButtonIconSize => 42;
  @override
  double get linkButtonIconRadius => 11;
  @override
  double get linkButtonIconInnerSize => 21;
  @override
  double get linkButtonIconSpacing => 16;
  @override
  double get linkButtonLabelFontSize => 16;
  @override
  double get linkButtonTrailingIconSize => 20;

  // ----- Radio Inline Card -----
  @override
  double get radioCardPadding => 18;
  @override
  double get radioCardBorderRadius => 16;
  @override
  double get radioIconContainerSize => 56;
  @override
  double get radioIconContainerRadius => 14;
  @override
  double get radioIconSize => 28;
  @override
  double get radioIconSpacing => 18;
  @override
  double get radioTitleFontSize => 16;
  @override
  double get radioSubtitleFontSize => 13;
  @override
  double get radioPlayButtonSize => 54;
  @override
  double get radioPlayButtonRadius => 28;
  @override
  double get radioPlayIconSize => 28;
  @override
  double get radioWaveBarWidth => 4;
  @override
  double get radioWaveBarSpacing => 2;
  @override
  double get radioWaveBarBorderRadius => 3;
  @override
  double get radioWaveBarMaxHeight => 26;
  @override
  double get radioWaveBarMinHeight => 8;
  @override
  double get radioWaveBarAlpha => 0.3; // oransal

  // ----- Mini Player -----
  @override
  double get miniPlayerPaddingHorizontal => 24;
  @override
  double get miniPlayerPaddingVertical => 14;
  @override
  double get miniPlayerLogoSize => 50;
  @override
  double get miniPlayerLogoRadius => 12;
  @override
  double get miniPlayerLogoSpacing => 16;
  @override
  double get miniPlayerTitleFontSize => 16;
  @override
  double get miniPlayerSubtitleFontSize => 13;
  @override
  double get miniPlayerPlayIconSize => 42;
  @override
  double get miniPlayerStopIconSize => 34;
  @override
  double get miniPlayerLoadingSize => 24;

  // ----- Shorts (abstract'teki mevcut getter'lar) -----
  // tablet listesinde shortsCardHeight yok, makul bir değer atanıyor
  @override
  double get shortsCardHeight => 320;
  @override
  double get shortsCardRadius => 16; // shortsCardBorderRadius ile eşleşir
  @override
  double get shortsTitleSize => 16; // shortsTitleFontSize
  @override
  double get shortsDescSize => 13; // shortsDescFontSize
  @override
  double get shortsMetaSize => 12; // shortsMetaFontSize

  // ----- Error View -----
  @override
  double get errorIconSize => 56;
  @override
  double get errorSpacingLarge => 20;
  @override
  double get errorSpacingSmall => 20;
  @override
  double get errorFontSize => 16;

  // ----- Empty View -----
  @override
  double get emptyIconContainerSize => 88;
  @override
  double get emptyIconSize => 44;
  @override
  double get emptySpacingLarge => 20;
  @override
  double get emptySpacingSmall => 8;
  @override
  double get emptyTitleFontSize => 20;
  @override
  double get emptySubtitleFontSize => 16;

  // ----- Shimmer (abstract'tekiler) -----
  @override
  double get shimmerVideoHeight => 120;
  @override
  double get shimmerVideoBorderRadius => 18;

  // ----- Section Title -----
  @override
  double get sectionTitleFontSize => 18;

  // ----- Favorite Button -----
  @override
  double get favButtonPaddingVertical => 16;
  @override
  double get favButtonBorderRadius => 16;
  @override
  double get favButtonIconSize => 22;
  @override
  double get favButtonFontSize => 16;
  @override
  double get favButtonLoadingSize => 20;

  // ================================================
  //  TABLET'E ÖZGÜ EKSTRA GETTER'LAR (abstract'ta yok)
  // ================================================

  // Shorts List Card (detaylı)
  double get shortsCardPadding => 14;
  double get shortsCardBorderRadius => 16;
  double get shortsThumbnailWidth => 88;
  double get shortsThumbnailHeight => 130;
  double get shortsThumbnailRadius => 12;
  double get shortsThumbnailSpacing => 16;
  double get shortsTitleFontSize => 16;
  double get shortsTitleLineHeight => 1.35;
  double get shortsDescFontSize => 13;
  double get shortsDescLineHeight => 1.35;
  double get shortsMetaFontSize => 12;
  double get shortsMetaSpacing => 14;
  double get shortsBadgePaddingHorizontal => 8;
  double get shortsBadgePaddingVertical => 3;
  double get shortsBadgeBorderRadius => 5;
  double get shortsBadgeIconSize => 12;
  double get shortsBadgeFontSize => 9;
  double get shortsDurationChipPaddingHorizontal => 6;
  double get shortsDurationChipPaddingVertical => 3;
  double get shortsDurationChipBorderRadius => 5;
  double get shortsDurationChipFontSize => 10;
  double get shortsPlayOverlaySize => 36;
  double get shortsPlayIconSize => 22;

  // Shimmer (tablet'e özel)
  double get shimmerShortsHeight => 150;
  double get shimmerShortsBorderRadius => 16;
}
