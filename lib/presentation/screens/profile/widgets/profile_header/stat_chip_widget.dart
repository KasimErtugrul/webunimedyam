import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';

class StatChipWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const StatChipWidget({super.key, required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppTheme.textSec(context), fontSize: 11)),
      ],
    );
  }
}