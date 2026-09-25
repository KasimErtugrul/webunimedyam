// lib/presentation/screens/search/widgets/search_results_header.dart
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../search_layout_spec.dart';

class SearchResultsHeader extends StatelessWidget {
  final SearchLayoutSpec spec;
  final int count;

  const SearchResultsHeader({
    super.key,
    required this.spec,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        spec.resultsPaddingH,
        spec.resultsPaddingV,
        spec.resultsPaddingH,
        spec.resultsCountSpacing,
      ),
      child: Text(
        count == 1 ? '1 sonuç' : '$count sonuç',
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: spec.resultsCountFontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}