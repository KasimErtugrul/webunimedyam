// lib/presentation/screens/signup_preferences/utils/singup_preferences_sizes.dart

// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT — Stitch "Tema Seçimi" + "Üniversite
// Seçimi" tasarımlarının tüm ölçüleri (5 adımlı akış).
// Phone → ScreenUtil ile ölçekli, Tablet → ham dp.
// ═══════════════════════════════════════════════════════════

abstract class SignupPreferencesSizes {
  const SignupPreferencesSizes();

  bool get isTablet;

  // ── Header (h-16 px-margin, blur bar) ─────────────────────
  double get headerHeight; // h-16 (64)
  double get headerHPadding; // px-margin (16)
  double get headerGap; // gap-space-sm (8)
  double get backButtonSize; // w-11 h-11 (44)
  double get backButtonIconSize; // text-[24px]
  double get logoHeight; // h-8 (32)
  double get headerTitleFontSize; // headline-sm (18)
  double get skipFontSize; // label-md (12)
  double get avatarSize; // w-8 h-8 (32)
  double get avatarIconSize; // text-[18px]

  // ── Progress tracker ──────────────────────────────────────
  double get progressVPadding; // py-space-md (16)
  double get progressLabelFontSize; // label-sm (10)
  double get progressLabelGap; // gap-space-xs (4)
  double get progressDotSize; // w-2 (8)
  double get segmentHeight; // h-1.5 (6)
  double get segmentGap; // gap-1.5 (6)

  // ── Intro kartı (ambient glow) ────────────────────────────
  double get introRadius; // rounded-xl (12)
  double get introPadding; // p-space-md (16)
  double get introBottomGap; // mb-space-lg (24)
  double get introGlowSize; // w-32 h-32 (128)
  double get introGlowOffset; // -right-8 -top-8 (32)
  double get introIconBoxSize; // w-10 h-10 (40)
  double get introIconBoxRadius; // rounded-lg (8)
  double get introIconSize; // text-[24px]
  double get introTitleFontSize; // headline-xl-mobile (26)
  double get introDescFontSize; // body-md (14)
  double get introTitleDescGap; // mt-space-xs (4)
  double get introIconTextGap; // gap-space-sm (8)

  // ── Seçenek kartları ──────────────────────────────────────
  double get cardRadius; // rounded-xl (12)
  double get cardPadding; // p-space-md (16)
  double get cardGap; // gap-space-md (16)
  double get optionIconCircleSize; // w-9 h-9 (36)
  double get optionIconSize; // text-[20px]
  double get optionTitleFontSize; // headline-sm (18)
  double get optionSubtitleFontSize; // body-sm (12)
  double get optionBadgeFontSize; // label-sm (10)
  double get optionBadgeHPadding; // px-1.5 (6)
  double get optionBadgeVPadding; // py-0.5 (2)
  double get optionBadgeGap; // gap-1.5 (6)
  double get radioSize; // w-6 h-6 (24)
  double get radioIconSize; // text-[16px]
  double get mockupHeight; // h-24 (96)
  double get mockupRadius; // rounded-lg (8)
  double get headerMockupGap; // mb-space-md (16)

  // ── Mini mockup öğeleri ───────────────────────────────────
  double get mPad; // p-2.5 (10)
  double get mDot; // w-3 (12)
  double get mBarW; // w-14 (56)
  double get mBarWShort; // w-10 (40)
  double get mBarH; // h-2 (8)
  double get mLineH; // h-2 (8)
  double get mLineHSm; // h-1.5 (6)
  double get mCircle; // w-4 (16)
  double get mThumbW; // w-16 (64)
  double get mThumbWShort; // w-8 (32)
  double get mThumbH; // h-11 (44)
  double get mThumbRadius; // rounded-md (6)
  double get mThumbIcon; // text-[14px]
  double get mMiniIcon; // text-[12px]
  double get mIconBox; // w-8 (32)
  double get mNavW; // w-4 (16)
  double get mNavH; // h-1 (4)
  double get mMiniGap; // gap-1.5 (6)

  // ── Footer / buton ────────────────────────────────────────
  double get buttonHeight; // h-14 (56)
  double get buttonRadius; // rounded-lg (8)
  double get dockButtonRadius; // rounded-xl (12)
  double get buttonFontSize; // headline-sm (18)
  double get buttonIconSize; // text-[22px]
  double get rocketIconSize; // text-[24px]
  double get footerTopGap; // mt-space-xl (32)
  double get captionFontSize; // body-sm (12)
  double get dockCaptionFontSize; // label-sm (10)
  double get dockHPadding; // px-margin (16)
  double get dockVPadding; // py-space-sm (8)
  double get footerHPadding;

  // ── Üniversite adımı ──────────────────────────────────────
  double get pillGap; // gap-1.5 (6)
  double get pillHPadding; // px-2.5 (10)
  double get pillVPadding; // py-1 (4)
  double get pillFontSize; // label-sm (10)
  double get pillIconSize; // text-[14px]
  double get pillBottomGap; // mb-space-sm (8)
  double get titleDescGap; // mb-space-xs (4)
  double get searchHeight; // h-12 (48)
  double get searchRadius; // rounded-xl (12)
  double get searchIconSize; // text-[20px]
  double get searchIconLeft; // left-3.5 (14)
  double get searchPaddingLeft; // pl-11 (44)
  double get clearIconSize; // text-[18px]
  double get clearRight; // right-3 (12)
  double get sectionGap; // space-md (16)
  double get counterFontSize; // label-lg (14)
  double get counterIconSize; // text-[18px]
  double get clearAllFontSize; // label-md (12)
  double get gridGap; // gap-gutter-sm (12)
  double get uniCardRadius; // rounded-xl (12)
  double get uniCardPadding; // p-space-md (16)
  double get uniBadgeSize; // w-6 h-6 (24)
  double get uniBadgeOffset; // top/right-2.5 (10)
  double get uniBadgeIconSize; // text-[16px]
  double get uniEmblemSize; // w-13 h-13 (52)
  double get uniEmblemRadius; // rounded-xl (12)
  double get uniEmblemPadding; // p-2 (8)
  double get uniEmblemIconSize;
  double get uniNameFontSize; // headline-sm (18)
  double get uniFullNameFontSize; // body-sm (12)
  double get uniTagFontSize; // label-sm (10)
  double get uniTagHPadding; // px-2 (8)
  double get uniTagVPadding; // py-0.5 (2)
  double get uniTagGap; // gap-1.5 (6)
  double get gridBottomClearance; // pb-28 (112)
  double get emptyIconBox; // w-16 h-16 (64)
  double get emptyIconSize; // text-[32px]
  double get emptyTitleFontSize; // headline-sm (18)
  double get emptyDescFontSize; // body-md (14)
  double get emptyDescMaxWidth; // max-w-xs (320)

  // Şehir / Seçilenler filtre çipleri
  double get chipHPadding; // px-3 (12)
  double get chipVPadding; // py-1.5 (6)
  double get chipFontSize; // label-md (12)
  double get chipGap; // gap-1.5 (6) — ikon ile metin arası
  double get chipSpacing; // çipler arası boşluk (4)
  double get chipIconSize; // label-md (12)
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class SignupPreferencesPhoneSizes extends SignupPreferencesSizes {
  const SignupPreferencesPhoneSizes();

  @override
  bool get isTablet => false;

  @override
  double get headerHeight => 64;
  @override
  double get headerHPadding => 16;
  @override
  double get headerGap => 8;
  @override
  double get backButtonSize => 44;
  @override
  double get backButtonIconSize => 24;
  @override
  double get logoHeight => 32;
  @override
  double get headerTitleFontSize => 18;
  @override
  double get skipFontSize => 12;
  @override
  double get avatarSize => 32;
  @override
  double get avatarIconSize => 18;

  @override
  double get progressVPadding => 16;
  @override
  double get progressLabelFontSize => 10;
  @override
  double get progressLabelGap => 4;
  @override
  double get progressDotSize => 8;
  @override
  double get segmentHeight => 6;
  @override
  double get segmentGap => 6;

  @override
  double get introRadius => 12;
  @override
  double get introPadding => 16;
  @override
  double get introBottomGap => 24;
  @override
  double get introGlowSize => 128;
  @override
  double get introGlowOffset => 32;
  @override
  double get introIconBoxSize => 40;
  @override
  double get introIconBoxRadius => 8;
  @override
  double get introIconSize => 24;
  @override
  double get introTitleFontSize => 26;
  @override
  double get introDescFontSize => 14;
  @override
  double get introTitleDescGap => 4;
  @override
  double get introIconTextGap => 8;

  @override
  double get cardRadius => 12;
  @override
  double get cardPadding => 16;
  @override
  double get cardGap => 16;
  @override
  double get optionIconCircleSize => 36;
  @override
  double get optionIconSize => 20;
  @override
  double get optionTitleFontSize => 18;
  @override
  double get optionSubtitleFontSize => 12;
  @override
  double get optionBadgeFontSize => 10;
  @override
  double get optionBadgeHPadding => 6;
  @override
  double get optionBadgeVPadding => 2;
  @override
  double get optionBadgeGap => 6;
  @override
  double get radioSize => 24;
  @override
  double get radioIconSize => 16;
  @override
  double get mockupHeight => 96;
  @override
  double get mockupRadius => 8;
  @override
  double get headerMockupGap => 16;

  @override
  double get mPad => 10;
  @override
  double get mDot => 12;
  @override
  double get mBarW => 56;
  @override
  double get mBarWShort => 40;
  @override
  double get mBarH => 8;
  @override
  double get mLineH => 8;
  @override
  double get mLineHSm => 6;
  @override
  double get mCircle => 16;
  @override
  double get mThumbW => 64;
  @override
  double get mThumbWShort => 32;
  @override
  double get mThumbH => 44;
  @override
  double get mThumbRadius => 6;
  @override
  double get mThumbIcon => 14;
  @override
  double get mMiniIcon => 12;
  @override
  double get mIconBox => 32;
  @override
  double get mNavW => 16;
  @override
  double get mNavH => 4;
  @override
  double get mMiniGap => 6;

  @override
  double get buttonHeight => 56;
  @override
  double get buttonRadius => 8;
  @override
  double get dockButtonRadius => 12;
  @override
  double get buttonFontSize => 18;
  @override
  double get buttonIconSize => 22;
  @override
  double get rocketIconSize => 24;
  @override
  double get footerTopGap => 32;
  @override
  double get captionFontSize => 12;
  @override
  double get dockCaptionFontSize => 10;
  @override
  double get dockHPadding => 16;
  @override
  double get dockVPadding => 8;
  @override
  double get footerHPadding => 16;

  @override
  double get pillGap => 6;
  @override
  double get pillHPadding => 10;
  @override
  double get pillVPadding => 4;
  @override
  double get pillFontSize => 10;
  @override
  double get pillIconSize => 14;
  @override
  double get pillBottomGap => 8;
  @override
  double get titleDescGap => 4;
  @override
  double get searchHeight => 48;
  @override
  double get searchRadius => 12;
  @override
  double get searchIconSize => 20;
  @override
  double get searchIconLeft => 14;
  @override
  double get searchPaddingLeft => 44;
  @override
  double get clearIconSize => 18;
  @override
  double get clearRight => 12;
  @override
  double get sectionGap => 16;
  @override
  double get counterFontSize => 14;
  @override
  double get counterIconSize => 18;
  @override
  double get clearAllFontSize => 12;
  @override
  double get gridGap => 12;
  @override
  double get uniCardRadius => 12;
  @override
  double get uniCardPadding => 16;
  @override
  double get uniBadgeSize => 24;
  @override
  double get uniBadgeOffset => 10;
  @override
  double get uniBadgeIconSize => 16;
  @override
  double get uniEmblemSize => 52;
  @override
  double get uniEmblemRadius => 12;
  @override
  double get uniEmblemPadding => 8;
  @override
  double get uniEmblemIconSize => 24;
  @override
  double get uniNameFontSize => 18;
  @override
  double get uniFullNameFontSize => 12;
  @override
  double get uniTagFontSize => 10;
  @override
  double get uniTagHPadding => 8;
  @override
  double get uniTagVPadding => 2;
  @override
  double get uniTagGap => 6;
  @override
  double get gridBottomClearance => 112;
  @override
  double get emptyIconBox => 64;
  @override
  double get emptyIconSize => 32;
  @override
  double get emptyTitleFontSize => 18;
  @override
  double get emptyDescFontSize => 14;
  @override
  double get emptyDescMaxWidth => 320;
  // Şehir / Seçilenler filtre çipleri
  @override
  double get chipHPadding => 12;
  @override
  double get chipVPadding => 6;
  @override
  double get chipFontSize => 12;
  @override
  double get chipGap => 6;
  @override
  double get chipSpacing => 4;
  @override
  double get chipIconSize => 12;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class SignupPreferencesTabletSizes extends SignupPreferencesSizes {
  const SignupPreferencesTabletSizes();

  @override
  bool get isTablet => true;

  @override
  double get headerHeight => 72;
  @override
  double get headerHPadding => 32;
  @override
  double get headerGap => 12;
  @override
  double get backButtonSize => 50;
  @override
  double get backButtonIconSize => 26;
  @override
  double get logoHeight => 36;
  @override
  double get headerTitleFontSize => 21;
  @override
  double get skipFontSize => 14;
  @override
  double get avatarSize => 38;
  @override
  double get avatarIconSize => 20;

  @override
  double get progressVPadding => 20;
  @override
  double get progressLabelFontSize => 12;
  @override
  double get progressLabelGap => 6;
  @override
  double get progressDotSize => 10;
  @override
  double get segmentHeight => 8;
  @override
  double get segmentGap => 8;

  @override
  double get introRadius => 16;
  @override
  double get introPadding => 22;
  @override
  double get introBottomGap => 30;
  @override
  double get introGlowSize => 160;
  @override
  double get introGlowOffset => 40;
  @override
  double get introIconBoxSize => 50;
  @override
  double get introIconBoxRadius => 12;
  @override
  double get introIconSize => 28;
  @override
  double get introTitleFontSize => 32;
  @override
  double get introDescFontSize => 16;
  @override
  double get introTitleDescGap => 6;
  @override
  double get introIconTextGap => 12;

  @override
  double get cardRadius => 16;
  @override
  double get cardPadding => 22;
  @override
  double get cardGap => 18;
  @override
  double get optionIconCircleSize => 44;
  @override
  double get optionIconSize => 24;
  @override
  double get optionTitleFontSize => 21;
  @override
  double get optionSubtitleFontSize => 14;
  @override
  double get optionBadgeFontSize => 12;
  @override
  double get optionBadgeHPadding => 8;
  @override
  double get optionBadgeVPadding => 4;
  @override
  double get optionBadgeGap => 8;
  @override
  double get radioSize => 30;
  @override
  double get radioIconSize => 18;
  @override
  double get mockupHeight => 124;
  @override
  double get mockupRadius => 12;
  @override
  double get headerMockupGap => 20;

  @override
  double get mPad => 14;
  @override
  double get mDot => 15;
  @override
  double get mBarW => 70;
  @override
  double get mBarWShort => 50;
  @override
  double get mBarH => 10;
  @override
  double get mLineH => 10;
  @override
  double get mLineHSm => 8;
  @override
  double get mCircle => 20;
  @override
  double get mThumbW => 80;
  @override
  double get mThumbWShort => 40;
  @override
  double get mThumbH => 56;
  @override
  double get mThumbRadius => 8;
  @override
  double get mThumbIcon => 17;
  @override
  double get mMiniIcon => 14;
  @override
  double get mIconBox => 40;
  @override
  double get mNavW => 20;
  @override
  double get mNavH => 5;
  @override
  double get mMiniGap => 8;

  @override
  double get buttonHeight => 62;
  @override
  double get buttonRadius => 12;
  @override
  double get dockButtonRadius => 16;
  @override
  double get buttonFontSize => 20;
  @override
  double get buttonIconSize => 24;
  @override
  double get rocketIconSize => 27;
  @override
  double get footerTopGap => 36;
  @override
  double get captionFontSize => 14;
  @override
  double get dockCaptionFontSize => 12;
  @override
  double get dockHPadding => 24;
  @override
  double get dockVPadding => 12;
  @override
  double get footerHPadding => 24;

  @override
  double get pillGap => 8;
  @override
  double get pillHPadding => 14;
  @override
  double get pillVPadding => 6;
  @override
  double get pillFontSize => 12;
  @override
  double get pillIconSize => 16;
  @override
  double get pillBottomGap => 12;
  @override
  double get titleDescGap => 6;
  @override
  double get searchHeight => 56;
  @override
  double get searchRadius => 14;
  @override
  double get searchIconSize => 22;
  @override
  double get searchIconLeft => 18;
  @override
  double get searchPaddingLeft => 52;
  @override
  double get clearIconSize => 20;
  @override
  double get clearRight => 14;
  @override
  double get sectionGap => 20;
  @override
  double get counterFontSize => 16;
  @override
  double get counterIconSize => 20;
  @override
  double get clearAllFontSize => 14;
  @override
  double get gridGap => 14;
  @override
  double get uniCardRadius => 16;
  @override
  double get uniCardPadding => 18;
  @override
  double get uniBadgeSize => 28;
  @override
  double get uniBadgeOffset => 12;
  @override
  double get uniBadgeIconSize => 18;
  @override
  double get uniEmblemSize => 62;
  @override
  double get uniEmblemRadius => 14;
  @override
  double get uniEmblemPadding => 10;
  @override
  double get uniEmblemIconSize => 28;
  @override
  double get uniNameFontSize => 21;
  @override
  double get uniFullNameFontSize => 13;
  @override
  double get uniTagFontSize => 12;
  @override
  double get uniTagHPadding => 10;
  @override
  double get uniTagVPadding => 4;
  @override
  double get uniTagGap => 8;
  @override
  double get gridBottomClearance => 120;
  @override
  double get emptyIconBox => 76;
  @override
  double get emptyIconSize => 38;
  @override
  double get emptyTitleFontSize => 21;
  @override
  double get emptyDescFontSize => 15;
  @override
  double get emptyDescMaxWidth => 400;
  // Şehir / Seçilenler filtre çipleri
  @override
  double get chipHPadding => 16;
  @override
  double get chipVPadding => 8;
  @override
  double get chipFontSize => 14;
  @override
  double get chipGap => 8;
  @override
  double get chipSpacing => 6;
  @override
  double get chipIconSize => 14;
}
