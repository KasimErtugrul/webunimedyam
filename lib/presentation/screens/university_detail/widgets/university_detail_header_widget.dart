// lib/presentation/screens/university_detail/widgets/university_detail_header.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/university_detail_controller.dart';
import '../university_detail_layout_spec.dart';

class UniversityDetailHeader extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityDetailController controller;
  const UniversityDetailHeader({
    super.key,
    required this.spec,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uni = controller.university.value;
      if (uni == null) {
        return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      }

      final hasLogo = uni.logoUrl?.isNotEmpty == true;
      final primary = AppTheme.primaryColor;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.10),
              AppTheme.bg(context).withValues(alpha: 0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: spec.headerTopPadding.h),

            // ── Logo ──
            Container(
              width: spec.headerLogoOuter.w,
              height: spec.headerLogoOuter.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primary.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
              child: Center(
                child: Container(
                  width: spec.headerLogoInner.w,
                  height: spec.headerLogoInner.w,
                  padding: EdgeInsets.all(spec.headerLogoPadding.w),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primary.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.18),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: uni.logoUrl!,
                            fit: BoxFit.contain,
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: primary,
                              size: spec.headerLogoInner.w * 0.4,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: primary,
                            size: spec.headerLogoInner.w * 0.4,
                          ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scaleXY(begin: 0.85, end: 1, curve: Curves.easeOutBack),

            SizedBox(height: 14.h),

            // ── Ad ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                uni.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: spec.headerNameFontSize.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPri(context),
                  height: spec.headerNameLineHeight,
                ),
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            // ── Şehir ──
            if (uni.city != null) ...[
              SizedBox(height: 6.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: (spec.headerCityFontSize + 1).sp,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    uni.city!,
                    style: TextStyle(
                      fontSize: spec.headerCityFontSize.sp,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            ],

            SizedBox(height: 10.h),

            // ── Favori badge ──
            Obx(() {
              if (!controller.isFavorite.value) return const SizedBox.shrink();
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spec.headerBadgePaddingH.w,
                  vertical: spec.headerBadgePaddingV.h,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark_rounded,
                      size: spec.headerBadgeFontSize.sp + 2,
                      color: primary,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Favorilerimde',
                      style: TextStyle(
                        fontSize: spec.headerBadgeFontSize.sp,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .scaleXY(begin: 0.9, end: 1, curve: Curves.easeOutBack);
            }),
          ],
        ),
      );
    });
  }
}