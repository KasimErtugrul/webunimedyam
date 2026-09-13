// lib/presentation/screens/auth/forgot_password_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../../core/responsive.dart';

@immutable
class ForgotPasswordLayoutSpec {
  final bool isTablet;

  // ── Hero ──
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

  // ── Card ──
  final double maxContentWidth;
  final double cardRadius;
  final double cardPaddingH;
  final double cardPaddingV;
  final double cardTopSpacing;

  // ── Alan ──
  final double fieldFontSize;
  final double fieldIconSize;
  final double fieldRadius;
  final double fieldPaddingH;
  final double fieldPaddingV;

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
  final double errorIconSize;
  final double errorMarginBottom;

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
    required this.fieldFontSize,
    required this.fieldIconSize,
    required this.fieldRadius,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.loaderSize,
    required this.loaderStroke,
    required this.errorFontSize,
    required this.errorPadding,
    required this.errorRadius,
    required this.errorIconSize,
    required this.errorMarginBottom,
  });

  factory ForgotPasswordLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const ForgotPasswordLayoutSpec._(
        isTablet: true,
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
        fieldFontSize: 17,
        fieldIconSize: 24,
        fieldRadius: 14,
        fieldPaddingH: 18,
        fieldPaddingV: 20,
        buttonHeight: 60,
        buttonRadius: 16,
        buttonFontSize: 18,
        loaderSize: 26,
        loaderStroke: 3,
        errorFontSize: 15,
        errorPadding: 16,
        errorRadius: 14,
        errorIconSize: 22,
        errorMarginBottom: 18,
      );
    }
    return const ForgotPasswordLayoutSpec._(
      isTablet: false,
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
      fieldFontSize: 15,
      fieldIconSize: 20,
      fieldRadius: 12,
      fieldPaddingH: 14,
      fieldPaddingV: 16,
      buttonHeight: 54,
      buttonRadius: 14,
      buttonFontSize: 16,
      loaderSize: 22,
      loaderStroke: 2.5,
      errorFontSize: 13,
      errorPadding: 12,
      errorRadius: 12,
      errorIconSize: 20,
      errorMarginBottom: 16,
    );
  }
}