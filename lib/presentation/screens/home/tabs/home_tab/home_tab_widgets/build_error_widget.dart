import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../controllers/home_controller.dart';

class HomeTabWidgetBuildErrorWidget extends StatelessWidget {
  const HomeTabWidgetBuildErrorWidget({
    super.key,
    required this.controller,
    required this.context,
  });

  final HomeController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: AppTheme.textSec(context),
            size: 48.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            controller.errorMessage.value,
            style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size(100.w, 40.h)),
            onPressed: controller.loadVideos,
            child: Text('Tekrar Dene', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}
