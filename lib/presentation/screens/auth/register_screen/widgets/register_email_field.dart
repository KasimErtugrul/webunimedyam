// lib/presentation/screens/auth/widgets/register_email_field.dart

import 'package:flutter/material.dart';


import '../register_layout_spec.dart';
import 'register_text_field.dart';

/// E-posta alanı — etiketin sağında ".edu.tr ile Rozet Kazan" ipucu.
class RegisterEmailField extends StatelessWidget {
  const RegisterEmailField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sizes,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final RegisterSizes sizes;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return RegisterTextField(
      sizes: s,
      controller: controller,
      focusNode: focusNode,
      label: 'E-posta Adresi',
      icon: Icons.mail_outline_rounded,
      hint: 'ogrenci@edu.tr veya kişisel e-posta',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      enableSuggestions: false,
      autocorrect: false,
      validator: validator,
      onSubmitted: onSubmitted,
      labelHint: Text(
        '.edu.tr ile Rozet Kazan',
        style: TextStyle(
          color: scheme.secondary,
          fontSize: s.labelHintFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.04 * s.labelHintFontSize,
        ),
      ),
    );
  }
}