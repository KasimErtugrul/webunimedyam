// lib/presentation/screens/auth/widgets/auth_password_field.dart
import 'package:flutter/material.dart';

import 'auth_text_field.dart';

class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction textInputAction;

  /// `AutofillHints.password` veya `AutofillHints.newPassword`.
  final String autofillHint;

  final double fontSize;
  final double iconSize;
  final double radius;
  final double paddingH;
  final double paddingV;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleObscure,
    required this.fontSize,
    required this.iconSize,
    required this.radius,
    required this.paddingH,
    required this.paddingV,
    this.focusNode,
    this.validator,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.next,
    this.autofillHint = AutofillHints.password,
  });

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: controller,
      focusNode: focusNode,
      label: label,
      prefixIcon: Icons.lock_outlined,
      obscure: obscure,
      onToggleObscure: onToggleObscure,
      autofillHints: [autofillHint],
      enableSuggestions: false,
      autocorrect: false,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      fontSize: fontSize,
      iconSize: iconSize,
      radius: radius,
      paddingH: paddingH,
      paddingV: paddingV,
    );
  }
}