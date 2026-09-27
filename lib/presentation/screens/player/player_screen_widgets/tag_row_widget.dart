// lib/presentation/screens/player/player_screen_widgets/tag_row_widget.dart
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

class _Sizes {
  final double spacing;
  final double runSpacing;
  final double paddingH;
  final double paddingV;
  final double borderRadius;
  final double fontSize;

  const _Sizes._({
    required this.spacing,
    required this.runSpacing,
    required this.paddingH,
    required this.paddingV,
    required this.borderRadius,
    required this.fontSize,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        spacing: 8,
        runSpacing: 8,
        paddingH: 14,
        paddingV: 6,
        borderRadius: 24,
        fontSize: 13,
      );
    }
    return const _Sizes._(
      spacing: 6,
      runSpacing: 6,
      paddingH: 10,
      paddingV: 4,
      borderRadius: 20,
      fontSize: 11,
    );
  }
}

class TagsRowWidget extends StatelessWidget {
  final List<String> tags;
  const TagsRowWidget({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    return Wrap(
      spacing: s.spacing,
      runSpacing: s.runSpacing,
      children: tags
          .take(8)
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: s.paddingH,
                vertical: s.paddingV,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                '#$tag',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: s.fontSize,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}