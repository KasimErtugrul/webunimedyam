// lib/presentation/screens/auth/widgets/register_password_field.dart

import 'package:flutter/material.dart';


import '../register_layout_spec.dart';
import 'register_text_field.dart';

/// Şifre alanı + JS'teki bire bir güç göstergesi:
///   len 0   → 0 bar,  "En az 8 karakter"   (outline)
///   len <6  → 1 bar,  "Zayıf"              (tertiary)
///   len <10 → 2 bar,  "Orta Düzey"         (secondary-fixed-dim)
///   len ≥10 → 3 bar,  "Güçlü ve Güvenli"   (primary, bold)
class RegisterPasswordField extends StatelessWidget {
  const RegisterPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sizes,
    required this.obscure,
    required this.onToggleObscure,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final RegisterSizes sizes;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        RegisterTextField(
          sizes: s,
          controller: controller,
          focusNode: focusNode,
          label: 'Şifre',
          icon: Icons.lock_outline_rounded,
          hint: '••••••••',
          obscure: obscure,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.newPassword],
          validator: validator,
          onSubmitted: onSubmitted,
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
                size: s.toggleIconSize,
                color: scheme.outline,
              ),
            ),
          ),
        ),

        // Password Indicator Tips — mt-1 px-1
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final len = value.text.length;

            // JS eşikleri: 0 / <6 / <10 / ≥10
            final int filledBars;
            final String hint;
            final Color hintColor;
            if (len == 0) {
              filledBars = 0;
              hint = 'En az 8 karakter';
              hintColor = scheme.outline;
            } else if (len < 6) {
              filledBars = 1;
              hint = 'Zayıf';
              hintColor = scheme.tertiary;
            } else if (len < 10) {
              filledBars = 2;
              hint = 'Orta Düzey';
              hintColor = scheme.secondaryFixedDim;
            } else {
              filledBars = 3;
              hint = 'Güçlü ve Güvenli';
              hintColor = scheme.primary;
            }

            return Padding(
              padding: EdgeInsets.only(
                top: s.strengthTopGap,
                left: s.strengthRowHPadding,
                right: s.strengthRowHPadding,
              ),
              child: Row(
                children: [
                  // 3 bar — flex-1 h-1 gap-1
                  Expanded(
                    child: Row(
                      children: List.generate(3, (i) {
                        final active = i < filledBars;
                        return Expanded(
                          child: Container(
                            height: s.strengthBarHeight,
                            margin: EdgeInsets.only(
                              right: i == 2 ? 0 : s.strengthBarGap,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? hintColor // bar rengi = ipucu rengi (JS)
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                s.strengthBarHeight,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: s.strengthRowGap),
                  // İpucu metni
                  Text(
                    hint,
                    style: TextStyle(
                      color: hintColor,
                      fontSize: s.strengthHintFontSize,
                      fontWeight:
                          filledBars == 3 ? FontWeight.w700 : FontWeight.w700,
                      letterSpacing: 0.04 * s.strengthHintFontSize,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}