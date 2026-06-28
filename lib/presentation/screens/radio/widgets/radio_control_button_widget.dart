import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class RadioControlButtonWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const RadioControlButtonWidget({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? AppTheme.primaryColor.withValues(alpha: .1)
              : AppTheme.primaryColor.withValues(alpha: .05),
        ),
        child: Icon(
          icon,
          size: 28.sp,
          color: enabled ? AppTheme.primaryColor : Colors.grey.shade500,
        ),
      ),
    );
  }
}