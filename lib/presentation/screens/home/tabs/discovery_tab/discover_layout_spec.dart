// lib/presentation/screens/home/widgets/tabs/discover_tab/discover_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../../../../core/responsive.dart';

@immutable
class DiscoverLayoutSpec {
  final bool isTablet;

  // Hero
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

  // TabBar
  final double tabBarHeight;
  final double tabBarFontSize;
  final double tabBarRadius;
  final double tabBarHPadding;

  // Content
  final double contentTopPadding;
  final double contentBottomPadding;

  // Section
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

  // Shimmer / skeleton
  final int shimmerItemCount;
  final double shimmerCardWidth;
  final double shimmerCardRadius;

  // Dialog
  final double dialogRadius;
  final double dialogTitleFontSize;
  final double dialogContentFontSize;
  final double dialogContentLineHeight;

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
  });

  factory DiscoverLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const DiscoverLayoutSpec._(
        isTablet: true,
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
      );
    }
    return const DiscoverLayoutSpec._(
      isTablet: false,
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
    );
  }
}