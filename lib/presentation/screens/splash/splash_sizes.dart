/* // lib/presentation/screens/splash/splash_sizes.dart

// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT — Stitch "Splash Screen - ÜniTV"
// tasarımının tüm ölçüleri. Phone → ScreenUtil, Tablet → ham dp.
// ═══════════════════════════════════════════════════════════

abstract class SplashSizes {
  const SplashSizes();

  bool get isTablet;

  // ── Sayfa ─────────────────────────────────────────────────
  double get pageHPadding; // px-space-lg (24)
  double get pageVPadding; // py-space-xl (32)

  // ── Ambient glow ──────────────────────────────────────────
  double get glowPrimarySize; // w-80 (320) animate-pulse
  double get glowSecondarySize; // w-56 (224)

  // ── Grid vektörler ────────────────────────────────────────
  double get gridMaxWidth; // max-w-sm (384)
  double get gridMaxHeight; // viewBox oranı (600)

  // ── Üst etiket ────────────────────────────────────────────
  double get tagTopPadding; // pt-space-md (16)
  double get tagPillHPadding; // px-space-md (16)
  double get tagPillVPadding; // py-1.5 (6)
  double get tagDotSize; // w-2 (8)
  double get tagGap; // gap-space-xs (4)
  double get tagFontSize; // label-sm (10)

  // ── Hero ──────────────────────────────────────────────────
  double get heroMaxWidth; // max-w-xs (320)
  double get heroVerticalGap; // my-space-xl (32)
  double get logoImageWidth; // w-44 (176)
  double get logoImageHeight; // görsel yüksekliği
  double get logoPad; // p-space-md (16)
  double get logoRadius; // rounded-xl (12)
  double get auraExtent; // -inset-4 (16) → aura taşması
  double get auraRadius; // blur-xl yumuşaklık payı

  // HD badge — absolute -bottom-2.5 -right-2
  double get hdBadgeBottom; // -bottom-2.5 (10)
  double get hdBadgeRight; // -right-2 (8)
  double get hdBadgeHPadding; // px-2 (8)
  double get hdBadgeVPadding; // py-0.5 (2)
  double get hdBadgeFontSize; // label-sm (10)
  double get hdBadgeIconSize; // text-xs (12)

  // Başlık + aksan
  double get titleFontSize; // headline-xl (32)
  double get titleGap; // gap-space-xs (4)
  double get accentHPadding; // px-space-sm (8)
  double get accentVPadding; // py-0.5 (2)
  double get accentFontSize; // label-md (12)
  double get accentRadius; // rounded-md (6)
  double get sloganTopGap; // mt-space-md (16)
  double get sloganFontSize; // body-md (14)

  // ── İstatistik pill'i ─────────────────────────────────────
  double get statTopGap; // mt-space-lg (24)
  double get statPadding; // p-space-sm (8)
  double get statRadius; // rounded-xl (12)
  double get statIconSize; // text-sm (14)
  double get statFontSize; // label-md (12)
  double get statItemHPadding; // px-2 (8)
  double get statDividerWidth; // w-1 (4)
  double get statDividerHeight; // h-3 (12)

  // ── Alt bölüm ─────────────────────────────────────────────
  double get bottomMaxWidth; // max-w-xs (320)
  double get bottomTopGap; // mt-space-md (16)
  double get bottomGap; // gap-space-md (16)
  double get progressLabelFontSize; // label-sm (10)
  double get progressLabelHPadding; // px-0.5 (2)
  double get progressLabelGap; // gap-1 (4)
  double get progressDotSize; // w-1.5 (6)
  double get progressTrackHeight; // h-1.5 (6)
  double get stageGap; // gap-space-xs (4)
  double get credentialsGap; // gap-0.5 (2)
  double get credentialsIconSize; // text-xs (12)
  double get credentialsTopGap; // pt-space-xs (4)
  double get versionFontSize; // label-sm (10)
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class SplashPhoneSizes extends SplashSizes {
  const SplashPhoneSizes();

  @override
  bool get isTablet => false;

  @override
  double get pageHPadding => 24;
  @override
  double get pageVPadding => 32;

  @override
  double get glowPrimarySize => 320;
  @override
  double get glowSecondarySize => 224;

  @override
  double get gridMaxWidth => 384;
  @override
  double get gridMaxHeight => 640;

  @override
  double get tagTopPadding => 16;
  @override
  double get tagPillHPadding => 16;
  @override
  double get tagPillVPadding => 6;
  @override
  double get tagDotSize => 8;
  @override
  double get tagGap => 4;
  @override
  double get tagFontSize => 10;

  @override
  double get heroMaxWidth => 320;
  @override
  double get heroVerticalGap => 32;
  @override
  double get logoImageWidth => 176;
  @override
  double get logoImageHeight => 120;
  @override
  double get logoPad => 16;
  @override
  double get logoRadius => 12;
  @override
  double get auraExtent => 16;
  @override
  double get auraRadius => 28;

  @override
  double get hdBadgeBottom => 10;
  @override
  double get hdBadgeRight => 8;
  @override
  double get hdBadgeHPadding => 8;
  @override
  double get hdBadgeVPadding => 2;
  @override
  double get hdBadgeFontSize => 10;
  @override
  double get hdBadgeIconSize => 12;

  @override
  double get titleFontSize => 32;
  @override
  double get titleGap => 4;
  @override
  double get accentHPadding => 8;
  @override
  double get accentVPadding => 2;
  @override
  double get accentFontSize => 12;
  @override
  double get accentRadius => 6;
  @override
  double get sloganTopGap => 16;
  @override
  double get sloganFontSize => 14;

  @override
  double get statTopGap => 24;
  @override
  double get statPadding => 8;
  @override
  double get statRadius => 12;
  @override
  double get statIconSize => 14;
  @override
  double get statFontSize => 12;
  @override
  double get statItemHPadding => 8;
  @override
  double get statDividerWidth => 4;
  @override
  double get statDividerHeight => 12;

  @override
  double get bottomMaxWidth => 320;
  @override
  double get bottomTopGap => 16;
  @override
  double get bottomGap => 16;
  @override
  double get progressLabelFontSize => 10;
  @override
  double get progressLabelHPadding => 2;
  @override
  double get progressLabelGap => 4;
  @override
  double get progressDotSize => 6;
  @override
  double get progressTrackHeight => 6;
  @override
  double get stageGap => 4;
  @override
  double get credentialsGap => 2;
  @override
  double get credentialsIconSize => 12;
  @override
  double get credentialsTopGap => 4;
  @override
  double get versionFontSize => 10;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class SplashTabletSizes extends SplashSizes {
  const SplashTabletSizes();

  @override
  bool get isTablet => true;

  @override
  double get pageHPadding => 36;
  @override
  double get pageVPadding => 44;

  @override
  double get glowPrimarySize => 400;
  @override
  double get glowSecondarySize => 280;

  @override
  double get gridMaxWidth => 480;
  @override
  double get gridMaxHeight => 800;

  @override
  double get tagTopPadding => 20;
  @override
  double get tagPillHPadding => 20;
  @override
  double get tagPillVPadding => 8;
  @override
  double get tagDotSize => 10;
  @override
  double get tagGap => 6;
  @override
  double get tagFontSize => 12;

  @override
  double get heroMaxWidth => 400;
  @override
  double get heroVerticalGap => 40;
  @override
  double get logoImageWidth => 220;
  @override
  double get logoImageHeight => 150;
  @override
  double get logoPad => 20;
  @override
  double get logoRadius => 16;
  @override
  double get auraExtent => 20;
  @override
  double get auraRadius => 36;

  @override
  double get hdBadgeBottom => 12;
  @override
  double get hdBadgeRight => 10;
  @override
  double get hdBadgeHPadding => 12;
  @override
  double get hdBadgeVPadding => 4;
  @override
  double get hdBadgeFontSize => 12;
  @override
  double get hdBadgeIconSize => 14;

  @override
  double get titleFontSize => 40;
  @override
  double get titleGap => 6;
  @override
  double get accentHPadding => 12;
  @override
  double get accentVPadding => 4;
  @override
  double get accentFontSize => 14;
  @override
  double get accentRadius => 8;
  @override
  double get sloganTopGap => 20;
  @override
  double get sloganFontSize => 16;

  @override
  double get statTopGap => 28;
  @override
  double get statPadding => 12;
  @override
  double get statRadius => 16;
  @override
  double get statIconSize => 16;
  @override
  double get statFontSize => 14;
  @override
  double get statItemHPadding => 12;
  @override
  double get statDividerWidth => 5;
  @override
  double get statDividerHeight => 14;

  @override
  double get bottomMaxWidth => 400;
  @override
  double get bottomTopGap => 20;
  @override
  double get bottomGap => 20;
  @override
  double get progressLabelFontSize => 12;
  @override
  double get progressLabelHPadding => 4;
  @override
  double get progressLabelGap => 6;
  @override
  double get progressDotSize => 8;
  @override
  double get progressTrackHeight => 8;
  @override
  double get stageGap => 6;
  @override
  double get credentialsGap => 4;
  @override
  double get credentialsIconSize => 14;
  @override
  double get credentialsTopGap => 6;
  @override
  double get versionFontSize => 12;
}
 */