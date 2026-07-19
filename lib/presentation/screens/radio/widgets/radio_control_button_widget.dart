// lib/presentation/screens/radio/widgets/radio_control_button_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ KONTROL BUTONU
// Konsept: "Modern Glassmorphism Control Button with Hover Effect"
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double containerSize = 48;
  static const double iconSize = 26;
  static const double activeAlpha = 0.15;
  static const double inactiveAlpha = 0.05;
  static const double activeBorderAlpha = 0.3;
}

class _TabletSizes {
  static const double containerSize = 56;
  static const double iconSize = 30;
  static const double activeAlpha = 0.15;
  static const double inactiveAlpha = 0.05;
  static const double activeBorderAlpha = 0.3;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioControlButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const RadioControlButtonWidget({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
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
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _PhoneSizes.containerSize.r,
        height: _PhoneSizes.containerSize.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeAlpha),
                    AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeAlpha * 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled
              ? null
              : AppTheme.primaryColor.withValues(alpha: _PhoneSizes.inactiveAlpha),
          border: Border.all(
            color: enabled
                ? AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeBorderAlpha)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: _PhoneSizes.iconSize.sp,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade600,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TABLET - ✨ YENİ ✨
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _TabletSizes.containerSize,
        height: _TabletSizes.containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeAlpha),
                    AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeAlpha * 0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled
              ? null
              : AppTheme.primaryColor.withValues(alpha: _TabletSizes.inactiveAlpha),
          border: Border.all(
            color: enabled
                ? AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeBorderAlpha)
                : Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: _TabletSizes.iconSize,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade600,
        ),
      ),
    );
  }
}