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

  void _openDetail() =>
      Get.toNamed(AppRoutes.universityDetail, arguments: university);

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        university.logoUrl != null && university.logoUrl!.isNotEmpty;
    final hasRadio =
        university.radioLink != null && university.radioLink!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openDetail,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Logo: sade tek daire ─────────────────────────────
                ClipOval(
                  child: Container(
                    width: 48.w,
                    height: 48.w,
                    color: AppTheme.isDark(context)
                        ? const Color(0xFF1E1E1E)
                        : AppTheme.bg(context),
                    padding: EdgeInsets.all(hasLogo ? 6.w : 0),
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: university.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5.w,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: 20.sp,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: 20.sp,
                          ),
                  ),
                ),

                SizedBox(width: 12.w),

                // ── Bilgiler ──────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name ?? '',
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),

                      // Şehir / yıl / radyo — taşma yapmaz, satıra döner
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (university.city != null)
                            _MetaItem(
                              icon: Icons.location_on_rounded,
                              label: university.city!,
                            ),
                          if (university.foundedYear != null)
                            _MetaItem(
                              icon: Icons.calendar_today_rounded,
                              label: '${university.foundedYear}',
                            ),
                          if (hasRadio)
                            _MetaItem(
                              icon: Icons.radio_rounded,
                              label: 'Radyo',
                              color: const Color(0xFF8B5CF6),
                            ),
                        ],
                      ),

                      SizedBox(height: 8.h),

                      // İstatistik çipleri
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 4.h,
                        children: [
                          if (university.subscriberCount != null &&
                              university.subscriberCount! > 0)
                            _StatMicroChip(
                              icon: Icons.people_rounded,
                              label: _formatCount(university.subscriberCount!),
                            ),
                          if (university.viewCount != null &&
                              university.viewCount! > 0)
                            _StatMicroChip(
                              icon: Icons.visibility_rounded,
                              label: _formatCount(university.viewCount!),
                            ),
                          if (university.videoCount != null &&
                              university.videoCount! > 0)
                            _StatMicroChip(
                              icon: Icons.play_circle_fill_rounded,
                              label: '${university.videoCount}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 8.w),

                // ── Sağ: Takip + Ok ──────────────────────────────────
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FollowButton(university: university),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openDetail,
                      child: Container(
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.primaryColor,
                          size: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

// ─── Takip Butonu (sadece kendisi rebuild olur) ────────────────────────────

class _FollowButton extends StatelessWidget {
  final UniversityModel university;
  const _FollowButton({required this.university});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Obx(() {
      final isFav = ctrl.favoriteUniversityIds.contains(university.id);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ctrl.toggleUniversityFavorite(university),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: isFav
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
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
    });
  }
}

// ─── Meta Bilgi (şehir / yıl / radyo) ──────────────────────────────────────

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaItem({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11.sp, color: c),
        SizedBox(width: 3.w),
        Text(
          label,
          style: TextStyle(
            color: c,
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
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
