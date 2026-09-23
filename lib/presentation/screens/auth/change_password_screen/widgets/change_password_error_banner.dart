// lib/presentation/screens/auth/widgets/change_password_error_banner.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../change_password_layout_spec.dart';

/// Sunucu kaynaklı hatalar için tema uyumlu uyarı bandı.
class ChangePasswordErrorBanner extends StatelessWidget {
  final String message;
  final ChangePasswordLayoutSpec spec;
  const ChangePasswordErrorBanner({
    super.key,
    required this.message,
    required this.spec,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(spec.radius.r),
        border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: scheme.error, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: scheme.error,
                fontSize: spec.errorFontSize.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}