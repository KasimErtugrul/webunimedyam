// lib/presentation/screens/auth/login_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';

@immutable
class LoginLayoutSpec {
  final bool isTablet;

  // ── Hero ──
  final double heroHeight;
  final double heroLogoSize;
  final double heroLogoRadius;
  final double heroIconSize;
  final double heroTitleFontSize;
  final double heroSubtitleFontSize;
  final double heroTitleSpacing;
  final double heroSubtitleSpacing;
  final double backButtonSize;
  final double backButtonPadding;

  // ── Card ──
  final double maxContentWidth;
  final double cardRadius;
  final double cardPaddingH;
  final double cardPaddingV;
  final double cardTopSpacing;

  // ── Başlık (kart içi) ──
  final double welcomeFontSize;
  final double subtitleFontSize;
  final double formSpacing;
  final double fieldSpacing;

  // ── Alanlar ──
  final double fieldFontSize;
  final double fieldPaddingH;
  final double fieldPaddingV;
  final double fieldRadius;
  final double iconSize;

  // ── Buton ──
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double loaderSize;
  final double loaderStroke;

  // ── Hata ──
  final double errorFontSize;
  final double errorPadding;
  final double errorRadius;

  // ── Linkler ──
  final double linkFontSize;
  final double guestFontSize;

  const LoginLayoutSpec._({
    required this.isTablet,
    required this.heroHeight,
    required this.heroLogoSize,
    required this.heroLogoRadius,
    required this.heroIconSize,
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
    required this.welcomeFontSize,
    required this.subtitleFontSize,
    required this.formSpacing,
    required this.fieldSpacing,
    required this.fieldFontSize,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.fieldRadius,
    required this.iconSize,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.loaderSize,
    required this.loaderStroke,
    required this.errorFontSize,
    required this.errorPadding,
    required this.errorRadius,
    required this.linkFontSize,
    required this.guestFontSize,
  });

  factory LoginLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const LoginLayoutSpec._(
        isTablet: true,
        heroHeight: 400,
        heroLogoSize: 104,
        heroLogoRadius: 26,
        heroIconSize: 56,
        heroTitleFontSize: 38,
        heroSubtitleFontSize: 16,
        heroTitleSpacing: 22,
        heroSubtitleSpacing: 8,
        backButtonSize: 24,
        backButtonPadding: 12,
        maxContentWidth: 480,
        cardRadius: 32,
        cardPaddingH: 40,
        cardPaddingV: 40,
        cardTopSpacing: 32,
        welcomeFontSize: 30,
        subtitleFontSize: 16,
        formSpacing: 20,
        fieldSpacing: 36,
        fieldFontSize: 17,
        fieldPaddingH: 18,
        fieldPaddingV: 20,
        fieldRadius: 14,
        iconSize: 24,
        buttonHeight: 60,
        buttonRadius: 16,
        buttonFontSize: 18,
        loaderSize: 26,
        loaderStroke: 3,
        errorFontSize: 15,
        errorPadding: 16,
        errorRadius: 14,
        linkFontSize: 16,
        guestFontSize: 15,
      );
    }
    return const LoginLayoutSpec._(
      isTablet: false,
      heroHeight: 340,
      heroLogoSize: 80,
      heroLogoRadius: 20,
      heroIconSize: 42,
      heroTitleFontSize: 28,
      heroSubtitleFontSize: 13,
      heroTitleSpacing: 16,
      heroSubtitleSpacing: 6,
      backButtonSize: 20,
      backButtonPadding: 10,
      maxContentWidth: double.infinity,
      cardRadius: 28,
      cardPaddingH: 24,
      cardPaddingV: 28,
      cardTopSpacing: 24,
      welcomeFontSize: 24,
      subtitleFontSize: 14,
      formSpacing: 16,
      fieldSpacing: 28,
      fieldFontSize: 15,
      fieldPaddingH: 14,
      fieldPaddingV: 16,
      fieldRadius: 12,
      iconSize: 20,
      buttonHeight: 54,
      buttonRadius: 14,
      buttonFontSize: 16,
      loaderSize: 22,
      loaderStroke: 2.5,
      errorFontSize: 13,
      errorPadding: 12,
      errorRadius: 12,
      linkFontSize: 14,
      guestFontSize: 13,
    );
  }
}