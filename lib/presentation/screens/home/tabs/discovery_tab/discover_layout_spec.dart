// lib/presentation/screens/home/widgets/tabs/discover_tab/discover_layout_spec.dart
//
// Discover tab ölçü kaynağı. Değerler HAM dp — üzerine asla .w/.h/.sp
// uygulanmaz (çifte ölçek bug'ı: bkz. video/channel tab fix).
//
// NOT: Eski "Section" grubundaki sectionTitleFontSize / sectionListViewHeight
// vb. alanlar mevcut ekranda KULLANILMIYOR gibi görünüyor (başlık 17/15'ti,
// spec'te 20/16 duruyordu). Kırdım ama işaretsiz bıraktım — emin olunca sil.

import 'package:flutter/material.dart';

import '../../../../../../core/responsive.dart';

@immutable
class DiscoverLayoutSpec {
  final bool isTablet;

  /// WEB ölçeği bayrağı — yalnızca DiscoverWebLayoutSpec true döner.
  bool get isWeb => false;

  // ── Hero (mevcut) ──
  final double heroHPadding;
  final double heroTopPadding;
  final double heroIconSize;
  final double heroIconInner;
  final double heroIconRadius;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroTitleSpacing;
  final double heroSubtitleSpacing;
  final double heroBottomPadding;

  // ── TabBar (mevcut) ──
  final double tabBarHeight;
  final double tabBarFontSize;
  final double tabBarRadius;
  final double tabBarHPadding;

  // ── Content (mevcut, video/channel tab kullanıyor) ──
  final double contentTopPadding;
  final double contentBottomPadding;

  // ── Section (ESKİ grup — büyük ihtimalle ölü, dokunulmadı) ──
  final double sectionTitleFontSize;
  final double sectionTitlePaddingLeft;
  final double sectionTitlePaddingBottom;
  final double sectionInfoIconSize;
  final double sectionInfoIconSplash;
  final double sectionViewAllFontSize;
  final double sectionListViewHeight;
  final double sectionListPaddingH;
  final double sectionCardSpacing;
  final double sectionSpacing;

  // ── Shimmer / skeleton (mevcut) ──
  final int shimmerItemCount;
  final double shimmerCardWidth;
  final double shimmerCardRadius;

  // ── Dialog (mevcut) ──
  final double dialogRadius;
  final double dialogTitleFontSize;
  final double dialogContentFontSize;
  final double dialogContentLineHeight;

  // ── YENİ: Liste genel aralıkları ──
  final double listPadH;
  final double hubSegmentGap;
  final double videosTopGap;
  final double bottomGap;
  final double sectionGapLarge;
  final double sectionGapMedium;
  final double largeCardGap;
  final double headerContentGap;
  final double channelRowVGap;

  // ── YENİ: Hub kartı + arama çubuğu ──
  final double hubCardRadius;
  final double hubGlowSize;
  final double hubGlowShift;
  final double hubPad;
  final double searchHeight;
  final double searchPadH;
  final double searchRadius;
  final double searchIconSize;
  final double searchIconGap;
  final double searchFontSize;
  final double searchTuneBoxSize;
  final double searchTuneRadius;
  final double searchTuneIconSize;

  // ── YENİ: Segment switcher ──
  final double segmentOuterPad;
  final double segmentOuterRadius;
  final double segmentButtonVPad;
  final double segmentButtonRadius;
  final double segmentIconSize;
  final double segmentIconGap;
  final double segmentFontSize;

  // ── YENİ: Bölüm başlığı ──
  final double secHeaderIconSize;
  final double secHeaderGap;
  final double secHeaderTitleSize;
  final double secBadgePadH;
  final double secBadgePadV;
  final double secBadgeRadius;
  final double secBadgeFontSize;
  final double secTrailingFontSize;
  final double secTrailingLetterSpacing;
  final double secSeeAllFontSize;
  final double secSeeAllIconSize;

  // ── YENİ: Büyük video kartı ──
  final double largeCardRadius;
  final double largeCardBadgeTop;
  final double largeCardBadgeLeft;
  final double largeCardBadgePadH;
  final double largeCardBadgePadV;
  final double largeCardBadgeRadius;
  final double largeCardBadgeIconSize;
  final double largeCardBadgeFontSize;
  final double largeCardDurationBottom;
  final double largeCardDurationRight;
  final double largeCardDurationPadH;
  final double largeCardDurationPadV;
  final double largeCardDurationRadius;
  final double largeCardDurationFontSize;
  final double largeCardPlaySize;
  final double largeCardPlayIconSize;
  final double largeCardInfoPad;
  final double largeCardTitleSize;
  final double largeCardTitleGap;
  final double largeCardAvatarSize;
  final double largeCardAvatarFontSize;
  final double largeCardAvatarGap;
  final double largeCardChannelFontSize;
  final double largeCardChannelVerifiedGap;
  final double largeCardVerifiedIconSize;
  final double largeCardMetaGap;
  final double largeCardMetaFontSize;
  final double largeCardDotFontSize;

  // ── YENİ: Kanal satırı ──
  final double channelRowPad;
  final double channelRowRadius;
  final double channelLogoSize;
  final double channelLogoRadius;
  final double channelInitialsFontSize;
  final double channelCheckBadgeSize;
  final double channelCheckIconSize;
  final double channelCheckOffset;
  final double channelRowGap;
  final double channelNameFontSize;
  final double channelNameDotSize;
  final double channelNameDotGap;
  final double channelStatsFontSize;
  final double channelStatsDotFontSize;
  final double channelStatsGap;
  final double channelButtonGap;
  final double channelButtonPadH;
  final double channelButtonPadV;
  final double channelButtonRadius;
  final double channelButtonIconSize;
  final double channelButtonFontSize;

  // ── YENİ: Leaderboard (görünebilen kısım) ──
  final double leaderboardPad;
  final double leaderboardRadius;
  final double leaderboardColumnGap;

  const DiscoverLayoutSpec._({
    required this.isTablet,
    required this.heroHPadding,
    required this.heroTopPadding,
    required this.heroIconSize,
    required this.heroIconInner,
    required this.heroIconRadius,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.heroTitleSpacing,
    required this.heroSubtitleSpacing,
    required this.heroBottomPadding,
    required this.tabBarHeight,
    required this.tabBarFontSize,
    required this.tabBarRadius,
    required this.tabBarHPadding,
    required this.contentTopPadding,
    required this.contentBottomPadding,
    required this.sectionTitleFontSize,
    required this.sectionTitlePaddingLeft,
    required this.sectionTitlePaddingBottom,
    required this.sectionInfoIconSize,
    required this.sectionInfoIconSplash,
    required this.sectionViewAllFontSize,
    required this.sectionListViewHeight,
    required this.sectionListPaddingH,
    required this.sectionCardSpacing,
    required this.sectionSpacing,
    required this.shimmerItemCount,
    required this.shimmerCardWidth,
    required this.shimmerCardRadius,
    required this.dialogRadius,
    required this.dialogTitleFontSize,
    required this.dialogContentFontSize,
    required this.dialogContentLineHeight,
    required this.listPadH,
    required this.hubSegmentGap,
    required this.videosTopGap,
    required this.bottomGap,
    required this.sectionGapLarge,
    required this.sectionGapMedium,
    required this.largeCardGap,
    required this.headerContentGap,
    required this.channelRowVGap,
    required this.hubCardRadius,
    required this.hubGlowSize,
    required this.hubGlowShift,
    required this.hubPad,
    required this.searchHeight,
    required this.searchPadH,
    required this.searchRadius,
    required this.searchIconSize,
    required this.searchIconGap,
    required this.searchFontSize,
    required this.searchTuneBoxSize,
    required this.searchTuneRadius,
    required this.searchTuneIconSize,
    required this.segmentOuterPad,
    required this.segmentOuterRadius,
    required this.segmentButtonVPad,
    required this.segmentButtonRadius,
    required this.segmentIconSize,
    required this.segmentIconGap,
    required this.segmentFontSize,
    required this.secHeaderIconSize,
    required this.secHeaderGap,
    required this.secHeaderTitleSize,
    required this.secBadgePadH,
    required this.secBadgePadV,
    required this.secBadgeRadius,
    required this.secBadgeFontSize,
    required this.secTrailingFontSize,
    required this.secTrailingLetterSpacing,
    required this.secSeeAllFontSize,
    required this.secSeeAllIconSize,
    required this.largeCardRadius,
    required this.largeCardBadgeTop,
    required this.largeCardBadgeLeft,
    required this.largeCardBadgePadH,
    required this.largeCardBadgePadV,
    required this.largeCardBadgeRadius,
    required this.largeCardBadgeIconSize,
    required this.largeCardBadgeFontSize,
    required this.largeCardDurationBottom,
    required this.largeCardDurationRight,
    required this.largeCardDurationPadH,
    required this.largeCardDurationPadV,
    required this.largeCardDurationRadius,
    required this.largeCardDurationFontSize,
    required this.largeCardPlaySize,
    required this.largeCardPlayIconSize,
    required this.largeCardInfoPad,
    required this.largeCardTitleSize,
    required this.largeCardTitleGap,
    required this.largeCardAvatarSize,
    required this.largeCardAvatarFontSize,
    required this.largeCardAvatarGap,
    required this.largeCardChannelFontSize,
    required this.largeCardChannelVerifiedGap,
    required this.largeCardVerifiedIconSize,
    required this.largeCardMetaGap,
    required this.largeCardMetaFontSize,
    required this.largeCardDotFontSize,
    required this.channelRowPad,
    required this.channelRowRadius,
    required this.channelLogoSize,
    required this.channelLogoRadius,
    required this.channelInitialsFontSize,
    required this.channelCheckBadgeSize,
    required this.channelCheckIconSize,
    required this.channelCheckOffset,
    required this.channelRowGap,
    required this.channelNameFontSize,
    required this.channelNameDotSize,
    required this.channelNameDotGap,
    required this.channelStatsFontSize,
    required this.channelStatsDotFontSize,
    required this.channelStatsGap,
    required this.channelButtonGap,
    required this.channelButtonPadH,
    required this.channelButtonPadV,
    required this.channelButtonRadius,
    required this.channelButtonIconSize,
    required this.channelButtonFontSize,
    required this.leaderboardPad,
    required this.leaderboardRadius,
    required this.leaderboardColumnGap,
  });

  factory DiscoverLayoutSpec.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet yerleşimini temel alır;
    // masaüstünde bölüm şeritleri ve hub kartı daha nefesli ölçeklenir.
    if (Responsive.isWeb(context)) {
      return const DiscoverWebLayoutSpec._();
    }
    if (Responsive.isTablet(context)) {
      return const DiscoverLayoutSpec._(
        isTablet: true,
        // ── mevcut alanlar (aynen) ──
        heroHPadding: 24,
        heroTopPadding: 24,
        heroIconSize: 52,
        heroIconInner: 28,
        heroIconRadius: 16,
        heroTitleFontSize: 30,
        heroSubtitleFontSize: 14,
        heroTitleSpacing: 20,
        heroSubtitleSpacing: 2,
        heroBottomPadding: 22,
        tabBarHeight: 52,
        tabBarFontSize: 15,
        tabBarRadius: 16,
        tabBarHPadding: 12,
        contentTopPadding: 20,
        contentBottomPadding: 32,
        sectionTitleFontSize: 20,
        sectionTitlePaddingLeft: 20,
        sectionTitlePaddingBottom: 12,
        sectionInfoIconSize: 22,
        sectionInfoIconSplash: 24,
        sectionViewAllFontSize: 14,
        sectionListViewHeight: 250,
        sectionListPaddingH: 20,
        sectionCardSpacing: 14,
        sectionSpacing: 28,
        shimmerItemCount: 4,
        shimmerCardWidth: 180,
        shimmerCardRadius: 16,
        dialogRadius: 20,
        dialogTitleFontSize: 20,
        dialogContentFontSize: 16,
        dialogContentLineHeight: 1.6,
        // ── yeni alanlar ──
        listPadH: 16,
        hubSegmentGap: 14,
        videosTopGap: 16,
        bottomGap: 32,
        sectionGapLarge: 20,
        sectionGapMedium: 16,
        largeCardGap: 12,
        headerContentGap: 10,
        channelRowVGap: 8,
        hubCardRadius: 16,
        hubGlowSize: 120,
        hubGlowShift: 20,
        hubPad: 14,
        searchHeight: 46,
        searchPadH: 12,
        searchRadius: 10,
        searchIconSize: 20,
        searchIconGap: 8,
        searchFontSize: 13.5,
        searchTuneBoxSize: 28,
        searchTuneRadius: 6,
        searchTuneIconSize: 16,
        segmentOuterPad: 4,
        segmentOuterRadius: 12,
        segmentButtonVPad: 9,
        segmentButtonRadius: 9,
        segmentIconSize: 18,
        segmentIconGap: 6,
        segmentFontSize: 14,
        secHeaderIconSize: 22,
        secHeaderGap: 6,
        secHeaderTitleSize: 17,
        secBadgePadH: 6,
        secBadgePadV: 2,
        secBadgeRadius: 4,
        secBadgeFontSize: 10,
        secTrailingFontSize: 10.5,
        secTrailingLetterSpacing: 0.8,
        secSeeAllFontSize: 13,
        secSeeAllIconSize: 16,
        largeCardRadius: 14,
        largeCardBadgeTop: 10,
        largeCardBadgeLeft: 10,
        largeCardBadgePadH: 8,
        largeCardBadgePadV: 4,
        largeCardBadgeRadius: 6,
        largeCardBadgeIconSize: 13,
        largeCardBadgeFontSize: 10,
        largeCardDurationBottom: 10,
        largeCardDurationRight: 10,
        largeCardDurationPadH: 6,
        largeCardDurationPadV: 2,
        largeCardDurationRadius: 4,
        largeCardDurationFontSize: 10,
        largeCardPlaySize: 44,
        largeCardPlayIconSize: 26,
        largeCardInfoPad: 12,
        largeCardTitleSize: 15,
        largeCardTitleGap: 8,
        largeCardAvatarSize: 24,
        largeCardAvatarFontSize: 8.5,
        largeCardAvatarGap: 8,
        largeCardChannelFontSize: 12,
        largeCardChannelVerifiedGap: 4,
        largeCardVerifiedIconSize: 13,
        largeCardMetaGap: 6,
        largeCardMetaFontSize: 11,
        largeCardDotFontSize: 11,
        channelRowPad: 12,
        channelRowRadius: 12,
        channelLogoSize: 48,
        channelLogoRadius: 12,
        channelInitialsFontSize: 16,
        channelCheckBadgeSize: 14,
        channelCheckIconSize: 9,
        channelCheckOffset: 2,
        channelRowGap: 12,
        channelNameFontSize: 14.5,
        channelNameDotSize: 5,
        channelNameDotGap: 5,
        channelStatsFontSize: 11.5,
        channelStatsDotFontSize: 11,
        channelStatsGap: 6,
        channelButtonGap: 8,
        channelButtonPadH: 10,
        channelButtonPadV: 6,
        channelButtonRadius: 8,
        channelButtonIconSize: 14,
        channelButtonFontSize: 11,
        leaderboardPad: 12,
        leaderboardRadius: 14,
        leaderboardColumnGap: 10,
      );
    }
    return const DiscoverLayoutSpec._(
      isTablet: false,
      // ── mevcut alanlar (aynen) ──
      heroHPadding: 20,
      heroTopPadding: 16,
      heroIconSize: 42,
      heroIconInner: 22,
      heroIconRadius: 12,
      heroTitleFontSize: 24,
      heroSubtitleFontSize: 12,
      heroTitleSpacing: 16,
      heroSubtitleSpacing: 2,
      heroBottomPadding: 16,
      tabBarHeight: 48,
      tabBarFontSize: 13.5,
      tabBarRadius: 14,
      tabBarHPadding: 8,
      contentTopPadding: 14,
      contentBottomPadding: 24,
      sectionTitleFontSize: 16,
      sectionTitlePaddingLeft: 16,
      sectionTitlePaddingBottom: 10,
      sectionInfoIconSize: 18,
      sectionInfoIconSplash: 20,
      sectionViewAllFontSize: 12,
      sectionListViewHeight: 220,
      sectionListPaddingH: 16,
      sectionCardSpacing: 12,
      sectionSpacing: 24,
      shimmerItemCount: 5,
      shimmerCardWidth: 160,
      shimmerCardRadius: 14,
      dialogRadius: 16,
      dialogTitleFontSize: 16,
      dialogContentFontSize: 14,
      dialogContentLineHeight: 1.5,
      // ── yeni alanlar ──
      listPadH: 16,
      hubSegmentGap: 14,
      videosTopGap: 16,
      bottomGap: 32,
      sectionGapLarge: 20,
      sectionGapMedium: 16,
      largeCardGap: 12,
      headerContentGap: 10,
      channelRowVGap: 8,
      hubCardRadius: 16,
      hubGlowSize: 120,
      hubGlowShift: 20,
      hubPad: 14,
      searchHeight: 42,
      searchPadH: 12,
      searchRadius: 10,
      searchIconSize: 20,
      searchIconGap: 8,
      searchFontSize: 12,
      searchTuneBoxSize: 28,
      searchTuneRadius: 6,
      searchTuneIconSize: 16,
      segmentOuterPad: 4,
      segmentOuterRadius: 12,
      segmentButtonVPad: 9,
      segmentButtonRadius: 9,
      segmentIconSize: 16,
      segmentIconGap: 6,
      segmentFontSize: 13,
      secHeaderIconSize: 18,
      secHeaderGap: 6,
      secHeaderTitleSize: 15,
      secBadgePadH: 6,
      secBadgePadV: 2,
      secBadgeRadius: 4,
      secBadgeFontSize: 10,
      secTrailingFontSize: 10.5,
      secTrailingLetterSpacing: 0.8,
      secSeeAllFontSize: 12,
      secSeeAllIconSize: 16,
      largeCardRadius: 14,
      largeCardBadgeTop: 10,
      largeCardBadgeLeft: 10,
      largeCardBadgePadH: 8,
      largeCardBadgePadV: 4,
      largeCardBadgeRadius: 6,
      largeCardBadgeIconSize: 13,
      largeCardBadgeFontSize: 10,
      largeCardDurationBottom: 10,
      largeCardDurationRight: 10,
      largeCardDurationPadH: 6,
      largeCardDurationPadV: 2,
      largeCardDurationRadius: 4,
      largeCardDurationFontSize: 10,
      largeCardPlaySize: 44,
      largeCardPlayIconSize: 26,
      largeCardInfoPad: 12,
      largeCardTitleSize: 13.5,
      largeCardTitleGap: 8,
      largeCardAvatarSize: 24,
      largeCardAvatarFontSize: 8.5,
      largeCardAvatarGap: 8,
      largeCardChannelFontSize: 12,
      largeCardChannelVerifiedGap: 4,
      largeCardVerifiedIconSize: 13,
      largeCardMetaGap: 6,
      largeCardMetaFontSize: 11,
      largeCardDotFontSize: 11,
      channelRowPad: 12,
      channelRowRadius: 12,
      channelLogoSize: 42,
      channelLogoRadius: 12,
      channelInitialsFontSize: 14,
      channelCheckBadgeSize: 14,
      channelCheckIconSize: 9,
      channelCheckOffset: 2,
      channelRowGap: 12,
      channelNameFontSize: 13.5,
      channelNameDotSize: 5,
      channelNameDotGap: 5,
      channelStatsFontSize: 11.5,
      channelStatsDotFontSize: 11,
      channelStatsGap: 6,
      channelButtonGap: 8,
      channelButtonPadH: 10,
      channelButtonPadV: 6,
      channelButtonRadius: 8,
      channelButtonIconSize: 14,
      channelButtonFontSize: 11,
      leaderboardPad: 12,
      leaderboardRadius: 14,
      leaderboardColumnGap: 10,
    );
  }
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
///
/// Tablet değerlerini super'e aynen aktarır; yalnızca web'de
/// farklılaşan sayfa-seviyesi ölçüleri ezer: bölüm şeritleri ve hub
/// kartı masaüstünde daha geniş pad'lerle nefes alır. Kart içi
/// ölçüler tablet değerde kalır (kart genişliği şerit yüksekliğiyle
/// sınırlı, büyütmek görsel dengesizlik yaratır).
class DiscoverWebLayoutSpec extends DiscoverLayoutSpec {
  const DiscoverWebLayoutSpec._()
    : super._(
        isTablet: true,
        // ── mevcut alanlar (aynen) ──
        heroHPadding: 24,
        heroTopPadding: 24,
        heroIconSize: 52,
        heroIconInner: 28,
        heroIconRadius: 16,
        heroTitleFontSize: 30,
        heroSubtitleFontSize: 14,
        heroTitleSpacing: 20,
        heroSubtitleSpacing: 2,
        heroBottomPadding: 22,
        tabBarHeight: 52,
        tabBarFontSize: 15,
        tabBarRadius: 16,
        tabBarHPadding: 12,
        contentTopPadding: 20,
        contentBottomPadding: 32,
        sectionTitleFontSize: 20,
        sectionTitlePaddingLeft: 20,
        sectionTitlePaddingBottom: 12,
        sectionInfoIconSize: 22,
        sectionInfoIconSplash: 24,
        sectionViewAllFontSize: 14,
        sectionListViewHeight: 250,
        sectionListPaddingH: 20,
        sectionCardSpacing: 14,
        sectionSpacing: 28,
        shimmerItemCount: 4,
        shimmerCardWidth: 180,
        shimmerCardRadius: 16,
        dialogRadius: 20,
        dialogTitleFontSize: 20,
        dialogContentFontSize: 16,
        dialogContentLineHeight: 1.6,
        // ── yeni alanlar ──
        listPadH: 16,
        hubSegmentGap: 14,
        videosTopGap: 16,
        bottomGap: 32,
        sectionGapLarge: 20,
        sectionGapMedium: 16,
        largeCardGap: 12,
        headerContentGap: 10,
        channelRowVGap: 8,
        hubCardRadius: 16,
        hubGlowSize: 120,
        hubGlowShift: 20,
        hubPad: 14,
        searchHeight: 46,
        searchPadH: 12,
        searchRadius: 10,
        searchIconSize: 20,
        searchIconGap: 8,
        searchFontSize: 13.5,
        searchTuneBoxSize: 28,
        searchTuneRadius: 6,
        searchTuneIconSize: 16,
        segmentOuterPad: 4,
        segmentOuterRadius: 12,
        segmentButtonVPad: 9,
        segmentButtonRadius: 9,
        segmentIconSize: 18,
        segmentIconGap: 6,
        segmentFontSize: 14,
        secHeaderIconSize: 22,
        secHeaderGap: 6,
        secHeaderTitleSize: 17,
        secBadgePadH: 6,
        secBadgePadV: 2,
        secBadgeRadius: 4,
        secBadgeFontSize: 10,
        secTrailingFontSize: 10.5,
        secTrailingLetterSpacing: 0.8,
        secSeeAllFontSize: 13,
        secSeeAllIconSize: 16,
        largeCardRadius: 14,
        largeCardBadgeTop: 10,
        largeCardBadgeLeft: 10,
        largeCardBadgePadH: 8,
        largeCardBadgePadV: 4,
        largeCardBadgeRadius: 6,
        largeCardBadgeIconSize: 13,
        largeCardBadgeFontSize: 10,
        largeCardDurationBottom: 10,
        largeCardDurationRight: 10,
        largeCardDurationPadH: 6,
        largeCardDurationPadV: 2,
        largeCardDurationRadius: 4,
        largeCardDurationFontSize: 10,
        largeCardPlaySize: 44,
        largeCardPlayIconSize: 26,
        largeCardInfoPad: 12,
        largeCardTitleSize: 15,
        largeCardTitleGap: 8,
        largeCardAvatarSize: 24,
        largeCardAvatarFontSize: 8.5,
        largeCardAvatarGap: 8,
        largeCardChannelFontSize: 12,
        largeCardChannelVerifiedGap: 4,
        largeCardVerifiedIconSize: 13,
        largeCardMetaGap: 6,
        largeCardMetaFontSize: 11,
        largeCardDotFontSize: 11,
        channelRowPad: 12,
        channelRowRadius: 12,
        channelLogoSize: 48,
        channelLogoRadius: 12,
        channelInitialsFontSize: 16,
        channelCheckBadgeSize: 14,
        channelCheckIconSize: 9,
        channelCheckOffset: 2,
        channelRowGap: 12,
        channelNameFontSize: 14.5,
        channelNameDotSize: 5,
        channelNameDotGap: 5,
        channelStatsFontSize: 11.5,
        channelStatsDotFontSize: 11,
        channelStatsGap: 6,
        channelButtonGap: 8,
        channelButtonPadH: 10,
        channelButtonPadV: 6,
        channelButtonRadius: 8,
        channelButtonIconSize: 14,
        channelButtonFontSize: 11,
        leaderboardPad: 12,
        leaderboardRadius: 14,
        leaderboardColumnGap: 10,
      );

  @override
  bool get isWeb => true;

  @override
  double get heroHPadding => 32;
  @override
  double get heroTopPadding => 28;
  @override
  double get contentTopPadding => 24;
  @override
  double get sectionTitlePaddingLeft => 32;
  @override
  double get sectionListPaddingH => 32;
  @override
  double get sectionListViewHeight => 270;
  @override
  double get sectionSpacing => 32;
  @override
  double get bottomGap => 48;
  @override
  double get listPadH => 24;
  @override
  double get searchHeight => 48;
}
