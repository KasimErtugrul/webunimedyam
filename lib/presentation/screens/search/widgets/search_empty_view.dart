// lib/presentation/screens/search/widgets/search_empty_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../app/themes/app_theme.dart';
import '../search_layout_spec.dart';

class SearchEmptyView extends StatelessWidget {
  final SearchLayoutSpec spec;
  final String query;
  final VoidCallback onClear;

  const SearchEmptyView({
    super.key,
    required this.spec,
    required this.query,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spec.sectionH * 2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                color: AppTheme.textSec(context).withValues(alpha: 0.5),
                size: spec.emptyIconSize,
              )
                  .animate()
                  .fadeIn(duration: 350.ms)
                  .scaleXY(begin: 0.7, end: 1, curve: Curves.easeOutBack),
              SizedBox(height: spec.emptySpacing),
              Text(
                'Sonuç bulunamadı',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: spec.emptyTitleFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 300.ms),
              SizedBox(height: (spec.emptySpacing / 2)),
              Text(
                '"$query" için eşleşen bir video yok.\nFarklı bir kelime dene.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: spec.emptySubtitleFontSize,
                  height: 1.5,
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 300.ms),
              SizedBox(height: spec.emptySpacing * 1.5),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Aramayı temizle'),
              ).animate().fadeIn(delay: 220.ms, duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}