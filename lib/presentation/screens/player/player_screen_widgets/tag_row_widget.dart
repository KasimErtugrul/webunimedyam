// ═══════════════════════════════════════════════════════════════════════════
// Etiketler
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class TagsRowWidget extends StatelessWidget {
  final List<String> tags;
  const TagsRowWidget({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: tags
          .take(8)
          .map(
            (tag) => Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '#$tag',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 11.sp,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}