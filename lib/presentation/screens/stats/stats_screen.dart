// lib/presentation/screens/stats/stats_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/user_stats_model.dart';
import '../../controllers/stats_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 18;
  static const double backIconSize = 20;
  static const double refreshIconSize = 22;

  // Loading
  static const double loadingStrokeWidth = 3;

  // Error view
  static const double errorIconSize = 56;
  static const double errorSpacingLarge = 16;
  static const double errorSpacingSmall = 8;
  static const double errorSpacingButton = 24;
  static const double errorTitleFontSize = 16;
  static const double errorSubtitleFontSize = 13;
  static const double errorButtonFontSize = 14;

  // Body padding
  static const double bodyPaddingLeft = 16;
  static const double bodyPaddingTop = 8;
  static const double bodyPaddingRight = 16;
  static const double bodyPaddingBottom = 32;
  static const double bodySectionSpacing = 20;
  static const double bodySectionTitleSpacing = 10;

  // Hero card
  static const double heroPadding = 18;
  static const double heroBorderRadius = 16;
  static const double heroBorderWidth = 1;
  static const double heroAvatarSize = 46;
  static const double heroAvatarIconSize = 26;
  static const double heroAvatarSpacing = 12;
  static const double heroNameFontSize = 15;
  static const double heroMemberFontSize = 11;
  static const double heroWatchTimeFontSize = 13;
  static const double heroWatchTimeLabelFontSize = 10;
  static const double heroDividerSpacing = 16;
  static const double heroDividerHeight = 1;
  static const double heroStatValueFontSize = 22;
  static const double heroStatLabelFontSize = 11;
  static const double heroDividerWidth = 1;
  static const double heroDividerHeightVert = 32;

  // Streak card
  static const double streakPaddingHorizontal = 18;
  static const double streakPaddingVertical = 14;
  static const double streakBorderRadius = 14;
  static const double streakBorderWidth = 1;
  static const double streakIconSize = 44;
  static const double streakIconInnerSize = 24;
  static const double streakIconSpacing = 14;
  static const double streakTitleFontSize = 14;
  static const double streakSubtitleFontSize = 12;
  static const double streakEmojiFontSize = 22;

  // Metric card
  static const double metricPaddingHorizontal = 14;
  static const double metricPaddingVertical = 14;
  static const double metricBorderRadius = 12;
  static const double metricIconSize = 16;
  static const double metricIconSpacing = 6;
  static const double metricLabelFontSize = 11;
  static const double metricValueFontSize = 24;
  static const double metricSubFontSize = 10;
  static const double metricSpacingSmall = 8;
  static const double metricSpacingMedium = 2;
  static const double metricRowSpacing = 10;

  // Top university card
  static const double topUniPadding = 14;
  static const double topUniBorderRadius = 14;
  static const double topUniLogoSize = 48;
  static const double topUniLogoBorderRadius = 8;
  static const double topUniLogoSpacing = 14;
  static const double topUniNameFontSize = 14;
  static const double topUniSubFontSize = 12;
  static const double topUniStarSize = 22;
  static const double topUniSubSpacing = 4;

  // Video card
  static const double videoPadding = 12;
  static const double videoBorderRadius = 14;
  static const double videoThumbnailWidth = 72;
  static const double videoThumbnailHeight = 52;
  static const double videoThumbnailBorderRadius = 8;
  static const double videoTitleFontSize = 12;
  static const double videoTitleLineHeight = 1.4;
  static const double videoDateFontSize = 11;
  static const double videoIconSize = 20;
  static const double videoSpacing = 12;
  static const double videoSpacingSmall = 8;
  static const double videoSpacingDate = 4;

  // Thumb fallback
  static const double thumbFallbackIconSize = 24;

  // Section title
  static const double sectionTitleFontSize = 12;
  static const double sectionTitleLetterSpacing = 0.4;

  // Logo fallback
  static const double logoFallbackSize = 24;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double appBarTitleSize = 22;
  static const double backIconSize = 24;
  static const double refreshIconSize = 26;

  // Loading - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;

  // Error view - tablet için daha büyük
  static const double errorIconSize = 68;
  static const double errorSpacingLarge = 20;
  static const double errorSpacingSmall = 10;
  static const double errorSpacingButton = 28;
  static const double errorTitleFontSize = 20;
  static const double errorSubtitleFontSize = 16;
  static const double errorButtonFontSize = 16;

  // Body padding - tablet için daha büyük
  static const double bodyPaddingLeft = 24;
  static const double bodyPaddingTop = 12;
  static const double bodyPaddingRight = 24;
  static const double bodyPaddingBottom = 40;
  static const double bodySectionSpacing = 24;
  static const double bodySectionTitleSpacing = 14;

  // Hero card - tablet için daha büyük
  static const double heroPadding = 24;
  static const double heroBorderRadius = 20;
  static const double heroBorderWidth = 1.2;
  static const double heroAvatarSize = 56;
  static const double heroAvatarIconSize = 32;
  static const double heroAvatarSpacing = 16;
  static const double heroNameFontSize = 18;
  static const double heroMemberFontSize = 13;
  static const double heroWatchTimeFontSize = 16;
  static const double heroWatchTimeLabelFontSize = 12;
  static const double heroDividerSpacing = 20;
  static const double heroDividerHeight = 1.2;
  static const double heroStatValueFontSize = 28;
  static const double heroStatLabelFontSize = 13;
  static const double heroDividerWidth = 1.2;
  static const double heroDividerHeightVert = 40;

  // Streak card - tablet için daha büyük
  static const double streakPaddingHorizontal = 24;
  static const double streakPaddingVertical = 18;
  static const double streakBorderRadius = 18;
  static const double streakBorderWidth = 1.2;
  static const double streakIconSize = 52;
  static const double streakIconInnerSize = 28;
  static const double streakIconSpacing = 18;
  static const double streakTitleFontSize = 16;
  static const double streakSubtitleFontSize = 14;
  static const double streakEmojiFontSize = 26;

  // Metric card - tablet için daha büyük
  static const double metricPaddingHorizontal = 18;
  static const double metricPaddingVertical = 18;
  static const double metricBorderRadius = 14;
  static const double metricIconSize = 20;
  static const double metricIconSpacing = 8;
  static const double metricLabelFontSize = 13;
  static const double metricValueFontSize = 30;
  static const double metricSubFontSize = 12;
  static const double metricSpacingSmall = 10;
  static const double metricSpacingMedium = 3;
  static const double metricRowSpacing = 14;

  // Top university card - tablet için daha büyük
  static const double topUniPadding = 18;
  static const double topUniBorderRadius = 18;
  static const double topUniLogoSize = 56;
  static const double topUniLogoBorderRadius = 10;
  static const double topUniLogoSpacing = 18;
  static const double topUniNameFontSize = 16;
  static const double topUniSubFontSize = 14;
  static const double topUniStarSize = 26;
  static const double topUniSubSpacing = 6;

  // Video card - tablet için daha büyük
  static const double videoPadding = 16;
  static const double videoBorderRadius = 16;
  static const double videoThumbnailWidth = 88;
  static const double videoThumbnailHeight = 62;
  static const double videoThumbnailBorderRadius = 10;
  static const double videoTitleFontSize = 14;
  static const double videoTitleLineHeight = 1.45;
  static const double videoDateFontSize = 13;
  static const double videoIconSize = 24;
  static const double videoSpacing = 16;
  static const double videoSpacingSmall = 10;
  static const double videoSpacingDate = 6;

  // Thumb fallback - tablet için daha büyük
  static const double thumbFallbackIconSize = 30;

  // Section title - tablet için daha büyük
  static const double sectionTitleFontSize = 14;
  static const double sectionTitleLetterSpacing = 0.5;

  // Logo fallback - tablet için daha büyük
  static const double logoFallbackSize = 28;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
    final controller = Get.find<StatsController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'İstatistiklerim',
          style: TextStyle(
            fontSize: _PhoneSizes.appBarTitleSize.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPri(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: _PhoneSizes.backIconSize.sp,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSec(context),
                      size: _PhoneSizes.refreshIconSize.sp,
                    ),
                    tooltip: 'Yenile',
                    onPressed: controller.refresh,
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
            ),
          );
        }

        if (controller.errorMessage.value != null ||
            controller.stats.value == null) {
          return _ErrorViewPhone(onRetry: controller.refresh);
        }

        return _StatsBodyPhone(stats: controller.stats.value!);
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<StatsController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'İstatistiklerim',
          style: TextStyle(
            fontSize: _TabletSizes.appBarTitleSize,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPri(context),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: _TabletSizes.backIconSize,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const SizedBox.shrink()
                : IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSec(context),
                      size: _TabletSizes.refreshIconSize,
                    ),
                    tooltip: 'Yenile',
                    onPressed: controller.refresh,
                  ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: _TabletSizes.loadingStrokeWidth,
            ),
          );
        }

        if (controller.errorMessage.value != null ||
            controller.stats.value == null) {
          return _ErrorViewTablet(onRetry: controller.refresh);
        }

        return _StatsBodyTablet(stats: controller.stats.value!);
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (PHONE)
// ═══════════════════════════════════════════════════════════════════════

// ─── Error View (Phone) ──────────────────────────────────────────────────────

class _ErrorViewPhone extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorViewPhone({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: _PhoneSizes.errorIconSize.sp,
            color: AppTheme.textSec(context),
          ),
          SizedBox(height: _PhoneSizes.errorSpacingLarge.h),
          Text(
            'İstatistikler yüklenemedi',
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _PhoneSizes.errorTitleFontSize.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _PhoneSizes.errorSpacingSmall.h),
          Text(
            'İnternet bağlantını kontrol et ve tekrar dene.',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _PhoneSizes.errorSubtitleFontSize.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _PhoneSizes.errorSpacingButton.h),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(
              'Tekrar Dene',
              style: TextStyle(fontSize: _PhoneSizes.errorButtonFontSize.sp),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Body (Phone) ──────────────────────────────────────────────────────

class _StatsBodyPhone extends StatelessWidget {
  final UserStatsModel stats;
  const _StatsBodyPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => Get.find<StatsController>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          _PhoneSizes.bodyPaddingLeft.w,
          _PhoneSizes.bodyPaddingTop.h,
          _PhoneSizes.bodyPaddingRight.w,
          _PhoneSizes.bodyPaddingBottom.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCardPhone(stats: stats),
            SizedBox(height: _PhoneSizes.bodySectionSpacing.h),
            if (stats.currentStreakDays > 0 || stats.longestStreakDays > 0) ...[
              _StreakCardPhone(stats: stats),
              SizedBox(height: _PhoneSizes.bodySectionSpacing.h),
            ],
            _SectionTitlePhone(title: 'Dönem aktivitesi'),
            SizedBox(height: _PhoneSizes.bodySectionTitleSpacing.h),
            _PeriodGridPhone(stats: stats),
            SizedBox(height: _PhoneSizes.bodySectionSpacing.h),
            _SectionTitlePhone(title: 'Genel aktivite'),
            SizedBox(height: _PhoneSizes.bodySectionTitleSpacing.h),
            _ActivityGridPhone(stats: stats),
            SizedBox(height: _PhoneSizes.bodySectionSpacing.h),
            if (stats.topUniversityName != null) ...[
              _SectionTitlePhone(title: 'En çok izlediğin üniversite'),
              SizedBox(height: _PhoneSizes.bodySectionTitleSpacing.h),
              _TopUniversityCardPhone(stats: stats),
              SizedBox(height: _PhoneSizes.bodySectionSpacing.h),
            ],
            if (stats.lastWatchedTitle != null) ...[
              _SectionTitlePhone(title: 'Son izlediğin video'),
              SizedBox(height: _PhoneSizes.bodySectionTitleSpacing.h),
              _VideoCardPhone(
                title: stats.lastWatchedTitle!,
                thumbnail: stats.lastWatchedThumbnail,
                date: stats.lastWatchedAt,
                icon: Icons.play_circle_rounded,
              ),
              SizedBox(height: _PhoneSizes.bodySectionSpacing.h),
            ],
            if (stats.lastLikedTitle != null) ...[
              _SectionTitlePhone(title: 'Son beğendiğin video'),
              SizedBox(height: _PhoneSizes.bodySectionTitleSpacing.h),
              _VideoCardPhone(
                title: stats.lastLikedTitle!,
                thumbnail: stats.lastLikedThumbnail,
                date: stats.lastLikedAt,
                icon: Icons.favorite_rounded,
                iconColor: Colors.redAccent,
              ),
              SizedBox(height: _PhoneSizes.bodyPaddingBottom.h),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Hero Card (Phone) ──────────────────────────────────────────────────────

class _HeroCardPhone extends StatelessWidget {
  final UserStatsModel stats;
  const _HeroCardPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    final hours = stats.estimatedWatchMinutes ~/ 60;
    final mins = stats.estimatedWatchMinutes % 60;
    final watchTimeStr = hours > 0 ? '~$hours sa $mins dk' : '~$mins dk';

    return Container(
      padding: EdgeInsets.all(_PhoneSizes.heroPadding.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_PhoneSizes.heroBorderRadius.r),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: _PhoneSizes.heroBorderWidth.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _PhoneSizes.heroAvatarSize.w,
                height: _PhoneSizes.heroAvatarSize.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: _PhoneSizes.heroAvatarIconSize.sp,
                ),
              ),
              SizedBox(width: _PhoneSizes.heroAvatarSpacing.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.username ?? stats.fullName ?? 'Kullanıcı',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.heroNameFontSize.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (stats.memberSince != null)
                      Text(
                        'Üye · ${_formatDate(stats.memberSince!)}',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: _PhoneSizes.heroMemberFontSize.sp,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    watchTimeStr,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: _PhoneSizes.heroWatchTimeFontSize.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'izleme süresi',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.heroWatchTimeLabelFontSize.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: _PhoneSizes.heroDividerSpacing.h),
          Divider(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            height: _PhoneSizes.heroDividerHeight,
          ),
          SizedBox(height: _PhoneSizes.heroDividerSpacing.h),
          Row(
            children: [
              _HeroStatPhone(
                value: stats.totalWatched.toString(),
                label: 'İzlenen',
              ),
              _VertDividerPhone(),
              _HeroStatPhone(
                value: stats.totalLiked.toString(),
                label: 'Beğenilen',
              ),
              _VertDividerPhone(),
              _HeroStatPhone(
                value: stats.totalFavorited.toString(),
                label: 'Favori',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}

class _HeroStatPhone extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStatPhone({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: _PhoneSizes.heroStatValueFontSize.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: _PhoneSizes.metricSpacingMedium.h),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _PhoneSizes.heroStatLabelFontSize.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDividerPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _PhoneSizes.heroDividerWidth.w,
      height: _PhoneSizes.heroDividerHeightVert.h,
      color: AppTheme.primaryColor.withValues(alpha: 0.2),
    );
  }
}

// ─── Streak Card (Phone) ────────────────────────────────────────────────────

class _StreakCardPhone extends StatelessWidget {
  final UserStatsModel stats;
  const _StreakCardPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.streakPaddingHorizontal.w,
        vertical: _PhoneSizes.streakPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.streakBorderRadius.r),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: _PhoneSizes.streakBorderWidth.w,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _PhoneSizes.streakIconSize.w,
            height: _PhoneSizes.streakIconSize.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: _PhoneSizes.streakIconInnerSize.sp,
            ),
          ),
          SizedBox(width: _PhoneSizes.streakIconSpacing.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreakDays} günlük seri 🔥',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.streakTitleFontSize.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: _PhoneSizes.metricSpacingMedium.h),
                Text(
                  'En uzun serin: ${stats.longestStreakDays} gün',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.streakSubtitleFontSize.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '🏆',
            style: TextStyle(fontSize: _PhoneSizes.streakEmojiFontSize.sp),
          ),
        ],
      ),
    );
  }
}

// ─── Period Grid (Phone) ─────────────────────────────────────────────────────

class _PeriodGridPhone extends StatelessWidget {
  final UserStatsModel stats;
  const _PeriodGridPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCardPhone(
            icon: Icons.today_rounded,
            label: 'Bu hafta',
            value: stats.watchedThisWeek.toString(),
            sub: 'video izlendi',
          ),
        ),
        SizedBox(width: _PhoneSizes.metricRowSpacing.w),
        Expanded(
          child: _MetricCardPhone(
            icon: Icons.calendar_month_rounded,
            label: 'Bu ay',
            value: stats.watchedThisMonth.toString(),
            sub: 'video izlendi',
          ),
        ),
      ],
    );
  }
}

// ─── Activity Grid (Phone) ───────────────────────────────────────────────────

class _ActivityGridPhone extends StatelessWidget {
  final UserStatsModel stats;
  const _ActivityGridPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCardPhone(
                icon: Icons.chat_bubble_rounded,
                label: 'Yorum',
                value: stats.totalCommented.toString(),
                sub: 'yapıldı',
              ),
            ),
            SizedBox(width: _PhoneSizes.metricRowSpacing.w),
            Expanded(
              child: _MetricCardPhone(
                icon: Icons.share_rounded,
                label: 'Paylaşım',
                value: stats.totalShared.toString(),
                sub: 'yapıldı',
              ),
            ),
          ],
        ),
        SizedBox(height: _PhoneSizes.metricRowSpacing.h),
        Row(
          children: [
            Expanded(
              child: _MetricCardPhone(
                icon: Icons.school_rounded,
                label: 'Üniversite',
                value: stats.uniqueUniversitiesWatched.toString(),
                sub: 'farklı keşfedildi',
              ),
            ),
            SizedBox(width: _PhoneSizes.metricRowSpacing.w),
            Expanded(
              child: _MetricCardPhone(
                icon: Icons.play_circle_fill_rounded,
                label: 'Toplam',
                value: stats.totalWatched.toString(),
                sub: 'video izlendi',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Metric Card (Phone) ─────────────────────────────────────────────────────

class _MetricCardPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _MetricCardPhone({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.metricPaddingHorizontal.w,
        vertical: _PhoneSizes.metricPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.metricBorderRadius.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: _PhoneSizes.metricIconSize.sp,
              ),
              SizedBox(width: _PhoneSizes.metricIconSpacing.w),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.metricLabelFontSize.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: _PhoneSizes.metricSpacingSmall.h),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _PhoneSizes.metricValueFontSize.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: _PhoneSizes.metricSpacingMedium.h),
          Text(
            sub,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _PhoneSizes.metricSubFontSize.sp,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top University Card (Phone) ────────────────────────────────────────────

class _TopUniversityCardPhone extends StatelessWidget {
  final UserStatsModel stats;
  const _TopUniversityCardPhone({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_PhoneSizes.topUniPadding.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.topUniBorderRadius.r),
      ),
      child: Row(
        children: [
          if (stats.topUniversityLogo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                _PhoneSizes.topUniLogoBorderRadius.r,
              ),
              child: CachedNetworkImage(
                imageUrl: stats.topUniversityLogo!,
                width: _PhoneSizes.topUniLogoSize.w,
                height: _PhoneSizes.topUniLogoSize.w,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _LogoFallbackPhone(),
              ),
            )
          else
            _LogoFallbackPhone(),
          SizedBox(width: _PhoneSizes.topUniLogoSpacing.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.topUniversityName!,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.topUniNameFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _PhoneSizes.topUniSubSpacing.h),
                Text(
                  '${stats.topUniversityWatchCount ?? 0} video izlendi',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.topUniSubFontSize.sp,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: _PhoneSizes.topUniStarSize.sp,
          ),
        ],
      ),
    );
  }
}

class _LogoFallbackPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _PhoneSizes.topUniLogoSize.w,
      height: _PhoneSizes.topUniLogoSize.w,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.topUniLogoBorderRadius.r,
        ),
      ),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.logoFallbackSize.sp,
      ),
    );
  }
}

// ─── Video Card (Phone) ──────────────────────────────────────────────────────

class _VideoCardPhone extends StatelessWidget {
  final String title;
  final String? thumbnail;
  final DateTime? date;
  final IconData icon;
  final Color? iconColor;

  const _VideoCardPhone({
    required this.title,
    this.thumbnail,
    this.date,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_PhoneSizes.videoPadding.w),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.videoBorderRadius.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              _PhoneSizes.videoThumbnailBorderRadius.r,
            ),
            child: thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: thumbnail!,
                    width: _PhoneSizes.videoThumbnailWidth.w,
                    height: _PhoneSizes.videoThumbnailHeight.h,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _ThumbFallbackPhone(),
                  )
                : _ThumbFallbackPhone(),
          ),
          SizedBox(width: _PhoneSizes.videoSpacing.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.videoTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                    height: _PhoneSizes.videoTitleLineHeight,
                  ),
                ),
                if (date != null) ...[
                  SizedBox(height: _PhoneSizes.videoSpacingDate.h),
                  Text(
                    _formatRelative(date!),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.videoDateFontSize.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: _PhoneSizes.videoSpacingSmall.w),
          Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: _PhoneSizes.videoIconSize.sp,
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _ThumbFallbackPhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _PhoneSizes.videoThumbnailWidth.w,
      height: _PhoneSizes.videoThumbnailHeight.h,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(
          _PhoneSizes.videoThumbnailBorderRadius.r,
        ),
      ),
      child: Icon(
        Icons.play_circle_outline_rounded,
        color: AppTheme.textSec(context),
        size: _PhoneSizes.thumbFallbackIconSize.sp,
      ),
    );
  }
}

// ─── Section Title (Phone) ──────────────────────────────────────────────────

class _SectionTitlePhone extends StatelessWidget {
  final String title;
  const _SectionTitlePhone({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: _PhoneSizes.sectionTitleFontSize.sp,
        fontWeight: FontWeight.w600,
        letterSpacing: _PhoneSizes.sectionTitleLetterSpacing,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (TABLET)
// ═══════════════════════════════════════════════════════════════════════

// ─── Error View (Tablet) ──────────────────────────────────────────────────────

class _ErrorViewTablet extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorViewTablet({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_rounded,
            size: _TabletSizes.errorIconSize,
            color: AppTheme.textSec(context),
          ),
          SizedBox(height: _TabletSizes.errorSpacingLarge),
          Text(
            'İstatistikler yüklenemedi',
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _TabletSizes.errorTitleFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: _TabletSizes.errorSpacingSmall),
          Text(
            'İnternet bağlantını kontrol et ve tekrar dene.',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.errorSubtitleFontSize,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _TabletSizes.errorSpacingButton),
          ElevatedButton(
            onPressed: onRetry,
            child: Text(
              'Tekrar Dene',
              style: TextStyle(fontSize: _TabletSizes.errorButtonFontSize),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Body (Tablet) ──────────────────────────────────────────────────────

class _StatsBodyTablet extends StatelessWidget {
  final UserStatsModel stats;
  const _StatsBodyTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.primaryColor,
      onRefresh: () => Get.find<StatsController>().refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          _TabletSizes.bodyPaddingLeft,
          _TabletSizes.bodyPaddingTop,
          _TabletSizes.bodyPaddingRight,
          _TabletSizes.bodyPaddingBottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCardTablet(stats: stats),
            SizedBox(height: _TabletSizes.bodySectionSpacing),
            if (stats.currentStreakDays > 0 || stats.longestStreakDays > 0) ...[
              _StreakCardTablet(stats: stats),
              SizedBox(height: _TabletSizes.bodySectionSpacing),
            ],
            _SectionTitleTablet(title: 'Dönem aktivitesi'),
            SizedBox(height: _TabletSizes.bodySectionTitleSpacing),
            _PeriodGridTablet(stats: stats),
            SizedBox(height: _TabletSizes.bodySectionSpacing),
            _SectionTitleTablet(title: 'Genel aktivite'),
            SizedBox(height: _TabletSizes.bodySectionTitleSpacing),
            _ActivityGridTablet(stats: stats),
            SizedBox(height: _TabletSizes.bodySectionSpacing),
            if (stats.topUniversityName != null) ...[
              _SectionTitleTablet(title: 'En çok izlediğin üniversite'),
              SizedBox(height: _TabletSizes.bodySectionTitleSpacing),
              _TopUniversityCardTablet(stats: stats),
              SizedBox(height: _TabletSizes.bodySectionSpacing),
            ],
            if (stats.lastWatchedTitle != null) ...[
              _SectionTitleTablet(title: 'Son izlediğin video'),
              SizedBox(height: _TabletSizes.bodySectionTitleSpacing),
              _VideoCardTablet(
                title: stats.lastWatchedTitle!,
                thumbnail: stats.lastWatchedThumbnail,
                date: stats.lastWatchedAt,
                icon: Icons.play_circle_rounded,
              ),
              SizedBox(height: _TabletSizes.bodySectionSpacing),
            ],
            if (stats.lastLikedTitle != null) ...[
              _SectionTitleTablet(title: 'Son beğendiğin video'),
              SizedBox(height: _TabletSizes.bodySectionTitleSpacing),
              _VideoCardTablet(
                title: stats.lastLikedTitle!,
                thumbnail: stats.lastLikedThumbnail,
                date: stats.lastLikedAt,
                icon: Icons.favorite_rounded,
                iconColor: Colors.redAccent,
              ),
              SizedBox(height: _TabletSizes.bodyPaddingBottom),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Hero Card (Tablet) ──────────────────────────────────────────────────────

class _HeroCardTablet extends StatelessWidget {
  final UserStatsModel stats;
  const _HeroCardTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    final hours = stats.estimatedWatchMinutes ~/ 60;
    final mins = stats.estimatedWatchMinutes % 60;
    final watchTimeStr = hours > 0 ? '~$hours sa $mins dk' : '~$mins dk';

    return Container(
      padding: EdgeInsets.all(_TabletSizes.heroPadding),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(_TabletSizes.heroBorderRadius),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.25),
          width: _TabletSizes.heroBorderWidth,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: _TabletSizes.heroAvatarSize,
                height: _TabletSizes.heroAvatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                  size: _TabletSizes.heroAvatarIconSize,
                ),
              ),
              SizedBox(width: _TabletSizes.heroAvatarSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stats.username ?? stats.fullName ?? 'Kullanıcı',
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.heroNameFontSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (stats.memberSince != null)
                      Text(
                        'Üye · ${_formatDate(stats.memberSince!)}',
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: _TabletSizes.heroMemberFontSize,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    watchTimeStr,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: _TabletSizes.heroWatchTimeFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'izleme süresi',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.heroWatchTimeLabelFontSize,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: _TabletSizes.heroDividerSpacing),
          Divider(
            color: AppTheme.primaryColor.withValues(alpha: 0.15),
            height: _TabletSizes.heroDividerHeight,
          ),
          SizedBox(height: _TabletSizes.heroDividerSpacing),
          Row(
            children: [
              _HeroStatTablet(
                value: stats.totalWatched.toString(),
                label: 'İzlenen',
              ),
              _VertDividerTablet(),
              _HeroStatTablet(
                value: stats.totalLiked.toString(),
                label: 'Beğenilen',
              ),
              _VertDividerTablet(),
              _HeroStatTablet(
                value: stats.totalFavorited.toString(),
                label: 'Favori',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${months[dt.month]} ${dt.year}';
  }
}

class _HeroStatTablet extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStatTablet({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: _TabletSizes.heroStatValueFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: _TabletSizes.metricSpacingMedium),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.heroStatLabelFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDividerTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _TabletSizes.heroDividerWidth,
      height: _TabletSizes.heroDividerHeightVert,
      color: AppTheme.primaryColor.withValues(alpha: 0.2),
    );
  }
}

// ─── Streak Card (Tablet) ────────────────────────────────────────────────────

class _StreakCardTablet extends StatelessWidget {
  final UserStatsModel stats;
  const _StreakCardTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.streakPaddingHorizontal,
        vertical: _TabletSizes.streakPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.streakBorderRadius),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.15),
          width: _TabletSizes.streakBorderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: _TabletSizes.streakIconSize,
            height: _TabletSizes.streakIconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.withValues(alpha: 0.15),
            ),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Colors.orange,
              size: _TabletSizes.streakIconInnerSize,
            ),
          ),
          SizedBox(width: _TabletSizes.streakIconSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.currentStreakDays} günlük seri 🔥',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.streakTitleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: _TabletSizes.metricSpacingMedium),
                Text(
                  'En uzun serin: ${stats.longestStreakDays} gün',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.streakSubtitleFontSize,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '🏆',
            style: TextStyle(fontSize: _TabletSizes.streakEmojiFontSize),
          ),
        ],
      ),
    );
  }
}

// ─── Period Grid (Tablet) ─────────────────────────────────────────────────────

class _PeriodGridTablet extends StatelessWidget {
  final UserStatsModel stats;
  const _PeriodGridTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCardTablet(
            icon: Icons.today_rounded,
            label: 'Bu hafta',
            value: stats.watchedThisWeek.toString(),
            sub: 'video izlendi',
          ),
        ),
        SizedBox(width: _TabletSizes.metricRowSpacing),
        Expanded(
          child: _MetricCardTablet(
            icon: Icons.calendar_month_rounded,
            label: 'Bu ay',
            value: stats.watchedThisMonth.toString(),
            sub: 'video izlendi',
          ),
        ),
      ],
    );
  }
}

// ─── Activity Grid (Tablet) ───────────────────────────────────────────────────

class _ActivityGridTablet extends StatelessWidget {
  final UserStatsModel stats;
  const _ActivityGridTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCardTablet(
                icon: Icons.chat_bubble_rounded,
                label: 'Yorum',
                value: stats.totalCommented.toString(),
                sub: 'yapıldı',
              ),
            ),
            SizedBox(width: _TabletSizes.metricRowSpacing),
            Expanded(
              child: _MetricCardTablet(
                icon: Icons.share_rounded,
                label: 'Paylaşım',
                value: stats.totalShared.toString(),
                sub: 'yapıldı',
              ),
            ),
          ],
        ),
        SizedBox(height: _TabletSizes.metricRowSpacing),
        Row(
          children: [
            Expanded(
              child: _MetricCardTablet(
                icon: Icons.school_rounded,
                label: 'Üniversite',
                value: stats.uniqueUniversitiesWatched.toString(),
                sub: 'farklı keşfedildi',
              ),
            ),
            SizedBox(width: _TabletSizes.metricRowSpacing),
            Expanded(
              child: _MetricCardTablet(
                icon: Icons.play_circle_fill_rounded,
                label: 'Toplam',
                value: stats.totalWatched.toString(),
                sub: 'video izlendi',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Metric Card (Tablet) ─────────────────────────────────────────────────────

class _MetricCardTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;

  const _MetricCardTablet({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.metricPaddingHorizontal,
        vertical: _TabletSizes.metricPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.metricBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
                size: _TabletSizes.metricIconSize,
              ),
              SizedBox(width: _TabletSizes.metricIconSpacing),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.metricLabelFontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: _TabletSizes.metricSpacingSmall),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _TabletSizes.metricValueFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: _TabletSizes.metricSpacingMedium),
          Text(
            sub,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.metricSubFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top University Card (Tablet) ────────────────────────────────────────────

class _TopUniversityCardTablet extends StatelessWidget {
  final UserStatsModel stats;
  const _TopUniversityCardTablet({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_TabletSizes.topUniPadding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.topUniBorderRadius),
      ),
      child: Row(
        children: [
          if (stats.topUniversityLogo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(
                _TabletSizes.topUniLogoBorderRadius,
              ),
              child: CachedNetworkImage(
                imageUrl: stats.topUniversityLogo!,
                width: _TabletSizes.topUniLogoSize,
                height: _TabletSizes.topUniLogoSize,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _LogoFallbackTablet(),
              ),
            )
          else
            _LogoFallbackTablet(),
          SizedBox(width: _TabletSizes.topUniLogoSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.topUniversityName!,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.topUniNameFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: _TabletSizes.topUniSubSpacing),
                Text(
                  '${stats.topUniversityWatchCount ?? 0} video izlendi',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.topUniSubFontSize,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star_rounded,
            color: Colors.amber,
            size: _TabletSizes.topUniStarSize,
          ),
        ],
      ),
    );
  }
}

class _LogoFallbackTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _TabletSizes.topUniLogoSize,
      height: _TabletSizes.topUniLogoSize,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(
          _TabletSizes.topUniLogoBorderRadius,
        ),
      ),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(context),
        size: _TabletSizes.logoFallbackSize,
      ),
    );
  }
}

// ─── Video Card (Tablet) ──────────────────────────────────────────────────────

class _VideoCardTablet extends StatelessWidget {
  final String title;
  final String? thumbnail;
  final DateTime? date;
  final IconData icon;
  final Color? iconColor;

  const _VideoCardTablet({
    required this.title,
    this.thumbnail,
    this.date,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(_TabletSizes.videoPadding),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.videoBorderRadius),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              _TabletSizes.videoThumbnailBorderRadius,
            ),
            child: thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: thumbnail!,
                    width: _TabletSizes.videoThumbnailWidth,
                    height: _TabletSizes.videoThumbnailHeight,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => _ThumbFallbackTablet(),
                  )
                : _ThumbFallbackTablet(),
          ),
          SizedBox(width: _TabletSizes.videoSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.videoTitleFontSize,
                    fontWeight: FontWeight.w600,
                    height: _TabletSizes.videoTitleLineHeight,
                  ),
                ),
                if (date != null) ...[
                  SizedBox(height: _TabletSizes.videoSpacingDate),
                  Text(
                    _formatRelative(date!),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.videoDateFontSize,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: _TabletSizes.videoSpacingSmall),
          Icon(
            icon,
            color: iconColor ?? AppTheme.primaryColor,
            size: _TabletSizes.videoIconSize,
          ),
        ],
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    const months = [
      '', 'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _ThumbFallbackTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: _TabletSizes.videoThumbnailWidth,
      height: _TabletSizes.videoThumbnailHeight,
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(
          _TabletSizes.videoThumbnailBorderRadius,
        ),
      ),
      child: Icon(
        Icons.play_circle_outline_rounded,
        color: AppTheme.textSec(context),
        size: _TabletSizes.thumbFallbackIconSize,
      ),
    );
  }
}

// ─── Section Title (Tablet) ──────────────────────────────────────────────────

class _SectionTitleTablet extends StatelessWidget {
  final String title;
  const _SectionTitleTablet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: _TabletSizes.sectionTitleFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: _TabletSizes.sectionTitleLetterSpacing,
      ),
    );
  }
}