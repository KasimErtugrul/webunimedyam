// lib/presentation/screens/auth/otp_verification_layout_spec.dart
import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';

@immutable
class OtpVerificationLayoutSpec {
  final bool isTablet;
  final double maxContentWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double bottomPadding;

  // Hero
  final double heroSize;
  final double heroIconSize;
  final double heroRadius;

  // Başlık / alt başlık
  final double titleFontSize;
  final double subtitleFontSize;
  final double titleTopSpacing;
  final double subtitleTopSpacing;
  final double formTopSpacing;

  // OTP kutuları
  final double otpBoxWidth;
  final double otpBoxHeight;
  final double otpBoxRadius;
  final double otpFontSize;
  final double otpSpacing;

  // Buton
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double loaderSize;
  final double loaderStroke;
  final double buttonTopSpacing;

  // Hata
  final double errorFontSize;
  final double errorPadding;
  final double errorRadius;
  final double errorIconSize;
  final double errorMarginBottom;

  // Resend
  final double resendFontSize;
  final double resendTopSpacing;

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
  });

  factory OtpVerificationLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const OtpVerificationLayoutSpec._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 32,
        verticalPadding: 24,
        bottomPadding: 28,
        heroSize: 88,
        heroIconSize: 44,
        heroRadius: 24,
        titleFontSize: 30,
        subtitleFontSize: 16,
        titleTopSpacing: 28,
        subtitleTopSpacing: 10,
        formTopSpacing: 40,
        otpBoxWidth: 56,
        otpBoxHeight: 68,
        otpBoxRadius: 14,
        otpFontSize: 26,
        otpSpacing: 14,
        buttonHeight: 58,
        buttonRadius: 14,
        buttonFontSize: 17,
        loaderSize: 26,
        loaderStroke: 2.5,
        buttonTopSpacing: 24,
        errorFontSize: 14,
        errorPadding: 16,
        errorRadius: 12,
        errorIconSize: 22,
        errorMarginBottom: 18,
        resendFontSize: 15,
        resendTopSpacing: 24,
      );
    }
    return const OtpVerificationLayoutSpec._(
      isTablet: false,
      maxContentWidth: double.infinity,
      horizontalPadding: 24,
      verticalPadding: 20,
      bottomPadding: 20,
      heroSize: 72,
      heroIconSize: 36,
      heroRadius: 20,
      titleFontSize: 26,
      subtitleFontSize: 15,
      titleTopSpacing: 24,
      subtitleTopSpacing: 8,
      formTopSpacing: 32,
      otpBoxWidth: 44,
      otpBoxHeight: 56,
      otpBoxRadius: 12,
      otpFontSize: 22,
      otpSpacing: 8,
      buttonHeight: 54,
      buttonRadius: 14,
      buttonFontSize: 16,
      loaderSize: 24,
      loaderStroke: 2.5,
      buttonTopSpacing: 20,
      errorFontSize: 13,
      errorPadding: 14,
      errorRadius: 12,
      errorIconSize: 20,
      errorMarginBottom: 16,
      resendFontSize: 14,
      resendTopSpacing: 20,
    );
  }
}