// lib/presentation/screens/auth/change_password_layout_spec.dart
import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';

@immutable
class ChangePasswordLayoutSpec {
  final bool isTablet;
  final double maxContentWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double topSpacing;
  final double bottomSpacing;
  final double fieldSpacing;
  final double sectionSpacing;
  final double fontSize;
  final double errorFontSize;
  final double iconSize;
  final double radius;
  final double buttonHeight;
  final double loaderSize;
  final double loaderStroke;

  const ChangePasswordLayoutSpec._({
    required this.isTablet,
    required this.maxContentWidth,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.topSpacing,
    required this.bottomSpacing,
    required this.fieldSpacing,
    required this.sectionSpacing,
    required this.fontSize,
    required this.errorFontSize,
    required this.iconSize,
    required this.radius,
    required this.buttonHeight,
    required this.loaderSize,
    required this.loaderStroke,
  });

  factory ChangePasswordLayoutSpec.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const ChangePasswordLayoutSpec._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 32,
        verticalPadding: 28,
        topSpacing: 16,
        bottomSpacing: 28,
        fieldSpacing: 18,
        sectionSpacing: 24,
        fontSize: 16,
        errorFontSize: 14,
        iconSize: 22,
        radius: 12,
        buttonHeight: 58,
        loaderSize: 26,
        loaderStroke: 2.5,
      );
    }
    return const ChangePasswordLayoutSpec._(
      isTablet: false,
      maxContentWidth: double.infinity,
      horizontalPadding: 24,
      verticalPadding: 20,
      topSpacing: 12,
      bottomSpacing: 20,
      fieldSpacing: 16,
      sectionSpacing: 20,
      fontSize: 16,
      errorFontSize: 13,
      iconSize: 20,
      radius: 12,
      buttonHeight: 54,
      loaderSize: 24,
      loaderStroke: 2.5,
    );
  }
}