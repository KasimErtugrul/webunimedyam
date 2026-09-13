// lib/presentation/screens/auth/widgets/auth_gradient_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

/// Marka gradient'i + loading state + opsiyonel ok ikonu içeren ortak CTA.
class AuthGradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  final double height;
  final double radius;
  final double fontSize;
  final double loaderSize;
  final double loaderStroke;
  final IconData? trailingIcon;

  const AuthGradientButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    required this.height,
    required this.radius,
    required this.fontSize,
    required this.loaderSize,
    this.loaderStroke = 2.5,
    this.trailingIcon = Icons.arrow_forward_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppTheme.surface(context);
    final textSec = AppTheme.textSec(context);
    final primary = AppTheme.primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: loading
            ? null
            : const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: loading ? surface : null,
        borderRadius: BorderRadius.circular(radius.r),
        boxShadow: loading
            ? const []
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          minimumSize: Size(double.infinity, height.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius.r),
          ),
        ),
        child: loading
            ? SizedBox(
                width: loaderSize.w,
                height: loaderSize.w,
                child: CircularProgressIndicator(
                  color: textSec,
                  strokeWidth: loaderStroke,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      trailingIcon,
                      color: Colors.white,
                      size: (fontSize + 2).sp,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}