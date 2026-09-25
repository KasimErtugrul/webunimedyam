// lib/presentation/screens/auth/widgets/auth_form_card.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';

class AuthFormCard extends StatelessWidget {
  final Widget child;
  final double padding;
  final double radius;

  const AuthFormCard({
    super.key,
    required this.child,
    required this.padding,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: child,
    );
  }
}