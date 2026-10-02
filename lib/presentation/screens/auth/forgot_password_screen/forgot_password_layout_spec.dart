// lib/presentation/screens/auth/forgot_password_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';

@immutable
class ForgotPasswordLayoutSpec {
  final bool isTablet;

  /// WEB ölçeği bayrağı — yalnızca ForgotPasswordWebLayoutSpec true döner.
  bool get isWeb => false;

  // ── Eski hero/kart alanları (geriye dönük uyumluluk için korundu) ──
  final double heroHeight;
  final double heroIconBoxSize;
  final double heroIconSize;
  final double heroIconRadius;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroTitleSpacing;
  final double heroSubtitleSpacing;
  final double backButtonSize;
  final double backButtonPadding;
  final double maxContentWidth;
  final double cardRadius;
  final double cardPaddingH;
  final double cardPaddingV;
  final double cardTopSpacing;

  // ── Nav bar (tasarım: py-space-md, w-10 h-10 buton, 20px ikon) ──
  final double navVerticalPadding;
  final double navButtonSize;
  final double navIconSize;

  // ── Hero görsel (tasarım: glow 112, dış 80, iç 56, nişan 24) ──
  final double heroTopSpacing;
  final double heroGlowSize;
  final double heroOuterSize;
  final double heroInnerSize;
  final double heroLockIconSize;
  final double heroBadgeSize;
  final double heroBadgeIconSize;
  final double heroStackToTitleSpacing;
  final double heroTitleToSubtitleSpacing;
  final double heroBottomSpacing;
  final double heroSubtitleMaxWidth;

  // ── Form (tasarım: gap-space-lg = 24) ──
  final double formGap;
  final double fieldLabelFontSize;
  final double fieldLabelGap;
  final double fieldFontSize;
  final double fieldIconSize;
  final double fieldRadius;
  final double fieldPaddingH;
  final double fieldPaddingV;
  final double clearButtonSize;
  final double clearIconSize;

  // ── Güvenlik notu (tasarım: p-space-md, rounded-xl) ──
  final double noteRadius;
  final double notePadding;
  final double noteGap;
  final double noteTitleFontSize;
  final double noteTextFontSize;
  final double noteIconSize;

  // ── Buton (tasarım: py-3.5 → 48, rounded-xl, bolt 20px) ──
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double buttonGap;
  final double buttonIconSize;
  final double loaderSize;
  final double loaderStroke;

  // ── Başarı bildirimi (tasarım: mt-space-md, p-space-md) ──
  final double alertRadius;
  final double alertPadding;
  final double alertGap;
  final double alertIconSize;
  final double alertTextFontSize;

  // ── Hata bandı (koddaki öğe — korunuyor) ──
  final double errorFontSize;
  final double errorPadding;
  final double errorRadius;
  final double errorIconSize;
  final double errorMarginBottom;

  // ── Alt bağlantı (tasarım: mt-space-xl = 32, py-space-sm = 8) ──
  final double bottomLinkSpacing;
  final double linkFontSize;
  final double linkIconSize;
  final double linkGap;
  final double linkVerticalPadding;

  const ForgotPasswordLayoutSpec._({
    required this.isTablet,
    required this.heroHeight,
    required this.heroIconBoxSize,
    required this.heroIconSize,
    required this.heroIconRadius,
    required this.heroTitleFontSize,
    required this.heroSubtitleFontSize,
    required this.heroTitleSpacing,
    required this.heroSubtitleSpacing,
    required this.backButtonSize,
    required this.backButtonPadding,
    required this.maxContentWidth,
    required this.cardRadius,
    required this.cardPaddingH,
    required this.cardPaddingV,
    required this.cardTopSpacing,
    required this.navVerticalPadding,
    required this.navButtonSize,
    required this.navIconSize,
    required this.heroTopSpacing,
    required this.heroGlowSize,
    required this.heroOuterSize,
    required this.heroInnerSize,
    required this.heroLockIconSize,
    required this.heroBadgeSize,
    required this.heroBadgeIconSize,
    required this.heroStackToTitleSpacing,
    required this.heroTitleToSubtitleSpacing,
    required this.heroBottomSpacing,
    required this.heroSubtitleMaxWidth,
    required this.formGap,
    required this.fieldLabelFontSize,
    required this.fieldLabelGap,
    required this.fieldFontSize,
    required this.fieldIconSize,
    required this.fieldRadius,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.clearButtonSize,
    required this.clearIconSize,
    required this.noteRadius,
    required this.notePadding,
    required this.noteGap,
    required this.noteTitleFontSize,
    required this.noteTextFontSize,
    required this.noteIconSize,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.buttonGap,
    required this.buttonIconSize,
    required this.loaderSize,
    required this.loaderStroke,
    required this.alertRadius,
    required this.alertPadding,
    required this.alertGap,
    required this.alertIconSize,
    required this.alertTextFontSize,
    required this.errorFontSize,
    required this.errorPadding,
    required this.errorRadius,
    required this.errorIconSize,
    required this.errorMarginBottom,
    required this.bottomLinkSpacing,
    required this.linkFontSize,
    required this.linkIconSize,
    required this.linkGap,
    required this.linkVerticalPadding,
  });

  factory ForgotPasswordLayoutSpec.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet yerleşimini temel alır.
    if (Responsive.isWeb(context)) {
      return const ForgotPasswordWebLayoutSpec._();
    }
    if (Responsive.isTablet(context)) {
      return const ForgotPasswordLayoutSpec._(
        isTablet: true,
        // ── Eski alanlar ──
        heroHeight: 360,
        heroIconBoxSize: 88,
        heroIconSize: 44,
        heroIconRadius: 24,
        heroTitleFontSize: 30,
        heroSubtitleFontSize: 16,
        heroTitleSpacing: 22,
        heroSubtitleSpacing: 8,
        backButtonSize: 24,
        backButtonPadding: 12,
        maxContentWidth: 480,
        cardRadius: 32,
        cardPaddingH: 40,
        cardPaddingV: 36,
        cardTopSpacing: 24,
        // ── Nav bar ──
        navVerticalPadding: 16,
        navButtonSize: 44,
        navIconSize: 22,
        // ── Hero ──
        heroTopSpacing: 20,
        heroGlowSize: 128,
        heroOuterSize: 92,
        heroInnerSize: 64,
        heroLockIconSize: 36,
        heroBadgeSize: 28,
        heroBadgeIconSize: 15,
        heroStackToTitleSpacing: 28,
        heroTitleToSubtitleSpacing: 6,
        heroBottomSpacing: 28,
        heroSubtitleMaxWidth: 380,
        // ── Form ──
        formGap: 28,
        fieldLabelFontSize: 13,
        fieldLabelGap: 5,
        fieldFontSize: 15,
        fieldIconSize: 22,
        fieldRadius: 14,
        fieldPaddingH: 18,
        fieldPaddingV: 16,
        clearButtonSize: 32,
        clearIconSize: 18,
        // ── Not ──
        noteRadius: 14,
        notePadding: 16,
        noteGap: 12,
        noteTitleFontSize: 11,
        noteTextFontSize: 13,
        noteIconSize: 22,
        // ── Buton ──
        buttonHeight: 52,
        buttonRadius: 14,
        buttonFontSize: 15,
        buttonGap: 10,
        buttonIconSize: 20,
        loaderSize: 22,
        loaderStroke: 2.5,
        // ── Bildirim ──
        alertRadius: 14,
        alertPadding: 16,
        alertGap: 12,
        alertIconSize: 22,
        alertTextFontSize: 13,
        // ── Hata ──
        errorFontSize: 14,
        errorPadding: 14,
        errorRadius: 14,
        errorIconSize: 22,
        errorMarginBottom: 18,
        // ── Bağlantı ──
        bottomLinkSpacing: 36,
        linkFontSize: 13,
        linkIconSize: 16,
        linkGap: 8,
        linkVerticalPadding: 10,
      );
    }
    return const ForgotPasswordLayoutSpec._(
      isTablet: false,
      // ── Eski alanlar ──
      heroHeight: 300,
      heroIconBoxSize: 72,
      heroIconSize: 36,
      heroIconRadius: 20,
      heroTitleFontSize: 24,
      heroSubtitleFontSize: 14,
      heroTitleSpacing: 16,
      heroSubtitleSpacing: 6,
      backButtonSize: 20,
      backButtonPadding: 10,
      maxContentWidth: double.infinity,
      cardRadius: 28,
      cardPaddingH: 24,
      cardPaddingV: 28,
      cardTopSpacing: 20,
      // ── Nav bar ──
      navVerticalPadding: 14,
      navButtonSize: 40,
      navIconSize: 20,
      // ── Hero ──
      heroTopSpacing: 16,
      heroGlowSize: 112,
      heroOuterSize: 80,
      heroInnerSize: 56,
      heroLockIconSize: 32,
      heroBadgeSize: 24,
      heroBadgeIconSize: 13,
      heroStackToTitleSpacing: 24,
      heroTitleToSubtitleSpacing: 4,
      heroBottomSpacing: 24,
      heroSubtitleMaxWidth: 320,
      // ── Form ──
      formGap: 24,
      fieldLabelFontSize: 12,
      fieldLabelGap: 4,
      fieldFontSize: 14,
      fieldIconSize: 20,
      fieldRadius: 12,
      fieldPaddingH: 16,
      fieldPaddingV: 14,
      clearButtonSize: 28,
      clearIconSize: 16,
      // ── Not ──
      noteRadius: 12,
      notePadding: 14,
      noteGap: 10,
      noteTitleFontSize: 10,
      noteTextFontSize: 12,
      noteIconSize: 20,
      // ── Buton ──
      buttonHeight: 48,
      buttonRadius: 12,
      buttonFontSize: 14,
      buttonGap: 8,
      buttonIconSize: 18,
      loaderSize: 20,
      loaderStroke: 2.2,
      // ── Bildirim ──
      alertRadius: 12,
      alertPadding: 14,
      alertGap: 10,
      alertIconSize: 20,
      alertTextFontSize: 12,
      // ── Hata ──
      errorFontSize: 13,
      errorPadding: 12,
      errorRadius: 12,
      errorIconSize: 20,
      errorMarginBottom: 16,
      // ── Bağlantı ──
      bottomLinkSpacing: 32,
      linkFontSize: 12,
      linkIconSize: 14,
      linkGap: 6,
      linkVerticalPadding: 8,
    );
  }
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet değerlerini super'e aynen aktarır; yalnızca web'de
/// farklılaşan ölçüleri ezer.
class ForgotPasswordWebLayoutSpec extends ForgotPasswordLayoutSpec {
  const ForgotPasswordWebLayoutSpec._()
    : super._(
        isTablet: true,
        // ── Eski alanlar ──
        heroHeight: 360,
        heroIconBoxSize: 88,
        heroIconSize: 44,
        heroIconRadius: 24,
        heroTitleFontSize: 30,
        heroSubtitleFontSize: 16,
        heroTitleSpacing: 22,
        heroSubtitleSpacing: 8,
        backButtonSize: 24,
        backButtonPadding: 12,
        maxContentWidth: 480,
        cardRadius: 32,
        cardPaddingH: 40,
        cardPaddingV: 36,
        cardTopSpacing: 24,
        // ── Nav bar ──
        navVerticalPadding: 16,
        navButtonSize: 44,
        navIconSize: 22,
        // ── Hero ──
        heroTopSpacing: 20,
        heroGlowSize: 128,
        heroOuterSize: 92,
        heroInnerSize: 64,
        heroLockIconSize: 36,
        heroBadgeSize: 28,
        heroBadgeIconSize: 15,
        heroStackToTitleSpacing: 28,
        heroTitleToSubtitleSpacing: 6,
        heroBottomSpacing: 28,
        heroSubtitleMaxWidth: 380,
        // ── Form ──
        formGap: 28,
        fieldLabelFontSize: 13,
        fieldLabelGap: 5,
        fieldFontSize: 15,
        fieldIconSize: 22,
        fieldRadius: 14,
        fieldPaddingH: 18,
        fieldPaddingV: 16,
        clearButtonSize: 32,
        clearIconSize: 18,
        // ── Not ──
        noteRadius: 14,
        notePadding: 16,
        noteGap: 12,
        noteTitleFontSize: 11,
        noteTextFontSize: 13,
        noteIconSize: 22,
        // ── Buton ──
        buttonHeight: 52,
        buttonRadius: 14,
        buttonFontSize: 15,
        buttonGap: 10,
        buttonIconSize: 20,
        loaderSize: 22,
        loaderStroke: 2.5,
        // ── Bildirim ──
        alertRadius: 14,
        alertPadding: 16,
        alertGap: 12,
        alertIconSize: 22,
        alertTextFontSize: 13,
        // ── Hata ──
        errorFontSize: 14,
        errorPadding: 14,
        errorRadius: 14,
        errorIconSize: 22,
        errorMarginBottom: 18,
        // ── Bağlantı ──
        bottomLinkSpacing: 36,
        linkFontSize: 13,
        linkIconSize: 16,
        linkGap: 8,
        linkVerticalPadding: 10,
      );

  @override
  bool get isWeb => true;

  @override
  double get maxContentWidth => 500;
}
