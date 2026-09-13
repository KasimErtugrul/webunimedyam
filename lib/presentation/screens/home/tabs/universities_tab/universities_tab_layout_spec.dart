// lib/presentation/screens/home/widgets/tabs/universities_tab/universities_tab_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../../../../core/responsive.dart';

@immutable
class UniversitiesTabLayoutSpec {
  final bool isTablet;

  // ── Hero ──
  final double heroHeight;
  final double heroHPadding;
  final double heroTopPadding;
  final double heroIconSize;
  final double heroIconInner;
  final double heroIconRadius;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroBottomPadding;


  // ── Search ──
  final double searchHeight;
  final double searchRadius;
  final double searchFontSize;
  final double searchIconSize;
  final double searchHPadding;
  final double searchOverlap;

  // ── Chips ──
  final double chipSpacing;
  final double chipRunSpacing;
  final double chipFontSize;
  final double chipIconSize;
  final double chipRadius;

  // ── Stats row ──
  final double statsFontSize;
  final double statsIconSize;
  final double statsVPadding;

  // ── Content ──
  final double contentHPadding;
  final double listBottomPadding;

  // ── Empty ──
  final double emptyIconSize;
  final double emptyIconInner;
  final double emptyTitleFontSize;
  final double emptySubtitleFontSize;
  final double emptySpacingL;
  final double emptySpacingM;
  final double emptyButtonHeight;
  final double emptyButtonFontSize;
  final double emptyButtonRadius;

  // ── Sort sheet ──
  final double sheetRadius;
  final double sheetHandleW;
  final double sheetHandleH;
  final double sheetTitleFontSize;
  final double sheetSubtitleFontSize;
  final double sheetOptionFontSize;
  final double sheetOptionSubFontSize;
  final double sheetOptionIconBox;
  final double sheetOptionIconBoxRadius;
  final double sheetOptionIconSize;
  final double sheetOptionSpacing;
  final double sheetHPadding;

  // ── Alphabet sidebar ──
  final double sidebarWidth;
  final double sidebarActiveFontSize;
  final double sidebarInactiveFontSize;
  final double sidebarPillWidth;

  // ── Card ──
  final double cardPadding;
  final double cardRadius;
  final double cardLogoSize;
  final double cardLogoPadding;
  final double cardTitleFontSize;
  final double cardTitleLineHeight;
  final double cardMetaFontSize;
  final double cardMetaIconSize;
  final double cardStatFontSize;
  final double cardStatPaddingH;
  final double cardStatPaddingV;
  final double cardStatRadius;
  final double cardStatIconSize;
  final double cardFollowHeight;
  final double cardFollowFontSize;
  final double cardFollowRadius;
  final double cardBottomMargin;

  // ── Shimmer ──
  final double shimmerCardHeight;

  const UniversitiesTabLayoutSpec._({
    required this.isTablet,
    required this.heroHeight,
    required this.heroHPadding,
    required this.heroTopPadding,
    required this.heroBottomPadding,
    required this.heroIconSize,
    required this.heroIconInner,
    required this.heroIconRadius,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.searchHeight,
    required this.searchRadius,
    required this.searchFontSize,
    required this.searchIconSize,
    required this.searchHPadding,
    required this.searchOverlap,
    required this.chipSpacing,
    required this.chipRunSpacing,
    required this.chipFontSize,
    required this.chipIconSize,
    required this.chipRadius,
    required this.statsFontSize,
    required this.statsIconSize,
    required this.statsVPadding,
    required this.contentHPadding,
    required this.listBottomPadding,
    required this.emptyIconSize,
    required this.emptyIconInner,
    required this.emptyTitleFontSize,
    required this.emptySubtitleFontSize,
    required this.emptySpacingL,
    required this.emptySpacingM,
    required this.emptyButtonHeight,
    required this.emptyButtonFontSize,
    required this.emptyButtonRadius,
    required this.sheetRadius,
    required this.sheetHandleW,
    required this.sheetHandleH,
    required this.sheetTitleFontSize,
    required this.sheetSubtitleFontSize,
    required this.sheetOptionFontSize,
    required this.sheetOptionSubFontSize,
    required this.sheetOptionIconBox,
    required this.sheetOptionIconBoxRadius,
    required this.sheetOptionIconSize,
    required this.sheetOptionSpacing,
    required this.sheetHPadding,
    required this.sidebarWidth,
    required this.sidebarActiveFontSize,
    required this.sidebarInactiveFontSize,
    required this.sidebarPillWidth,
    required this.cardPadding,
    required this.cardRadius,
    required this.cardLogoSize,
    required this.cardLogoPadding,
    required this.cardTitleFontSize,
    required this.cardTitleLineHeight,
    required this.cardMetaFontSize,
    required this.cardMetaIconSize,
    required this.cardStatFontSize,
    required this.cardStatPaddingH,
    required this.cardStatPaddingV,
    required this.cardStatRadius,
    required this.cardStatIconSize,
    required this.cardFollowHeight,
    required this.cardFollowFontSize,
    required this.cardFollowRadius,
    required this.cardBottomMargin,
    required this.shimmerCardHeight,
  });

  factory UniversitiesTabLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const UniversitiesTabLayoutSpec._(
        isTablet: true,
        heroHeight: 200,
        heroHPadding: 24,
        heroTopPadding: 28,
        heroIconSize: 52,
        heroBottomPadding: 18,

        heroIconInner: 28,
        heroIconRadius: 16,
        heroTitleFontSize: 30,
        heroSubtitleFontSize: 14,
        searchHeight: 56,
        searchRadius: 16,
        searchFontSize: 16,
        searchIconSize: 22,
        searchHPadding: 20,
        searchOverlap: 28,
        chipSpacing: 10,
        chipRunSpacing: 8,
        chipFontSize: 14,
        chipIconSize: 16,
        chipRadius: 20,
        statsFontSize: 15,
        statsIconSize: 20,
        statsVPadding: 14,
        contentHPadding: 16,
        listBottomPadding: 40,
        emptyIconSize: 104,
        emptyIconInner: 48,
        emptyTitleFontSize: 22,
        emptySubtitleFontSize: 16,
        emptySpacingL: 24,
        emptySpacingM: 10,
        emptyButtonHeight: 52,
        emptyButtonFontSize: 16,
        emptyButtonRadius: 14,
        sheetRadius: 28,
        sheetHandleW: 48,
        sheetHandleH: 5,
        sheetTitleFontSize: 22,
        sheetSubtitleFontSize: 14,
        sheetOptionFontSize: 16,
        sheetOptionSubFontSize: 13,
        sheetOptionIconBox: 48,
        sheetOptionIconBoxRadius: 14,
        sheetOptionIconSize: 24,
        sheetOptionSpacing: 8,
        sheetHPadding: 20,
        sidebarWidth: 28,
        sidebarActiveFontSize: 15,
        sidebarInactiveFontSize: 12,
        sidebarPillWidth: 26,
        cardPadding: 16,
        cardRadius: 18,
        cardLogoSize: 48,
        cardLogoPadding: 8,
        cardTitleFontSize: 17,
        cardTitleLineHeight: 1.3,
        cardMetaFontSize: 13,
        cardMetaIconSize: 14,
        cardStatFontSize: 12,
        cardStatPaddingH: 8,
        cardStatPaddingV: 4,
        cardStatRadius: 7,
        cardStatIconSize: 13,
        cardFollowHeight: 38,
        cardFollowFontSize: 13,
        cardFollowRadius: 19,
        cardBottomMargin: 12,
        shimmerCardHeight: 130,
      );
    }
    return const UniversitiesTabLayoutSpec._(
      isTablet: false,
      heroHeight: 165,
      heroHPadding: 20,
      heroBottomPadding: 22,
      heroTopPadding: 20,
      heroIconSize: 42,
      heroIconInner: 22,
      heroIconRadius: 12,
      heroTitleFontSize: 22,
      heroSubtitleFontSize: 12,
      searchHeight: 48,
      searchRadius: 14,
      searchFontSize: 14,
      searchIconSize: 20,
      searchHPadding: 16,
      searchOverlap: 24,
      chipSpacing: 8,
      chipRunSpacing: 6,
      chipFontSize: 12,
      chipIconSize: 14,
      chipRadius: 18,
      statsFontSize: 13,
      statsIconSize: 18,
      statsVPadding: 10,
      contentHPadding: 14,
      listBottomPadding: 32,
      emptyIconSize: 88,
      emptyIconInner: 40,
      emptyTitleFontSize: 18,
      emptySubtitleFontSize: 14,
      emptySpacingL: 20,
      emptySpacingM: 8,
      emptyButtonHeight: 46,
      emptyButtonFontSize: 14,
      emptyButtonRadius: 12,
      sheetRadius: 24,
      sheetHandleW: 40,
      sheetHandleH: 4,
      sheetTitleFontSize: 18,
      sheetSubtitleFontSize: 12,
      sheetOptionFontSize: 15,
      sheetOptionSubFontSize: 12,
      sheetOptionIconBox: 42,
      sheetOptionIconBoxRadius: 12,
      sheetOptionIconSize: 20,
      sheetOptionSpacing: 6,
      sheetHPadding: 16,
      sidebarWidth: 22,
      sidebarActiveFontSize: 13,
      sidebarInactiveFontSize: 10,
      sidebarPillWidth: 20,
      cardPadding: 12,
      cardRadius: 16,
      cardLogoSize: 48,
      cardLogoPadding: 6,
      cardTitleFontSize: 14.5,
      cardTitleLineHeight: 1.25,
      cardMetaFontSize: 11,
      cardMetaIconSize: 12,
      cardStatFontSize: 10,
      cardStatPaddingH: 6,
      cardStatPaddingV: 3,
      cardStatRadius: 6,
      cardStatIconSize: 11,
      cardFollowHeight: 32,
      cardFollowFontSize: 11,
      cardFollowRadius: 16,
      cardBottomMargin: 10,
      shimmerCardHeight: 108,
    );
  }
}
