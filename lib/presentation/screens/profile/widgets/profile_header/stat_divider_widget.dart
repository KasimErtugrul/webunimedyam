// lib/presentation/screens/profile/widgets/profile_header/stat_divider_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double width = 1;
  static const double height = 28;
}

class _TabletSizes {
  static const double width = 1.5;
  static const double height = 34;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class StatDividerWidget extends StatelessWidget {
  const StatDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    // final sizes = isTablet ? _TabletSizes() : _PhoneSizes();

    return Container(
      width: isTablet ? _TabletSizes.width : _PhoneSizes.width.w,
      height: isTablet ? _TabletSizes.height : _PhoneSizes.height.h,
      color: AppTheme.surface(context),
    );
  }
}
