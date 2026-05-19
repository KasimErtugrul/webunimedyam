
// ═══════════════════════════════════════════════════════════════════════════
// Etiketler
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';

class TagsRowWidget extends StatelessWidget {
  final List<String> tags;
  const TagsRowWidget({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: tags
          .take(8)
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 11,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}