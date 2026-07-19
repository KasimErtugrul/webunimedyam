// lib/presentation/screens/radio/widgets/radio_play_button_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ PLAY BUTONU
// Konsept: "Modern Glassmorphism Play Button with Pulse Animation"
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double containerSize = 72;
  static const double iconSize = 36;
  static const double activeAlpha = 0.15;
  static const double shadowAlpha = 0.4;
  static const double shadowBlurRadius = 24;
  static const double shadowSpreadRadius = 6;
  static const double pulseRingSize = 88;
}

class _TabletSizes {
  static const double containerSize = 84;
  static const double iconSize = 42;
  static const double activeAlpha = 0.15;
  static const double shadowAlpha = 0.4;
  static const double shadowBlurRadius = 28;
  static const double shadowSpreadRadius = 8;
  static const double pulseRingSize = 100;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioPlayButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const RadioPlayButtonWidget({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        // ✨ Pulse halkası (aktifken)
        if (active)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.0 + (value * 0.15),
                child: Container(
                  width: _PhoneSizes.pulseRingSize.r,
                  height: _PhoneSizes.pulseRingSize.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(
                      alpha: (0.12 - value * 0.1).clamp(0.0, 0.12),
                    ),
                  ),
                ),
              );
            },
            onEnd: () {},
          ),

        // ✨ Ana buton
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _PhoneSizes.containerSize.r,
            height: _PhoneSizes.containerSize.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: active
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: active
                  ? null
                  : AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeAlpha),
              border: active
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.shadowAlpha),
                        blurRadius: _PhoneSizes.shadowBlurRadius.r,
                        spreadRadius: _PhoneSizes.shadowSpreadRadius.r,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: _PhoneSizes.iconSize.sp,
              color: active ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TABLET - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (active)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 1.0 + (value * 0.15),
                child: Container(
                  width: _TabletSizes.pulseRingSize,
                  height: _TabletSizes.pulseRingSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(
                      alpha: (0.12 - value * 0.1).clamp(0.0, 0.12),
                    ),
                  ),
                ),
              );
            },
            onEnd: () {},
          ),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _TabletSizes.containerSize,
            height: _TabletSizes.containerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: active
                  ? LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: active
                  ? null
                  : AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeAlpha),
              border: active
                  ? Border.all(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.shadowAlpha),
                        blurRadius: _TabletSizes.shadowBlurRadius,
                        spreadRadius: _TabletSizes.shadowSpreadRadius,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: _TabletSizes.iconSize,
              color: active ? Colors.white : AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}