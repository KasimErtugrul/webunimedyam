// ═══════════════════════════════════════════════════════════════════════════
// Yorum başlığı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';

class CommentsHeaderWidget extends StatelessWidget {
  final int count;
  const CommentsHeaderWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Yorumlar',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 13),
          ),
        ],
      ],
    );
  }
}