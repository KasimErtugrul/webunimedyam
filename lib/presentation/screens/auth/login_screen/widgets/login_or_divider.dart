// lib/presentation/screens/auth/widgets/login_or_divider.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class LoginOrDivider extends StatelessWidget {
  final double fontSize;
  const LoginOrDivider({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.textSec(context).withValues(alpha: 0.25);
    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Text(
            'veya',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
      ],
    );
  }
}