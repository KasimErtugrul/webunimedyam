// lib/presentation/screens/auth/otp_verification_layout_spec.dart
import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';

@immutable
class OtpVerificationLayoutSpec {
  final bool isTablet;

  /// WEB ölçeği bayrağı — yalnızca OtpVerificationWebLayoutSpec true döner.
  bool get isWeb => false;
  final double maxContentWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double bottomPadding;

  // ── Eski alanlar (geriye dönük uyumluluk — korundu) ──
  final double heroSize;
  final double heroIconSize;
  final double heroRadius;
  final double titleFontSize;
  final double subtitleFontSize;
  final double titleTopSpacing;
  final double subtitleTopSpacing;
  final double formTopSpacing;
  final double otpBoxWidth;
  final double otpBoxHeight;
  final double otpBoxRadius;
  final double otpFontSize;
  final double otpSpacing;
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double loaderSize;
  final double loaderStroke;
  final double buttonTopSpacing;
  final double errorFontSize;
  final double errorPadding;
  final double errorRadius;
  final double errorIconSize;
  final double errorMarginBottom;
  final double resendFontSize;
  final double resendTopSpacing;

  // ── Header (tasarım: h-16, w-11 geri, w-8 avatar) ──
  final double headerHeight;
  final double headerBackSize;
  final double headerBackIconSize;
  final double headerTitleFontSize;
  final double headerAvatarSize;
  final double headerAvatarIconSize;

  // ── Hero (tasarım: glow 80, ring 92, daire 64, nişan 24) ──
  final double heroTopSpacing;
  final double heroGlowSize;
  final double heroRingSize;
  final double heroCircleSize;
  final double heroGlyphSize;
  final double heroBadgeSize;
  final double heroBadgeIconSize;
  final double heroToPillSpacing;

  // ── Pill ("Akademik Kimlik Doğrulama") ──
  final double pillPaddingH;
  final double pillPaddingV;
  final double pillFontSize;
  final double pillDotSize;
  final double pillGap;

  // ── Başlık / açıklama / e-posta değiştir ──
  final double subtitleMaxWidth;
  final double changeEmailTopSpacing;
  final double changeEmailFontSize;
  final double changeEmailIconSize;

  // ── OTP kartı ──
  final double cardPadding;
  final double cardRowGap;
  final double gridGap;
  final double gridBottomSpacing;
  final double boxCursorWidth;
  final double boxCursorHeight;
  final double boxDotSize;
  final double securityTopSpacing;
  final double securityFontSize;
  final double securityIconSize;

  // ── Sayaç & yapıştır çipleri ──
  final double chipPaddingH;
  final double chipPaddingV;
  final double chipGap;
  final double timerIconSize;
  final double timerLabelFontSize;
  final double timerValueFontSize;

  // ── "Kodu almadınız mı?" kartı ──
  final double resendCardPadding;
  final double resendIconBoxSize;
  final double resendIconBoxRadius;
  final double resendIconBoxIconSize;
  final double resendTitleFontSize;
  final double resendSubtitleFontSize;
  final double resendActionIconSize;
  final double resendCardBottomSpacing;

  // ── Buton / tuş takımı / footer ──
  final double buttonIconSize;
  final double buttonBottomSpacing;
  final double keypadPadding;
  final double keypadRadius;
  final double keypadGap;
  final double keyHeight;
  final double keyRadius;
  final double keyFontSize;
  final double keypadBottomSpacing;
  final double supportFontSize;
  final double supportLinkFontSize;
  final double supportGap;

  const OtpVerificationLayoutSpec._({
    required this.isTablet,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.bottomPadding,
    required this.heroSize,
    required this.heroIconSize,
    required this.heroRadius,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.titleTopSpacing,
    required this.subtitleTopSpacing,
    required this.formTopSpacing,
    required this.otpBoxWidth,
    required this.otpBoxHeight,
    required this.otpBoxRadius,
    required this.otpFontSize,
    required this.otpSpacing,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.loaderSize,
    required this.loaderStroke,
    required this.buttonTopSpacing,
    required this.errorFontSize,
    required this.errorPadding,
    required this.errorRadius,
    required this.errorIconSize,
    required this.errorMarginBottom,
    required this.resendFontSize,
    required this.resendTopSpacing,
    required this.headerHeight,
    required this.headerBackSize,
    required this.headerBackIconSize,
    required this.headerTitleFontSize,
    required this.headerAvatarSize,
    required this.headerAvatarIconSize,
    required this.heroTopSpacing,
    required this.heroGlowSize,
    required this.heroRingSize,
    required this.heroCircleSize,
    required this.heroGlyphSize,
    required this.heroBadgeSize,
    required this.heroBadgeIconSize,
    required this.heroToPillSpacing,
    required this.pillPaddingH,
    required this.pillPaddingV,
    required this.pillFontSize,
    required this.pillDotSize,
    required this.pillGap,
    required this.subtitleMaxWidth,
    required this.changeEmailTopSpacing,
    required this.changeEmailFontSize,
    required this.changeEmailIconSize,
    required this.cardPadding,
    required this.cardRowGap,
    required this.gridGap,
    required this.gridBottomSpacing,
    required this.boxCursorWidth,
    required this.boxCursorHeight,
    required this.boxDotSize,
    required this.securityTopSpacing,
    required this.securityFontSize,
    required this.securityIconSize,
    required this.chipPaddingH,
    required this.chipPaddingV,
    required this.chipGap,
    required this.timerIconSize,
    required this.timerLabelFontSize,
    required this.timerValueFontSize,
    required this.resendCardPadding,
    required this.resendIconBoxSize,
    required this.resendIconBoxRadius,
    required this.resendIconBoxIconSize,
    required this.resendTitleFontSize,
    required this.resendSubtitleFontSize,
    required this.resendActionIconSize,
    required this.resendCardBottomSpacing,
    required this.buttonIconSize,
    required this.buttonBottomSpacing,
    required this.keypadPadding,
    required this.keypadRadius,
    required this.keypadGap,
    required this.keyHeight,
    required this.keyRadius,
    required this.keyFontSize,
    required this.keypadBottomSpacing,
    required this.supportFontSize,
    required this.supportLinkFontSize,
    required this.supportGap,
  });

  factory OtpVerificationLayoutSpec.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet yerleşimini temel alır.
    if (Responsive.isWeb(context)) {
      return const OtpVerificationWebLayoutSpec._();
    }
    if (Responsive.isTablet(context)) {
      return const OtpVerificationLayoutSpec._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 24,
        verticalPadding: 24,
        bottomPadding: 28,
        // ── Eski alanlar ──
        heroSize: 88,
        heroIconSize: 44,
        heroRadius: 24,
        titleFontSize: 30,
        subtitleFontSize: 16,
        titleTopSpacing: 10,
        subtitleTopSpacing: 10,
        formTopSpacing: 28,
        otpBoxWidth: 56,
        otpBoxHeight: 64,
        otpBoxRadius: 14,
        otpFontSize: 24,
        otpSpacing: 10,
        buttonHeight: 56,
        buttonRadius: 10,
        buttonFontSize: 15,
        loaderSize: 22,
        loaderStroke: 2.5,
        buttonTopSpacing: 0,
        errorFontSize: 14,
        errorPadding: 16,
        errorRadius: 12,
        errorIconSize: 22,
        errorMarginBottom: 18,
        resendFontSize: 13,
        resendTopSpacing: 0,
        // ── Header ──
        headerHeight: 72,
        headerBackSize: 48,
        headerBackIconSize: 24,
        headerTitleFontSize: 20,
        headerAvatarSize: 36,
        headerAvatarIconSize: 20,
        // ── Hero ──
        heroTopSpacing: 12,
        heroGlowSize: 96,
        heroRingSize: 110,
        heroCircleSize: 76,
        heroGlyphSize: 38,
        heroBadgeSize: 28,
        heroBadgeIconSize: 16,
        heroToPillSpacing: 24,
        // ── Pill ──
        pillPaddingH: 14,
        pillPaddingV: 5,
        pillFontSize: 11,
        pillDotSize: 7,
        pillGap: 7,
        // ── Metinler ──
        subtitleMaxWidth: 340,
        changeEmailTopSpacing: 10,
        changeEmailFontSize: 13,
        changeEmailIconSize: 18,
        // ── OTP kartı ──
        cardPadding: 20,
        cardRowGap: 18,
        gridGap: 10,
        gridBottomSpacing: 14,
        boxCursorWidth: 2.5,
        boxCursorHeight: 28,
        boxDotSize: 9,
        securityTopSpacing: 10,
        securityFontSize: 11,
        securityIconSize: 18,
        // ── Çipler ──
        chipPaddingH: 12,
        chipPaddingV: 5,
        chipGap: 7,
        timerIconSize: 15,
        timerLabelFontSize: 11,
        timerValueFontSize: 15,
        // ── Resend kartı ──
        resendCardPadding: 16,
        resendIconBoxSize: 36,
        resendIconBoxRadius: 9,
        resendIconBoxIconSize: 20,
        resendTitleFontSize: 13,
        resendSubtitleFontSize: 13,
        resendActionIconSize: 17,
        resendCardBottomSpacing: 24,
        // ── Buton / keypad / footer ──
        buttonIconSize: 22,
        buttonBottomSpacing: 18,
        keypadPadding: 14,
        keypadRadius: 13,
        keypadGap: 10,
        keyHeight: 52,
        keyRadius: 9,
        keyFontSize: 20,
        keypadBottomSpacing: 18,
        supportFontSize: 13,
        supportLinkFontSize: 13,
        supportGap: 7,
      );
    }
    return const OtpVerificationLayoutSpec._(
      isTablet: false,
      maxContentWidth: double.infinity,
      horizontalPadding: 16,
      verticalPadding: 20,
      bottomPadding: 20,
      // ── Eski alanlar ──
      heroSize: 72,
      heroIconSize: 36,
      heroRadius: 20,
      titleFontSize: 26, // headline-xl-mobile
      subtitleFontSize: 14, // body-md
      titleTopSpacing: 8,
      subtitleTopSpacing: 8,
      formTopSpacing: 24,
      otpBoxWidth: 44,
      otpBoxHeight: 56, // h-14
      otpBoxRadius: 12, // rounded-xl
      otpFontSize: 20, // headline-md
      otpSpacing: 8,
      buttonHeight: 48, // h-12
      buttonRadius: 8, // rounded-lg
      buttonFontSize: 14, // label-lg
      loaderSize: 20,
      loaderStroke: 2.2,
      buttonTopSpacing: 0,
      errorFontSize: 13,
      errorPadding: 14,
      errorRadius: 12,
      errorIconSize: 20,
      errorMarginBottom: 16,
      resendFontSize: 12, // label-md
      resendTopSpacing: 0,
      // ── Header ──
      headerHeight: 64, // h-16
      headerBackSize: 44, // w-11
      headerBackIconSize: 24,
      headerTitleFontSize: 18, // headline-sm
      headerAvatarSize: 32, // w-8
      headerAvatarIconSize: 18,
      // ── Hero ──
      heroTopSpacing: 8, // mt-2
      heroGlowSize: 80, // w-20
      heroRingSize: 92, // -inset-1.5
      heroCircleSize: 64, // w-16
      heroGlyphSize: 32,
      heroBadgeSize: 24, // w-6
      heroBadgeIconSize: 14,
      heroToPillSpacing: 20, // mb-5
      // ── Pill ──
      pillPaddingH: 12, // px-3
      pillPaddingV: 4, // py-1
      pillFontSize: 10, // label-sm
      pillDotSize: 6, // w-1.5
      pillGap: 6, // gap-1.5
      // ── Metinler ──
      subtitleMaxWidth: 280, // max-w-[280px]
      changeEmailTopSpacing: 8, // mt-2
      changeEmailFontSize: 12, // label-md
      changeEmailIconSize: 16,
      // ── OTP kartı ──
      cardPadding: 16, // p-4
      cardRowGap: 16, // mb-4
      gridGap: 8, // gap-2
      gridBottomSpacing: 12, // mb-3
      boxCursorWidth: 2, // w-0.5
      boxCursorHeight: 24, // h-6
      boxDotSize: 8, // w-2
      securityTopSpacing: 8, // pt-2
      securityFontSize: 10, // label-sm
      securityIconSize: 16,
      // ── Çipler ──
      chipPaddingH: 10, // px-2.5
      chipPaddingV: 4, // py-1
      chipGap: 6, // gap-1.5
      timerIconSize: 14,
      timerLabelFontSize: 10, // label-sm
      timerValueFontSize: 14, // label-lg
      // ── Resend kartı ──
      resendCardPadding: 14, // p-3.5
      resendIconBoxSize: 32, // w-8
      resendIconBoxRadius: 8, // rounded-lg
      resendIconBoxIconSize: 18,
      resendTitleFontSize: 12, // label-md
      resendSubtitleFontSize: 12, // body-sm
      resendActionIconSize: 16,
      resendCardBottomSpacing: 20, // mb-5
      // ── Buton / keypad / footer ──
      buttonIconSize: 20, // arrow_forward 20px
      buttonBottomSpacing: 16, // mb-4
      keypadPadding: 12, // p-3
      keypadRadius: 12, // rounded-xl
      keypadGap: 8, // gap-2
      keyHeight: 44, // h-11
      keyRadius: 8, // rounded-lg
      keyFontSize: 18, // headline-sm
      keypadBottomSpacing: 16, // mb-4
      supportFontSize: 12, // body-sm
      supportLinkFontSize: 12, // label-md
      supportGap: 6, // gap-1.5
    );
  }
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet değerlerini super'e aynen aktarır; yalnızca web'de
/// farklılaşan ölçüleri ezer.
class OtpVerificationWebLayoutSpec extends OtpVerificationLayoutSpec {
  const OtpVerificationWebLayoutSpec._()
    : super._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 24,
        verticalPadding: 24,
        bottomPadding: 28,
        // ── Eski alanlar ──
        heroSize: 88,
        heroIconSize: 44,
        heroRadius: 24,
        titleFontSize: 30,
        subtitleFontSize: 16,
        titleTopSpacing: 10,
        subtitleTopSpacing: 10,
        formTopSpacing: 28,
        otpBoxWidth: 56,
        otpBoxHeight: 64,
        otpBoxRadius: 14,
        otpFontSize: 24,
        otpSpacing: 10,
        buttonHeight: 56,
        buttonRadius: 10,
        buttonFontSize: 15,
        loaderSize: 22,
        loaderStroke: 2.5,
        buttonTopSpacing: 0,
        errorFontSize: 14,
        errorPadding: 16,
        errorRadius: 12,
        errorIconSize: 22,
        errorMarginBottom: 18,
        resendFontSize: 13,
        resendTopSpacing: 0,
        // ── Header ──
        headerHeight: 72,
        headerBackSize: 48,
        headerBackIconSize: 24,
        headerTitleFontSize: 20,
        headerAvatarSize: 36,
        headerAvatarIconSize: 20,
        // ── Hero ──
        heroTopSpacing: 12,
        heroGlowSize: 96,
        heroRingSize: 110,
        heroCircleSize: 76,
        heroGlyphSize: 38,
        heroBadgeSize: 28,
        heroBadgeIconSize: 16,
        heroToPillSpacing: 24,
        // ── Pill ──
        pillPaddingH: 14,
        pillPaddingV: 5,
        pillFontSize: 11,
        pillDotSize: 7,
        pillGap: 7,
        // ── Metinler ──
        subtitleMaxWidth: 340,
        changeEmailTopSpacing: 10,
        changeEmailFontSize: 13,
        changeEmailIconSize: 18,
        // ── OTP kartı ──
        cardPadding: 20,
        cardRowGap: 18,
        gridGap: 10,
        gridBottomSpacing: 14,
        boxCursorWidth: 2.5,
        boxCursorHeight: 28,
        boxDotSize: 9,
        securityTopSpacing: 10,
        securityFontSize: 11,
        securityIconSize: 18,
        // ── Çipler ──
        chipPaddingH: 12,
        chipPaddingV: 5,
        chipGap: 7,
        timerIconSize: 15,
        timerLabelFontSize: 11,
        timerValueFontSize: 15,
        // ── Resend kartı ──
        resendCardPadding: 16,
        resendIconBoxSize: 36,
        resendIconBoxRadius: 9,
        resendIconBoxIconSize: 20,
        resendTitleFontSize: 13,
        resendSubtitleFontSize: 13,
        resendActionIconSize: 17,
        resendCardBottomSpacing: 24,
        // ── Buton / keypad / footer ──
        buttonIconSize: 22,
        buttonBottomSpacing: 18,
        keypadPadding: 14,
        keypadRadius: 13,
        keypadGap: 10,
        keyHeight: 52,
        keyRadius: 9,
        keyFontSize: 20,
        keypadBottomSpacing: 18,
        supportFontSize: 13,
        supportLinkFontSize: 13,
        supportGap: 7,
      );

  @override
  bool get isWeb => true;

  @override
  double get maxContentWidth => 540;
}
