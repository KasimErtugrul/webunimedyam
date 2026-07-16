// lib/presentation/screens/radio/widgets/radio_fallback_logo_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/models/university_model.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double fontSize = 40;
  static const double alpha = 0.1;
}

class _TabletSizes {
  static const double fontSize = 52;
  static const double alpha = 0.1;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateless)
// ═══════════════════════════════════════════════════════════

class RadioFallbackLogoWidget extends StatelessWidget {
  final UniversityModel uni;
  const RadioFallbackLogoWidget({super.key, required this.uni});

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
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: _PhoneSizes.alpha),
      child: Center(
        child: Text(
          uni.name!.isNotEmpty ? uni.name![0] : '?',
          style: TextStyle(
            fontSize: _PhoneSizes.fontSize.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: _TabletSizes.alpha),
      child: Center(
        child: Text(
          uni.name!.isNotEmpty ? uni.name![0] : '?',
          style: TextStyle(
            fontSize: _TabletSizes.fontSize,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}