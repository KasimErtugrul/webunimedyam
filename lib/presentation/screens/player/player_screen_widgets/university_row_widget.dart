// ═══════════════════════════════════════════════════════════════════════════
// Üniversite Satırı  (logo · üniversite adı)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class UniversityRowWidget extends StatelessWidget {
  final String universityName;
  final String? logoUrl;
  final VoidCallback? onTap;

  const UniversityRowWidget({
    super.key,
    required this.universityName,
    this.logoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                universityName,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: 18.sp,
              ),
          ],
        ),
      ),
    );
  }
}
