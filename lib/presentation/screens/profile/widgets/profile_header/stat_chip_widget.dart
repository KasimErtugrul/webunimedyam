// lib/presentation/screens/profile/widgets/profile_header/stat_chip_widget.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final bool isTablet;
  final double iconSize;
  final double countFontSize;
  final double labelFontSize;
  final double spacing;
  final double innerSpacing;

  const _Sizes._({
    required this.isTablet,
    required this.iconSize,
    required this.countFontSize,
    required this.labelFontSize,
    required this.spacing,
    required this.innerSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    // WEB: tablet ölçüleri — dokunma/tıklama hedefi konforlu kalır.
    if (Responsive.isWeb(context) || Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        iconSize: 18,
        countFontSize: 16,
        labelFontSize: 12,
        spacing: 4,
        innerSpacing: 6,
      );
    }
    return const _Sizes._(
      isTablet: false,
      iconSize: 14,
      countFontSize: 14,
      labelFontSize: 10.5,
      spacing: 3,
      innerSpacing: 5,
    );
  }
}

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
    final spec = _Sizes.of(context);
    double w(double v) => spec.isTablet ? v : v;
    double h(double v) => spec.isTablet ? v : v;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: spec.iconSize,
                color: AppTheme.textSec(context).withValues(alpha: 0.7),
              ),
              SizedBox(width: w(spec.innerSpacing)),
              Text(
                '$count',
                maxLines: 1,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: spec.countFontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: h(spec.spacing)),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.textSec(context).withValues(alpha: 0.8),
            fontSize: spec.labelFontSize,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ],
    );
  }
}
