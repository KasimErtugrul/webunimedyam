// lib/presentation/screens/auth/widgets/change_password_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../change_password_layout_spec.dart';

/// Tasarımdaki satır yapısı:
///   [Label]--------------------------[opsiyonel trailing link]
///   [ (prefix) hint --------------- (suffix göz) ]
class ChangePasswordField extends StatelessWidget {
  final ChangePasswordLayoutSpec spec;
  final String label;
  final Widget? labelTrailing;
  final TextEditingController textController;
  final FocusNode? focusNode;
  final IconData prefixIcon;
  final String hint;

  /// Verilirse göz ikonu gösterilir ve alan maskelenir.
  /// null → düz metin (tasarımda "Tekrar" alanında ikon yok).
  final RxBool? obscure;
  final VoidCallback? onToggleObscure;

  final String? autofillHint;
  final FormFieldValidator<String>? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const ChangePasswordField({
    super.key,
    required this.spec,
    required this.label,
    required this.textController,
    required this.prefixIcon,
    required this.hint,
    this.labelTrailing,
    this.focusNode,
    this.obscure,
    this.onToggleObscure,
    this.autofillHint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final showEye = obscure != null && onToggleObscure != null;
    final Widget field;
    if (obscure == null) {
      field = _buildField(context, isObscured: false, showEye: false);
    } else {
      field = Obx(
        () => _buildField(
          context,
          isObscured: obscure!.value,
          showEye: showEye,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: spec.labelFontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (labelTrailing != null) labelTrailing!,
          ],
        ),
        SizedBox(height: 8.h),
        field,
      ],
    );
  }

  Widget _buildField(
    BuildContext context, {
    required bool isObscured,
    required bool showEye,
  }) {
    return TextFormField(
      controller: textController,
      focusNode: focusNode,
      obscureText: isObscured,
      autofillHints: autofillHint == null ? null : [autofillHint!],
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: spec.fontSize.sp,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          prefixIcon,
          size: spec.iconSize.sp,
          color: AppTheme.textSec(context),
        ),
        suffixIcon: showEye
            ? IconButton(
                tooltip: isObscured ? 'Şifreyi göster' : 'Şifreyi gizle',
                onPressed: onToggleObscure,
                icon: Icon(
                  isObscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: spec.iconSize.sp,
                  color: AppTheme.textSec(context),
                ),
              )
            : null,
      ),
    );
  }
}