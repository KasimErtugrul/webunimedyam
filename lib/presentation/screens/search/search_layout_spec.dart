// lib/presentation/screens/search/search_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../core/responsive.dart';

@immutable
class SearchLayoutSpec {
  final bool isTablet;

  // Search field
  final double fieldFontSize;
  final double fieldPaddingH;
  final double fieldPaddingV;
  final double fieldRadius;
  final double fieldIconSize;

  // Chips
  final double chipFontSize;
  final double chipPaddingH;
  final double chipPaddingV;
  final double chipRadius;
  final double chipSpacing;
  final double chipRunSpacing;

  // Section
  final double sectionTitleFontSize;
  final double sectionTitleSpacing;
  final double sectionTopPadding;
  final double sectionH;

  // Empty / loading
  final double emptyIconSize;
  final double emptyTitleFontSize;
  final double emptySubtitleFontSize;
  final double emptySpacing;
  final double loadingStrokeWidth;

  // Results
  final double resultsPaddingH;
  final double resultsPaddingV;
  final double resultsCountFontSize;
  final double resultsCountSpacing;

  // Result card
  final double cardBottomMargin;
  final double cardRadius;
  final double cardThumbW;
  final double cardThumbH;
  final double cardThumbSpacing;
  final double cardPaddingV;
  final double cardTitleFontSize;
  final double cardUniFontSize;
  final double cardViewFontSize;
  final double cardSpacingSm;
  final double cardSpacingMd;
  final double cardPlaceholderIconSize;
  final double cardTrailingSpacing;

  const SearchLayoutSpec._({
    required this.isTablet,
    required this.fieldFontSize,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.fieldRadius,
    required this.fieldIconSize,
    required this.chipFontSize,
    required this.chipPaddingH,
    required this.chipPaddingV,
    required this.chipRadius,
    required this.chipSpacing,
    required this.chipRunSpacing,
    required this.sectionTitleFontSize,
    required this.sectionTitleSpacing,
    required this.sectionTopPadding,
    required this.sectionH,
    required this.emptyIconSize,
    required this.emptyTitleFontSize,
    required this.emptySubtitleFontSize,
    required this.emptySpacing,
    required this.loadingStrokeWidth,
    required this.resultsPaddingH,
    required this.resultsPaddingV,
    required this.resultsCountFontSize,
    required this.resultsCountSpacing,
    required this.cardBottomMargin,
    required this.cardRadius,
    required this.cardThumbW,
    required this.cardThumbH,
    required this.cardThumbSpacing,
    required this.cardPaddingV,
    required this.cardTitleFontSize,
    required this.cardUniFontSize,
    required this.cardViewFontSize,
    required this.cardSpacingSm,
    required this.cardSpacingMd,
    required this.cardPlaceholderIconSize,
    required this.cardTrailingSpacing,
  });

  factory SearchLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const SearchLayoutSpec._(
        isTablet: true,
        fieldFontSize: 17,
        fieldPaddingH: 18,
        fieldPaddingV: 14,
        fieldRadius: 16,
        fieldIconSize: 22,
        chipFontSize: 14,
        chipPaddingH: 16,
        chipPaddingV: 9,
        chipRadius: 22,
        chipSpacing: 10,
        chipRunSpacing: 10,
        sectionTitleFontSize: 15,
        sectionTitleSpacing: 14,
        sectionTopPadding: 20,
        sectionH: 24,
        emptyIconSize: 96,
        emptyTitleFontSize: 20,
        emptySubtitleFontSize: 15,
        emptySpacing: 16,
        loadingStrokeWidth: 3.5,
        resultsPaddingH: 24,
        resultsPaddingV: 12,
        resultsCountFontSize: 14,
        resultsCountSpacing: 12,
        cardBottomMargin: 14,
        cardRadius: 14,
        cardThumbW: 160,
        cardThumbH: 100,
        cardThumbSpacing: 16,
        cardPaddingV: 14,
        cardTitleFontSize: 16,
        cardUniFontSize: 13,
        cardViewFontSize: 13,
        cardSpacingSm: 6,
        cardSpacingMd: 3,
        cardPlaceholderIconSize: 40,
        cardTrailingSpacing: 12,
      );
    }
    return const SearchLayoutSpec._(
      isTablet: false,
      fieldFontSize: 15,
      fieldPaddingH: 16,
      fieldPaddingV: 12,
      fieldRadius: 14,
      fieldIconSize: 20,
      chipFontSize: 13,
      chipPaddingH: 14,
      chipPaddingV: 8,
      chipRadius: 20,
      chipSpacing: 8,
      chipRunSpacing: 8,
      sectionTitleFontSize: 13,
      sectionTitleSpacing: 12,
      sectionTopPadding: 16,
      sectionH: 20,
      emptyIconSize: 80,
      emptyTitleFontSize: 17,
      emptySubtitleFontSize: 13,
      emptySpacing: 14,
      loadingStrokeWidth: 3,
      resultsPaddingH: 16,
      resultsPaddingV: 10,
      resultsCountFontSize: 12,
      resultsCountSpacing: 10,
      cardBottomMargin: 12,
      cardRadius: 12,
      cardThumbW: 120,
      cardThumbH: 80,
      cardThumbSpacing: 12,
      cardPaddingV: 10,
      cardTitleFontSize: 13,
      cardUniFontSize: 11,
      cardViewFontSize: 11,
      cardSpacingSm: 4,
      cardSpacingMd: 2,
      cardPlaceholderIconSize: 32,
      cardTrailingSpacing: 8,
    );
  }
}