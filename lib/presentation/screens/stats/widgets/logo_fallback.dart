
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class LogoFallback extends StatelessWidget {
  final StatsSizes sizes;
  const LogoFallback({super.key, required this.sizes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizes.topUniLogoSize,
      height: sizes.topUniLogoSize,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(sizes.topUniLogoBorderRadius),
      ),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(context),
        size: sizes.logoFallbackSize,
      ),
    );
  }
}