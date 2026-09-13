// lib/presentation/screens/auth/widgets/login_password_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final LoginLayoutSpec spec;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onSubmitted;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.spec,
    required this.obscure,
    required this.onToggleObscure,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final border = AppTheme.textSec(context);
    final fill = AppTheme.surface(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: onSubmitted,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: spec.fieldFontSize.sp,
        fontWeight: FontWeight.w500,
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Şifre gerekli' : null,
      decoration: InputDecoration(
        labelText: 'Şifre',
        labelStyle: TextStyle(fontSize: spec.fieldFontSize.sp),
        prefixIcon: Icon(
          Icons.lock_outlined,
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
        filled: true,
        fillColor: fill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spec.fieldPaddingH.w,
          vertical: spec.fieldPaddingV.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide(
            color: border.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spec.fieldRadius.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}