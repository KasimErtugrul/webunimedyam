// lib/presentation/screens/auth/widgets/auth_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

/// Auth ekranlarındaki tüm text field'ların ortak implementasyonu.
/// `AuthEmailField` / `AuthPasswordField` bunun üzerine kurulu.
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  /// `AutofillHints.email` gibi static String sabitleri.
  final List<String>? autofillHints;

  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool autofocus;
  final int? maxLength;

  // Görsel spec
  final double fontSize;
  final double iconSize;
  final double radius;
  final double paddingH;
  final double paddingV;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    required this.fontSize,
    required this.iconSize,
    required this.radius,
    required this.paddingH,
    required this.paddingV,
    this.focusNode,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.obscure = false,
    this.onToggleObscure,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.autofocus = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.12);

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      autofocus: autofocus,
      maxLength: maxLength,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: fontSize.sp,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: (fontSize - 1).sp,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          color: AppTheme.primaryColor,
          fontSize: (fontSize - 2).sp,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: AppTheme.primaryColor,
          size: iconSize.sp,
        ),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                tooltip: obscure ? 'Şifreyi göster' : 'Şifreyi gizle',
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textSec(context),
                  size: iconSize.sp,
                ),
                onPressed: onToggleObscure,
              )
            : null,
        filled: true,
        fillColor: isDark
            ? AppTheme.darkBackground.withValues(alpha: 0.6)
            : AppTheme.lightBackground,
        counterText: '',
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingH.w,
          vertical: paddingV.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.8,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.r),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.8),
        ),
      ),
    );
  }
}