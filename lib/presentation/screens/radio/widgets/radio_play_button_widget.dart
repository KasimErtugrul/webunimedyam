// lib/presentation/screens/radio/widgets/radio_play_button_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double containerSize = 72;
  static const double iconSize = 36;
  static const double activeAlpha = 0.15;
  static const double shadowAlpha = 0.3;
  static const double shadowBlurRadius = 20;
  static const double shadowSpreadRadius = 5;
}

class _TabletSizes {
  static const double containerSize = 84;
  static const double iconSize = 42;
  static const double activeAlpha = 0.15;
  static const double shadowAlpha = 0.3;
  static const double shadowBlurRadius = 24;
  static const double shadowSpreadRadius = 6;
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
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _PhoneSizes.containerSize.r,
        height: _PhoneSizes.containerSize.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeAlpha),
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
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _TabletSizes.containerSize,
        height: _TabletSizes.containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeAlpha),
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
    );
  }
}