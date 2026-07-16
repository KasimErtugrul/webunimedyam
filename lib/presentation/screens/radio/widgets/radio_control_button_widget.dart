// lib/presentation/screens/radio/widgets/radio_control_button_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double containerSize = 48;
  static const double iconSize = 28;
  static const double activeAlpha = 0.1;
  static const double inactiveAlpha = 0.05;
}

class _TabletSizes {
  static const double containerSize = 56;
  static const double iconSize = 32;
  static const double activeAlpha = 0.1;
  static const double inactiveAlpha = 0.05;
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
      onTap: enabled ? onTap : null,
      child: Container(
        width: _PhoneSizes.containerSize.r,
        height: _PhoneSizes.containerSize.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppTheme.primaryColor.withValues(alpha: _PhoneSizes.activeAlpha)
              : AppTheme.primaryColor.withValues(alpha: _PhoneSizes.inactiveAlpha),
        ),
        child: Icon(
          icon,
          size: _PhoneSizes.iconSize.sp,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade500,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: _TabletSizes.containerSize,
        height: _TabletSizes.containerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppTheme.primaryColor.withValues(alpha: _TabletSizes.activeAlpha)
              : AppTheme.primaryColor.withValues(alpha: _TabletSizes.inactiveAlpha),
        ),
        child: Icon(
          icon,
          size: _TabletSizes.iconSize,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade500,
        ),
      ),
    );
  }
}