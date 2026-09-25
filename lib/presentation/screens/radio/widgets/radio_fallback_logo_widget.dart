// lib/presentation/screens/radio/widgets/radio_fallback_logo_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ FALLBACK LOGO
// Konsept: "Modern Gradient Fallback with Neon Glow"
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/university_model.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double fontSize = 44;
  static const double alpha = 0.12;
  static const double borderAlpha = 0.2;
  static const double glowAlpha = 0.15;
}

class _TabletSizes {
  static const double fontSize = 56;
  static const double alpha = 0.12;
  static const double borderAlpha = 0.2;
  static const double glowAlpha = 0.15;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioFallbackLogoWidget extends StatelessWidget {
  final UniversityModel uni;
  const RadioFallbackLogoWidget({super.key, required this.uni});

  @override
  Widget build(BuildContext context) {
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PHONE - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: _PhoneSizes.alpha),
            AppTheme.primaryColor.withValues(alpha: _PhoneSizes.alpha * 0.5),
            AppTheme.secondaryColor.withValues(alpha: _PhoneSizes.alpha * 0.3),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.borderAlpha),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.glowAlpha),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          uni.name!.isNotEmpty ? uni.name![0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: _PhoneSizes.fontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TABLET - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withValues(alpha: _TabletSizes.alpha),
            AppTheme.primaryColor.withValues(alpha: _TabletSizes.alpha * 0.5),
            AppTheme.secondaryColor.withValues(alpha: _TabletSizes.alpha * 0.3),
          ],
        ),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.borderAlpha),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.glowAlpha),
            blurRadius: 14,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          uni.name!.isNotEmpty ? uni.name![0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: _TabletSizes.fontSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryColor,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}