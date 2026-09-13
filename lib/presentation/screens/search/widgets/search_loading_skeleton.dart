// lib/presentation/screens/search/widgets/search_loading_skeleton.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../app/themes/app_theme.dart';
import '../search_layout_spec.dart';

class SearchLoadingSkeleton extends StatelessWidget {
  final SearchLayoutSpec spec;
  const SearchLoadingSkeleton({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: spec.resultsPaddingH.w,
          vertical: spec.resultsPaddingV.h,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => _SkeletonCard(spec: spec),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final SearchLayoutSpec spec;
  const _SkeletonCard({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: spec.cardBottomMargin.h),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(spec.cardRadius.r),
      ),
      child: Row(
        children: [
          Container(
            width: spec.cardThumbW.w,
            height: spec.cardThumbH.h,
            decoration: BoxDecoration(
              color: AppTheme.surface(context),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(spec.cardRadius.r),
                bottomLeft: Radius.circular(spec.cardRadius.r),
              ),
            ),
          ),
          SizedBox(width: spec.cardThumbSpacing.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spec.cardPaddingV.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: spec.cardTitleFontSize.sp,
                    width: double.infinity,
                    color: AppTheme.surface(context),
                  ),
                  SizedBox(height: spec.cardSpacingSm.h),
                  Container(
                    height: spec.cardTitleFontSize.sp,
                    width: 120.w,
                    color: AppTheme.surface(context),
                  ),
                  SizedBox(height: spec.cardSpacingSm.h),
                  Container(
                    height: spec.cardUniFontSize.sp,
                    width: 80.w,
                    color: AppTheme.surface(context),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: spec.cardTrailingSpacing.w),
        ],
      ),
    );
  }
}