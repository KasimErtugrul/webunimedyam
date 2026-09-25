// lib/presentation/screens/auth/register_sizes.dart


// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT — Stitch "Register - ÜniTV" tasarımının
// tüm ölçüleri. Phone → ScreenUtil ile ölçekli, Tablet → ham dp.
// ═══════════════════════════════════════════════════════════

abstract class RegisterSizes {
  const RegisterSizes();

  bool get isTablet;

  // ── Sayfa ─────────────────────────────────────────────────
  double get maxContentWidth;
  double get pageHPadding;      // px-margin (16)
  double get pageBottomPadding; // pb-space-xl (32)

  // ── Üst bar ───────────────────────────────────────────────
  double get topBarVPadding;    // py-space-md (16)
  double get backButtonSize;    // w-10 h-10 (40)
  double get backButtonIconSize;// text-body-lg (16)
  double get livePillGap;       // gap-space-xs (4)
  double get livePillHPadding;  // px-space-sm (8)
  double get livePillVPadding;  // py-1 (4)
  double get livePillDotSize;   // w-2 (8)
  double get livePillFontSize;  // label-sm (10)

  // ── Başlık bölümü ─────────────────────────────────────────
  double get headerTopGap;      // mt-space-sm (8)
  double get headerBottomGap;   // mb-space-lg (24)
  double get headerGroupGap;    // gap-space-xs (4)
  double get headerLabelFontSize; // label-md (12)
  double get headerLabelIconSize; // label-lg (14)
  double get titleFontSize;     // headline-xl-mobile (26)
  double get descFontSize;      // body-md (14)
  double get descLineHeight;    // leading-relaxed (1.625)

  // ── Kampüs önizleme kartı ─────────────────────────────────
  double get previewRadius;     // rounded-xl (12)
  double get previewPadding;    // p-space-md (16)
  double get previewGap;        // gap-space-md (16)
  double get previewImageSize;  // w-14 h-14 (56)
  double get previewImageRadius;// rounded-lg (8)
  double get previewTitleFontSize; // label-md (12)
  double get previewVerifiedIconSize; // label-sm (10)
  double get previewSubFontSize;   // body-sm (12)

  // ── Form ──────────────────────────────────────────────────
  double get formGap;           // gap-space-md (16)
  double get fieldGroupGap;     // gap-space-xs (4)
  double get labelFontSize;     // label-md (12)
  double get labelHintFontSize; // label-sm (10)
  double get fieldRadius;       // rounded-lg (8)
  double get fieldFontSize;     // body-md (14)
  double get fieldIconSize;     // text-body-lg (16)
  double get fieldIconLeft;     // left-3.5 (14)
  double get fieldPaddingLeft;  // pl-11 (44)
  double get fieldPaddingRight; // pr-4 (16)
  double get fieldPaddingRightPassword; // pr-12 (48)
  double get fieldVPadding;     // py-3 (12)
  double get toggleSize;        // w-8 h-8 (32)
  double get toggleRight;       // right-2 (8)
  double get toggleIconSize;    // text-body-lg (16)

  // ── Şifre gücü ────────────────────────────────────────────
  double get strengthTopGap;    // mt-1 (4)
  double get strengthRowHPadding; // px-1 (4)
  double get strengthRowGap;    // gap-space-sm (8)
  double get strengthBarHeight; // h-1 (4)
  double get strengthBarGap;    // gap-1 (4)
  double get strengthHintFontSize; // label-sm (10)

  // ── Kampüs kartı ──────────────────────────────────────────
  double get campusTopGap;      // mt-space-xs (4)
  double get campusCardPadding; // p-space-md (16)
  double get campusCardRadius;  // rounded-xl (12)
  double get campusCardGap;     // gap-space-md (16)
  double get campusIconBoxSize; // w-9 h-9 (36)
  double get campusIconBoxRadius; // rounded-lg (8)
  double get campusIconSize;    // text-headline-sm (18)
  double get campusTitleFontSize; // label-lg (14)
  double get campusSubFontSize; // body-sm (12)
  double get chevronSize;       // w-8 h-8 (32)
  double get chevronIconSize;   // ~18
  double get chipHPadding;      // px-3 (12)
  double get chipVPadding;      // py-1.5 (6)
  double get chipFontSize;      // label-md (12)
  double get chipGap;           // gap-1.5 (6)
  double get chipSpacing;       // gap-space-xs (4)
  double get chipIconSize;      // label-md (12)
  double get dropdownRadius;    // rounded-lg (8)
  double get dropdownVPadding;  // py-2.5 (10)
  double get dropdownHPadding;  // px-3 (12)
  double get dropdownFontSize;  // body-md (14)
  double get dropdownIconSize;  // text-body-md (14)

  // ── Koşul checkbox ────────────────────────────────────────
  double get termsTopGap;       // mt-space-xs (4)
  double get termsGap;          // gap-space-sm (8)
  double get termsBoxSize;      // w-5 h-5 (20)
  double get termsBoxRadius;    // rounded (4)
  double get termsIconSize;     // text-body-md (14)
  double get termsFontSize;     // body-sm (12)

  // ── Submit ────────────────────────────────────────────────
  double get submitTopGap;      // mt-space-sm (8)
  double get submitHeight;      // py-3.5 + headline-sm satırı (~52)
  double get submitRadius;      // rounded-lg (8)
  double get submitFontSize;    // headline-sm (18)
  double get submitIconSize;    // text-headline-sm (18)
  double get submitHPadding;    // px-space-lg (24)

  // ── Login footer ──────────────────────────────────────────
  double get footerTopGap;      // mt-space-xl (32)
  double get footerVPadding;    // py-space-sm (8)
  double get footerGap;         // gap-space-xs (4)
  double get footerFontSize;    // body-md (14)
  double get footerLinkFontSize; // label-lg (14)
  double get footerLinkIconSize; // text-body-md (14)

  // ── Radyo şeridi ──────────────────────────────────────────
  double get stripTopGap;       // mt-space-md (16)
  double get stripPadding;      // p-space-sm (8)
  double get stripRadius;       // rounded-xl (12)
  double get stripIconSize;     // text-body-md (14)
  double get stripFontSize;     // label-sm (10)
  double get stripAvatarSize;   // w-5 h-5 (20)
  double get stripAvatarFontSize; // text-[10px]
  double get stripAvatarOverlap; // -space-x-1.5 (6)

  // ── Hata / loader ─────────────────────────────────────────
  double get errorFontSize;
  double get errorPadding;
  double get errorRadius;
  double get errorIconSize;
  double get errorMarginBottom;
  double get loaderSize;
  double get loaderStroke;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class RegisterPhoneSizes extends RegisterSizes {
  const RegisterPhoneSizes();

  @override bool get isTablet => false;

  @override double get maxContentWidth => 448;
  @override double get pageHPadding => 16;
  @override double get pageBottomPadding => 32;

  @override double get topBarVPadding => 16;
  @override double get backButtonSize => 40;
  @override double get backButtonIconSize => 16;
  @override double get livePillGap => 4;
  @override double get livePillHPadding => 8;
  @override double get livePillVPadding => 4;
  @override double get livePillDotSize => 8;
  @override double get livePillFontSize => 10;

  @override double get headerTopGap => 8;
  @override double get headerBottomGap => 24;
  @override double get headerGroupGap => 4;
  @override double get headerLabelFontSize => 12;
  @override double get headerLabelIconSize => 14;
  @override double get titleFontSize => 26;
  @override double get descFontSize => 14;
  @override double get descLineHeight => 1.625;

  @override double get previewRadius => 12;
  @override double get previewPadding => 16;
  @override double get previewGap => 16;
  @override double get previewImageSize => 56;
  @override double get previewImageRadius => 8;
  @override double get previewTitleFontSize => 12;
  @override double get previewVerifiedIconSize => 10;
  @override double get previewSubFontSize => 12;

  @override double get formGap => 16;
  @override double get fieldGroupGap => 4;
  @override double get labelFontSize => 12;
  @override double get labelHintFontSize => 10;
  @override double get fieldRadius => 8;
  @override double get fieldFontSize => 14;
  @override double get fieldIconSize => 16;
  @override double get fieldIconLeft => 14;
  @override double get fieldPaddingLeft => 44;
  @override double get fieldPaddingRight => 16;
  @override double get fieldPaddingRightPassword => 48;
  @override double get fieldVPadding => 12;
  @override double get toggleSize => 32;
  @override double get toggleRight => 8;
  @override double get toggleIconSize => 16;

  @override double get strengthTopGap => 4;
  @override double get strengthRowHPadding => 4;
  @override double get strengthRowGap => 8;
  @override double get strengthBarHeight => 4;
  @override double get strengthBarGap => 4;
  @override double get strengthHintFontSize => 10;

  @override double get campusTopGap => 4;
  @override double get campusCardPadding => 16;
  @override double get campusCardRadius => 12;
  @override double get campusCardGap => 16;
  @override double get campusIconBoxSize => 36;
  @override double get campusIconBoxRadius => 8;
  @override double get campusIconSize => 18;
  @override double get campusTitleFontSize => 14;
  @override double get campusSubFontSize => 12;
  @override double get chevronSize => 32;
  @override double get chevronIconSize => 18;
  @override double get chipHPadding => 12;
  @override double get chipVPadding => 6;
  @override double get chipFontSize => 12;
  @override double get chipGap => 6;
  @override double get chipSpacing => 4;
  @override double get chipIconSize => 12;
  @override double get dropdownRadius => 8;
  @override double get dropdownVPadding => 10;
  @override double get dropdownHPadding => 12;
  @override double get dropdownFontSize => 14;
  @override double get dropdownIconSize => 14;

  @override double get termsTopGap => 4;
  @override double get termsGap => 8;
  @override double get termsBoxSize => 20;
  @override double get termsBoxRadius => 4;
  @override double get termsIconSize => 14;
  @override double get termsFontSize => 12;

  @override double get submitTopGap => 8;
  @override double get submitHeight => 52;
  @override double get submitRadius => 8;
  @override double get submitFontSize => 18;
  @override double get submitIconSize => 18;
  @override double get submitHPadding => 24;

  @override double get footerTopGap => 32;
  @override double get footerVPadding => 8;
  @override double get footerGap => 4;
  @override double get footerFontSize => 14;
  @override double get footerLinkFontSize => 14;
  @override double get footerLinkIconSize => 14;

  @override double get stripTopGap => 16;
  @override double get stripPadding => 8;
  @override double get stripRadius => 12;
  @override double get stripIconSize => 14;
  @override double get stripFontSize => 10;
  @override double get stripAvatarSize => 20;
  @override double get stripAvatarFontSize => 10;
  @override double get stripAvatarOverlap => 6;

  @override double get errorFontSize => 13;
  @override double get errorPadding => 12;
  @override double get errorRadius => 10;
  @override double get errorIconSize => 20;
  @override double get errorMarginBottom => 12;
  @override double get loaderSize => 20;
  @override double get loaderStroke => 2.2;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class RegisterTabletSizes extends RegisterSizes {
  const RegisterTabletSizes();

  @override bool get isTablet => true;

  @override double get maxContentWidth => 520;
  @override double get pageHPadding => 32;
  @override double get pageBottomPadding => 40;

  @override double get topBarVPadding => 20;
  @override double get backButtonSize => 48;
  @override double get backButtonIconSize => 20;
  @override double get livePillGap => 6;
  @override double get livePillHPadding => 12;
  @override double get livePillVPadding => 6;
  @override double get livePillDotSize => 10;
  @override double get livePillFontSize => 12;

  @override double get headerTopGap => 10;
  @override double get headerBottomGap => 30;
  @override double get headerGroupGap => 6;
  @override double get headerLabelFontSize => 14;
  @override double get headerLabelIconSize => 16;
  @override double get titleFontSize => 32;
  @override double get descFontSize => 16;
  @override double get descLineHeight => 1.6;

  @override double get previewRadius => 16;
  @override double get previewPadding => 20;
  @override double get previewGap => 20;
  @override double get previewImageSize => 68;
  @override double get previewImageRadius => 10;
  @override double get previewTitleFontSize => 14;
  @override double get previewVerifiedIconSize => 12;
  @override double get previewSubFontSize => 13;

  @override double get formGap => 20;
  @override double get fieldGroupGap => 6;
  @override double get labelFontSize => 14;
  @override double get labelHintFontSize => 12;
  @override double get fieldRadius => 10;
  @override double get fieldFontSize => 15;
  @override double get fieldIconSize => 18;
  @override double get fieldIconLeft => 18;
  @override double get fieldPaddingLeft => 52;
  @override double get fieldPaddingRight => 20;
  @override double get fieldPaddingRightPassword => 56;
  @override double get fieldVPadding => 15;
  @override double get toggleSize => 38;
  @override double get toggleRight => 10;
  @override double get toggleIconSize => 18;

  @override double get strengthTopGap => 6;
  @override double get strengthRowHPadding => 4;
  @override double get strengthRowGap => 10;
  @override double get strengthBarHeight => 5;
  @override double get strengthBarGap => 5;
  @override double get strengthHintFontSize => 12;

  @override double get campusTopGap => 6;
  @override double get campusCardPadding => 20;
  @override double get campusCardRadius => 16;
  @override double get campusCardGap => 20;
  @override double get campusIconBoxSize => 44;
  @override double get campusIconBoxRadius => 10;
  @override double get campusIconSize => 22;
  @override double get campusTitleFontSize => 16;
  @override double get campusSubFontSize => 13;
  @override double get chevronSize => 38;
  @override double get chevronIconSize => 20;
  @override double get chipHPadding => 16;
  @override double get chipVPadding => 8;
  @override double get chipFontSize => 14;
  @override double get chipGap => 8;
  @override double get chipSpacing => 6;
  @override double get chipIconSize => 14;
  @override double get dropdownRadius => 10;
  @override double get dropdownVPadding => 13;
  @override double get dropdownHPadding => 16;
  @override double get dropdownFontSize => 15;
  @override double get dropdownIconSize => 16;

  @override double get termsTopGap => 6;
  @override double get termsGap => 10;
  @override double get termsBoxSize => 24;
  @override double get termsBoxRadius => 6;
  @override double get termsIconSize => 16;
  @override double get termsFontSize => 13;

  @override double get submitTopGap => 10;
  @override double get submitHeight => 60;
  @override double get submitRadius => 10;
  @override double get submitFontSize => 20;
  @override double get submitIconSize => 20;
  @override double get submitHPadding => 28;

  @override double get footerTopGap => 40;
  @override double get footerVPadding => 10;
  @override double get footerGap => 6;
  @override double get footerFontSize => 15;
  @override double get footerLinkFontSize => 15;
  @override double get footerLinkIconSize => 16;

  @override double get stripTopGap => 20;
  @override double get stripPadding => 12;
  @override double get stripRadius => 16;
  @override double get stripIconSize => 16;
  @override double get stripFontSize => 12;
  @override double get stripAvatarSize => 24;
  @override double get stripAvatarFontSize => 11;
  @override double get stripAvatarOverlap => 7;

  @override double get errorFontSize => 14;
  @override double get errorPadding => 16;
  @override double get errorRadius => 12;
  @override double get errorIconSize => 22;
  @override double get errorMarginBottom => 16;
  @override double get loaderSize => 24;
  @override double get loaderStroke => 2.5;
}