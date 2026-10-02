// lib/presentation/screens/auth/change_password_layout_spec.dart
import 'package:flutter/material.dart';
import '../../../../core/responsive.dart';

@immutable
class ChangePasswordLayoutSpec {
  final bool isTablet;

  /// WEB ölçeği bayrağı — yalnızca ChangePasswordWebLayoutSpec true döner.
  bool get isWeb => false;
  final double maxContentWidth;
  final double horizontalPadding;
  final double verticalPadding;
  final double topSpacing;
  final double bottomSpacing;
  final double fieldSpacing;
  final double sectionSpacing;
  final double cardPadding; // form kartının iç boşluğu
  final double buttonGap; // Güncelle ↔ Vazgeç arası
  final double fontSize; // input & buton metni
  final double labelFontSize; // alan üstü başlıklar
  final double smallFontSize; // güç etiketi + checklist
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
    required this.cardPadding,
    required this.buttonGap,
    required this.fontSize,
    required this.labelFontSize,
    required this.smallFontSize,
    required this.errorFontSize,
    required this.iconSize,
    required this.radius,
    required this.buttonHeight,
    required this.loaderSize,
    required this.loaderStroke,
  });

  factory ChangePasswordLayoutSpec.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px): tablet yerleşimini temel alır.
    if (Responsive.isWeb(context)) {
      return const ChangePasswordWebLayoutSpec._();
    }
    if (Responsive.isTablet(context)) {
      return const ChangePasswordLayoutSpec._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 32,
        verticalPadding: 16,
        topSpacing: 32,
        bottomSpacing: 32,
        fieldSpacing: 20,
        sectionSpacing: 32,
        cardPadding: 24,
        buttonGap: 14,
        fontSize: 16,
        labelFontSize: 17,
        smallFontSize: 14,
        errorFontSize: 14,
        iconSize: 24,
        radius: 12,
        buttonHeight: 58,
        loaderSize: 26,
        loaderStroke: 2.5,
      );
    }
    return const ChangePasswordLayoutSpec._(
      isTablet: false,
      maxContentWidth: double.infinity,
      horizontalPadding: 20,
      verticalPadding: 12,
      topSpacing: 24,
      bottomSpacing: 24,
      fieldSpacing: 18,
      sectionSpacing: 28,
      cardPadding: 18,
      buttonGap: 12,
      fontSize: 16,
      labelFontSize: 16,
      smallFontSize: 13,
      errorFontSize: 13,
      iconSize: 22,
      radius: 12,
      buttonHeight: 54,
      loaderSize: 24,
      loaderStroke: 2.5,
    );
  }
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
/// Tablet değerlerini super'e aynen aktarır; yalnızca web'de
/// farklılaşan ölçüleri ezer.
class ChangePasswordWebLayoutSpec extends ChangePasswordLayoutSpec {
  const ChangePasswordWebLayoutSpec._()
    : super._(
        isTablet: true,
        maxContentWidth: 520,
        horizontalPadding: 32,
        verticalPadding: 16,
        topSpacing: 32,
        bottomSpacing: 32,
        fieldSpacing: 20,
        sectionSpacing: 32,
        cardPadding: 24,
        buttonGap: 14,
        fontSize: 16,
        labelFontSize: 17,
        smallFontSize: 14,
        errorFontSize: 14,
        iconSize: 24,
        radius: 12,
        buttonHeight: 58,
        loaderSize: 26,
        loaderStroke: 2.5,
      );

  @override
  bool get isWeb => true;

  @override
  double get maxContentWidth => 540;
}
