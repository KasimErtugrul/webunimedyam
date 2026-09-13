// lib/presentation/screens/auth/register_layout_spec.dart
import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';

@immutable
class RegisterLayoutSpec {
  final bool isTablet;
  final double maxContentWidth;
  final double horizontalPadding;
  final double topSpacing;
  final double bottomSpacing;
  final double headerSpacing;

  // Header icon
  final double heroSize;
  final double heroIconSize;
  final double heroRadius;

  // Header text
  final double titleFontSize;
  final double subtitleFontSize;
  final double subtitleSpacing;

  // Card
  final double cardPadding;
  final double cardRadius;

  // Fields
  final double fieldFontSize;
  final double fieldIconSize;
  final double fieldRadius;
  final double fieldPaddingH;
  final double fieldPaddingV;
  final double fieldSpacing;

  // Error
  final double errorFontSize;
  final double errorPadding;
  final double errorRadius;
  final double errorIconSize;
  final double errorMarginBottom;

  // Button
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double loaderSize;
  final double loaderStroke;

  const RegisterLayoutSpec._({
    required this.isTablet,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.topSpacing,
    required this.bottomSpacing,
    required this.headerSpacing,
    required this.heroSize,
    required this.heroIconSize,
    required this.heroRadius,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.subtitleSpacing,
    required this.cardPadding,
    required this.cardRadius,
    required this.fieldFontSize,
    required this.fieldIconSize,
    required this.fieldRadius,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.fieldSpacing,
    required this.errorFontSize,
    required this.errorPadding,
    required this.errorRadius,
    required this.errorIconSize,
    required this.errorMarginBottom,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.loaderSize,
    required this.loaderStroke,
  });

  factory RegisterLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const RegisterLayoutSpec._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 32,
        topSpacing: 30,
        bottomSpacing: 30,
        headerSpacing: 30,
        heroSize: 88,
        heroIconSize: 44,
        heroRadius: 24,
        titleFontSize: 32,
        subtitleFontSize: 18,
        subtitleSpacing: 10,
        cardPadding: 28,
        cardRadius: 24,
        fieldFontSize: 17,
        fieldIconSize: 26,
        fieldRadius: 14,
        fieldPaddingH: 20,
        fieldPaddingV: 20,
        fieldSpacing: 20,
        errorFontSize: 15,
        errorPadding: 18,
        errorRadius: 14,
        errorIconSize: 24,
        errorMarginBottom: 20,
        buttonHeight: 60,
        buttonRadius: 16,
        buttonFontSize: 18,
        loaderSize: 28,
        loaderStroke: 3,
      );
    }
    return const RegisterLayoutSpec._(
      isTablet: false,
      maxContentWidth: double.infinity,
      horizontalPadding: 24,
      topSpacing: 20,
      bottomSpacing: 24,
      headerSpacing: 24,
      heroSize: 72,
      heroIconSize: 36,
      heroRadius: 20,
      titleFontSize: 26,
      subtitleFontSize: 15,
      subtitleSpacing: 8,
      cardPadding: 20,
      cardRadius: 20,
      fieldFontSize: 15,
      fieldIconSize: 22,
      fieldRadius: 12,
      fieldPaddingH: 16,
      fieldPaddingV: 16,
      fieldSpacing: 16,
      errorFontSize: 13,
      errorPadding: 14,
      errorRadius: 12,
      errorIconSize: 20,
      errorMarginBottom: 16,
      buttonHeight: 54,
      buttonRadius: 14,
      buttonFontSize: 16,
      loaderSize: 24,
      loaderStroke: 2.5,
    );
  }
}