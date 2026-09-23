// lib/presentation/screens/auth/widgets/login_email_field.dart

import 'package:flutter/material.dart';

import '../login_layout_spec.dart';
import 'login_text_field.dart';

class LoginEmailField extends StatelessWidget {
  const LoginEmailField({
    super.key,
    required this.controller,
    required this.sizes,
    this.focusNode,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final LoginSizes sizes;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return LoginTextField(
      sizes: sizes,
      controller: controller,
      focusNode: focusNode,
      label: 'E-Posta veya Öğrenci Adresi',
      icon: Icons.mail_outline_rounded,
      hint: 'ogrenci@universite.edu.tr veya e-posta',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      enableSuggestions: false,
      autocorrect: false,
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'E-posta gerekli';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
          return 'Geçerli bir e-posta girin';
        }
        return null;
      },
      onSubmitted: onSubmitted,
    );
  }
}