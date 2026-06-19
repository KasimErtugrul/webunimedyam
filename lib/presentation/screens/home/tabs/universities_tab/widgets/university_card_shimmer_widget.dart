// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_card_shimmer_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/themes/app_theme.dart';

class UniversityCardShimmerWidget extends StatelessWidget {
  const UniversityCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo placeholder (daire)
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  shape: BoxShape.circle,
                ),
              ),

              SizedBox(width: 12.w),

              // Metin placeholder'ları
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // İsim
                    Container(
                      height: 14.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Şehir + yıl
                    Container(
                      height: 10.h,
                      width: 120.w,
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    // Stat chip'ler
                    Row(
                      children: [
                        Container(
                          height: 18.h,
                          width: 55.w,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          height: 18.h,
                          width: 55.w,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          height: 18.h,
                          width: 45.w,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Ok placeholder
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}