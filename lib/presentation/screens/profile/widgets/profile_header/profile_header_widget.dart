// lib/presentation/screens/profile/widgets/profile_header/profile_header_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/profile_controller.dart';
import 'avatar_source_sheet.dart';
import 'avatar_widget.dart';
import 'stat_chip_widget.dart';
import 'stat_divider_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

const double kProfileBannerHeight = 96;
const double kProfileAvatarSize = 88;

class _PhoneSizes {
  static const double bannerBorderRadius = 26;
  static const double avatarTopSpacing = 12;
  static const double usernameFontSize = 19;
  static const double usernameSpacing = 3;
  static const double atUsernameFontSize = 13;
  static const double memberSinceFontSize = 11.5;
  static const double memberSinceSpacing = 4;
  static const double editButtonSpacing = 14;
  static const double statsRowSpacing = 16;
  static const double statsRowBottomSpacing = 10;
  static const double statsRowBorderRadius = 16;
  static const double statsRowPaddingVertical = 12;
  static const double editButtonIconSize = 15;
  static const double editButtonFontSize = 12.5;
  static const double editButtonPaddingHorizontal = 16;
  static const double editButtonPaddingVertical = 8;
  static const double editButtonBorderRadius = 20;
  static const double editButtonBorderWidth = 1.2;
  static const double statsLoadingSize = 18;
  static const double statsLoadingStrokeWidth = 2;
  
  // Stats chip
/*   static const double statChipCountFontSize = 17;
  static const double statChipLabelFontSize = 11;
  static const double statChipSpacing = 2;
  
  // Divider
  static const double dividerWidth = 1;
  static const double dividerHeight = 28; */
  
  // Blob
  static const double blobOpacity1 = 0.16;
  static const double blobOpacity2 = 0.14;
  static const double blobOpacity3 = 0.10;
}

class _TabletSizes {
  static const double bannerBorderRadius = 30;
  static const double avatarTopSpacing = 16;
  static const double usernameFontSize = 24;
  static const double usernameSpacing = 4;
  static const double atUsernameFontSize = 16;
  static const double memberSinceFontSize = 14;
  static const double memberSinceSpacing = 6;
  static const double editButtonSpacing = 18;
  static const double statsRowSpacing = 20;
  static const double statsRowBottomSpacing = 14;
  static const double statsRowBorderRadius = 20;
  static const double statsRowPaddingVertical = 16;
  static const double editButtonIconSize = 18;
  static const double editButtonFontSize = 15;
  static const double editButtonPaddingHorizontal = 20;
  static const double editButtonPaddingVertical = 10;
  static const double editButtonBorderRadius = 24;
  static const double editButtonBorderWidth = 1.5;
  static const double statsLoadingSize = 22;
  static const double statsLoadingStrokeWidth = 2.5;
  
  // Stats chip - tablet için daha büyük
 /*  static const double statChipCountFontSize = 21;
  static const double statChipLabelFontSize = 14;
  static const double statChipSpacing = 3;
  
  // Divider - tablet için daha büyük
  static const double dividerWidth = 1.5;
  static const double dividerHeight = 34; */
  
  // Blob - tablet için daha büyük
  static const double blobOpacity1 = 0.16;
  static const double blobOpacity2 = 0.14;
  static const double blobOpacity3 = 0.10;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeaderWidget({super.key, required this.controller});

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
    return Obx(() {
      final profile = controller.profile.value;
      final stats = controller.stats.value;
      final isOwn = controller.isOwnProfile;

      return Container(
        color: AppTheme.bg(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: kProfileBannerHeight.h + kProfileAvatarSize.w / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _CoverBannerPhone(height: kProfileBannerHeight.h),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ProfileAvatarWidget(
                        avatarUrl: profile?.avatarUrl,
                        username: profile?.username ?? 'U',
                        isOwnProfile: isOwn,
                        isUploading: controller.isUploadingAvatar.value,
                        size: kProfileAvatarSize.w,
                        onTap: () => showAvatarSourceSheet(context, controller),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _PhoneSizes.avatarTopSpacing.h),
            Text(
              (profile?.fullName?.isNotEmpty ?? false)
                  ? profile!.fullName!
                  : (profile?.username ?? 'Kullanıcı'),
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.usernameFontSize.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if ((profile?.fullName?.isNotEmpty ?? false) &&
                (profile?.username?.isNotEmpty ?? false)) ...[
              SizedBox(height: _PhoneSizes.usernameSpacing.h),
              Text(
                '@${profile!.username}',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.atUsernameFontSize.sp,
                ),
              ),
            ],
            if (profile != null) ...[
              SizedBox(height: _PhoneSizes.memberSinceSpacing.h),
              Text(
                _memberSinceLabel(profile.createdAt),
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.75),
                  fontSize: _PhoneSizes.memberSinceFontSize.sp,
                ),
              ),
            ],
            if (isOwn) ...[
              SizedBox(height: _PhoneSizes.editButtonSpacing.h),
              const _EditProfileButtonPhone(),
            ],
            if (isOwn) ...[
              SizedBox(height: _PhoneSizes.statsRowSpacing.h),
              _StatsRowPhone(
                stats: stats,
                isLoading: controller.isLoadingStats.value,
              ),
            ],
            SizedBox(height: _PhoneSizes.statsRowBottomSpacing.h),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;
      final stats = controller.stats.value;
      final isOwn = controller.isOwnProfile;

      return Container(
        color: AppTheme.bg(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: kProfileBannerHeight + kProfileAvatarSize / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _CoverBannerTablet(height: kProfileBannerHeight),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ProfileAvatarWidget(
                        avatarUrl: profile?.avatarUrl,
                        username: profile?.username ?? 'U',
                        isOwnProfile: isOwn,
                        isUploading: controller.isUploadingAvatar.value,
                        size: kProfileAvatarSize,
                        onTap: () => showAvatarSourceSheet(context, controller),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: _TabletSizes.avatarTopSpacing),
            Text(
              (profile?.fullName?.isNotEmpty ?? false)
                  ? profile!.fullName!
                  : (profile?.username ?? 'Kullanıcı'),
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.usernameFontSize,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if ((profile?.fullName?.isNotEmpty ?? false) &&
                (profile?.username?.isNotEmpty ?? false)) ...[
              SizedBox(height: _TabletSizes.usernameSpacing),
              Text(
                '@${profile!.username}',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.atUsernameFontSize,
                ),
              ),
            ],
            if (profile != null) ...[
              SizedBox(height: _TabletSizes.memberSinceSpacing),
              Text(
                _memberSinceLabel(profile.createdAt),
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.75),
                  fontSize: _TabletSizes.memberSinceFontSize,
                ),
              ),
            ],
            if (isOwn) ...[
              SizedBox(height: _TabletSizes.editButtonSpacing),
              const _EditProfileButtonTablet(),
            ],
            if (isOwn) ...[
              SizedBox(height: _TabletSizes.statsRowSpacing),
              _StatsRowTablet(
                stats: stats,
                isLoading: controller.isLoadingStats.value,
              ),
            ],
            SizedBox(height: _TabletSizes.statsRowBottomSpacing),
          ],
        ),
      );
    });
  }

  String _memberSinceLabel(DateTime date) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    final monthName = months[(date.month - 1).clamp(0, 11)];
    return '$monthName ${date.year}\'den beri üye';
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

// ─── Kapak (Banner) Phone ─────────────────────────────────────────────────

class _CoverBannerPhone extends StatelessWidget {
  final double height;
  const _CoverBannerPhone({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(_PhoneSizes.bannerBorderRadius.r),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFF0F5C2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -26.w,
                top: -30.h,
                child: _BlobPhone(size: 130.w, opacity: _PhoneSizes.blobOpacity1),
              ),
              Positioned(
                left: -20.w,
                bottom: -34.h,
                child: _BlobPhone(size: 96.w, opacity: _PhoneSizes.blobOpacity2),
              ),
              Positioned(
                left: 60.w,
                top: -18.h,
                child: _BlobPhone(size: 46.w, opacity: _PhoneSizes.blobOpacity3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlobPhone extends StatelessWidget {
  final double size;
  final double opacity;
  const _BlobPhone({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// ─── Profili Düzenle Butonu Phone ───────────────────────────────────────

class _EditProfileButtonPhone extends StatelessWidget {
  const _EditProfileButtonPhone();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.editProfile),
      icon: Icon(
        Icons.edit_outlined,
        size: _PhoneSizes.editButtonIconSize.sp,
      ),
      label: Text(
        'Profili Düzenle',
        style: TextStyle(fontSize: _PhoneSizes.editButtonFontSize.sp),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPri(context),
        side: BorderSide(
          color: AppTheme.surface(context),
          width: _PhoneSizes.editButtonBorderWidth.w,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.editButtonPaddingHorizontal.w,
          vertical: _PhoneSizes.editButtonPaddingVertical.h,
        ),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_PhoneSizes.editButtonBorderRadius.r),
        ),
      ),
    );
  }
}

// ─── Özet İstatistik Şeridi Phone ───────────────────────────────────────

class _StatsRowPhone extends StatelessWidget {
  final dynamic stats;
  final bool isLoading;
  const _StatsRowPhone({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (stats == null && isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 56.h,
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.statsRowBorderRadius.r),
        ),
        child: Center(
          child: SizedBox(
            width: _PhoneSizes.statsLoadingSize.w,
            height: _PhoneSizes.statsLoadingSize.w,
            child: CircularProgressIndicator(
              strokeWidth: _PhoneSizes.statsLoadingStrokeWidth.w,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(
        vertical: _PhoneSizes.statsRowPaddingVertical.h,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.statsRowBorderRadius.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: StatChipWidget(
              icon: Icons.play_circle_rounded,
              count: stats?.totalWatched ?? 0,
              label: 'İzlenen',
            ),
          ),
          const StatDividerWidget(),
          Expanded(
            child: StatChipWidget(
              icon: Icons.thumb_up_alt_rounded,
              count: stats?.totalLiked ?? 0,
              label: 'Beğenilen',
            ),
          ),
          const StatDividerWidget(),
          Expanded(
            child: StatChipWidget(
              icon: Icons.favorite_rounded,
              count: stats?.totalFavorited ?? 0,
              label: 'Favori',
            ),
          ),
          const StatDividerWidget(),
          Expanded(
            child: StatChipWidget(
              icon: Icons.chat_bubble_rounded,
              count: stats?.totalCommented ?? 0,
              label: 'Yorum',
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

// ─── Kapak (Banner) Tablet ─────────────────────────────────────────────────

class _CoverBannerTablet extends StatelessWidget {
  final double height;
  const _CoverBannerTablet({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(_TabletSizes.bannerBorderRadius),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, Color(0xFF0F5C2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -30,
                top: -36,
                child: _BlobTablet(size: 150, opacity: _TabletSizes.blobOpacity1),
              ),
              Positioned(
                left: -24,
                bottom: -40,
                child: _BlobTablet(size: 110, opacity: _TabletSizes.blobOpacity2),
              ),
              Positioned(
                left: 70,
                top: -22,
                child: _BlobTablet(size: 54, opacity: _TabletSizes.blobOpacity3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlobTablet extends StatelessWidget {
  final double size;
  final double opacity;
  const _BlobTablet({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

// ─── Profili Düzenle Butonu Tablet ───────────────────────────────────────

class _EditProfileButtonTablet extends StatelessWidget {
  const _EditProfileButtonTablet();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.editProfile),
      icon: Icon(
        Icons.edit_outlined,
        size: _TabletSizes.editButtonIconSize,
      ),
      label: Text(
        'Profili Düzenle',
        style: TextStyle(fontSize: _TabletSizes.editButtonFontSize),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPri(context),
        side: BorderSide(
          color: AppTheme.surface(context),
          width: _TabletSizes.editButtonBorderWidth,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.editButtonPaddingHorizontal,
          vertical: _TabletSizes.editButtonPaddingVertical,
        ),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_TabletSizes.editButtonBorderRadius),
        ),
      ),
    );
  }
}

// ─── Özet İstatistik Şeridi Tablet ───────────────────────────────────────

class _StatsRowTablet extends StatelessWidget {
  final dynamic stats;
  final bool isLoading;
  const _StatsRowTablet({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (stats == null && isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.statsRowBorderRadius),
        ),
        child: Center(
          child: SizedBox(
            width: _TabletSizes.statsLoadingSize,
            height: _TabletSizes.statsLoadingSize,
            child: CircularProgressIndicator(
              strokeWidth: _TabletSizes.statsLoadingStrokeWidth,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.symmetric(
        vertical: _TabletSizes.statsRowPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.statsRowBorderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: StatChipWidget(
              icon: Icons.play_circle_rounded,
              count: stats?.totalWatched ?? 0,
              label: 'İzlenen',
            ),
          ),
          const StatDividerWidget(),
          Expanded(
            child: StatChipWidget(
              icon: Icons.thumb_up_alt_rounded,
              count: stats?.totalLiked ?? 0,
              label: 'Beğenilen',
            ),
          ),
          const StatDividerWidget(),
          Expanded(
            child: StatChipWidget(
              icon: Icons.favorite_rounded,
              count: stats?.totalFavorited ?? 0,
              label: 'Favori',
            ),
          ),
          const StatDividerWidget(),
          Expanded(
            child: StatChipWidget(
              icon: Icons.chat_bubble_rounded,
              count: stats?.totalCommented ?? 0,
              label: 'Yorum',
            ),
          ),
        ],
      ),
    );
  }
}