// lib/presentation/screens/auth/widgets/login_greeting.dart

import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

/// "Tekrar Hoş Geldin!" + açıklama (headline-xl-mobile / body-md)
class LoginGreeting extends StatelessWidget {
  const LoginGreeting({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    final s = sizes;

    return Column(
      children: [
        Text(
          'Tekrar Hoş Geldin!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: s.titleFontSize,
            fontWeight: FontWeight.w800,
            height: 34 / 26,
            letterSpacing: -0.025 * s.titleFontSize, // tracking-tight
          ),
        ),
        SizedBox(height: s.titleSubtitleGap),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: s.subtitleMaxWidth),
          child: Text(
            'Kampüs yayınlarını, dersleri ve topluluk videolarını keşfetmeye devam et.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: s.subtitleFontSize,
              height: 20 / 14,
            ),
          ),
        ),
      ],
    );
  }
}