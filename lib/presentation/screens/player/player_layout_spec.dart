// lib/presentation/screens/player/player_layout_spec.dart
import 'package:flutter/material.dart';

import '../../../core/responsive.dart';

@immutable
class PlayerLayoutSpec {
  final bool isTablet;

  // Mini player
  final double miniW;
  final double miniH;
  final double miniPad;
  final double miniBorderRadius;
  final double miniShadowBlur;
  final Duration animDur;
  final Curve animCurve;
  final double dragTapThreshold;
  final double miniBottomOffset;

  // Back button
  final double backButtonLeft;
  final double backButtonTop;
  final double backButtonPadding;
  final double backButtonRadius;
  final double backButtonSize;
  final double backButtonAlpha;

  // Content
  final double contentPaddingLeft;
  final double contentPaddingTop;
  final double contentPaddingRight;
  final double contentPaddingBottom;
  final double dateFontSize;
  final double dateDurationDotSpacing;
  final double titleFontSize;
  final double titleLineHeight;
  final double titleSpacing;
  final double universitySpacing;
  final double engagementSpacing;
  final double engagementBottomSpacing;
  final double descriptionSpacing;
  final double tagsSpacing;
  final double tagsBottomSpacing;
  final double suggestedSpacing;
  final double dividerSpacing;
  final double commentsHeaderSpacing;
  final double commentsInputSpacing;
  final double commentsLoadingSpacing;
  final double commentsEmptySpacing;
  final double commentsEmptyFontSize;
  final double bottomSpacing;

  // Loading
  final double loadingStrokeWidth;

  // Auth dialog
  final double dialogBorderRadius;
  final double dialogButtonRadius;

  const PlayerLayoutSpec._({
    required this.isTablet,
    required this.miniW,
    required this.miniH,
    required this.miniPad,
    required this.miniBorderRadius,
    required this.miniShadowBlur,
    required this.animDur,
    required this.animCurve,
    required this.dragTapThreshold,
    required this.miniBottomOffset,
    required this.backButtonLeft,
    required this.backButtonTop,
    required this.backButtonPadding,
    required this.backButtonRadius,
    required this.backButtonSize,
    required this.backButtonAlpha,
    required this.contentPaddingLeft,
    required this.contentPaddingTop,
    required this.contentPaddingRight,
    required this.contentPaddingBottom,
    required this.dateFontSize,
    required this.dateDurationDotSpacing,
    required this.titleFontSize,
    required this.titleLineHeight,
    required this.titleSpacing,
    required this.universitySpacing,
    required this.engagementSpacing,
    required this.engagementBottomSpacing,
    required this.descriptionSpacing,
    required this.tagsSpacing,
    required this.tagsBottomSpacing,
    required this.suggestedSpacing,
    required this.dividerSpacing,
    required this.commentsHeaderSpacing,
    required this.commentsInputSpacing,
    required this.commentsLoadingSpacing,
    required this.commentsEmptySpacing,
    required this.commentsEmptyFontSize,
    required this.bottomSpacing,
    required this.loadingStrokeWidth,
    required this.dialogBorderRadius,
    required this.dialogButtonRadius,
  });

  /// WEB ölçeği bayrağı — yalnızca PlayerWebLayoutSpec true döner.
  /// (Masaüstü tarayıcıda isTablet de true kalır: web, tablet yerleşimini
  /// temel alır, yalnızca ölçüler farklıdır.)
  bool get isWeb => false;

  factory PlayerLayoutSpec.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı — tablet yerleşimini
    // alır; sayfa kenarları ve tipografi web'e göre nefes alır.
    if (Responsive.isWeb(context)) {
      return const PlayerWebLayoutSpec._();
    }
    if (Responsive.isTablet(context)) {
      return const PlayerLayoutSpec._(
        isTablet: true,
        miniW: 320,
        miniH: 180,
        miniPad: 20,
        miniBorderRadius: 12,
        miniShadowBlur: 24,
        animDur: Duration(milliseconds: 300),
        animCurve: Curves.easeInOutCubic,
        dragTapThreshold: 8,
        miniBottomOffset: 56,
        backButtonLeft: 8,
        backButtonTop: 12,
        backButtonPadding: 10,
        backButtonRadius: 24,
        backButtonSize: 22,
        backButtonAlpha: 0.55,
        contentPaddingLeft: 24,
        contentPaddingTop: 18,
        contentPaddingRight: 24,
        contentPaddingBottom: 24,
        dateFontSize: 13,
        dateDurationDotSpacing: 8,
        titleFontSize: 20,
        titleLineHeight: 1.45,
        titleSpacing: 8,
        universitySpacing: 6,
        engagementSpacing: 18,
        engagementBottomSpacing: 24,
        descriptionSpacing: 16,
        tagsSpacing: 18,
        tagsBottomSpacing: 24,
        suggestedSpacing: 24,
        dividerSpacing: 20,
        commentsHeaderSpacing: 16,
        commentsInputSpacing: 20,
        commentsLoadingSpacing: 30,
        commentsEmptySpacing: 24,
        commentsEmptyFontSize: 15,
        bottomSpacing: 40,
        loadingStrokeWidth: 3.5,
        dialogBorderRadius: 20,
        dialogButtonRadius: 10,
      );
    }
    return const PlayerLayoutSpec._(
      isTablet: false,
      miniW: 192,
      miniH: 108,
      miniPad: 14,
      miniBorderRadius: 10,
      miniShadowBlur: 18,
      animDur: Duration(milliseconds: 280),
      animCurve: Curves.easeInOutCubic,
      dragTapThreshold: 6,
      miniBottomOffset: 56,
      backButtonLeft: 4,
      backButtonTop: 8,
      backButtonPadding: 8,
      backButtonRadius: 20,
      backButtonSize: 18,
      backButtonAlpha: 0.55,
      contentPaddingLeft: 16,
      contentPaddingTop: 14,
      contentPaddingRight: 16,
      contentPaddingBottom: 16,
      dateFontSize: 11,
      dateDurationDotSpacing: 6,
      titleFontSize: 15,
      titleLineHeight: 1.4,
      titleSpacing: 6,
      universitySpacing: 4,
      engagementSpacing: 14,
      engagementBottomSpacing: 20,
      descriptionSpacing: 12,
      tagsSpacing: 14,
      tagsBottomSpacing: 20,
      suggestedSpacing: 20,
      dividerSpacing: 16,
      commentsHeaderSpacing: 12,
      commentsInputSpacing: 16,
      commentsLoadingSpacing: 24,
      commentsEmptySpacing: 20,
      commentsEmptyFontSize: 13,
      bottomSpacing: 32,
      loadingStrokeWidth: 3,
      dialogBorderRadius: 16,
      dialogButtonRadius: 8,
    );
  }
}

/// WEB (masaüstü tarayıcı, ≥1024px) ölçek katmanı.
///
/// Tablet değerlerini super'e aktarır; yalnızca web'de farklılaşan
/// ölçüleri ezer: iki kolonlu düzen (video + önerilenler rayı) korunur
/// ama sayfa kenar boşlukları ve başlık/etkileşim tipografisi masaüstü
/// okuma mesafesine göre büyütülür. Mini player ölçüleri aynıdır —
/// sürüklenebilir pencere boyutu zaten cihazdan bağımsızdır.
class PlayerWebLayoutSpec extends PlayerLayoutSpec {
  const PlayerWebLayoutSpec._()
    : super._(
        isTablet: true,
        miniW: 320,
        miniH: 180,
        miniPad: 20,
        miniBorderRadius: 12,
        miniShadowBlur: 24,
        animDur: const Duration(milliseconds: 300),
        animCurve: Curves.easeInOutCubic,
        dragTapThreshold: 8,
        miniBottomOffset: 56,
        backButtonLeft: 8,
        backButtonTop: 12,
        backButtonPadding: 10,
        backButtonRadius: 24,
        backButtonSize: 22,
        backButtonAlpha: 0.55,
        contentPaddingLeft: 32,
        contentPaddingTop: 20,
        contentPaddingRight: 32,
        contentPaddingBottom: 32,
        dateFontSize: 14,
        dateDurationDotSpacing: 8,
        titleFontSize: 24,
        titleLineHeight: 1.45,
        titleSpacing: 10,
        universitySpacing: 8,
        engagementSpacing: 20,
        engagementBottomSpacing: 28,
        descriptionSpacing: 18,
        tagsSpacing: 20,
        tagsBottomSpacing: 28,
        suggestedSpacing: 28,
        dividerSpacing: 24,
        commentsHeaderSpacing: 18,
        commentsInputSpacing: 22,
        commentsLoadingSpacing: 32,
        commentsEmptySpacing: 28,
        commentsEmptyFontSize: 15,
        bottomSpacing: 48,
        loadingStrokeWidth: 3.5,
        dialogBorderRadius: 20,
        dialogButtonRadius: 10,
      );

  @override
  bool get isWeb => true;

  @override
  double get contentPaddingLeft => 32;
  @override
  double get contentPaddingRight => 32;
  @override
  double get titleFontSize => 24;
}
