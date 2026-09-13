// lib/presentation/screens/auth/widgets/auth_error_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Auth ekranlarında server/client hatasını göstermek için ortak kart.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  final double fontSize;
  final double padding;
  final double radius;
  final double iconSize;
  final double marginBottom;

  const AuthErrorBanner({
    super.key,
    required this.message,
    required this.fontSize,
    required this.padding,
    required this.radius,
    required this.iconSize,
    this.marginBottom = 16,
  });

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade400;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding.w),
      margin: EdgeInsets.only(bottom: marginBottom.h),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(radius.r),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: red, size: iconSize.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: red,
                fontSize: fontSize.sp,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: -0.15, end: 0, curve: Curves.easeOut);
  }
}