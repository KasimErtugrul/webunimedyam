// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/university_list_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/home_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Kart
  static const double bottomPadding = 10;
  static const double borderRadius = 16;
  static const double borderOpacityLight = 0.06;
  static const double paddingAll = 12;
  static const double logoSize = 48;
  static const double logoPadding = 6;
  static const double logoSpacing = 12;
  static const double logoPlaceholderSize = 20;
  static const double logoLoaderSize = 16;
  static const double logoLoaderStrokeWidth = 1.5;

  // Title
  static const double titleFontSize = 14;
  static const double titleLineHeight = 1.25;

  // Meta
  static const double metaSpacing = 8;
  static const double metaRunSpacing = 4;
  static const double metaIconSize = 11;
  static const double metaFontSize = 11;
  static const double metaSpacingSmall = 3;

  // Stats
  static const double statSpacing = 6;
  static const double statRunSpacing = 4;
  static const double statPaddingHorizontal = 6;
  static const double statPaddingVertical = 3;
  static const double statBorderRadius = 6;
  static const double statIconSize = 11;
  static const double statFontSize = 10;
  static const double statSpacingSmall = 3;

  // Follow Button
  static const double followPaddingHorizontal = 10;
  static const double followPaddingVertical = 6;
  static const double followBorderRadius = 20;
  static const double followIconSize = 16;
  static const double followFontSize = 11;

  // Arrow
  static const double arrowSize = 30;
  static const double arrowIconSize = 12;
  static const double arrowSpacing = 8;
  static const double arrowOpacity = 0.08;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double bottomPadding = 12;
  static const double borderRadius = 18;
  static const double borderOpacityLight = 0.06;
  static const double paddingAll = 16;
  static const double logoSize = 56;
  static const double logoPadding = 8;
  static const double logoSpacing = 14;
  static const double logoPlaceholderSize = 24;
  static const double logoLoaderSize = 18;
  static const double logoLoaderStrokeWidth = 2;

  // Title - tablet için daha büyük
  static const double titleFontSize = 16;
  static const double titleLineHeight = 1.3;

  // Meta - tablet için daha büyük
  static const double metaSpacing = 10;
  static const double metaRunSpacing = 5;
  static const double metaIconSize = 13;
  static const double metaFontSize = 13;
  static const double metaSpacingSmall = 4;

  // Stats - tablet için daha büyük
  static const double statSpacing = 8;
  static const double statRunSpacing = 5;
  static const double statPaddingHorizontal = 8;
  static const double statPaddingVertical = 4;
  static const double statBorderRadius = 7;
  static const double statIconSize = 13;
  static const double statFontSize = 12;
  static const double statSpacingSmall = 4;

  // Follow Button - tablet için daha büyük
  static const double followPaddingHorizontal = 12;
  static const double followPaddingVertical = 8;
  static const double followBorderRadius = 22;
  static const double followIconSize = 18;
  static const double followFontSize = 13;

  // Arrow - tablet için daha büyük
  static const double arrowSize = 34;
  static const double arrowIconSize = 14;
  static const double arrowSpacing = 10;
  static const double arrowOpacity = 0.08;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class UniversityListCardWidget extends StatelessWidget {
  final UniversityModel university;

  const UniversityListCardWidget({super.key, required this.university});

  void _openDetail() =>
      Get.toNamed(AppRoutes.universityDetail, arguments: university);

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final hasLogo =
        university.logoUrl != null && university.logoUrl!.isNotEmpty;
    final hasRadio =
        university.radioLink != null && university.radioLink!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: _PhoneSizes.bottomPadding.h),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openDetail,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_PhoneSizes.borderRadius.r),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.white.withValues(
                        alpha: _PhoneSizes.borderOpacityLight,
                      )
                    : Colors.black.withValues(
                        alpha: _PhoneSizes.borderOpacityLight,
                      ),
              ),
            ),
            padding: EdgeInsets.all(_PhoneSizes.paddingAll.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    width: _PhoneSizes.logoSize.w,
                    height: _PhoneSizes.logoSize.w,
                    color: AppTheme.isDark(context)
                        ? const Color(0xFF1E1E1E)
                        : AppTheme.bg(context),
                    padding: EdgeInsets.all(
                      hasLogo ? _PhoneSizes.logoPadding.w : 0,
                    ),
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: university.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => Center(
                              child: SizedBox(
                                width: _PhoneSizes.logoLoaderSize.w,
                                height: _PhoneSizes.logoLoaderSize.w,
                                child: CircularProgressIndicator(
                                  strokeWidth:
                                      _PhoneSizes.logoLoaderStrokeWidth.w,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: _PhoneSizes.logoPlaceholderSize.sp,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: _PhoneSizes.logoPlaceholderSize.sp,
                          ),
                  ),
                ),
                SizedBox(width: _PhoneSizes.logoSpacing.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name ?? '',
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: _PhoneSizes.titleFontSize.sp,
                          fontWeight: FontWeight.w700,
                          height: _PhoneSizes.titleLineHeight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _PhoneSizes.metaSpacing.h),
                      Wrap(
                        spacing: _PhoneSizes.metaSpacing.w,
                        runSpacing: _PhoneSizes.metaRunSpacing.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (university.city != null)
                            _MetaItemPhone(
                              icon: Icons.location_on_rounded,
                              label: university.city!,
                            ),
                          if (university.foundedYear != null)
                            _MetaItemPhone(
                              icon: Icons.calendar_today_rounded,
                              label: '${university.foundedYear}',
                            ),
                          if (hasRadio)
                            _MetaItemPhone(
                              icon: Icons.radio_rounded,
                              label: 'Radyo',
                              color: const Color(0xFF8B5CF6),
                            ),
                        ],
                      ),
                      SizedBox(height: _PhoneSizes.statSpacing.h),
                      Wrap(
                        spacing: _PhoneSizes.statSpacing.w,
                        runSpacing: _PhoneSizes.statRunSpacing.h,
                        children: [
                          if (university.subscriberCount != null &&
                              university.subscriberCount! > 0)
                            _StatMicroChipPhone(
                              icon: Icons.people_rounded,
                              label: _formatCount(university.subscriberCount!),
                            ),
                          if (university.viewCount != null &&
                              university.viewCount! > 0)
                            _StatMicroChipPhone(
                              icon: Icons.visibility_rounded,
                              label: _formatCount(university.viewCount!),
                            ),
                          if (university.videoCount != null &&
                              university.videoCount! > 0)
                            _StatMicroChipPhone(
                              icon: Icons.play_circle_fill_rounded,
                              label: '${university.videoCount}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: _PhoneSizes.arrowSpacing.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FollowButtonPhone(university: university),
                    SizedBox(height: _PhoneSizes.metaSpacing.h),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openDetail,
                      child: Container(
                        width: _PhoneSizes.arrowSize.w,
                        height: _PhoneSizes.arrowSize.w,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(
                            alpha: _PhoneSizes.arrowOpacity,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.primaryColor,
                          size: _PhoneSizes.arrowIconSize.sp,
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

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final hasLogo =
        university.logoUrl != null && university.logoUrl!.isNotEmpty;
    final hasRadio =
        university.radioLink != null && university.radioLink!.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: _TabletSizes.bottomPadding),
      child: Material(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _openDetail,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_TabletSizes.borderRadius),
              border: Border.all(
                color: AppTheme.isDark(context)
                    ? Colors.white.withValues(
                        alpha: _TabletSizes.borderOpacityLight,
                      )
                    : Colors.black.withValues(
                        alpha: _TabletSizes.borderOpacityLight,
                      ),
              ),
            ),
            padding: EdgeInsets.all(_TabletSizes.paddingAll),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Container(
                    width: _TabletSizes.logoSize,
                    height: _TabletSizes.logoSize,
                    color: AppTheme.isDark(context)
                        ? const Color(0xFF1E1E1E)
                        : AppTheme.bg(context),
                    padding: EdgeInsets.all(
                      hasLogo ? _TabletSizes.logoPadding : 0,
                    ),
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: university.logoUrl!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => Center(
                              child: SizedBox(
                                width: _TabletSizes.logoLoaderSize,
                                height: _TabletSizes.logoLoaderSize,
                                child: CircularProgressIndicator(
                                  strokeWidth:
                                      _TabletSizes.logoLoaderStrokeWidth,
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Icon(
                              Icons.school_rounded,
                              color: AppTheme.primaryColor,
                              size: _TabletSizes.logoPlaceholderSize,
                            ),
                          )
                        : Icon(
                            Icons.school_rounded,
                            color: AppTheme.primaryColor,
                            size: _TabletSizes.logoPlaceholderSize,
                          ),
                  ),
                ),
                SizedBox(width: _TabletSizes.logoSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name ?? '',
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: _TabletSizes.titleFontSize,
                          fontWeight: FontWeight.w700,
                          height: _TabletSizes.titleLineHeight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: _TabletSizes.metaSpacing),
                      Wrap(
                        spacing: _TabletSizes.metaSpacing,
                        runSpacing: _TabletSizes.metaRunSpacing,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (university.city != null)
                            _MetaItemTablet(
                              icon: Icons.location_on_rounded,
                              label: university.city!,
                            ),
                          if (university.foundedYear != null)
                            _MetaItemTablet(
                              icon: Icons.calendar_today_rounded,
                              label: '${university.foundedYear}',
                            ),
                          if (hasRadio)
                            _MetaItemTablet(
                              icon: Icons.radio_rounded,
                              label: 'Radyo',
                              color: const Color(0xFF8B5CF6),
                            ),
                        ],
                      ),
                      SizedBox(height: _TabletSizes.statSpacing),
                      Wrap(
                        spacing: _TabletSizes.statSpacing,
                        runSpacing: _TabletSizes.statRunSpacing,
                        children: [
                          if (university.subscriberCount != null &&
                              university.subscriberCount! > 0)
                            _StatMicroChipTablet(
                              icon: Icons.people_rounded,
                              label: _formatCount(university.subscriberCount!),
                            ),
                          if (university.viewCount != null &&
                              university.viewCount! > 0)
                            _StatMicroChipTablet(
                              icon: Icons.visibility_rounded,
                              label: _formatCount(university.viewCount!),
                            ),
                          if (university.videoCount != null &&
                              university.videoCount! > 0)
                            _StatMicroChipTablet(
                              icon: Icons.play_circle_fill_rounded,
                              label: '${university.videoCount}',
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: _TabletSizes.arrowSpacing),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FollowButtonTablet(university: university),
                    SizedBox(height: _TabletSizes.metaSpacing),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _openDetail,
                      child: Container(
                        width: _TabletSizes.arrowSize,
                        height: _TabletSizes.arrowSize,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(
                            alpha: _TabletSizes.arrowOpacity,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.primaryColor,
                          size: _TabletSizes.arrowIconSize,
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
}

// ─── Takip Butonu (PHONE) ────────────────────────────────────────────────────

class _FollowButtonPhone extends StatelessWidget {
  final UniversityModel university;
  const _FollowButtonPhone({required this.university});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Obx(() {
      final isFav = ctrl.favoriteUniversityIds.contains(university.id);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ctrl.toggleUniversityFavorite(university),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _PhoneSizes.followPaddingHorizontal.w,
            vertical: _PhoneSizes.followPaddingVertical.h,
          ),
          decoration: BoxDecoration(
            color: isFav
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(
              _PhoneSizes.followBorderRadius.r,
            ),
          ),
          child: isFav
              ? Icon(
                  Icons.check_rounded,
                  color: AppTheme.primaryColor,
                  size: _PhoneSizes.followIconSize.sp,
                )
              : Text(
                  'Takip Et',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _PhoneSizes.followFontSize.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      );
    });
  }
}

// ─── Takip Butonu (TABLET) ───────────────────────────────────────────────────

class _FollowButtonTablet extends StatelessWidget {
  final UniversityModel university;
  const _FollowButtonTablet({required this.university});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    return Obx(() {
      final isFav = ctrl.favoriteUniversityIds.contains(university.id);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ctrl.toggleUniversityFavorite(university),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: _TabletSizes.followPaddingHorizontal,
            vertical: _TabletSizes.followPaddingVertical,
          ),
          decoration: BoxDecoration(
            color: isFav
                ? AppTheme.primaryColor.withValues(alpha: 0.15)
                : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(
              _TabletSizes.followBorderRadius,
            ),
          ),
          child: isFav
              ? Icon(
                  Icons.check_rounded,
                  color: AppTheme.primaryColor,
                  size: _TabletSizes.followIconSize,
                )
              : Text(
                  'Takip Et',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _TabletSizes.followFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      );
    });
  }
}

// ─── Meta Bilgi (PHONE) ──────────────────────────────────────────────────────

class _MetaItemPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaItemPhone({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _PhoneSizes.metaIconSize.sp, color: c),
        SizedBox(width: _PhoneSizes.metaSpacingSmall.w),
        Text(
          label,
          style: TextStyle(
            color: c,
            fontSize: _PhoneSizes.metaFontSize.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Meta Bilgi (TABLET) ─────────────────────────────────────────────────────

class _MetaItemTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _MetaItemTablet({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.textSec(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _TabletSizes.metaIconSize, color: c),
        SizedBox(width: _TabletSizes.metaSpacingSmall),
        Text(
          label,
          style: TextStyle(
            color: c,
            fontSize: _TabletSizes.metaFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Mikro İstatistik Çipi (PHONE) ──────────────────────────────────────────

class _StatMicroChipPhone extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatMicroChipPhone({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.statPaddingHorizontal.w,
        vertical: _PhoneSizes.statPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(_PhoneSizes.statBorderRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _PhoneSizes.statIconSize.sp,
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: _PhoneSizes.statSpacingSmall.w),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: _PhoneSizes.statFontSize.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mikro İstatistik Çipi (TABLET) ─────────────────────────────────────────

class _StatMicroChipTablet extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatMicroChipTablet({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.statPaddingHorizontal,
        vertical: _TabletSizes.statPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(_TabletSizes.statBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: _TabletSizes.statIconSize,
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: _TabletSizes.statSpacingSmall),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: _TabletSizes.statFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
