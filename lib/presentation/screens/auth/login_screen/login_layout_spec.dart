// lib/presentation/screens/auth/login_sizes.dart


// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT — Stitch "Login - ÜniTV" tasarımının
// tüm ölçüleri. Phone → ScreenUtil ile ölçekli, Tablet → ham dp.
// ═══════════════════════════════════════════════════════════

abstract class LoginSizes {
  const LoginSizes();

  bool get isTablet;

  // ── Sayfa düzeni ──────────────────────────────────────────
  double get maxContentWidth;   // max-w-md (448)
  double get pageHPadding;      // px-margin (16)
  double get pageVPadding;      // py-space-lg (24)

  // ── Ambient glow ──────────────────────────────────────────
  double get glowPrimarySize;   // w-64 (256), -top-12 (-48)
  double get glowPrimaryTop;
  double get glowSecondarySize; // w-48 (192), top-48, -right-12
  double get glowSecondaryTop;
  double get glowSecondaryRight;

  // ── Marka başlığı ─────────────────────────────────────────
  double get brandBottomGap;    // mb-space-lg (24)
  double get logoPad;           // p-space-xs (4)
  double get logoRadius;        // rounded-xl (12)
  double get logoHeight;        // h-10 (40)
  double get badgeGap;          // gap-1.5 (6)
  double get badgeHPadding;     // px-space-sm (8)
  double get badgeVPadding;     // py-0.5 (2)
  double get badgeDotSize;      // w-1.5 (6)
  double get badgeFontSize;     // label-sm (10)

  // ── Karşılama ─────────────────────────────────────────────
  double get greetingBottomGap; // mb-space-xl (32)
  double get titleFontSize;     // headline-xl-mobile (26)
  double get titleSubtitleGap;  // mb-space-xs (4)
  double get subtitleFontSize;  // body-md (14)
  double get subtitleMaxWidth;  // max-w-xs (320)

  // ── Form kartı ────────────────────────────────────────────
  double get cardRadius;        // rounded-xl (12)
  double get cardPadding;       // p-space-lg (24)
  double get cardGap;           // gap-space-md (16)

  // ── Alanlar ───────────────────────────────────────────────
  double get fieldHeight;       // h-12 (48)
  double get fieldRadius;       // rounded-lg (8)
  double get fieldFontSize;     // body-md (14)
  double get fieldLabelFontSize;// label-md (12)
  double get fieldLabelGap;     // gap-space-xs (4)
  double get fieldIconSize;     // text-[20px]
  double get fieldIconLeft;     // left-space-md (16)
  double get fieldPaddingLeft;  // pl-11 (44)
  double get fieldPaddingRightEmail;    // pr-space-md (16)
  double get toggleSize;        // h-9 w-9 (36)
  double get toggleRight;       // right-space-sm (8)

  // ── Şifremi unuttum ───────────────────────────────────────
  double get forgotTopOffset;   // -mt-1 (4)

  // ── CTA / butonlar ────────────────────────────────────────
  double get buttonHeight;      // h-12 (48)
  double get submitTopGap;      // mt-space-xs (4)
  double get buttonFontSize;    // label-lg (14)
  double get buttonIconSize;    // text-[18px]
  double get googleIconSize;    // w-5 (20)
  double get googleGap;         // gap-space-md (16)
  double get guestButtonHeight; // h-11 (44)
  double get guestFontSize;     // label-md (12)
  double get guestIconSize;     // text-[18px]
  double get guestGap;          // gap-1.5 (6)

  // ── Ayraç ─────────────────────────────────────────────────
  double get dividerFontSize;   // label-sm (10)
  double get dividerHPadding;   // px-space-md (16)

  // ── Kayıt yönlendirmesi ───────────────────────────────────
  double get footerTopGap;      // mt-space-xl (32)
  double get footerFontSize;    // body-md (14)
  double get footerLinkFontSize;// label-lg (14)
  double get footerChevronSize; // text-[16px]

  // ── Canlı yayın teaser ────────────────────────────────────
  double get teaserTopGap;      // mt-space-xl (32)
  double get teaserPadding;     // p-space-md (16)
  double get teaserRadius;      // rounded-xl (12)
  double get teaserGap;         // gap-space-sm (8)
  double get teaserIconBoxSize; // w-10 (40)
  double get teaserIconBoxRadius; // rounded-lg (8)
  double get teaserIconSize;    // text-[22px]
  double get teaserPingSize;    // w-2 (8)
  double get teaserPingOffset;  // top-1 right-1 (4)
  double get teaserLabelFontSize; // label-sm (10)
  double get teaserTitleFontSize; // label-md (12)
  double get teaserBadgeDotSize;  // w-1.5 (6)
  double get teaserBadgeFontSize; // label-sm (10)

  // ── Hata bandı ────────────────────────────────────────────
  double get errorFontSize;
  double get errorPadding;
  double get errorRadius;

  // ── Loader ────────────────────────────────────────────────
  double get loaderSize;
  double get loaderStroke;
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class LoginPhoneSizes extends LoginSizes {
  const LoginPhoneSizes();

  @override bool get isTablet => false;

  @override double get maxContentWidth => 448;
  @override double get pageHPadding => 16;
  @override double get pageVPadding => 24;

  @override double get glowPrimarySize => 256;
  @override double get glowPrimaryTop => -48;
  @override double get glowSecondarySize => 192;
  @override double get glowSecondaryTop => 192;
  @override double get glowSecondaryRight => -48;

  @override double get brandBottomGap => 24;
  @override double get logoPad => 4;
  @override double get logoRadius => 12;
  @override double get logoHeight => 40;
  @override double get badgeGap => 6;
  @override double get badgeHPadding => 8;
  @override double get badgeVPadding => 2;
  @override double get badgeDotSize => 6;
  @override double get badgeFontSize => 10;

  @override double get greetingBottomGap => 32;
  @override double get titleFontSize => 26;
  @override double get titleSubtitleGap => 4;
  @override double get subtitleFontSize => 14;
  @override double get subtitleMaxWidth => 320;

  @override double get cardRadius => 12;
  @override double get cardPadding => 24;
  @override double get cardGap => 16;

  @override double get fieldHeight => 48;
  @override double get fieldRadius => 8;
  @override double get fieldFontSize => 14;
  @override double get fieldLabelFontSize => 12;
  @override double get fieldLabelGap => 4;
  @override double get fieldIconSize => 20;
  @override double get fieldIconLeft => 16;
  @override double get fieldPaddingLeft => 44;
  @override double get fieldPaddingRightEmail => 16;
  @override double get toggleSize => 36;
  @override double get toggleRight => 8;

  @override double get forgotTopOffset => 4;

  @override double get buttonHeight => 48;
  @override double get submitTopGap => 4;
  @override double get buttonFontSize => 14;
  @override double get buttonIconSize => 18;
  @override double get googleIconSize => 20;
  @override double get googleGap => 16;
  @override double get guestButtonHeight => 44;
  @override double get guestFontSize => 12;
  @override double get guestIconSize => 18;
  @override double get guestGap => 6;

  @override double get dividerFontSize => 10;
  @override double get dividerHPadding => 16;

  @override double get footerTopGap => 32;
  @override double get footerFontSize => 14;
  @override double get footerLinkFontSize => 14;
  @override double get footerChevronSize => 16;

  @override double get teaserTopGap => 32;
  @override double get teaserPadding => 16;
  @override double get teaserRadius => 12;
  @override double get teaserGap => 8;
  @override double get teaserIconBoxSize => 40;
  @override double get teaserIconBoxRadius => 8;
  @override double get teaserIconSize => 22;
  @override double get teaserPingSize => 8;
  @override double get teaserPingOffset => 4;
  @override double get teaserLabelFontSize => 10;
  @override double get teaserTitleFontSize => 12;
  @override double get teaserBadgeDotSize => 6;
  @override double get teaserBadgeFontSize => 10;

  @override double get errorFontSize => 13;
  @override double get errorPadding => 12;
  @override double get errorRadius => 10;

  @override double get loaderSize => 20;
  @override double get loaderStroke => 2.2;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class LoginTabletSizes extends LoginSizes {
  const LoginTabletSizes();

  @override bool get isTablet => true;

  @override double get maxContentWidth => 520;
  @override double get pageHPadding => 32;
  @override double get pageVPadding => 36;

  @override double get glowPrimarySize => 320;
  @override double get glowPrimaryTop => -56;
  @override double get glowSecondarySize => 240;
  @override double get glowSecondaryTop => 220;
  @override double get glowSecondaryRight => -56;

  @override double get brandBottomGap => 28;
  @override double get logoPad => 6;
  @override double get logoRadius => 14;
  @override double get logoHeight => 48;
  @override double get badgeGap => 8;
  @override double get badgeHPadding => 12;
  @override double get badgeVPadding => 4;
  @override double get badgeDotSize => 8;
  @override double get badgeFontSize => 12;

  @override double get greetingBottomGap => 40;
  @override double get titleFontSize => 32;
  @override double get titleSubtitleGap => 6;
  @override double get subtitleFontSize => 16;
  @override double get subtitleMaxWidth => 400;

  @override double get cardRadius => 16;
  @override double get cardPadding => 32;
  @override double get cardGap => 20;

  @override double get fieldHeight => 56;
  @override double get fieldRadius => 10;
  @override double get fieldFontSize => 15;
  @override double get fieldLabelFontSize => 13;
  @override double get fieldLabelGap => 6;
  @override double get fieldIconSize => 22;
  @override double get fieldIconLeft => 18;
  @override double get fieldPaddingLeft => 52;
  @override double get fieldPaddingRightEmail => 20;
  @override double get toggleSize => 40;
  @override double get toggleRight => 10;

  @override double get forgotTopOffset => 4;

  @override double get buttonHeight => 56;
  @override double get submitTopGap => 6;
  @override double get buttonFontSize => 15;
  @override double get buttonIconSize => 20;
  @override double get googleIconSize => 24;
  @override double get googleGap => 20;
  @override double get guestButtonHeight => 50;
  @override double get guestFontSize => 14;
  @override double get guestIconSize => 20;
  @override double get guestGap => 8;

  @override double get dividerFontSize => 12;
  @override double get dividerHPadding => 20;

  @override double get footerTopGap => 40;
  @override double get footerFontSize => 15;
  @override double get footerLinkFontSize => 15;
  @override double get footerChevronSize => 18;

  @override double get teaserTopGap => 40;
  @override double get teaserPadding => 20;
  @override double get teaserRadius => 14;
  @override double get teaserGap => 12;
  @override double get teaserIconBoxSize => 48;
  @override double get teaserIconBoxRadius => 10;
  @override double get teaserIconSize => 26;
  @override double get teaserPingSize => 10;
  @override double get teaserPingOffset => 5;
  @override double get teaserLabelFontSize => 12;
  @override double get teaserTitleFontSize => 13;
  @override double get teaserBadgeDotSize => 8;
  @override double get teaserBadgeFontSize => 12;

  @override double get errorFontSize => 14;
  @override double get errorPadding => 16;
  @override double get errorRadius => 12;

  @override double get loaderSize => 24;
  @override double get loaderStroke => 2.5;
}