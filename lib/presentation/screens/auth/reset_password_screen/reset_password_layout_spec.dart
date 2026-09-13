// lib/presentation/screens/auth/reset_password_layout_spec.dart
import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';
import 'widgets/otp_code_input.dart';

@immutable
class ResetPasswordLayoutSpec {
  final bool isTablet;
  final double maxContentWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double bottomPadding;

  // Açıklama
  final double subtitleFontSize;
  final double subtitleTopSpacing;

  // OTP
  final OtpCodeInputSpec otpSpec;
  final double otpTopSpacing;
  final double resendTopSpacing;
  final double resendFontSize;

  // Şifre alanları
  final double fieldFontSize;
  final double fieldIconSize;
  final double fieldRadius;
  final double fieldPaddingH;
  final double fieldPaddingV;
  final double fieldSpacing;
  final double passwordsTopSpacing;

  // Hata
  final double errorFontSize;
  final double errorPadding;
  final double errorRadius;
  final double errorIconSize;
  final double errorMarginBottom;
  final double errorTopSpacing;

  // Buton
  final double buttonHeight;
  final double buttonRadius;
  final double buttonFontSize;
  final double loaderSize;
  final double loaderStroke;
  final double buttonTopSpacing;

  const ResetPasswordLayoutSpec._({
    required this.isTablet,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.bottomPadding,
    required this.subtitleFontSize,
    required this.subtitleTopSpacing,
    required this.otpSpec,
    required this.otpTopSpacing,
    required this.resendTopSpacing,
    required this.resendFontSize,
    required this.fieldFontSize,
    required this.fieldIconSize,
    required this.fieldRadius,
    required this.fieldPaddingH,
    required this.fieldPaddingV,
    required this.fieldSpacing,
    required this.passwordsTopSpacing,
    required this.errorFontSize,
    required this.errorPadding,
    required this.errorRadius,
    required this.errorIconSize,
    required this.errorMarginBottom,
    required this.errorTopSpacing,
    required this.buttonHeight,
    required this.buttonRadius,
    required this.buttonFontSize,
    required this.loaderSize,
    required this.loaderStroke,
    required this.buttonTopSpacing,
  });

  factory ResetPasswordLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const ResetPasswordLayoutSpec._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 32,
        verticalPadding: 24,
        bottomPadding: 28,
        subtitleFontSize: 16,
        subtitleTopSpacing: 8,
        otpSpec: OtpCodeInputSpec(
          otpBoxWidth: 56,
          otpBoxHeight: 68,
          otpBoxRadius: 14,
          otpFontSize: 26,
        ),
        otpTopSpacing: 24,
        resendTopSpacing: 12,
        resendFontSize: 15,
        fieldFontSize: 17,
        fieldIconSize: 26,
        fieldRadius: 14,
        fieldPaddingH: 20,
        fieldPaddingV: 20,
        fieldSpacing: 20,
        passwordsTopSpacing: 24,
        errorFontSize: 14,
        errorPadding: 16,
        errorRadius: 12,
        errorIconSize: 22,
        errorMarginBottom: 18,
        errorTopSpacing: 20,
        buttonHeight: 58,
        buttonRadius: 14,
        buttonFontSize: 17,
        loaderSize: 26,
        loaderStroke: 2.5,
        buttonTopSpacing: 8,
      );
    }
    return const ResetPasswordLayoutSpec._(
      isTablet: false,
      maxContentWidth: double.infinity,
      horizontalPadding: 24,
      verticalPadding: 20,
      bottomPadding: 20,
      subtitleFontSize: 15,
      subtitleTopSpacing: 0,
      otpSpec: OtpCodeInputSpec(
        otpBoxWidth: 44,
        otpBoxHeight: 56,
        otpBoxRadius: 12,
        otpFontSize: 22,
      ),
      otpTopSpacing: 24,
      resendTopSpacing: 12,
      resendFontSize: 14,
      fieldFontSize: 16,
      fieldIconSize: 22,
      fieldRadius: 12,
      fieldPaddingH: 16,
      fieldPaddingV: 16,
      fieldSpacing: 16,
      passwordsTopSpacing: 20,
      errorFontSize: 13,
      errorPadding: 14,
      errorRadius: 12,
      errorIconSize: 20,
      errorMarginBottom: 16,
      errorTopSpacing: 20,
      buttonHeight: 54,
      buttonRadius: 14,
      buttonFontSize: 16,
      loaderSize: 24,
      loaderStroke: 2.5,
      buttonTopSpacing: 8,
    );
  }
}