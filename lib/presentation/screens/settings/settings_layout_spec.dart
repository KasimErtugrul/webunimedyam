// lib/presentation/screens/settings/settings_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../core/responsive.dart';

@immutable
class SettingsLayoutSpec {
  final bool isTablet;

  // Hero
  final double heroHeight;
  final double heroIconBoxSize;
  final double heroIconSize;
  final double heroIconRadius;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroTitleSpacing;
  final double backButtonSize;
  final double backButtonPadding;

  // Content
  final double maxContentWidth;
  final double contentPaddingH;
  final double contentPaddingBottom;
  final double sectionSpacing;
  final double sectionHeaderSpacing;
  final double sectionTitleFontSize;
  final double sectionTitleLetterSpacing;

  // Card
  final double cardRadius;

  // Tile
  final double tilePaddingH;
  final double tilePaddingV;
  final double tileIconBoxSize;
  final double tileIconBoxRadius;
  final double tileIconSize;
  final double tileTitleFontSize;
  final double tileSubtitleFontSize;
  final double tileTrailingIconSize;

  // Visibility badge
  final double visBadgePaddingH;
  final double visBadgePaddingV;
  final double visBadgeRadius;
  final double visBadgeIconSize;
  final double visBadgeFontSize;

  // Sheet
  final double sheetRadius;
  final double sheetHandleWidth;
  final double sheetHandleHeight;
  final double sheetHandleSpacing;
  final double sheetTitleFontSize;
  final double sheetSubtitleFontSize;
  final double sheetOptionSpacing;
  final double sheetPaddingBottom;
  final double sheetOptionIconBoxSize;
  final double sheetOptionIconBoxRadius;
  final double sheetOptionIconSize;
  final double sheetOptionTitleFontSize;
  final double sheetOptionSubtitleFontSize;

  // Ceiling note
  final double noteMarginV;
  final double notePaddingH;
  final double notePaddingV;
  final double noteRadius;
  final double noteIconSize;
  final double noteFontSize;
  final double noteLineHeight;

  // Dialog
  final double dialogTitleFontSize;
  final double dialogRadius;
  final double dialogButtonHeight;
  final double dialogButtonFontSize;

  const SettingsLayoutSpec._({
    required this.isTablet,
    required this.heroHeight,
    required this.heroIconBoxSize,
    required this.heroIconSize,
    required this.heroIconRadius,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.heroTitleSpacing,
    required this.backButtonSize,
    required this.backButtonPadding,
    required this.maxContentWidth,
    required this.contentPaddingH,
    required this.contentPaddingBottom,
    required this.sectionSpacing,
    required this.sectionHeaderSpacing,
    required this.sectionTitleFontSize,
    required this.sectionTitleLetterSpacing,
    required this.cardRadius,
    required this.tilePaddingH,
    required this.tilePaddingV,
    required this.tileIconBoxSize,
    required this.tileIconBoxRadius,
    required this.tileIconSize,
    required this.tileTitleFontSize,
    required this.tileSubtitleFontSize,
    required this.tileTrailingIconSize,
    required this.visBadgePaddingH,
    required this.visBadgePaddingV,
    required this.visBadgeRadius,
    required this.visBadgeIconSize,
    required this.visBadgeFontSize,
    required this.sheetRadius,
    required this.sheetHandleWidth,
    required this.sheetHandleHeight,
    required this.sheetHandleSpacing,
    required this.sheetTitleFontSize,
    required this.sheetSubtitleFontSize,
    required this.sheetOptionSpacing,
    required this.sheetPaddingBottom,
    required this.sheetOptionIconBoxSize,
    required this.sheetOptionIconBoxRadius,
    required this.sheetOptionIconSize,
    required this.sheetOptionTitleFontSize,
    required this.sheetOptionSubtitleFontSize,
    required this.noteMarginV,
    required this.notePaddingH,
    required this.notePaddingV,
    required this.noteRadius,
    required this.noteIconSize,
    required this.noteFontSize,
    required this.noteLineHeight,
    required this.dialogTitleFontSize,
    required this.dialogRadius,
    required this.dialogButtonHeight,
    required this.dialogButtonFontSize,
  });

  factory SettingsLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const SettingsLayoutSpec._(
        isTablet: true,
        heroHeight: 220,
        heroIconBoxSize: 72,
        heroIconSize: 36,
        heroIconRadius: 20,
        heroTitleFontSize: 32,
        heroSubtitleFontSize: 15,
        heroTitleSpacing: 16,
        backButtonSize: 24,
        backButtonPadding: 12,
        maxContentWidth: 620,
        contentPaddingH: 24,
        contentPaddingBottom: 40,
        sectionSpacing: 28,
        sectionHeaderSpacing: 12,
        sectionTitleFontSize: 13,
        sectionTitleLetterSpacing: 1.5,
        cardRadius: 20,
        tilePaddingH: 16,
        tilePaddingV: 14,
        tileIconBoxSize: 44,
        tileIconBoxRadius: 12,
        tileIconSize: 22,
        tileTitleFontSize: 17,
        tileSubtitleFontSize: 14,
        tileTrailingIconSize: 22,
        visBadgePaddingH: 12,
        visBadgePaddingV: 6,
        visBadgeRadius: 20,
        visBadgeIconSize: 14,
        visBadgeFontSize: 13,
        sheetRadius: 28,
        sheetHandleWidth: 48,
        sheetHandleHeight: 5,
        sheetHandleSpacing: 12,
        sheetTitleFontSize: 22,
        sheetSubtitleFontSize: 15,
        sheetOptionSpacing: 14,
        sheetPaddingBottom: 24,
        sheetOptionIconBoxSize: 48,
        sheetOptionIconBoxRadius: 14,
        sheetOptionIconSize: 24,
        sheetOptionTitleFontSize: 17,
        sheetOptionSubtitleFontSize: 14,
        noteMarginV: 4,
        notePaddingH: 16,
        notePaddingV: 12,
        noteRadius: 14,
        noteIconSize: 18,
        noteFontSize: 14,
        noteLineHeight: 1.5,
        dialogTitleFontSize: 20,
        dialogRadius: 24,
        dialogButtonHeight: 52,
        dialogButtonFontSize: 16,
      );
    }
    return const SettingsLayoutSpec._(
      isTablet: false,
      heroHeight: 170,
      heroIconBoxSize: 56,
      heroIconSize: 28,
      heroIconRadius: 16,
      heroTitleFontSize: 24,
      heroSubtitleFontSize: 13,
      heroTitleSpacing: 10,
      backButtonSize: 20,
      backButtonPadding: 10,
      maxContentWidth: double.infinity,
      contentPaddingH: 16,
      contentPaddingBottom: 32,
      sectionSpacing: 22,
      sectionHeaderSpacing: 10,
      sectionTitleFontSize: 11,
      sectionTitleLetterSpacing: 1.3,
      cardRadius: 16,
      tilePaddingH: 14,
      tilePaddingV: 12,
      tileIconBoxSize: 38,
      tileIconBoxRadius: 10,
      tileIconSize: 20,
      tileTitleFontSize: 15,
      tileSubtitleFontSize: 12.5,
      tileTrailingIconSize: 18,
      visBadgePaddingH: 10,
      visBadgePaddingV: 5,
      visBadgeRadius: 18,
      visBadgeIconSize: 12,
      visBadgeFontSize: 11,
      sheetRadius: 24,
      sheetHandleWidth: 40,
      sheetHandleHeight: 4,
      sheetHandleSpacing: 10,
      sheetTitleFontSize: 18,
      sheetSubtitleFontSize: 13,
      sheetOptionSpacing: 12,
      sheetPaddingBottom: 20,
      sheetOptionIconBoxSize: 42,
      sheetOptionIconBoxRadius: 12,
      sheetOptionIconSize: 20,
      sheetOptionTitleFontSize: 15,
      sheetOptionSubtitleFontSize: 12.5,
      noteMarginV: 4,
      notePaddingH: 12,
      notePaddingV: 10,
      noteRadius: 12,
      noteIconSize: 16,
      noteFontSize: 12.5,
      noteLineHeight: 1.45,
      dialogTitleFontSize: 18,
      dialogRadius: 20,
      dialogButtonHeight: 48,
      dialogButtonFontSize: 15,
    );
  }
}