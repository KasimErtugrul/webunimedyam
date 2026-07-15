// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_card_shimmer_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double bottomPadding = 10;
  static const double paddingLeft = 12;
  static const double paddingTop = 14;
  static const double paddingRight = 12;
  static const double paddingBottom = 12;
  static const double logoSize = 48;
  static const double logoSpacing = 12;
  static const double nameHeight = 14;
  static const double nameBorderRadius = 4;
  static const double subHeight = 10;
  static const double subWidth = 120;
  static const double spacingSmall = 6;
  static const double spacingMedium = 8;
  static const double chipHeight = 18;
  static const double chipWidth = 55;
  static const double chipSpacing = 6;
  static const double chipBorderRadius = 6;
  static const double chipWidthSmall = 45;
  static const double arrowSize = 32;
  static const double arrowSpacing = 8;
}

class _TabletSizes {
  static const double bottomPadding = 12;
  static const double paddingLeft = 16;
  static const double paddingTop = 16;
  static const double paddingRight = 16;
  static const double paddingBottom = 16;
  static const double logoSize = 56;
  static const double logoSpacing = 14;
  static const double nameHeight = 16;
  static const double nameBorderRadius = 5;
  static const double subHeight = 12;
  static const double subWidth = 140;
  static const double spacingSmall = 8;
  static const double spacingMedium = 10;
  static const double chipHeight = 20;
  static const double chipWidth = 65;
  static const double chipSpacing = 8;
  static const double chipBorderRadius = 7;
  static const double chipWidthSmall = 55;
  static const double arrowSize = 36;
  static const double arrowSpacing = 10;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversityCardShimmerWidget extends StatelessWidget {
  const UniversityCardShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
   // final sizes = isTablet ? _TabletSizes() : _PhoneSizes();

    return Padding(
      padding: EdgeInsets.only(
        bottom: isTablet ? _TabletSizes.bottomPadding : _PhoneSizes.bottomPadding.h,
      ),
      child: Shimmer.fromColors(
        baseColor: AppTheme.isDark(context)
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        highlightColor: AppTheme.isDark(context)
            ? const Color(0xFF3A3A3A)
            : const Color(0xFFF5F5F5),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            isTablet ? _TabletSizes.paddingLeft : _PhoneSizes.paddingLeft.w,
            isTablet ? _TabletSizes.paddingTop : _PhoneSizes.paddingTop.h,
            isTablet ? _TabletSizes.paddingRight : _PhoneSizes.paddingRight.w,
            isTablet ? _TabletSizes.paddingBottom : _PhoneSizes.paddingBottom.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: isTablet ? _TabletSizes.logoSize : _PhoneSizes.logoSize.w,
                height: isTablet ? _TabletSizes.logoSize : _PhoneSizes.logoSize.w,
                decoration: BoxDecoration(
                  color: AppTheme.card(context),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(
                width: isTablet ? _TabletSizes.logoSpacing : _PhoneSizes.logoSpacing.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: isTablet ? _TabletSizes.nameHeight : _PhoneSizes.nameHeight.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: BorderRadius.circular(
                          isTablet ? _TabletSizes.nameBorderRadius : _PhoneSizes.nameBorderRadius.r,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isTablet ? _TabletSizes.spacingSmall : _PhoneSizes.spacingSmall.h,
                    ),
                    Container(
                      height: isTablet ? _TabletSizes.subHeight : _PhoneSizes.subHeight.h,
                      width: isTablet ? _TabletSizes.subWidth : _PhoneSizes.subWidth.w,
                      decoration: BoxDecoration(
                        color: AppTheme.card(context),
                        borderRadius: BorderRadius.circular(
                          isTablet ? _TabletSizes.nameBorderRadius : _PhoneSizes.nameBorderRadius.r,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: isTablet ? _TabletSizes.spacingMedium : _PhoneSizes.spacingMedium.h,
                    ),
                    Row(
                      children: [
                        Container(
                          height: isTablet ? _TabletSizes.chipHeight : _PhoneSizes.chipHeight.h,
                          width: isTablet ? _TabletSizes.chipWidth : _PhoneSizes.chipWidth.w,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(
                              isTablet ? _TabletSizes.chipBorderRadius : _PhoneSizes.chipBorderRadius.r,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isTablet ? _TabletSizes.chipSpacing : _PhoneSizes.chipSpacing.w,
                        ),
                        Container(
                          height: isTablet ? _TabletSizes.chipHeight : _PhoneSizes.chipHeight.h,
                          width: isTablet ? _TabletSizes.chipWidth : _PhoneSizes.chipWidth.w,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(
                              isTablet ? _TabletSizes.chipBorderRadius : _PhoneSizes.chipBorderRadius.r,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isTablet ? _TabletSizes.chipSpacing : _PhoneSizes.chipSpacing.w,
                        ),
                        Container(
                          height: isTablet ? _TabletSizes.chipHeight : _PhoneSizes.chipHeight.h,
                          width: isTablet ? _TabletSizes.chipWidthSmall : _PhoneSizes.chipWidthSmall.w,
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(
                              isTablet ? _TabletSizes.chipBorderRadius : _PhoneSizes.chipBorderRadius.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: isTablet ? _TabletSizes.arrowSpacing : _PhoneSizes.arrowSpacing.w,
              ),
              Container(
                width: isTablet ? _TabletSizes.arrowSize : _PhoneSizes.arrowSize.w,
                height: isTablet ? _TabletSizes.arrowSize : _PhoneSizes.arrowSize.w,
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