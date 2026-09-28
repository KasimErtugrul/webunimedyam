// lib/presentation/screens/radio/widgets/radio_dot_indicator_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ DOT INDICATOR
// Konsept: "Modern Neon Dot Indicator with Glow Effect"
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double activeWidth = 20;
  static const double inactiveWidth = 6;
  static const double height = 6;
  static const double horizontalMargin = 2.5;
  static const double borderRadius = 3;
  static const double inactiveAlpha = 0.2;
  static const double activeGlowAlpha = 0.4;
}

class _TabletSizes {
  static const double activeWidth = 26;
  static const double inactiveWidth = 8;
  static const double height = 8;
  static const double horizontalMargin = 3;
  static const double borderRadius = 4;
  static const double inactiveAlpha = 0.2;
  static const double activeGlowAlpha = 0.4;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioDotIndicatorWidget extends StatelessWidget {
  final int count;
  final int current;

  const RadioDotIndicatorWidget({
    super.key,
    required this.count,
    required this.current,
  });

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
    final start = (current - 3).clamp(0, (count - 7).clamp(0, count));
    final end = (start + 7).clamp(0, count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _PhoneSizes.horizontalMargin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? _PhoneSizes.activeWidth : _PhoneSizes.inactiveWidth,
            height: _PhoneSizes.height,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: isActive
                  ? null
                  : AppTheme.primaryColor.withValues(alpha: _PhoneSizes.inactiveAlpha),
              borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeGlowAlpha),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TABLET - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final start = (current - 3).clamp(0, (count - 7).clamp(0, count));
    final end = (start + 7).clamp(0, count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: _TabletSizes.horizontalMargin),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isActive ? _TabletSizes.activeWidth : _TabletSizes.inactiveWidth,
            height: _TabletSizes.height,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.7),
                      ],
                    )
                  : null,
              color: isActive
                  ? null
                  : AppTheme.primaryColor.withValues(alpha: _TabletSizes.inactiveAlpha),
              borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeGlowAlpha),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}