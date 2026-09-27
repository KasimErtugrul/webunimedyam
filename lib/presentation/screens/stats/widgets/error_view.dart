// ─── Error View ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/stats_sizes.dart';

class StatsErrorView extends StatelessWidget {
  final StatsSizes sizes;
  final VoidCallback onRetry;
  const StatsErrorView({super.key, required this.sizes, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: sizes.errorIconSize,
                color: AppTheme.textSec(context),
              ),
              SizedBox(height: sizes.errorSpacingLarge),
              Text(
                'İstatistikler yüklenemedi',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: sizes.errorTitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: sizes.errorSpacingSmall),
              Text(
                'İnternet bağlantını kontrol et ve tekrar dene.',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: sizes.errorSubtitleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sizes.errorSpacingButton),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(
                  'Tekrar Dene',
                  style: TextStyle(fontSize: sizes.errorButtonFontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}