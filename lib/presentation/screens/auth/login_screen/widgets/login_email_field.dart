// lib/presentation/screens/auth/widgets/login_email_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

class LoginEmailField extends StatelessWidget {
  final TextEditingController controller;
  final LoginLayoutSpec spec;
  final ValueChanged<String>? onSubmitted;

  const LoginEmailField({
    super.key,
    required this.controller,
    required this.spec,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final border = AppTheme.textSec(context);
    final fill = AppTheme.surface(context);

    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email, AutofillHints.username],
      enableSuggestions: false,
      autocorrect: false,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: spec.fieldFontSize.sp,
        fontWeight: FontWeight.w500,
      ),
      validator: (value) {
        final v = value?.trim() ?? '';
        if (v.isEmpty) return 'Email gerekli';
        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
          return 'Geçerli bir email girin';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'ornek@comu.edu.tr',
        labelStyle: TextStyle(fontSize: spec.fieldFontSize.sp),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppTheme.textSec(context),
          size: spec.iconSize.sp,
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