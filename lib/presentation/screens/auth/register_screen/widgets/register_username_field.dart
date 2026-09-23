// lib/presentation/screens/auth/widgets/register_username_field.dart

import 'package:flutter/material.dart';


import '../register_layout_spec.dart';
import 'register_text_field.dart';

/// Kullanıcı Adı alanı — etiketin sağında "✓ Uygun" rozeti,
/// girdi ≥ 3 karakter olduğunda opacity 0→1 (JS davranışının aynısı).
class RegisterUsernameField extends StatelessWidget {
  const RegisterUsernameField({
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
      label: 'Kullanıcı Adı',
      icon: Icons.alternate_email_rounded,
      hint: 'kullanici_adi',
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      validator: validator,
      onSubmitted: onSubmitted,
      labelHint: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) {
          final isValid = value.text.trim().length >= 3;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isValid ? 1 : 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: s.labelHintFontSize + 2,
                  color: scheme.primary,
                ),
                SizedBox(width: s.livePillGap / 2),
                Text(
                  'Uygun',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: s.labelHintFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04 * s.labelHintFontSize,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}