// lib/presentation/screens/auth/widgets/change_password_header.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../change_password_layout_spec.dart';

/// Ekran başlığı: parlayan kalkan rozeti + "Hesap Güvenliği" + açıklama.
class ChangePasswordHeader extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  const ChangePasswordHeader({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.primary.withValues(alpha: 0.08),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.22),
                blurRadius: 48,
                spreadRadius: 6,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shield_outlined, size: 46, color: scheme.primary),
              Padding(
                padding: EdgeInsets.only(top: 3),
                child:
                    Icon(Icons.lock_rounded, size: 15, color: scheme.primary),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Hesap Güvenliği',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        SizedBox(height: 10),
        Text(
          'Şifreniz en az 8 karakterden oluşmalı, harf ve rakam içermelidir.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSec(context),
                height: 1.5,
              ),
        ),
      ],
    );
  }
}