import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class StatDividerWidget extends StatelessWidget {
  const StatDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 28.h,
      color: AppTheme.surface(context),
    );
  }
}
