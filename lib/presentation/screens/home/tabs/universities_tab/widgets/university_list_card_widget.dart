import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/home_controller.dart';

class UniversityListCardWidget extends StatelessWidget {
  final UniversityModel university;

  const UniversityListCardWidget({super.key, required this.university});

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        university.logoUrl != null && university.logoUrl!.isNotEmpty;
    final hasRadio =
        university.radioLink != null && university.radioLink!.isNotEmpty;

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
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Logo + Bilgiler: Tıklanabilir Alan ────────────────────────
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Get.toNamed(
                    AppRoutes.universityDetail,
                    arguments: university,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Logo: Glow Daire ────────────────────────────────
                      Container(
                        width: 62.w,
                        height: 62.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            radius: 0.6,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 52.w,
                            height: 52.w,
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: AppTheme.isDark(context)
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.12,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 12.r,
                                  spreadRadius: 1.r,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: hasLogo
                                  ? CachedNetworkImage(
                                      imageUrl: university.logoUrl!,
                                      fit: BoxFit.contain,
                                      placeholder: (_, __) => Center(
                                        child: SizedBox(
                                          width: 18.w,
                                          height: 18.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5.w,
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.school_rounded,
                                        color: AppTheme.primaryColor,
                                        size: 22.sp,
                                      ),
                                    )
                                  : Icon(
                                      Icons.school_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 22.sp,
                                    ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 14.w),

                      // ── Ortadaki Bilgiler ───────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Satır 1: Üniversite Adı ────────────────
                            Text(
                              university.name ?? '',
                              style: TextStyle(
                                color: AppTheme.textPri(context),
                                fontSize: 14.5.sp,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 5.h),

                            // ── Satır 2: Şehir + Kuruluş Yılı + Radyo ──
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
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (university.foundedYear != null) ...[
                                  if (university.city != null)
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                      ),
                                      child: Text(
                                        '·',
                                        style: TextStyle(
                                          color: AppTheme.textSec(context),
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 10.sp,
                                    color: AppTheme.textSec(context),
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    '${university.foundedYear}',
                                    style: TextStyle(
                                      color: AppTheme.textSec(context),
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                if (hasRadio) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                    ),
                                    child: Text(
                                      '·',
                                      style: TextStyle(
                                        color: AppTheme.textSec(context),
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF8B5CF6,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.radio_rounded,
                                          size: 9.sp,
                                          color: const Color(0xFF8B5CF6),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Radyo',
                                          style: TextStyle(
                                            color: const Color(0xFF8B5CF6),
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            SizedBox(height: 8.h),

                            // ── Satır 3: İstatistik Çipleri ─────────────
                            Row(
                              children: [
                                // Abone
                                if (university.subscriberCount != null &&
                                    university.subscriberCount! > 0)
                                  _StatMicroChip(
                                    icon: Icons.people_rounded,
                                    label: _formatCount(
                                      university.subscriberCount!,
                                    ),
                                  ),
                                // İzlenme
                                if (university.viewCount != null &&
                                    university.viewCount! > 0) ...[
                                  SizedBox(width: 6.w),
                                  _StatMicroChip(
                                    icon: Icons.visibility_rounded,
                                    label: _formatCount(university.viewCount!),
                                  ),
                                ],
                                // Video
                                if (university.videoCount != null &&
                                    university.videoCount! > 0) ...[
                                  SizedBox(width: 6.w),
                                  _StatMicroChip(
                                    icon: Icons.play_circle_fill_rounded,
                                    label: '${university.videoCount}',
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // ── Sağ: Takip + Ok ───────────────────────────────────────────────
              Builder(
                builder: (context) {
                  final ctrl = Get.find<HomeController>();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final isFav = ctrl.favoriteUniversityIds.contains(
                          university.id,
                        );
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            debugPrint('TAP ALINDI — ${university.id}');
                            ctrl.toggleUniversityFavorite(university);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isFav
                                  ? AppTheme.primaryColor.withValues(
                                      alpha: 0.15,
                                    )
                                  : AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: isFav
                                ? Icon(
                                    Icons.check_rounded,
                                    color: AppTheme.primaryColor,
                                    size: 16.sp,
                                  )
                                : Text(
                                    'Takip Et',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        );
                      }),

                      SizedBox(height: 8.h),

                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.toNamed(
                          AppRoutes.universityDetail,
                          arguments: university,
                        ),
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppTheme.primaryColor,
                            size: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 1200 → 1.2K, 1200000 → 1.2M
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// ─── Mikro İstatistik Çipi ──────────────────────────────────────────────────

class _StatMicroChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatMicroChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: AppTheme.primaryColor),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
