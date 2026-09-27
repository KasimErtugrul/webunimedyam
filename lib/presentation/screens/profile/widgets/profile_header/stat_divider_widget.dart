// lib/presentation/screens/profile/widgets/profile_header/stat_divider_widget.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final bool isTablet;
  final double width;
  final double height;
  final double opacity;

  const _Sizes._({
    required this.isTablet,
    required this.width,
    required this.height,
    required this.opacity,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        width: 1,
        height: 30,
        opacity: 0.12,
      );
    }
    return const _Sizes._(isTablet: false, width: 1, height: 24, opacity: 0.12);
  }
}

class StatDividerWidget extends StatelessWidget {
  const StatDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = _Sizes.of(context);
    return Container(
      width: spec.isTablet ? spec.width : spec.width,
      height: spec.isTablet ? spec.height : spec.height,
      color: AppTheme.textSec(context).withValues(alpha: spec.opacity),
    );
  }
}
