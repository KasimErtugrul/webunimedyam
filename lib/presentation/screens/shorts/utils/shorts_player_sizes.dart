// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// ═══════════════════════════════════════════════════════════

abstract class ShortsPlayerSizes {
  const ShortsPlayerSizes();

  bool get isTablet;

  // Top bar
  double get topBarPaddingHorizontal;
  double get topBarPaddingVertical;
  double get backIconSize;
  double get shortsBadgePaddingHorizontal;
  double get shortsBadgePaddingVertical;
  double get shortsBadgeBorderRadius;
  double get shortsBadgeFontSize;
  double get shortsBadgeLetterSpacing;
  double get counterFontSize;
  double get counterSpacing;
  double get muteButtonSize;
  double get muteIconSize;

  // Üniversite logo wheel
  double get wheelHeight;
  double get wheelItemExtent;
  double get wheelActiveLogoSize;
  double get wheelInactiveLogoSize;
  double get wheelLogoPadding;
  double get wheelDiameterRatio;
  double get wheelPerspective;
  double get wheelHintFontSize;
  double get wheelHintSpacing;

  // Sayfa / bölüm düzeni
  double get pageHorizontalPadding;
  double get sectionSpacing;

  // Saf video alanı
  double get videoMaxWidth; // tablet'te sol kolon genişliği
  double get videoBorderRadius;
  double get videoAspectRatio; // width / height

  // İlerleme çubuğu
  double get progressBarHeight;
  double get progressBarRadius;
  double get timeLabelFontSize;

  // Aksiyon çubuğu (beğen / kaydet / paylaş / ses)
  double get actionBarPadding;
  double get actionBarRadius;
  double get actionIconContainerSize;
  double get actionIconSize;
  double get actionLabelFontSize;
  double get actionLabelSpacing;

  // Kanal / bilgi kartı
  double get cardPadding;
  double get cardBorderRadius;
  double get avatarSize;
  double get avatarBorderWidth;
  double get channelNameFontSize;
  double get channelSubFontSize;
  double get followBtnPaddingHorizontal;
  double get followBtnPaddingVertical;
  double get followBtnFontSize;
  double get followBtnRadius;
  double get descriptionFontSize;
  double get descriptionLineHeight;

  // "Tam İzle" CTA
  double get ctaHeight;
  double get ctaFontSize;
  double get ctaIconSize;
  double get ctaRadius;

  // İlgili shorts rafı
  double get relatedTitleFontSize;
  double get relatedItemWidth;
  double get relatedItemRadius;
  double get relatedItemSpacing;
  double get relatedThumbAspectRatio;
  double get relatedCardTitleFontSize;
  double get relatedDurationFontSize;

  // Play/pause ortası
  double get playIconSize;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class ShortsPlayerPhoneSizes extends ShortsPlayerSizes {
  const ShortsPlayerPhoneSizes();

  @override
  bool get isTablet => false;

  @override
  double get topBarPaddingHorizontal => 4;
  @override
  double get topBarPaddingVertical => 2;
  @override
  double get backIconSize => 20;
  @override
  double get shortsBadgePaddingHorizontal => 8;
  @override
  double get shortsBadgePaddingVertical => 3;
  @override
  double get shortsBadgeBorderRadius => 5;
  @override
  double get shortsBadgeFontSize => 10;
  @override
  double get shortsBadgeLetterSpacing => 1.2;
  @override
  double get counterFontSize => 12;
  @override
  double get counterSpacing => 8;
  @override
  double get muteButtonSize => 34;
  @override
  double get muteIconSize => 16;

  @override
  double get wheelHeight => 92;
  @override
  double get wheelItemExtent => 68;
  @override
  double get wheelActiveLogoSize => 54;
  @override
  double get wheelInactiveLogoSize => 38;
  @override
  double get wheelLogoPadding => 6;
  @override
  double get wheelDiameterRatio => 2.0;
  @override
  double get wheelPerspective => 0.0022;
  @override
  double get wheelHintFontSize => 11;
  @override
  double get wheelHintSpacing => 4;

  @override
  double get pageHorizontalPadding => 16;
  @override
  double get sectionSpacing => 12;

  @override
  double get videoMaxWidth => double.infinity;
  @override
  double get videoBorderRadius => 18;
  @override
  double get videoAspectRatio => 9 / 14;

  @override
  double get progressBarHeight => 5;
  @override
  double get progressBarRadius => 3;
  @override
  double get timeLabelFontSize => 11;

  @override
  double get actionBarPadding => 8;
  @override
  double get actionBarRadius => 16;
  @override
  double get actionIconContainerSize => 38;
  @override
  double get actionIconSize => 20;
  @override
  double get actionLabelFontSize => 11;
  @override
  double get actionLabelSpacing => 3;

  @override
  double get cardPadding => 14;
  @override
  double get cardBorderRadius => 18;
  @override
  double get avatarSize => 40;
  @override
  double get avatarBorderWidth => 2;
  @override
  double get channelNameFontSize => 14;
  @override
  double get channelSubFontSize => 12;
  @override
  double get followBtnPaddingHorizontal => 14;
  @override
  double get followBtnPaddingVertical => 8;
  @override
  double get followBtnFontSize => 12.5;
  @override
  double get followBtnRadius => 999;
  @override
  double get descriptionFontSize => 13.5;
  @override
  double get descriptionLineHeight => 1.4;

  @override
  double get ctaHeight => 46;
  @override
  double get ctaFontSize => 14;
  @override
  double get ctaIconSize => 18;
  @override
  double get ctaRadius => 12;

  @override
  double get relatedTitleFontSize => 15;
  @override
  double get relatedItemWidth => 132;
  @override
  double get relatedItemRadius => 14;
  @override
  double get relatedItemSpacing => 10;
  @override
  double get relatedThumbAspectRatio => 9 / 13;
  @override
  double get relatedCardTitleFontSize => 12;
  @override
  double get relatedDurationFontSize => 10;

  @override
  double get playIconSize => 60;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class ShortsPlayerTabletSizes extends ShortsPlayerSizes {
  const ShortsPlayerTabletSizes();

  @override
  bool get isTablet => true;

  @override
  double get topBarPaddingHorizontal => 8;
  @override
  double get topBarPaddingVertical => 4;
  @override
  double get backIconSize => 24;
  @override
  double get shortsBadgePaddingHorizontal => 10;
  @override
  double get shortsBadgePaddingVertical => 4;
  @override
  double get shortsBadgeBorderRadius => 6;
  @override
  double get shortsBadgeFontSize => 12;
  @override
  double get shortsBadgeLetterSpacing => 1.4;
  @override
  double get counterFontSize => 14;
  @override
  double get counterSpacing => 10;
  @override
  double get muteButtonSize => 40;
  @override
  double get muteIconSize => 20;

  @override
  double get wheelHeight => 112;
  @override
  double get wheelItemExtent => 84;
  @override
  double get wheelActiveLogoSize => 68;
  @override
  double get wheelInactiveLogoSize => 46;
  @override
  double get wheelLogoPadding => 8;
  @override
  double get wheelDiameterRatio => 2.2;
  @override
  double get wheelPerspective => 0.0020;
  @override
  double get wheelHintFontSize => 13;
  @override
  double get wheelHintSpacing => 6;

  @override
  double get pageHorizontalPadding => 28;
  @override
  double get sectionSpacing => 16;

  @override
  double get videoMaxWidth => 420;
  @override
  double get videoBorderRadius => 22;
  @override
  double get videoAspectRatio => 9 / 16;

  @override
  double get progressBarHeight => 6;
  @override
  double get progressBarRadius => 3;
  @override
  double get timeLabelFontSize => 12;

  @override
  double get actionBarPadding => 8;
  @override
  double get actionBarRadius => 18;
  @override
  double get actionIconContainerSize => 44;
  @override
  double get actionIconSize => 22;
  @override
  double get actionLabelFontSize => 12;
  @override
  double get actionLabelSpacing => 4;

  @override
  double get cardPadding => 18;
  @override
  double get cardBorderRadius => 22;
  @override
  double get avatarSize => 52;
  @override
  double get avatarBorderWidth => 2.5;
  @override
  double get channelNameFontSize => 17;
  @override
  double get channelSubFontSize => 13;
  @override
  double get followBtnPaddingHorizontal => 18;
  @override
  double get followBtnPaddingVertical => 10;
  @override
  double get followBtnFontSize => 14;
  @override
  double get followBtnRadius => 999;
  @override
  double get descriptionFontSize => 14.5;
  @override
  double get descriptionLineHeight => 1.45;

  @override
  double get ctaHeight => 50;
  @override
  double get ctaFontSize => 15;
  @override
  double get ctaIconSize => 20;
  @override
  double get ctaRadius => 14;

  @override
  double get relatedTitleFontSize => 18;
  @override
  double get relatedItemWidth => 168;
  @override
  double get relatedItemRadius => 16;
  @override
  double get relatedItemSpacing => 14;
  @override
  double get relatedThumbAspectRatio => 9 / 12;
  @override
  double get relatedCardTitleFontSize => 13.5;
  @override
  double get relatedDurationFontSize => 11;

  @override
  double get playIconSize => 76;
}
