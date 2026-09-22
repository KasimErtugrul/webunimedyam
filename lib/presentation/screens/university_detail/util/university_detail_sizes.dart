import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  double get appBarExpandedHeight => 240.h;
  @override
  double get appBarTitleSize => 16.sp;
  @override
  double get appBarLogoSize => 30.sp;
  @override
  double get appBarLogoIconSize => 18.sp;
  @override
  double get appBarActionIconSize => 26.sp;
  @override
  double get appBarActionPaddingRight => 8.w;
  @override
  double get appBarLeadingIconSize => 22.sp;

  @override
  double get headerTopPadding => 56.h;
  @override
  double get headerLogoOuterSize => 100.sp;
  @override
  double get headerLogoInnerSize => 78.sp;
  @override
  double get headerLogoPadding => 6.sp;
  @override
  double get headerLogoBorderWidth => 2.sp;
  @override
  double get headerLogoShadowBlur => 24.sp;
  @override
  double get headerLogoShadowSpread => 2.sp;
  @override
  double get headerNameFontSize => 19.sp;
  @override
  double get headerNameLineHeight => 1.3.sp;
  @override
  double get headerCitySpacing => 6.sp;
  @override
  double get headerCityFontSize => 13.sp;
  @override
  double get headerCityIconSize => 14.sp;
  @override
  double get headerCityIconSpacing => 3.sp;
  @override
  double get headerBadgeSpacing => 10.sp;
  @override
  double get headerBadgePaddingHorizontal => 12.w;
  @override
  double get headerBadgePaddingVertical => 4.h;
  @override
  double get headerBadgeBorderRadius => 20.r;
  @override
  double get headerBadgeIconSize => 12.sp;
  @override
  double get headerBadgeFontSize => 11.sp;
  @override
  double get headerPaddingHorizontal => 32.w;

  @override
  double get tabBarHeight => 48.h;
  @override
  double get tabBarIndicatorWeight => 2.5.sp;
  @override
  double get tabBarLabelFontSize => 14.sp;
  @override
  double get tabBarUnselectedLabelFontSize => 14.sp;

  @override
  double get aboutPaddingHorizontal => 16.w;
  @override
  double get aboutPaddingTop => 20.h;
  @override
  double get aboutPaddingBottom => 32.h;
  @override
  double get aboutSectionSpacing => 20.sp;
  @override
  double get aboutSectionTitleSpacing => 8.sp;
  @override
  double get aboutDescriptionFontSize => 13.sp;
  @override
  double get aboutDescriptionLineHeight => 1.6.sp;
  @override
  double get aboutCardPadding => 14.sp;
  @override
  double get aboutCardBorderRadius => 14.r;

  @override
  double get infoRowPaddingHorizontal => 14.w;
  @override
  double get infoRowPaddingVertical => 12.h;
  @override
  double get infoRowIconSize => 34.sp;
  @override
  double get infoRowIconRadius => 9.r;
  @override
  double get infoRowIconInnerSize => 17.sp;
  @override
  double get infoRowIconSpacing => 12.sp;
  @override
  double get infoRowLabelFontSize => 11.sp;
  @override
  double get infoRowValueFontSize => 13.sp;
  @override
  double get infoRowValueSpacing => 2.sp;

  @override
  double get linkButtonPaddingHorizontal => 14.w;
  @override
  double get linkButtonPaddingVertical => 12.h;
  @override
  double get linkButtonIconSize => 34.sp;
  @override
  double get linkButtonIconRadius => 9.r;
  @override
  double get linkButtonIconInnerSize => 17.sp;
  @override
  double get linkButtonIconSpacing => 12.sp;
  @override
  double get linkButtonLabelFontSize => 13.sp;
  @override
  double get linkButtonTrailingIconSize => 16.sp;

  @override
  double get radioCardPadding => 14.sp;
  @override
  double get radioCardBorderRadius => 14.r;
  @override
  double get radioIconContainerSize => 46.sp;
  @override
  double get radioIconContainerRadius => 12.r;
  @override
  double get radioIconSize => 22.sp;
  @override
  double get radioIconSpacing => 14.sp;
  @override
  double get radioTitleFontSize => 14.sp;
  @override
  double get radioSubtitleFontSize => 11.5.sp;
  @override
  double get radioPlayButtonSize => 44.sp;
  @override
  double get radioPlayButtonRadius => 24.r;
  @override
  double get radioPlayIconSize => 24.sp;
  @override
  double get radioWaveBarWidth => 3.w;
  @override
  double get radioWaveBarSpacing => 1.5.sp;
  @override
  double get radioWaveBarBorderRadius => 2.r;
  @override
  double get radioWaveBarMaxHeight => 20.h;
  @override
  double get radioWaveBarMinHeight => 6.h;
  @override
  double get radioWaveBarAlpha => 0.3; // birimsiz

  @override
  double get miniPlayerPaddingHorizontal => 16.w;
  @override
  double get miniPlayerPaddingVertical => 10.h;
  @override
  double get miniPlayerLogoSize => 42.sp;
  @override
  double get miniPlayerLogoRadius => 10.r;
  @override
  double get miniPlayerLogoSpacing => 12.sp;
  @override
  double get miniPlayerTitleFontSize => 13.sp;
  @override
  double get miniPlayerSubtitleFontSize => 11.sp;
  @override
  double get miniPlayerPlayIconSize => 36.sp;
  @override
  double get miniPlayerStopIconSize => 28.sp;
  @override
  double get miniPlayerLoadingSize => 20.sp;

  @override
  double get shortsCardHeight => 280.h;
  @override
  double get shortsCardRadius => 14.r;
  @override
  double get shortsTitleSize => 12.5.sp;
  @override
  double get shortsDescSize => 11.sp;
  @override
  double get shortsMetaSize => 10.sp;

  @override
  double get errorIconSize => 48.sp;
  @override
  double get errorSpacingLarge => 16.sp;
  @override
  double get errorSpacingSmall => 16.sp;
  @override
  double get errorFontSize => 14.sp;

  @override
  double get emptyIconContainerSize => 72.sp;
  @override
  double get emptyIconSize => 36.sp;
  @override
  double get emptySpacingLarge => 16.sp;
  @override
  double get emptySpacingSmall => 6.sp;
  @override
  double get emptyTitleFontSize => 16.sp;
  @override
  double get emptySubtitleFontSize => 13.sp;

  @override
  double get shimmerVideoHeight => 100.h;
  @override
  double get shimmerVideoBorderRadius => 16.r;

  @override
  double get sectionTitleFontSize => 15.sp;

  @override
  double get favButtonPaddingVertical => 13.h;
  @override
  double get favButtonBorderRadius => 14.r;
  @override
  double get favButtonIconSize => 18.sp;
  @override
  double get favButtonFontSize => 14.sp;
  @override
  double get favButtonLoadingSize => 16.sp;
}

// ==================== TABLET IMPLEMENTATION ====================
class UniversityDetailTabletSizes extends UniversityDetailSizes {
  const UniversityDetailTabletSizes();

  // ----- AppBar -----
  @override
  double get appBarExpandedHeight => 300.h;
  @override
  double get appBarTitleSize => 20.sp;
  @override
  double get appBarLogoSize => 36.sp;
  @override
  double get appBarLogoIconSize => 22.sp;
  @override
  double get appBarActionIconSize => 30.sp;
  @override
  double get appBarActionPaddingRight => 12.w;
  @override
  double get appBarLeadingIconSize => 26.sp;

  // ----- Header -----
  @override
  double get headerTopPadding => 70.h;
  @override
  double get headerLogoOuterSize => 130.sp;
  @override
  double get headerLogoInnerSize => 100.sp;
  @override
  double get headerLogoPadding => 8.sp;
  @override
  double get headerLogoBorderWidth => 2.5.sp;
  @override
  double get headerLogoShadowBlur => 30.sp;
  @override
  double get headerLogoShadowSpread => 3.sp;
  @override
  double get headerNameFontSize => 24.sp;
  @override
  double get headerNameLineHeight => 1.35.sp;
  @override
  double get headerCitySpacing => 8.sp;
  @override
  double get headerCityFontSize => 16.sp;
  @override
  double get headerCityIconSize => 18.sp;
  @override
  double get headerCityIconSpacing => 4.sp;
  @override
  double get headerBadgeSpacing => 14.sp;
  @override
  double get headerBadgePaddingHorizontal => 16.w;
  @override
  double get headerBadgePaddingVertical => 6.h;
  @override
  double get headerBadgeBorderRadius => 24.r;
  @override
  double get headerBadgeIconSize => 14.sp;
  @override
  double get headerBadgeFontSize => 13.sp;
  @override
  double get headerPaddingHorizontal => 48.w;

  // ----- TabBar -----
  @override
  double get tabBarHeight => 56.h;
  @override
  double get tabBarIndicatorWeight => 3.sp;
  @override
  double get tabBarLabelFontSize => 16.sp;
  @override
  double get tabBarUnselectedLabelFontSize => 16.sp;

  // ----- About Tab -----
  @override
  double get aboutPaddingHorizontal => 24.w;
  @override
  double get aboutPaddingTop => 28.h;
  @override
  double get aboutPaddingBottom => 40.h;
  @override
  double get aboutSectionSpacing => 24.sp;
  @override
  double get aboutSectionTitleSpacing => 10.sp;
  @override
  double get aboutDescriptionFontSize => 16.sp;
  @override
  double get aboutDescriptionLineHeight => 1.7.sp;
  @override
  double get aboutCardPadding => 18.sp;
  @override
  double get aboutCardBorderRadius => 16.r;

  // ----- Info Row -----
  @override
  double get infoRowPaddingHorizontal => 18.w;
  @override
  double get infoRowPaddingVertical => 16.h;
  @override
  double get infoRowIconSize => 42.sp;
  @override
  double get infoRowIconRadius => 11.r;
  @override
  double get infoRowIconInnerSize => 21.sp;
  @override
  double get infoRowIconSpacing => 16.sp;
  @override
  double get infoRowLabelFontSize => 13.sp;
  @override
  double get infoRowValueFontSize => 16.sp;
  @override
  double get infoRowValueSpacing => 3.sp;

  // ----- Link Button -----
  @override
  double get linkButtonPaddingHorizontal => 18.w;
  @override
  double get linkButtonPaddingVertical => 16.h;
  @override
  double get linkButtonIconSize => 42.sp;
  @override
  double get linkButtonIconRadius => 11.r;
  @override
  double get linkButtonIconInnerSize => 21.sp;
  @override
  double get linkButtonIconSpacing => 16.sp;
  @override
  double get linkButtonLabelFontSize => 16.sp;
  @override
  double get linkButtonTrailingIconSize => 20.sp;

  // ----- Radio Inline Card -----
  @override
  double get radioCardPadding => 18.sp;
  @override
  double get radioCardBorderRadius => 16.r;
  @override
  double get radioIconContainerSize => 56.sp;
  @override
  double get radioIconContainerRadius => 14.r;
  @override
  double get radioIconSize => 28.sp;
  @override
  double get radioIconSpacing => 18.sp;
  @override
  double get radioTitleFontSize => 16.sp;
  @override
  double get radioSubtitleFontSize => 13.sp;
  @override
  double get radioPlayButtonSize => 54.sp;
  @override
  double get radioPlayButtonRadius => 28.r;
  @override
  double get radioPlayIconSize => 28.sp;
  @override
  double get radioWaveBarWidth => 4.w;
  @override
  double get radioWaveBarSpacing => 2.sp;
  @override
  double get radioWaveBarBorderRadius => 3.r;
  @override
  double get radioWaveBarMaxHeight => 26.h;
  @override
  double get radioWaveBarMinHeight => 8.h;
  @override
  double get radioWaveBarAlpha => 0.3; // oransal

  // ----- Mini Player -----
  @override
  double get miniPlayerPaddingHorizontal => 24.w;
  @override
  double get miniPlayerPaddingVertical => 14.h;
  @override
  double get miniPlayerLogoSize => 50.sp;
  @override
  double get miniPlayerLogoRadius => 12.r;
  @override
  double get miniPlayerLogoSpacing => 16.sp;
  @override
  double get miniPlayerTitleFontSize => 16.sp;
  @override
  double get miniPlayerSubtitleFontSize => 13.sp;
  @override
  double get miniPlayerPlayIconSize => 42.sp;
  @override
  double get miniPlayerStopIconSize => 34.sp;
  @override
  double get miniPlayerLoadingSize => 24.sp;

  // ----- Shorts (abstract'teki mevcut getter'lar) -----
  // tablet listesinde shortsCardHeight yok, makul bir değer atanıyor
  @override
  double get shortsCardHeight => 320.h;
  @override
  double get shortsCardRadius => 16.r; // shortsCardBorderRadius ile eşleşir
  @override
  double get shortsTitleSize => 16.sp; // shortsTitleFontSize
  @override
  double get shortsDescSize => 13.sp; // shortsDescFontSize
  @override
  double get shortsMetaSize => 12.sp; // shortsMetaFontSize

  // ----- Error View -----
  @override
  double get errorIconSize => 56.sp;
  @override
  double get errorSpacingLarge => 20.sp;
  @override
  double get errorSpacingSmall => 20.sp;
  @override
  double get errorFontSize => 16.sp;

  // ----- Empty View -----
  @override
  double get emptyIconContainerSize => 88.sp;
  @override
  double get emptyIconSize => 44.sp;
  @override
  double get emptySpacingLarge => 20.sp;
  @override
  double get emptySpacingSmall => 8.sp;
  @override
  double get emptyTitleFontSize => 20.sp;
  @override
  double get emptySubtitleFontSize => 16.sp;

  // ----- Shimmer (abstract'tekiler) -----
  @override
  double get shimmerVideoHeight => 120.h;
  @override
  double get shimmerVideoBorderRadius => 18.r;

  // ----- Section Title -----
  @override
  double get sectionTitleFontSize => 18.sp;

  // ----- Favorite Button -----
  @override
  double get favButtonPaddingVertical => 16.h;
  @override
  double get favButtonBorderRadius => 16.r;
  @override
  double get favButtonIconSize => 22.sp;
  @override
  double get favButtonFontSize => 16.sp;
  @override
  double get favButtonLoadingSize => 20.sp;

  // ================================================
  //  TABLET'E ÖZGÜ EKSTRA GETTER'LAR (abstract'ta yok)
  // ================================================

  // Shorts List Card (detaylı)
  double get shortsCardPadding => 14.sp;
  double get shortsCardBorderRadius => 16.r;
  double get shortsThumbnailWidth => 88.w;
  double get shortsThumbnailHeight => 130.h;
  double get shortsThumbnailRadius => 12.r;
  double get shortsThumbnailSpacing => 16.sp;
  double get shortsTitleFontSize => 16.sp;
  double get shortsTitleLineHeight => 1.35.sp;
  double get shortsDescFontSize => 13.sp;
  double get shortsDescLineHeight => 1.35.sp;
  double get shortsMetaFontSize => 12.sp;
  double get shortsMetaSpacing => 14.sp;
  double get shortsBadgePaddingHorizontal => 8.w;
  double get shortsBadgePaddingVertical => 3.h;
  double get shortsBadgeBorderRadius => 5.r;
  double get shortsBadgeIconSize => 12.sp;
  double get shortsBadgeFontSize => 9.sp;
  double get shortsDurationChipPaddingHorizontal => 6.w;
  double get shortsDurationChipPaddingVertical => 3.h;
  double get shortsDurationChipBorderRadius => 5.r;
  double get shortsDurationChipFontSize => 10.sp;
  double get shortsPlayOverlaySize => 36.sp;
  double get shortsPlayIconSize => 22.sp;

  // Shimmer (tablet'e özel)
  double get shimmerShortsHeight => 150.h;
  double get shimmerShortsBorderRadius => 16.r;
}
