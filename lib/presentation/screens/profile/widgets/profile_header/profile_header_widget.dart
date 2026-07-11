// lib/presentation/screens/profile/widgets/profile_header/profile_header_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/profile_controller.dart';
import 'avatar_source_sheet.dart';
import 'avatar_widget.dart';
import 'stat_chip_widget.dart';
import 'stat_divider_widget.dart';

// Banner + üste taşan avatarın boyut sabitleri. profile_view_widget.dart
// artık bu widget'ı sabit yükseklikli bir SliverAppBar yerine normal bir
// sliver (SliverToBoxAdapter) olarak kullanıyor, bu yüzden toplam yükseklik
// içeriğe göre serbestçe büyüyebiliyor — burada sadece banner/avatar oranını
// tutarlı tutmak için sabitler tanımlı.
const double kProfileBannerHeight = 96;
const double kProfileAvatarSize = 88;

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;
      final stats = controller.stats.value;
      final isOwn = controller.isOwnProfile;

      return Container(
        color: AppTheme.bg(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ── Kapak (banner) + üste taşan avatar ───────────────────────
            SizedBox(
              height: kProfileBannerHeight.h + kProfileAvatarSize.w / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _CoverBanner(height: kProfileBannerHeight.h),
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

            SizedBox(height: 12.h),

            // ── Kullanıcı adı ────────────────────────────────────────────
            Text(
              (profile?.fullName?.isNotEmpty ?? false)
                  ? profile!.fullName!
                  : (profile?.username ?? 'Kullanıcı'),
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 19.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            // ── @kullanıcı adı (tam isim gösterildiyse ikinci satır) ───────
            if ((profile?.fullName?.isNotEmpty ?? false) &&
                (profile?.username?.isNotEmpty ?? false)) ...[
              SizedBox(height: 3.h),
              Text(
                '@${profile!.username}',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
            ],

            if (profile != null) ...[
              SizedBox(height: 4.h),
              Text(
                _memberSinceLabel(profile.createdAt),
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.75),
                  fontSize: 11.5.sp,
                ),
              ),
            ],

            // ── Profili Düzenle butonu ──────────────────────────────────
            if (isOwn) ...[
              SizedBox(height: 14.h),
              const _EditProfileButton(),
            ],

            // ── Özet istatistik şeridi ──────────────────────────────────
            if (isOwn) ...[
              SizedBox(height: 16.h),
              _StatsRow(stats: stats, isLoading: controller.isLoadingStats.value),
            ],

            SizedBox(height: 10.h),
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

// ─── Kapak (Banner) ──────────────────────────────────────────────────────

class _CoverBanner extends StatelessWidget {
  final double height;
  const _CoverBanner({required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(26.r)),
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
                child: _Blob(size: 130.w, opacity: 0.16),
              ),
              Positioned(
                left: -20.w,
                bottom: -34.h,
                child: _Blob(size: 96.w, opacity: 0.14),
              ),
              Positioned(
                left: 60.w,
                top: -18.h,
                child: _Blob(size: 46.w, opacity: 0.10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final double opacity;
  const _Blob({required this.size, required this.opacity});

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

// ─── Profili Düzenle Butonu ─────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.editProfile),
      icon: Icon(Icons.edit_outlined, size: 15.sp),
      label: Text('Profili Düzenle', style: TextStyle(fontSize: 12.5.sp)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPri(context),
        side: BorderSide(color: AppTheme.surface(context), width: 1.2.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}

// ─── Özet İstatistik Şeridi ─────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final dynamic stats; // UserStatsModel?
  final bool isLoading;
  const _StatsRow({required this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // Henüz hiç veri gelmediyse (ilk yükleme) hafif bir placeholder göster,
    // ama var olan veriyi (varsa) sıfırlamadan tutmaya devam et — böylece
    // pull-to-refresh sırasında sayılar aniden 0'a düşüp geri gelmiyor.
    if (stats == null && isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        height: 56.h,
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: SizedBox(
            width: 18.w,
            height: 18.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16.r),
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
