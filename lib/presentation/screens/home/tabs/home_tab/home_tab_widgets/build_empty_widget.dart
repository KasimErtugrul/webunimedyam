import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../app/themes/app_theme.dart';

class HomeTabWidgetBuildEmptyWidget extends StatelessWidget {
  const HomeTabWidgetBuildEmptyWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(32.w),
      child: Center(
        child: Text(
          'Henüz video yok.',
          style: TextStyle(color: AppTheme.textSec(context), fontSize: 14.sp),
        ),
      ),
    );
  }
}