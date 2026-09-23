// lib/presentation/screens/auth/widgets/login_or_divider.dart

import 'package:flutter/material.dart';

import '../login_layout_spec.dart';

/// Ayraç — çizgiler surface-container-highest, yazı "VEYA" (label-sm, outline)
class LoginOrDivider extends StatelessWidget {
  const LoginOrDivider({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Row(
      children: [
        Expanded(
          child: Container(height: 1, color: scheme.surfaceContainerHighest),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: s.dividerHPadding),
          child: Text(
            'VEYA',
            style: TextStyle(
              color: scheme.outline,
              fontSize: s.dividerFontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05 * s.dividerFontSize, // tracking-wider
            ),
          ),
        ),
        Expanded(
          child: Container(height: 1, color: scheme.surfaceContainerHighest),
        ),
      ],
    );
  }
}