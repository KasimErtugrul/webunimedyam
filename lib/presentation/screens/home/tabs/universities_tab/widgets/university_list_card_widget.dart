// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_list_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';

class UniversityListCardWidget extends StatelessWidget {
  /// Widget artık doğrudan [UniversityModel] kabul eder.
  /// [playlist] yerine [university] kullanılır; bu sayede
  /// üniversite detay sayfasına tüm bilgiler aktarılabilir.
  final UniversityModel university;

  const UniversityListCardWidget({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        university.logoUrl != null && university.logoUrl!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Card(
        color: AppTheme.card(context),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(
            AppRoutes.universityDetail,
            arguments: university,
          ),
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.08),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // ── Logo ─────────────────────────────────────────────────
                Container(
                  width: 56.w,
                  height: 56.w,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                        AppTheme.secondaryColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: hasLogo
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: CachedNetworkImage(
                            imageUrl: university.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.w,
                                  color: AppTheme.primaryColor
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: 24.sp,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.school_rounded,
                          color: AppTheme.primaryColor,
                          size: 24.sp,
                        ),
                ),

                SizedBox(width: 14.w),

                // ── Ad + video sayısı ─────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name ?? '',
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          if (university.city != null) ...[
                            Icon(
                              Icons.location_on_rounded,
                              size: 12.sp,
                              color: AppTheme.textSec(context),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              university.city!,
                              style: TextStyle(
                                color: AppTheme.textSec(context),
                                fontSize: 11.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          if (university.videoCount != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_circle_fill_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 12.sp,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    '${university.videoCount} video',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // ── Ok ────────────────────────────────────────────────────
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppTheme.primaryColor,
                    size: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}