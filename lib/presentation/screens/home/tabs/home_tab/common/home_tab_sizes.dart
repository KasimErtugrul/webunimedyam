// lib/presentation/screens/home/tabs/home_tab/common/home_tab_sizes.dart
//
// Home tab'ının TÜM ölçü sabitleri. İki implementasyon:
//   - PhoneHomeTabSizes : erişim anında ScreenUtil ile ölçeklenir (.w/.h/.sp/.r)
//   - TabletHomeTabSizes: sabit dp (dosyanın kendi kuralı: tablet-tablet dp farkı ihmal)
//
// DÜRÜST NOT: Orijinal tablet kodunda ScreenUtil kullanan 2 değer vardı
// (utilityBarPadV: 8.h, continueWatchingTopPad: 20.h). Davranışı bozmamak
// için .h olarak korundu — TabletHomeTabSizes içinde işaretli.
//
// Tablet'i tamamen ScreenUtil'e geçirmek istersen (0.75–1.33 ölçek bandı
// uyarısı geçerli): yalnızca TabletHomeTabSizes'ı değiştirmen yeterli.

import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class HomeTabSizes {
  const HomeTabSizes();

  // ── Genel spacing ──
  double get titleSpacingLarge; // utility bar + banner yatay pad
  double get utilityBarPadV;
  double get bottomSpacing; // listenin altındaki boşluk
  double get contentTitlePadHorizontal;
  double get contentTitlePadTop;
  double get contentTitlePadBottom;
  double get continueWatchingTopPad;
  double get continueWatchingExtraSpacing;

  // ── İçerik başlığı ("Üniversitelerin Son Videoları") ──
  double get contentTitleFontSize;
  double get contentTitleSubSpacing;
  double get contentSubtitleFontSize;
  double get contentTitleIconSize;
  double get contentTitleIconSpacing;
  double get sortFontSize;
  double get sortIconSize;
  double get sortPadH;
  double get sortPadV;

  // ── Utility bar (radyo pili + görünüm anahtarı) ──
  double get radioDotSize;
  double get radioIconSize;
  double get radioGapSmall;
  double get radioGapTiny;
  double get radioPadH;
  double get radioPadV;
  double get radioBadgePadH;
  double get radioBadgePadV;
  double get radioBadgeRadius;
  double get viewToggleOuterPad;
  double get viewToggleOuterRadius;
  double get viewToggleButtonSize;
  double get viewToggleIconSize;

  // ── Error / Empty / Dialog ──
  double get errorPadding;
  double get errorIconSize;
  double get errorSpacing;
  double get errorFontSize;
  double get errorButtonWidth;
  double get errorButtonHeight;
  double get emptyPadding;
  double get emptyFontSize;
  double get dialogBorderRadius;
  double get dialogButtonRadius;

  // ── Shimmer ──
  int get shimmerCount;
  double get shimmerItemSpacingVertical;
  double get shimmerItemSpacingHorizontal;
  double get shimmerBorderRadius;
  double get shimmerImageHeight;
  double get shimmerAvatarSize;
  double get shimmerAvatarSpacing;
  double get shimmerAvatarRadius;
  double get shimmerTitleHeight;
  double get shimmerTitleWidth;
  double get shimmerSubtitleHeight;
  double get shimmerSubtitleWidth;
  double get shimmerSpacingSmall;
  double get shimmerSpacingMedium;
  double get shimmerPaddingTop;
  double get shimmerPaddingBottom;
  double get shimmerPaddingLeft;
  double get shimmerPaddingRight;

  // ── Yaklaşan Canlı Yayın şeridi ──
  double get bannerVerticalGap;
  double get bannerBottomGap;
  double get bannerPadding;
  double get bannerContainerRadius;
  double get bannerIconBox;
  double get bannerIconRadius;
  double get bannerIconSize;
  double get bannerIconTextGap;
  double get bannerTitleFontSize;
  double get bannerSubtitleFontSize;
  double get bannerActionGap;
  double get bannerButtonRadius;
  double get bannerButtonPadH;
  double get bannerButtonPadV;
  double get bannerButtonFontSize;
}

class PhoneHomeTabSizes implements HomeTabSizes {
  const PhoneHomeTabSizes();

  @override double get titleSpacingLarge => 16.w;
  @override double get utilityBarPadV => 8.h;
  @override double get bottomSpacing => 24.h;
  @override double get contentTitlePadHorizontal => 16.w;
  @override double get contentTitlePadTop => 20.h;
  @override double get contentTitlePadBottom => 10.h;
  @override double get continueWatchingTopPad => 20.h;
  @override double get continueWatchingExtraSpacing => 20.h;

  @override double get contentTitleFontSize => 18.sp;
  @override double get contentTitleSubSpacing => 4.h;
  @override double get contentSubtitleFontSize => 12.sp;
  @override double get contentTitleIconSize => 20.sp;
  @override double get contentTitleIconSpacing => 6.w;
  @override double get sortFontSize => 13.sp;
  @override double get sortIconSize => 18.sp;
  @override double get sortPadH => 4.w;
  @override double get sortPadV => 4.h;

  @override double get radioDotSize => 8.w;
  @override double get radioIconSize => 16.sp;
  @override double get radioGapSmall => 6.w;
  @override double get radioGapTiny => 4.w;
  @override double get radioPadH => 12.w;
  @override double get radioPadV => 6.h;
  @override double get radioBadgePadH => 6.w;
  @override double get radioBadgePadV => 2.h;
  @override double get radioBadgeRadius => 4.r;
  @override double get viewToggleOuterPad => 2.w;
  @override double get viewToggleOuterRadius => 8.r;
  @override double get viewToggleButtonSize => 32.w;
  @override double get viewToggleIconSize => 18.sp;

  @override double get errorPadding => 32.w;
  @override double get errorIconSize => 48.sp;
  @override double get errorSpacing => 16.h;
  @override double get errorFontSize => 14.sp;
  @override double get errorButtonWidth => 100.w;
  @override double get errorButtonHeight => 40.h;
  @override double get emptyPadding => 32.w;
  @override double get emptyFontSize => 14.sp;
  @override double get dialogBorderRadius => 16.r;
  @override double get dialogButtonRadius => 8.r;

  @override int get shimmerCount => 4;
  @override double get shimmerItemSpacingVertical => 7.h;
  @override double get shimmerItemSpacingHorizontal => 14.w;
  @override double get shimmerBorderRadius => 16.r;
  @override double get shimmerImageHeight => 196.h;
  @override double get shimmerAvatarSize => 42.w;
  @override double get shimmerAvatarSpacing => 12.w;
  @override double get shimmerAvatarRadius => 10.r;
  @override double get shimmerTitleHeight => 14.h;
  @override double get shimmerTitleWidth => 160.w;
  @override double get shimmerSubtitleHeight => 11.h;
  @override double get shimmerSubtitleWidth => 100.w;
  @override double get shimmerSpacingSmall => 6.h;
  @override double get shimmerSpacingMedium => 8.h;
  @override double get shimmerPaddingTop => 12.h;
  @override double get shimmerPaddingBottom => 14.h;
  @override double get shimmerPaddingLeft => 14.w;
  @override double get shimmerPaddingRight => 14.w;

  @override double get bannerVerticalGap => 24.h;
  @override double get bannerBottomGap => 16.h;
  @override double get bannerPadding => 16.w;
  @override double get bannerContainerRadius => 20.r;
  @override double get bannerIconBox => 40.w;
  @override double get bannerIconRadius => 12.r;
  @override double get bannerIconSize => 24.sp;
  @override double get bannerIconTextGap => 12.w;
  @override double get bannerTitleFontSize => 14.sp;
  @override double get bannerSubtitleFontSize => 12.sp;
  @override double get bannerActionGap => 8.w;
  @override double get bannerButtonRadius => 8.r;
  @override double get bannerButtonPadH => 14.w;
  @override double get bannerButtonPadV => 8.h;
  @override double get bannerButtonFontSize => 13.sp;
}

class TabletHomeTabSizes implements HomeTabSizes {
  const TabletHomeTabSizes();

  @override double get titleSpacingLarge => 20;
  // ORİJİNALDE 8.h idi — ScreenUtil sızıntısı aynen korundu.
  // Sabit dp istersen 8 yap (görsel fark: tablet ölçeğine bağlı ~0-2px).
  @override double get utilityBarPadV => 8.h;
  @override double get bottomSpacing => 30;
  @override double get contentTitlePadHorizontal => 16;
  @override double get contentTitlePadTop => 20;
  @override double get contentTitlePadBottom => 12;
  // ORİJİNALDE 20.0.h idi — aynı sızıntı, aynen korundu.
  @override double get continueWatchingTopPad => 20.h;
  @override double get continueWatchingExtraSpacing => 24;

  @override double get contentTitleFontSize => 20;
  @override double get contentTitleSubSpacing => 4;
  @override double get contentSubtitleFontSize => 13;
  @override double get contentTitleIconSize => 22;
  @override double get contentTitleIconSpacing => 8;
  @override double get sortFontSize => 14;
  @override double get sortIconSize => 20;
  @override double get sortPadH => 6;
  @override double get sortPadV => 4;

  @override double get radioDotSize => 9;
  @override double get radioIconSize => 18;
  @override double get radioGapSmall => 7;
  @override double get radioGapTiny => 5;
  @override double get radioPadH => 14;
  @override double get radioPadV => 7;
  @override double get radioBadgePadH => 7;
  @override double get radioBadgePadV => 2.5;
  @override double get radioBadgeRadius => 5;
  @override double get viewToggleOuterPad => 3;
  @override double get viewToggleOuterRadius => 9;
  @override double get viewToggleButtonSize => 36;
  @override double get viewToggleIconSize => 20;

  @override double get errorPadding => 40;
  @override double get errorIconSize => 56;
  @override double get errorSpacing => 20;
  @override double get errorFontSize => 16;
  @override double get errorButtonWidth => 120;
  @override double get errorButtonHeight => 48;
  @override double get emptyPadding => 40;
  @override double get emptyFontSize => 16;
  @override double get dialogBorderRadius => 20;
  @override double get dialogButtonRadius => 10;

  @override int get shimmerCount => 3;
  @override double get shimmerItemSpacingVertical => 10;
  @override double get shimmerItemSpacingHorizontal => 18;
  @override double get shimmerBorderRadius => 20;
  @override double get shimmerImageHeight => 240;
  @override double get shimmerAvatarSize => 48;
  @override double get shimmerAvatarSpacing => 14;
  @override double get shimmerAvatarRadius => 12;
  @override double get shimmerTitleHeight => 16;
  @override double get shimmerTitleWidth => 200;
  @override double get shimmerSubtitleHeight => 13;
  @override double get shimmerSubtitleWidth => 120;
  // Orijinal tablet gövdesi iki boşluk için de shimmerSpacingSmall kullanıyordu
  // (medium yorum satırıydı) — görsel aynı kalsın diye medium = 8.
  @override double get shimmerSpacingSmall => 8;
  @override double get shimmerSpacingMedium => 8;
  @override double get shimmerPaddingTop => 14;
  @override double get shimmerPaddingBottom => 16;
  @override double get shimmerPaddingLeft => 16;
  @override double get shimmerPaddingRight => 16;

  @override double get bannerVerticalGap => 24;
  @override double get bannerBottomGap => 16;
  @override double get bannerPadding => 16;
  @override double get bannerContainerRadius => 20;
  @override double get bannerIconBox => 40;
  @override double get bannerIconRadius => 12;
  @override double get bannerIconSize => 24;
  @override double get bannerIconTextGap => 12;
  @override double get bannerTitleFontSize => 14;
  @override double get bannerSubtitleFontSize => 12;
  @override double get bannerActionGap => 8;
  @override double get bannerButtonRadius => 8;
  @override double get bannerButtonPadH => 14;
  @override double get bannerButtonPadV => 8;
  @override double get bannerButtonFontSize => 13;
}