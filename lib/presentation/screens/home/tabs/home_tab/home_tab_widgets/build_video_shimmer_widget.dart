import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/themes/app_theme.dart';

class HomeTabWidgetBuildVideoShimmerWidget extends StatelessWidget {
  const HomeTabWidgetBuildVideoShimmerWidget({
    super.key,
    required this.context,
  });

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 196.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.h,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.surface(context),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14.h,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(height: 6.h),
                              Container(
                                height: 14.h,
                                width: 160.w,
                                color: AppTheme.surface(context),
                              ),
                              SizedBox(height: 8.h),
                              Container(
                                height: 11.h,
                                width: 100.w,
                                color: AppTheme.surface(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}