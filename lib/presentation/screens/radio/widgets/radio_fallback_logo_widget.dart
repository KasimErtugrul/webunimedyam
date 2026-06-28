import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/university_model.dart';

class RadioFallbackLogoWidget extends StatelessWidget {
  final UniversityModel uni;
  const RadioFallbackLogoWidget({super.key, required this.uni});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor.withValues(alpha: .1),
      child: Center(
        child: Text(
          uni.name!.isNotEmpty ? uni.name![0] : '?',
          style: TextStyle(
            fontSize: 40.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}