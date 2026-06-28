import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class RadioPlayButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const RadioPlayButtonWidget({super.key, 
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.r,
        height: 72.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: .15),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: .3),
                    blurRadius: 20.r,
                    spreadRadius: 5.r,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 36.sp,
          color: active ? Colors.white : AppTheme.primaryColor,
        ),
      ),
    );
  }
}