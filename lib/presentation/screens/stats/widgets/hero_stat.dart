
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class HeroStat extends StatelessWidget {
  final StatsSizes sizes;
  final String value;
  final String label;
  const HeroStat({super.key, 
    required this.sizes,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: sizes.heroStatValueFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: sizes.metricSpacingMedium),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: sizes.heroStatLabelFontSize,
            ),
          ),
        ],
      ),
    );
  }
}
