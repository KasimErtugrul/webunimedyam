import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class StatChipWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const StatChipWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}