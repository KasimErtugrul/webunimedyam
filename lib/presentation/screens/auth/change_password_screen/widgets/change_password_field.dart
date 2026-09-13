// lib/presentation/screens/auth/widgets/change_password_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../change_password_layout_spec.dart';

class ChangePasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ChangePasswordLayoutSpec spec;
  final String label;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  /// `AutofillHints.password`, `AutofillHints.newPassword` gibi
  /// **static const String** sabitlerinden biri. (AutofillHints bir enum
  /// değildir; bu yüzden tip `String?`.)
  final String? autofillHint;

  const ChangePasswordField({
    super.key,
    required this.controller,
    required this.spec,
    required this.label,
    required this.obscure,
    required this.onToggleObscure,
    this.focusNode,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.autofillHint,
  });

  @override
  Widget build(BuildContext context) {
    // Yerel değişkene al → null-promotion çalışsın.
    final hint = autofillHint;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: textInputAction,
      autofillHints: hint == null ? null : [hint],
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: spec.fontSize.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: AppTheme.textSec(context),
          size: spec.iconSize.sp,
        ),
        suffixIcon: IconButton(
          tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppTheme.textSec(context),
            size: spec.iconSize.sp,
          ),
          onPressed: onToggleObscure,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.radius.r),
        ),
      ),
    );
  }
}