// lib/presentation/screens/university_detail/university_detail_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../core/responsive.dart';

@immutable
class UniversityDetailLayoutSpec {
  final bool isTablet;

  /// WEB ölçeği bayrağı — yalnızca UniversityDetailWebLayoutSpec true döner.
  bool get isWeb => false;

  // AppBar
  final double appBarExpandedHeight;
  final double appBarTitleFontSize;
  final double appBarLogoSize;
  final double appBarLogoIconSize;
  final double appBarActionIconSize;
  final double appBarLeadingIconSize;

  // Tab bar
  final double tabBarHeight;
  final double tabBarFontSize;
  final double tabBarIndicatorWeight;
  final double tabBarHPadding;
  final double tabBarRadius;

  // Header
  final double headerTopPadding;
  final double headerLogoOuter;
  final double headerLogoInner;
  final double headerLogoPadding;
  final double headerNameFontSize;
  final double headerNameLineHeight;
  final double headerCityFontSize;
  final double headerBadgeFontSize;
  final double headerBadgePaddingH;
  final double headerBadgePaddingV;

  // Content (about)
  final double contentPaddingH;
  final double contentPaddingTop;
  final double contentPaddingBottom;
  final double sectionSpacing;
  final double sectionTitleFontSize;

  // Card
  final double cardRadius;
  final double cardPadding;

  // Info / link rows
  final double rowIconBoxSize;
  final double rowIconBoxRadius;
  final double rowIconSize;
  final double rowIconSpacing;
  final double rowPaddingH;
  final double rowPaddingV;
  final double rowLabelFontSize;
  final double rowValueFontSize;
  final double rowValueSpacing;

  // Description
  final double descFontSize;
  final double descLineHeight;

  // Favorite button
  final double favButtonHeight;
  final double favButtonRadius;
  final double favButtonFontSize;
  final double favButtonIconSize;

  // Radio card
  final double radioCardRadius;
  final double radioIconBox;
  final double radioIconBoxRadius;
  final double radioIconSize;
  final double radioTitleFontSize;
  final double radioSubtitleFontSize;
  final double radioPlayBtnSize;
  final double radioPlayIconSize;

  // Mini player
  final double miniPaddingH;
  final double miniPaddingV;
  final double miniLogoSize;
  final double miniLogoRadius;
  final double miniTitleFontSize;
  final double miniSubtitleFontSize;
  final double miniPlayIconSize;
  final double miniStopIconSize;

  // Shorts
  final double shortsGridExtent;
  final double shortsCardRadius;
  final double shortsTitleFontSize;
  final double shortsDescFontSize;
  final double shortsMetaFontSize;
  final double shortsThumbW;
  final double shortsThumbH;
  final double shortsPlayOverlay;
  final double shortsPlayIcon;

  // Shimmer
  final double shimmerListHeight;
  final double shimmerRadius;

  // State views
  final double stateIconBox;
  final double stateIconSize;
  final double stateTitleFontSize;
  final double stateSubtitleFontSize;

  // Grid
  final double gridPaddingH;
  final double gridPaddingV;
  final double gridSpacing;
  final double gridAspectRatio;

  const UniversityDetailLayoutSpec._({
    required this.isTablet,
    required this.appBarExpandedHeight,
    required this.appBarTitleFontSize,
    required this.appBarLogoSize,
    required this.appBarLogoIconSize,
    required this.appBarActionIconSize,
    required this.appBarLeadingIconSize,
    required this.tabBarHeight,
    required this.tabBarFontSize,
    required this.tabBarIndicatorWeight,
    required this.tabBarHPadding,
    required this.tabBarRadius,
    required this.headerTopPadding,
    required this.headerLogoOuter,
    required this.headerLogoInner,
    required this.headerLogoPadding,
    required this.headerNameFontSize,
    required this.headerNameLineHeight,
    required this.headerCityFontSize,
    required this.headerBadgeFontSize,
    required this.headerBadgePaddingH,
    required this.headerBadgePaddingV,
    required this.contentPaddingH,
    required this.contentPaddingTop,
    required this.contentPaddingBottom,
    required this.sectionSpacing,
    required this.sectionTitleFontSize,
    required this.cardRadius,
    required this.cardPadding,
    required this.rowIconBoxSize,
    required this.rowIconBoxRadius,
    required this.rowIconSize,
    required this.rowIconSpacing,
    required this.rowPaddingH,
    required this.rowPaddingV,
    required this.rowLabelFontSize,
    required this.rowValueFontSize,
    required this.rowValueSpacing,
    required this.descFontSize,
    required this.descLineHeight,
    required this.favButtonHeight,
    required this.favButtonRadius,
    required this.favButtonFontSize,
    required this.favButtonIconSize,
    required this.radioCardRadius,
    required this.radioIconBox,
    required this.radioIconBoxRadius,
    required this.radioIconSize,
    required this.radioTitleFontSize,
    required this.radioSubtitleFontSize,
    required this.radioPlayBtnSize,
    required this.radioPlayIconSize,
    required this.miniPaddingH,
    required this.miniPaddingV,
    required this.miniLogoSize,
    required this.miniLogoRadius,
    required this.miniTitleFontSize,
    required this.miniSubtitleFontSize,
    required this.miniPlayIconSize,
    required this.miniStopIconSize,
    required this.shortsGridExtent,
    required this.shortsCardRadius,
    required this.shortsTitleFontSize,
    required this.shortsDescFontSize,
    required this.shortsMetaFontSize,
    required this.shortsThumbW,
    required this.shortsThumbH,
    required this.shortsPlayOverlay,
    required this.shortsPlayIcon,
    required this.shimmerListHeight,
    required this.shimmerRadius,
    required this.stateIconBox,
    required this.stateIconSize,
    required this.stateTitleFontSize,
    required this.stateSubtitleFontSize,
    required this.gridPaddingH,
    required this.gridPaddingV,
    required this.gridSpacing,
    required this.gridAspectRatio,
  });

  factory UniversityDetailLayoutSpec.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet yerleşimini temel alır.
    if (Responsive.isWeb(context)) {
      return const UniversityDetailWebLayoutSpec._();
    }
    if (Responsive.isTablet(context)) {
      return const UniversityDetailLayoutSpec._(
        isTablet: true,
        appBarExpandedHeight: 350,
        appBarTitleFontSize: 20,
        appBarLogoSize: 36,
        appBarLogoIconSize: 22,
        appBarActionIconSize: 30,
        appBarLeadingIconSize: 26,
        tabBarHeight: 60,
        tabBarFontSize: 15,
        tabBarIndicatorWeight: 3,
        tabBarHPadding: 12,
        tabBarRadius: 16,
        headerTopPadding: 70,
        headerLogoOuter: 140,
        headerLogoInner: 104,
        headerLogoPadding: 8,
        headerNameFontSize: 24,
        headerNameLineHeight: 1.35,
        headerCityFontSize: 15,
        headerBadgeFontSize: 12,
        headerBadgePaddingH: 14,
        headerBadgePaddingV: 6,
        contentPaddingH: 24,
        contentPaddingTop: 24,
        contentPaddingBottom: 40,
        sectionSpacing: 24,
        sectionTitleFontSize: 17,
        cardRadius: 16,
        cardPadding: 18,
        rowIconBoxSize: 42,
        rowIconBoxRadius: 11,
        rowIconSize: 21,
        rowIconSpacing: 16,
        rowPaddingH: 18,
        rowPaddingV: 16,
        rowLabelFontSize: 13,
        rowValueFontSize: 16,
        rowValueSpacing: 3,
        descFontSize: 15,
        descLineHeight: 1.7,
        favButtonHeight: 54,
        favButtonRadius: 14,
        favButtonFontSize: 16,
        favButtonIconSize: 22,
        radioCardRadius: 16,
        radioIconBox: 56,
        radioIconBoxRadius: 14,
        radioIconSize: 28,
        radioTitleFontSize: 16,
        radioSubtitleFontSize: 13,
        radioPlayBtnSize: 54,
        radioPlayIconSize: 26,
        miniPaddingH: 20,
        miniPaddingV: 12,
        miniLogoSize: 50,
        miniLogoRadius: 12,
        miniTitleFontSize: 15,
        miniSubtitleFontSize: 13,
        miniPlayIconSize: 40,
        miniStopIconSize: 30,
        shortsGridExtent: 180,
        shortsCardRadius: 16,
        shortsTitleFontSize: 15,
        shortsDescFontSize: 13,
        shortsMetaFontSize: 12,
        shortsThumbW: 96,
        shortsThumbH: 140,
        shortsPlayOverlay: 40,
        shortsPlayIcon: 24,
        shimmerListHeight: 120,
        shimmerRadius: 18,
        stateIconBox: 96,
        stateIconSize: 44,
        stateTitleFontSize: 20,
        stateSubtitleFontSize: 15,
        gridPaddingH: 16,
        gridPaddingV: 14,
        gridSpacing: 12,
        gridAspectRatio: 0.72,
      );
    }
    return const UniversityDetailLayoutSpec._(
      isTablet: false,
      appBarExpandedHeight: 240,
      appBarTitleFontSize: 16,
      appBarLogoSize: 30,
      appBarLogoIconSize: 18,
      appBarActionIconSize: 26,
      appBarLeadingIconSize: 22,
      tabBarHeight: 52,
      tabBarFontSize: 13.5,
      tabBarIndicatorWeight: 3,
      tabBarHPadding: 8,
      tabBarRadius: 14,
      headerTopPadding: 60,
      headerLogoOuter: 104,
      headerLogoInner: 80,
      headerLogoPadding: 6,
      headerNameFontSize: 19,
      headerNameLineHeight: 1.3,
      headerCityFontSize: 13,
      headerBadgeFontSize: 11,
      headerBadgePaddingH: 12,
      headerBadgePaddingV: 5,
      contentPaddingH: 16,
      contentPaddingTop: 20,
      contentPaddingBottom: 32,
      sectionSpacing: 20,
      sectionTitleFontSize: 15,
      cardRadius: 14,
      cardPadding: 14,
      rowIconBoxSize: 38,
      rowIconBoxRadius: 10,
      rowIconSize: 18,
      rowIconSpacing: 12,
      rowPaddingH: 14,
      rowPaddingV: 12,
      rowLabelFontSize: 11,
      rowValueFontSize: 13,
      rowValueSpacing: 2,
      descFontSize: 13.5,
      descLineHeight: 1.6,
      favButtonHeight: 50,
      favButtonRadius: 14,
      favButtonFontSize: 14.5,
      favButtonIconSize: 20,
      radioCardRadius: 14,
      radioIconBox: 46,
      radioIconBoxRadius: 12,
      radioIconSize: 22,
      radioTitleFontSize: 14,
      radioSubtitleFontSize: 11.5,
      radioPlayBtnSize: 44,
      radioPlayIconSize: 22,
      miniPaddingH: 14,
      miniPaddingV: 10,
      miniLogoSize: 42,
      miniLogoRadius: 10,
      miniTitleFontSize: 13,
      miniSubtitleFontSize: 11,
      miniPlayIconSize: 36,
      miniStopIconSize: 26,
      shortsGridExtent: 250,
      shortsCardRadius: 14,
      shortsTitleFontSize: 12.5,
      shortsDescFontSize: 11,
      shortsMetaFontSize: 10,
      shortsThumbW: 84,
      shortsThumbH: 130,
      shortsPlayOverlay: 34,
      shortsPlayIcon: 20,
      shimmerListHeight: 100,
      shimmerRadius: 16,
      stateIconBox: 80,
      stateIconSize: 38,
      stateTitleFontSize: 16,
      stateSubtitleFontSize: 13,
      gridPaddingH: 14,
      gridPaddingV: 10,
      gridSpacing: 10,
      gridAspectRatio: 0.72,
    );
  }
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet değerlerini super'e aynen aktarır; yalnızca web'de
/// farklılaşan ölçüleri ezer.
class UniversityDetailWebLayoutSpec extends UniversityDetailLayoutSpec {
  const UniversityDetailWebLayoutSpec._()
    : super._(
        isTablet: true,
        appBarExpandedHeight: 350,
        appBarTitleFontSize: 20,
        appBarLogoSize: 36,
        appBarLogoIconSize: 22,
        appBarActionIconSize: 30,
        appBarLeadingIconSize: 26,
        tabBarHeight: 60,
        tabBarFontSize: 15,
        tabBarIndicatorWeight: 3,
        tabBarHPadding: 12,
        tabBarRadius: 16,
        headerTopPadding: 70,
        headerLogoOuter: 140,
        headerLogoInner: 104,
        headerLogoPadding: 8,
        headerNameFontSize: 24,
        headerNameLineHeight: 1.35,
        headerCityFontSize: 15,
        headerBadgeFontSize: 12,
        headerBadgePaddingH: 14,
        headerBadgePaddingV: 6,
        contentPaddingH: 24,
        contentPaddingTop: 24,
        contentPaddingBottom: 40,
        sectionSpacing: 24,
        sectionTitleFontSize: 17,
        cardRadius: 16,
        cardPadding: 18,
        rowIconBoxSize: 42,
        rowIconBoxRadius: 11,
        rowIconSize: 21,
        rowIconSpacing: 16,
        rowPaddingH: 18,
        rowPaddingV: 16,
        rowLabelFontSize: 13,
        rowValueFontSize: 16,
        rowValueSpacing: 3,
        descFontSize: 15,
        descLineHeight: 1.7,
        favButtonHeight: 54,
        favButtonRadius: 14,
        favButtonFontSize: 16,
        favButtonIconSize: 22,
        radioCardRadius: 16,
        radioIconBox: 56,
        radioIconBoxRadius: 14,
        radioIconSize: 28,
        radioTitleFontSize: 16,
        radioSubtitleFontSize: 13,
        radioPlayBtnSize: 54,
        radioPlayIconSize: 26,
        miniPaddingH: 20,
        miniPaddingV: 12,
        miniLogoSize: 50,
        miniLogoRadius: 12,
        miniTitleFontSize: 15,
        miniSubtitleFontSize: 13,
        miniPlayIconSize: 40,
        miniStopIconSize: 30,
        shortsGridExtent: 180,
        shortsCardRadius: 16,
        shortsTitleFontSize: 15,
        shortsDescFontSize: 13,
        shortsMetaFontSize: 12,
        shortsThumbW: 96,
        shortsThumbH: 140,
        shortsPlayOverlay: 40,
        shortsPlayIcon: 24,
        shimmerListHeight: 120,
        shimmerRadius: 18,
        stateIconBox: 96,
        stateIconSize: 44,
        stateTitleFontSize: 20,
        stateSubtitleFontSize: 15,
        gridPaddingH: 16,
        gridPaddingV: 14,
        gridSpacing: 12,
        gridAspectRatio: 0.72,
      );

  @override
  bool get isWeb => true;

  @override
  double get contentPaddingH => 32;
  @override
  double get appBarExpandedHeight => 380;
  @override
  double get headerNameFontSize => 26;
  @override
  double get sectionTitleFontSize => 18;
}
