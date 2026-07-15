// lib/presentation/screens/profile/widgets/profile_header/stat_chip_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double countFontSize = 17;
  static const double labelFontSize = 11;
  static const double spacing = 2;
}

class _TabletSizes {
  static const double countFontSize = 21;
  static const double labelFontSize = 14;
  static const double spacing = 3;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class StatChipWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const StatChipWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    //final sizes = isTablet ? _TabletSizes() : _PhoneSizes();

    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: isTablet ? _TabletSizes.countFontSize : _PhoneSizes.countFontSize.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: isTablet ? _TabletSizes.spacing : _PhoneSizes.spacing.h,
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: isTablet ? _TabletSizes.labelFontSize : _PhoneSizes.labelFontSize.sp,
          ),
        ),
      ],
    );
  }
}