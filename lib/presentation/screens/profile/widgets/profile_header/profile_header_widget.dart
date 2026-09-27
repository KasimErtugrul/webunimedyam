// lib/presentation/screens/profile/widgets/profile_header/profile_header_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';
import '../../../../controllers/profile_controller.dart';
import 'avatar_source_sheet.dart';
import 'avatar_widget.dart';
import 'stat_chip_widget.dart';
import 'stat_divider_widget.dart';

const double _kBannerHeight = 96;
const double _kAvatarSize = 88;

class _Sizes {
  final bool isTablet;
  final double bannerRadius;
  final double avatarTopSpacing;
  final double usernameFontSize;
  final double usernameSpacing;
  final double atUsernameFontSize;
  final double memberSinceFontSize;
  final double memberSinceSpacing;
  final double editButtonSpacing;
  final double statsRowSpacing;
  final double statsRowBottomSpacing;
  final double statsRowRadius;
  final double statsRowPaddingV;
  final double statsRowMarginH;
  final double statsRowHeight;
  final double editButtonIconSize;
  final double editButtonFontSize;
  final double editButtonPaddingH;
  final double editButtonPaddingV;
  final double editButtonRadius;
  final double editButtonBorderWidth;
  final double statsLoadingSize;
  final double statsLoadingStrokeWidth;
  final double blob1Size;
  final double blob1Opacity;
  final double blob1Right;
  final double blob1Top;
  final double blob2Size;
  final double blob2Opacity;
  final double blob2Left;
  final double blob2Bottom;
  final double blob3Size;
  final double blob3Opacity;
  final double blob3Left;
  final double blob3Top;

  const _Sizes._({
    required this.isTablet,
    required this.bannerRadius,
    required this.avatarTopSpacing,
    required this.usernameFontSize,
    required this.usernameSpacing,
    required this.atUsernameFontSize,
    required this.memberSinceFontSize,
    required this.memberSinceSpacing,
    required this.editButtonSpacing,
    required this.statsRowSpacing,
    required this.statsRowBottomSpacing,
    required this.statsRowRadius,
    required this.statsRowPaddingV,
    required this.statsRowMarginH,
    required this.statsRowHeight,
    required this.editButtonIconSize,
    required this.editButtonFontSize,
    required this.editButtonPaddingH,
    required this.editButtonPaddingV,
    required this.editButtonRadius,
    required this.editButtonBorderWidth,
    required this.statsLoadingSize,
    required this.statsLoadingStrokeWidth,
    required this.blob1Size,
    required this.blob1Opacity,
    required this.blob1Right,
    required this.blob1Top,
    required this.blob2Size,
    required this.blob2Opacity,
    required this.blob2Left,
    required this.blob2Bottom,
    required this.blob3Size,
    required this.blob3Opacity,
    required this.blob3Left,
    required this.blob3Top,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        bannerRadius: 30,
        avatarTopSpacing: 16,
        usernameFontSize: 24,
        usernameSpacing: 4,
        atUsernameFontSize: 15,
        memberSinceFontSize: 13,
        memberSinceSpacing: 6,
        editButtonSpacing: 18,
        statsRowSpacing: 20,
        statsRowBottomSpacing: 14,
        statsRowRadius: 20,
        statsRowPaddingV: 16,
        statsRowMarginH: 24,
        statsRowHeight: 64,
        editButtonIconSize: 18,
        editButtonFontSize: 15,
        editButtonPaddingH: 20,
        editButtonPaddingV: 10,
        editButtonRadius: 24,
        editButtonBorderWidth: 1.4,
        statsLoadingSize: 22,
        statsLoadingStrokeWidth: 2.5,
        blob1Size: 150,
        blob1Opacity: 0.16,
        blob1Right: -30,
        blob1Top: -36,
        blob2Size: 110,
        blob2Opacity: 0.14,
        blob2Left: -24,
        blob2Bottom: -40,
        blob3Size: 54,
        blob3Opacity: 0.10,
        blob3Left: 70,
        blob3Top: -22,
      );
    }
    return const _Sizes._(
      isTablet: false,
      bannerRadius: 26,
      avatarTopSpacing: 12,
      usernameFontSize: 19,
      usernameSpacing: 3,
      atUsernameFontSize: 12.5,
      memberSinceFontSize: 11.5,
      memberSinceSpacing: 4,
      editButtonSpacing: 14,
      statsRowSpacing: 16,
      statsRowBottomSpacing: 10,
      statsRowRadius: 16,
      statsRowPaddingV: 12,
      statsRowMarginH: 20,
      statsRowHeight: 56,
      editButtonIconSize: 15,
      editButtonFontSize: 12.5,
      editButtonPaddingH: 16,
      editButtonPaddingV: 8,
      editButtonRadius: 20,
      editButtonBorderWidth: 1.2,
      statsLoadingSize: 18,
      statsLoadingStrokeWidth: 2,
      blob1Size: 130,
      blob1Opacity: 0.16,
      blob1Right: -26,
      blob1Top: -30,
      blob2Size: 96,
      blob2Opacity: 0.14,
      blob2Left: -20,
      blob2Bottom: -34,
      blob3Size: 46,
      blob3Opacity: 0.10,
      blob3Left: 60,
      blob3Top: -18,
    );
  }
}

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;

  const ProfileHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final spec = _Sizes.of(context);
    double w(double v) => spec.isTablet ? v : v;
    double h(double v) => spec.isTablet ? v : v;

    return Obx(() {
      final profile = controller.profile.value;
      final stats = controller.stats.value;
      final isOwn = controller.isOwnProfile;

      return Container(
        color: AppTheme.bg(context),
        child: Column(
          children: [
            SizedBox(
              height: h(_kBannerHeight) + w(_kAvatarSize) / 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _CoverBanner(spec: spec),
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
                        size: w(_kAvatarSize),
                        onTap: () =>
                            showAvatarSourceSheet(context, controller),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .scaleXY(
                            begin: 0.7,
                            end: 1,
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: h(spec.avatarTopSpacing)),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: w(spec.statsRowMarginH)),
              child: Text(
                (profile?.fullName?.isNotEmpty ?? false)
                    ? profile!.fullName!
                    : (profile?.username ?? 'Kullanıcı'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: spec.usernameFontSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 350.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            ),

            if ((profile?.fullName?.isNotEmpty ?? false) &&
                (profile?.username?.isNotEmpty ?? false)) ...[
              SizedBox(height: h(spec.usernameSpacing)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: w(spec.statsRowMarginH)),
                child: Text(
                  '@${profile!.username}',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: spec.atUsernameFontSize,
                  ),
                ).animate().fadeIn(delay: 280.ms, duration: 300.ms),
              ),
            ],

            if (profile != null) ...[
              SizedBox(height: h(spec.memberSinceSpacing)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: w(spec.statsRowMarginH)),
                child: Text(
                  _memberSinceLabel(profile.createdAt),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.7),
                    fontSize: spec.memberSinceFontSize,
                  ),
                ).animate().fadeIn(delay: 340.ms, duration: 300.ms),
              ),
            ],

            if (isOwn) ...[
              SizedBox(height: h(spec.editButtonSpacing)),
              _EditProfileButton(spec: spec)
                  .animate()
                  .fadeIn(delay: 420.ms, duration: 300.ms),
            ],

            if (isOwn) ...[
              SizedBox(height: h(spec.statsRowSpacing)),
              _StatsRow(
                stats: stats,
                isLoading: controller.isLoadingStats.value,
                spec: spec,
              ).animate().fadeIn(delay: 500.ms, duration: 350.ms),
            ],

            SizedBox(height: h(spec.statsRowBottomSpacing)),
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

// ─── Cover banner ────────────────────────────────────────────────────────

class _CoverBanner extends StatelessWidget {
  final _Sizes spec;
  const _CoverBanner({required this.spec});

  double w(double v) => spec.isTablet ? v : v;
  double h(double v) => spec.isTablet ? v : v;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(w(spec.bannerRadius)),
      ),
      child: SizedBox(
        height: h(_kBannerHeight),
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
                right: w(spec.blob1Right),
                top: h(spec.blob1Top),
                child: _Blob(
                  size: w(spec.blob1Size),
                  opacity: spec.blob1Opacity,
                ),
              ),
              Positioned(
                left: w(spec.blob2Left),
                bottom: h(spec.blob2Bottom),
                child: _Blob(
                  size: w(spec.blob2Size),
                  opacity: spec.blob2Opacity,
                ),
              ),
              Positioned(
                left: w(spec.blob3Left),
                top: h(spec.blob3Top),
                child: _Blob(
                  size: w(spec.blob3Size),
                  opacity: spec.blob3Opacity,
                ),
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

// ─── Edit profile button ─────────────────────────────────────────────────

class _EditProfileButton extends StatelessWidget {
  final _Sizes spec;
  const _EditProfileButton({required this.spec});

  @override
  Widget build(BuildContext context) {
    double w(double v) => spec.isTablet ? v : v;
    double h(double v) => spec.isTablet ? v : v;

    return OutlinedButton.icon(
      onPressed: () => Get.toNamed(AppRoutes.editProfile),
      icon: Icon(
        Icons.edit_outlined,
        size: spec.editButtonIconSize,
      ),
      label: Text(
        'Profili Düzenle',
        style: TextStyle(fontSize: spec.editButtonFontSize),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.textPri(context),
        side: BorderSide(
          color: AppTheme.textSec(context).withValues(alpha: 0.2),
          width: w(spec.editButtonBorderWidth),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: w(spec.editButtonPaddingH),
          vertical: h(spec.editButtonPaddingV),
        ),
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(w(spec.editButtonRadius)),
        ),
      ),
    );
  }
}

// ─── Stats row ───────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final dynamic stats;
  final bool isLoading;
  final _Sizes spec;

  const _StatsRow({
    required this.stats,
    required this.isLoading,
    required this.spec,
  });

  double w(double v) => spec.isTablet ? v : v;
  double h(double v) => spec.isTablet ? v : v;

  @override
  Widget build(BuildContext context) {
    final marginH = w(spec.statsRowMarginH);

    if (stats == null && isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: marginH),
        height: h(spec.statsRowHeight),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(w(spec.statsRowRadius)),
        ),
        child: Center(
          child: SizedBox(
            width: w(spec.statsLoadingSize),
            height: w(spec.statsLoadingSize),
            child: CircularProgressIndicator(
              strokeWidth: spec.statsLoadingStrokeWidth,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: marginH),
      padding: EdgeInsets.symmetric(vertical: h(spec.statsRowPaddingV)),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(w(spec.statsRowRadius)),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.06),
        ),
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