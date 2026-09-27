// ─── Metric Card ──────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class MetricCard extends StatelessWidget {
  final StatsSizes sizes;
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const MetricCard({super.key, 
    required this.sizes,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.metricPaddingHorizontal,
        vertical: sizes.metricPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(sizes.metricBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: sizes.metricIconSize,
              ),
              SizedBox(width: sizes.metricIconSpacing),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.metricLabelFontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.metricSpacingSmall),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: sizes.metricValueFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: sizes.metricSpacingMedium),
          Text(
            sub,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: sizes.metricSubFontSize,
            ),
          ),
        ],
      ),
    );
  }
}