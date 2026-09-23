// lib/presentation/screens/auth/widgets/login_password_field.dart

import 'package:flutter/material.dart';

import '../login_layout_spec.dart';
import 'login_text_field.dart';

class LoginPasswordField extends StatelessWidget {
  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.sizes,
    this.focusNode,
    required this.obscure,
    required this.onToggleObscure,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final LoginSizes sizes;
  final FocusNode? focusNode;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return LoginTextField(
      sizes: s,
      controller: controller,
      focusNode: focusNode,
      label: 'Şifre',
      icon: Icons.lock_outline_rounded,
      hint: '••••••••',
      obscure: obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: (v) => (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
      onSubmitted: onSubmitted,
      // Göster/Gizle — h-9 w-9, right-2
      suffix: Padding(
        padding: EdgeInsets.only(right: s.toggleRight),
        child: IconButton(
          tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
          onPressed: onToggleObscure,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: s.toggleSize,
            minHeight: s.toggleSize,
          ),
          icon: Icon(
            obscure
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            size: s.fieldIconSize,
            color: scheme.outline,
          ),
        ),
      ),
    );
  }
}