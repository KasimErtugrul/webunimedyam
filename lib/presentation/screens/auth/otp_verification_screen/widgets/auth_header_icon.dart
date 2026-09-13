// lib/presentation/screens/auth/widgets/auth_header_icon.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class AuthHeaderIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final double radius;

  const AuthHeaderIcon({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(radius.r),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize.sp),
      ),
    );
  }
}