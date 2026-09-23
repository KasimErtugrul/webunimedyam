// lib/presentation/screens/settings/settings_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../core/responsive.dart';

@immutable
class SettingsLayoutSpec {
  final bool isTablet;

  // ── ESKİ hero alanları (settings_hero.dart artık kullanılmıyor; dosya
  //    derlenebilsin diye alanlar korunuyor) ──
  final double heroHeight;
  final double heroIconBoxSize;
  final double heroIconSize;
  final double heroIconRadius;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroTitleSpacing;
  final double backButtonSize;
  final double backButtonPadding;

  // ── Header (tasarım: h-16, blur bar) ──
  final double headerHeight;
  final double headerIconSize;
  final double headerTouchSize;
  final double headerTitleFontSize;
  final double headerShareIconSize;
  final double headerAvatarSize;
  final double headerAvatarIconSize;
  final double headerGap;

  // ── İçerik ──
  final double maxContentWidth;
  final double contentPaddingH;
  final double contentPaddingBottom;
  final double subtitleTopPadding;
  final double subtitleBottomPadding;
  final double subtitleFontSize;
  final double sectionGap;
  final double sectionIconSize;
  final double sectionIconGap;
  final double sectionTitleFontSize;
  final double sectionHeaderGap;

  // ── Kart & satırlar ──
  final double cardRadius;
  final double cardPadding;
  final double cardInnerGap;
  final double rowPaddingH;
  final double rowPaddingV;
  final double rowTitleFontSize;
  final double rowSubtitleFontSize;
  final double rowIconSize;
  final double rowGap;
  final double dividerInset;
  final double labelFontSize;
  final double labelGap;
  final double switchScale;

  // ── Tema segmenti ──
  final double segmentContainerRadius;
  final double segmentContainerPadding;
  final double segmentTabRadius;
  final double segmentTabPaddingH;
  final double segmentTabPaddingV;
  final double segmentTabIconSize;
  final double segmentTabFontSize;

  // ── Akış şekli pill'i ──
  final double feedPillPadding;
  final double feedItemPaddingH;
  final double feedItemPaddingV;
  final double feedItemFontSize;
  final double feedItemIconSize;
  final double feedGap;

  // ── Kalite butonu ──
  final double qualityPaddingH;
  final double qualityPaddingV;
  final double qualityRadius;
  final double qualityFontSize;
  final double qualityIconSize;

  // ── Gizlilik ──
  final double noticePadding;
  final double noticeRadius;
  final double noticeIconSize;
  final double noticeTitleFontSize;
  final double noticeBodyFontSize;
  final double noticeGap;
  final double stripPaddingH;
  final double stripPaddingV;
  final double stripFontSize;
  final double stateButtonPaddingH;
  final double stateButtonPaddingV;
  final double stateButtonRadius;
  final double stateButtonIconSize;
  final double stateButtonFontSize;
  final double badgePaddingH;
  final double badgePaddingV;
  final double badgeFontSize;
  final double badgeDotSize;
  final double badgeGap;

  // ── Hesap ──
  final double logoutAreaPadding;
  final double logoutButtonPaddingV;
  final double logoutButtonRadius;
  final double logoutIconSize;
  final double logoutFontSize;
  final double logoutGap;
  final double cacheBadgePaddingH;
  final double cacheBadgePaddingV;
  final double cacheBadgeRadius;
  final double cacheBadgeFontSize;

  // ── Footer ──
  final double footerIconSize;
  final double footerTitleFontSize;
  final double footerVersionFontSize;
  final double footerGap;
  final double footerBottomSpacing;

  // ── ESKİ sheet alanları (settings_pickers.dart kullanıyor) ──
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

  // ── ESKİ ceiling note alanları (orphan dosya için korunuyor) ──
  final double noteMarginV;
  final double notePaddingH;
  final double notePaddingV;
  final double noteRadius;
  final double noteIconSize;
  final double noteFontSize;
  final double noteLineHeight;

  // ── Dialog ──
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
    required this.headerHeight,
    required this.headerIconSize,
    required this.headerTouchSize,
    required this.headerTitleFontSize,
    required this.headerShareIconSize,
    required this.headerAvatarSize,
    required this.headerAvatarIconSize,
    required this.headerGap,
    required this.maxContentWidth,
    required this.contentPaddingH,
    required this.contentPaddingBottom,
    required this.subtitleTopPadding,
    required this.subtitleBottomPadding,
    required this.subtitleFontSize,
    required this.sectionGap,
    required this.sectionIconSize,
    required this.sectionIconGap,
    required this.sectionTitleFontSize,
    required this.sectionHeaderGap,
    required this.cardRadius,
    required this.cardPadding,
    required this.cardInnerGap,
    required this.rowPaddingH,
    required this.rowPaddingV,
    required this.rowTitleFontSize,
    required this.rowSubtitleFontSize,
    required this.rowIconSize,
    required this.rowGap,
    required this.dividerInset,
    required this.labelFontSize,
    required this.labelGap,
    required this.switchScale,
    required this.segmentContainerRadius,
    required this.segmentContainerPadding,
    required this.segmentTabRadius,
    required this.segmentTabPaddingH,
    required this.segmentTabPaddingV,
    required this.segmentTabIconSize,
    required this.segmentTabFontSize,
    required this.feedPillPadding,
    required this.feedItemPaddingH,
    required this.feedItemPaddingV,
    required this.feedItemFontSize,
    required this.feedItemIconSize,
    required this.feedGap,
    required this.qualityPaddingH,
    required this.qualityPaddingV,
    required this.qualityRadius,
    required this.qualityFontSize,
    required this.qualityIconSize,
    required this.noticePadding,
    required this.noticeRadius,
    required this.noticeIconSize,
    required this.noticeTitleFontSize,
    required this.noticeBodyFontSize,
    required this.noticeGap,
    required this.stripPaddingH,
    required this.stripPaddingV,
    required this.stripFontSize,
    required this.stateButtonPaddingH,
    required this.stateButtonPaddingV,
    required this.stateButtonRadius,
    required this.stateButtonIconSize,
    required this.stateButtonFontSize,
    required this.badgePaddingH,
    required this.badgePaddingV,
    required this.badgeFontSize,
    required this.badgeDotSize,
    required this.badgeGap,
    required this.logoutAreaPadding,
    required this.logoutButtonPaddingV,
    required this.logoutButtonRadius,
    required this.logoutIconSize,
    required this.logoutFontSize,
    required this.logoutGap,
    required this.cacheBadgePaddingH,
    required this.cacheBadgePaddingV,
    required this.cacheBadgeRadius,
    required this.cacheBadgeFontSize,
    required this.footerIconSize,
    required this.footerTitleFontSize,
    required this.footerVersionFontSize,
    required this.footerGap,
    required this.footerBottomSpacing,
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
        // Eski hero
        heroHeight: 220,
        heroIconBoxSize: 72,
        heroIconSize: 36,
        heroIconRadius: 20,
        heroTitleFontSize: 32,
        heroSubtitleFontSize: 15,
        heroTitleSpacing: 16,
        backButtonSize: 24,
        backButtonPadding: 12,
        // Header
        headerHeight: 72,
        headerIconSize: 26,
        headerTouchSize: 48,
        headerTitleFontSize: 20,
        headerShareIconSize: 24,
        headerAvatarSize: 36,
        headerAvatarIconSize: 20,
        headerGap: 6,
        // İçerik
        maxContentWidth: 620,
        contentPaddingH: 24,
        contentPaddingBottom: 40,
        subtitleTopPadding: 6,
        subtitleBottomPadding: 18,
        subtitleFontSize: 15,
        sectionGap: 28,
        sectionIconSize: 22,
        sectionIconGap: 10,
        sectionTitleFontSize: 20,
        sectionHeaderGap: 10,
        // Kart & satır
        cardRadius: 14,
        cardPadding: 20,
        cardInnerGap: 20,
        rowPaddingH: 18,
        rowPaddingV: 18,
        rowTitleFontSize: 15,
        rowSubtitleFontSize: 13,
        rowIconSize: 22,
        rowGap: 3,
        dividerInset: 18,
        labelFontSize: 13,
        labelGap: 5,
        switchScale: 0.95,
        // Segment
        segmentContainerRadius: 10,
        segmentContainerPadding: 5,
        segmentTabRadius: 10,
        segmentTabPaddingH: 10,
        segmentTabPaddingV: 7,
        segmentTabIconSize: 18,
        segmentTabFontSize: 13,
        // Feed pill
        feedPillPadding: 5,
        feedItemPaddingH: 10,
        feedItemPaddingV: 5,
        feedItemFontSize: 11,
        feedItemIconSize: 15,
        feedGap: 5,
        // Kalite
        qualityPaddingH: 10,
        qualityPaddingV: 7,
        qualityRadius: 10,
        qualityFontSize: 13,
        qualityIconSize: 20,
        // Gizlilik
        noticePadding: 20,
        noticeRadius: 14,
        noticeIconSize: 24,
        noticeTitleFontSize: 13,
        noticeBodyFontSize: 13,
        noticeGap: 14,
        stripPaddingH: 18,
        stripPaddingV: 5,
        stripFontSize: 11,
        stateButtonPaddingH: 14,
        stateButtonPaddingV: 7,
        stateButtonRadius: 10,
        stateButtonIconSize: 16,
        stateButtonFontSize: 11,
        badgePaddingH: 10,
        badgePaddingV: 3,
        badgeFontSize: 11,
        badgeDotSize: 7,
        badgeGap: 5,
        // Hesap
        logoutAreaPadding: 20,
        logoutButtonPaddingV: 12,
        logoutButtonRadius: 10,
        logoutIconSize: 22,
        logoutFontSize: 15,
        logoutGap: 7,
        cacheBadgePaddingH: 10,
        cacheBadgePaddingV: 5,
        cacheBadgeRadius: 5,
        cacheBadgeFontSize: 11,
        // Footer
        footerIconSize: 18,
        footerTitleFontSize: 11,
        footerVersionFontSize: 13,
        footerGap: 7,
        footerBottomSpacing: 32,
        // Eski sheet
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
        // Eski note
        noteMarginV: 4,
        notePaddingH: 16,
        notePaddingV: 12,
        noteRadius: 14,
        noteIconSize: 18,
        noteFontSize: 14,
        noteLineHeight: 1.5,
        // Dialog
        dialogTitleFontSize: 20,
        dialogRadius: 24,
        dialogButtonHeight: 52,
        dialogButtonFontSize: 16,
      );
    }
    return const SettingsLayoutSpec._(
      isTablet: false,
      // Eski hero
      heroHeight: 170,
      heroIconBoxSize: 56,
      heroIconSize: 28,
      heroIconRadius: 16,
      heroTitleFontSize: 24,
      heroSubtitleFontSize: 13,
      heroTitleSpacing: 10,
      backButtonSize: 20,
      backButtonPadding: 10,
      // Header
      headerHeight: 64,
      headerIconSize: 24,
      headerTouchSize: 44,
      headerTitleFontSize: 18,
      headerShareIconSize: 22,
      headerAvatarSize: 32,
      headerAvatarIconSize: 18,
      headerGap: 4,
      // İçerik
      maxContentWidth: double.infinity,
      contentPaddingH: 16,
      contentPaddingBottom: 40,
      subtitleTopPadding: 4,
      subtitleBottomPadding: 16,
      subtitleFontSize: 14,
      sectionGap: 24,
      sectionIconSize: 20,
      sectionIconGap: 8,
      sectionTitleFontSize: 18,
      sectionHeaderGap: 8,
      // Kart & satır
      cardRadius: 12,
      cardPadding: 16,
      cardInnerGap: 16,
      rowPaddingH: 16,
      rowPaddingV: 16,
      rowTitleFontSize: 14,
      rowSubtitleFontSize: 12,
      rowIconSize: 20,
      rowGap: 2,
      dividerInset: 16,
      labelFontSize: 12,
      labelGap: 4,
      switchScale: 0.9,
      // Segment
      segmentContainerRadius: 8,
      segmentContainerPadding: 4,
      segmentTabRadius: 8,
      segmentTabPaddingH: 8,
      segmentTabPaddingV: 6,
      segmentTabIconSize: 16,
      segmentTabFontSize: 12,
      // Feed pill
      feedPillPadding: 4,
      feedItemPaddingH: 8,
      feedItemPaddingV: 4,
      feedItemFontSize: 10,
      feedItemIconSize: 14,
      feedGap: 4,
      // Kalite
      qualityPaddingH: 8,
      qualityPaddingV: 6,
      qualityRadius: 8,
      qualityFontSize: 12,
      qualityIconSize: 18,
      // Gizlilik
      noticePadding: 16,
      noticeRadius: 12,
      noticeIconSize: 22,
      noticeTitleFontSize: 12,
      noticeBodyFontSize: 12,
      noticeGap: 12,
      stripPaddingH: 16,
      stripPaddingV: 4,
      stripFontSize: 10,
      stateButtonPaddingH: 12,
      stateButtonPaddingV: 6,
      stateButtonRadius: 8,
      stateButtonIconSize: 15,
      stateButtonFontSize: 10,
      badgePaddingH: 8,
      badgePaddingV: 2,
      badgeFontSize: 10,
      badgeDotSize: 6,
      badgeGap: 4,
      // Hesap
      logoutAreaPadding: 16,
      logoutButtonPaddingV: 10,
      logoutButtonRadius: 8,
      logoutIconSize: 20,
      logoutFontSize: 14,
      logoutGap: 6,
      cacheBadgePaddingH: 8,
      cacheBadgePaddingV: 4,
      cacheBadgeRadius: 4,
      cacheBadgeFontSize: 10,
      // Footer
      footerIconSize: 16,
      footerTitleFontSize: 10,
      footerVersionFontSize: 12,
      footerGap: 6,
      footerBottomSpacing: 24,
      // Eski sheet
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
      // Eski note
      noteMarginV: 4,
      notePaddingH: 12,
      notePaddingV: 10,
      noteRadius: 12,
      noteIconSize: 16,
      noteFontSize: 12.5,
      noteLineHeight: 1.45,
      // Dialog
      dialogTitleFontSize: 18,
      dialogRadius: 20,
      dialogButtonHeight: 48,
      dialogButtonFontSize: 15,
    );
  }
}