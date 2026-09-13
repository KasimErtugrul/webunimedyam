// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_card_shimmer_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../universities_tab_layout_spec.dart';

/// Artık `Skeletonizer` paketiyle çalışır — anakart üzerinde sadece
/// statik gri bloklar çiziyoruz, shimmer efektini paket veriyor.
class UniversityCardShimmerWidget extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  const UniversityCardShimmerWidget({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: spec.cardBottomMargin.h),
      child: Container(
        padding: EdgeInsets.all(spec.cardPadding.w),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(spec.cardRadius.r),
          border: Border.all(
            color: AppTheme.textSec(context).withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: spec.cardLogoSize.w,
              height: spec.cardLogoSize.w,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            // Metin placeholder
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 14.h,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    height: 10.h,
                    width: 140.w,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Container(
                        height: 18.h,
                        width: 55.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        height: 18.h,
                        width: 55.w,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              height: spec.cardFollowHeight.h,
              width: 80.w,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(spec.cardFollowRadius.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kart listesi için hazır `Skeletonizer` sarmalayıcı.
class UniversityCardShimmerList extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final int count;
  const UniversityCardShimmerList({
    super.key,
    required this.spec,
    this.count = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: spec.contentHPadding.w,
        ),
        itemCount: count,
        itemBuilder: (_, _) => UniversityCardShimmerWidget(spec: spec),
      ),
    );
  }
}