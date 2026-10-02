
// ═══════════════════════════════════════════════════════════
// ABSTRACT SIZES CONTRACT (TEK ORTAK SÖZLEŞME)
// Stitch "onboarding" tasarımındaki (5 adım) tüm ölçüler.
// Phone → ScreenUtil ile ölçekli, Tablet → ham dp.
// ═══════════════════════════════════════════════════════════

abstract class OnboardingSizes {
  const OnboardingSizes();

  bool get isTablet;

  /// WEB ölçeği bayrağı — yalnızca OnboardingWebSizes true döner.
  bool get isWeb => false;

  // ─── Header (Top App Bar) ─────────────────────────────────
  double get headerHPadding;        // px-6
  double get headerVPadding;        // py-4
  double get logoSize;              // w-8 h-8
  double get logoRadius;            // rounded-xl (12)
  double get logoIconSize;          // text-[20px]
  double get logoGap;               // gap-2
  double get logoFontSize;          // text-xl
  double get skipFontSize;          // text-sm

  // ─── Sayfa ────────────────────────────────────────────────
  double get pageHPadding;          // px-6
  double get pageTopPadding;        // py-2
  double get visualMaxHeight;       // max-h-[300px]
  double get visualMaxWidth;        // max-w-[340px]
  double get visualRadius;          // rounded-3xl (24)
  double get visualPadding;         // p-6
  double get glowSize;              // w-44 h-44 blur blob

  // ─── Tipografi ────────────────────────────────────────────
  double get typographyTopGap;      // py-4
  double get labelFontSize;         // text-xs (ADIM N / 5)
  double get labelSpacing;          // mb-2
  double get titleFontSize;         // text-2xl font-extrabold
  double get titleSpacing;          // mb-2.5
  double get descriptionFontSize;   // text-sm
  double get descriptionLineHeight; // leading-relaxed (1.625)

  // ─── Ortak kart / pill ölçüleri ───────────────────────────
  double get tileRadius;            // rounded-2xl (16)
  double get pillHPadding;          // px-3
  double get pillVPadding;          // py-1.5
  double get pillFontSize;          // text-xs
  double get pillIconSize;          // 15-16px ikonlar
  double get pillGap;               // gap-1.5
  double get dotSize;               // w-2 h-2

  // ─── İç mini kartlar (bildirim / harf şeridi / radyo) ─────
  double get innerCardHPadding;     // px-4
  double get innerCardVPadding;     // py-2.5
  double get innerGap;              // gap-3
  double get iconTextGap;           // gap-2
  double get visualGap;             // gap-4
  double get visualGapSm;           // gap-3.5
  double get stackWidth;            // max-w-[270px]

  // ─── Adım 1 — Karşılama ───────────────────────────────────
  double get heroTileSize;          // w-20 h-20
  double get heroIconSize;          // text-[40px]

  // ─── Adım 2 — Üniversite çarkı ────────────────────────────
  double get spinnerSize;           // w-20 h-20
  double get spinnerIconSize;       // text-[36px]

  // ─── Adım 3 — Bildirim ────────────────────────────────────
  double get notifTileSize;         // w-10 h-10
  double get notifIconSize;         // text-[22px]
  double get notifTitleFontSize;    // text-xs
  double get notifBodyFontSize;     // text-[11px]

  // ─── Adım 4 — Etkileşim ───────────────────────────────────
  double get actionTileSize;        // w-14 h-14
  double get actionIconSize;        // text-[28px]

  // ─── Adım 5 — Hesap / radyo ───────────────────────────────
  double get avatarSize;            // w-16 h-16
  double get avatarIconSize;        // text-[32px]
  double get radioIconSize;         // text-[18px]
  double get eqBarWidth;            // w-1
  double get eqBarMaxHeight;        // h-4
  double get eqBarMinHeight;

  // ─── Noktalar (dots) ──────────────────────────────────────
  double get dotHeight;             // h-2
  double get dotActiveWidth;        // w-6
  double get dotInactiveWidth;      // w-2
  double get dotGap;                // gap-2

  // ─── Butonlar / Footer ────────────────────────────────────
  double get buttonHeight;          // h-12
  double get buttonRadius;          // rounded-2xl (16)
  double get buttonFontSize;        // text-sm
  double get buttonIconSize;        // text-[18px]
  double get buttonHPadding;        // px-6
  double get buttonsGap;            // gap-2.5
  double get navRowHeight;          // h-14
  double get footerTopPadding;      // pt-2
  double get footerBottomPadding;   // pb-safe (min 20)
}

// ═══════════════════════════════════════════════════════════
// PHONE SIZES (ScreenUtil ile ölçekli)
// ═══════════════════════════════════════════════════════════

class OnboardingPhoneSizes extends OnboardingSizes {
  const OnboardingPhoneSizes();

  @override bool get isTablet => false;

  @override double get headerHPadding => 24;
  @override double get headerVPadding => 16;
  @override double get logoSize => 32;
  @override double get logoRadius => 12;
  @override double get logoIconSize => 20;
  @override double get logoGap => 8;
  @override double get logoFontSize => 20;
  @override double get skipFontSize => 14;

  @override double get pageHPadding => 24;
  @override double get pageTopPadding => 8;
  @override double get visualMaxHeight => 300;
  @override double get visualMaxWidth => 340;
  @override double get visualRadius => 24;
  @override double get visualPadding => 24;
  @override double get glowSize => 176;

  @override double get typographyTopGap => 16;
  @override double get labelFontSize => 12;
  @override double get labelSpacing => 8;
  @override double get titleFontSize => 24;
  @override double get titleSpacing => 10;
  @override double get descriptionFontSize => 14;
  @override double get descriptionLineHeight => 1.625;

  @override double get tileRadius => 16;
  @override double get pillHPadding => 12;
  @override double get pillVPadding => 6;
  @override double get pillFontSize => 12;
  @override double get pillIconSize => 16;
  @override double get pillGap => 6;
  @override double get dotSize => 8;

  @override double get innerCardHPadding => 16;
  @override double get innerCardVPadding => 10;
  @override double get innerGap => 12;
  @override double get iconTextGap => 8;
  @override double get visualGap => 16;
  @override double get visualGapSm => 14;
  @override double get stackWidth => 270;

  @override double get heroTileSize => 80;
  @override double get heroIconSize => 40;
  @override double get spinnerSize => 80;
  @override double get spinnerIconSize => 36;
  @override double get notifTileSize => 40;
  @override double get notifIconSize => 22;
  @override double get notifTitleFontSize => 12;
  @override double get notifBodyFontSize => 11;
  @override double get actionTileSize => 56;
  @override double get actionIconSize => 28;
  @override double get avatarSize => 64;
  @override double get avatarIconSize => 32;
  @override double get radioIconSize => 18;
  @override double get eqBarWidth => 4;
  @override double get eqBarMaxHeight => 16;
  @override double get eqBarMinHeight => 6;

  @override double get dotHeight => 8;
  @override double get dotActiveWidth => 24;
  @override double get dotInactiveWidth => 8;
  @override double get dotGap => 8;

  @override double get buttonHeight => 48;
  @override double get buttonRadius => 16;
  @override double get buttonFontSize => 14;
  @override double get buttonIconSize => 18;
  @override double get buttonHPadding => 24;
  @override double get buttonsGap => 10;
  @override double get navRowHeight => 56;
  @override double get footerTopPadding => 8;
  @override double get footerBottomPadding => 20;
}

// ═══════════════════════════════════════════════════════════
// TABLET SIZES (ham dp)
// ═══════════════════════════════════════════════════════════

class OnboardingTabletSizes extends OnboardingSizes {
  const OnboardingTabletSizes();

  @override bool get isTablet => true;

  @override double get headerHPadding => 40;
  @override double get headerVPadding => 20;
  @override double get logoSize => 40;
  @override double get logoRadius => 14;
  @override double get logoIconSize => 24;
  @override double get logoGap => 10;
  @override double get logoFontSize => 24;
  @override double get skipFontSize => 16;

  @override double get pageHPadding => 48;
  @override double get pageTopPadding => 12;
  @override double get visualMaxHeight => 380;
  @override double get visualMaxWidth => 430;
  @override double get visualRadius => 28;
  @override double get visualPadding => 28;
  @override double get glowSize => 220;

  @override double get typographyTopGap => 20;
  @override double get labelFontSize => 14;
  @override double get labelSpacing => 10;
  @override double get titleFontSize => 30;
  @override double get titleSpacing => 12;
  @override double get descriptionFontSize => 17;
  @override double get descriptionLineHeight => 1.65;

  @override double get tileRadius => 20;
  @override double get pillHPadding => 16;
  @override double get pillVPadding => 8;
  @override double get pillFontSize => 14;
  @override double get pillIconSize => 18;
  @override double get pillGap => 8;
  @override double get dotSize => 10;

  @override double get innerCardHPadding => 20;
  @override double get innerCardVPadding => 12;
  @override double get innerGap => 14;
  @override double get iconTextGap => 10;
  @override double get visualGap => 20;
  @override double get visualGapSm => 18;
  @override double get stackWidth => 330;

  @override double get heroTileSize => 104;
  @override double get heroIconSize => 52;
  @override double get spinnerSize => 104;
  @override double get spinnerIconSize => 46;
  @override double get notifTileSize => 52;
  @override double get notifIconSize => 28;
  @override double get notifTitleFontSize => 14;
  @override double get notifBodyFontSize => 13;
  @override double get actionTileSize => 72;
  @override double get actionIconSize => 36;
  @override double get avatarSize => 80;
  @override double get avatarIconSize => 40;
  @override double get radioIconSize => 22;
  @override double get eqBarWidth => 5;
  @override double get eqBarMaxHeight => 20;
  @override double get eqBarMinHeight => 8;

  @override double get dotHeight => 10;
  @override double get dotActiveWidth => 32;
  @override double get dotInactiveWidth => 10;
  @override double get dotGap => 10;

  @override double get buttonHeight => 56;
  @override double get buttonRadius => 20;
  @override double get buttonFontSize => 16;
  @override double get buttonIconSize => 20;
  @override double get buttonHPadding => 28;
  @override double get buttonsGap => 12;
  @override double get navRowHeight => 64;
  @override double get footerTopPadding => 10;
  @override double get footerBottomPadding => 24;
}
/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet ölçülerini temel alır; onboarding web'de zaten atlanır
/// (main.dart kIsWeb guard'ı) ama dar pencere <1024'e düşünce tablet
/// düzeni görünür — web katmanı yine de tam olsun diye eklenmiştir.
class OnboardingWebSizes extends OnboardingTabletSizes {
  const OnboardingWebSizes();

  @override
  bool get isWeb => true;
}
