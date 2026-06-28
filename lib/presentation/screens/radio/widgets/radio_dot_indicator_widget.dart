import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

class RadioDotIndicatorWidget extends StatelessWidget {
  final int count;
  final int current;
  const RadioDotIndicatorWidget({super.key, required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    final start = (current - 3).clamp(0, (count - 7).clamp(0, count));
    final end = (start + 7).clamp(0, count);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(end - start, (i) {
        final idx = start + i;
        final isActive = idx == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 18.w : 6.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.primaryColor.withValues(alpha: .25),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}
