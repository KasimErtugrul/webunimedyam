// lib/presentation/screens/auth/widgets/auth_email_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class AuthEmailField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? hintText;
  final double fontSize;
  final double iconSize;
  final double radius;
  final double paddingH;
  final double paddingV;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool autofocus;

  const AuthEmailField({
    super.key,
    required this.controller,
    required this.label,
    required this.fontSize,
    required this.iconSize,
    required this.radius,
    required this.paddingH,
    required this.paddingV,
    this.focusNode,
    this.hintText,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final border = AppTheme.textSec(context);
    final fill = AppTheme.surface(context);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autofillHints: const [AutofillHints.email],
      enableSuggestions: false,
      autocorrect: false,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: fontSize.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(fontSize: fontSize.sp),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: AppTheme.textSec(context),
          size: iconSize.sp,
        ),
        filled: true,
        fillColor: fill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingH.w,
          vertical: paddingV.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(
            color: border.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}