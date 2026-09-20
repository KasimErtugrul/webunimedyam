// lib/presentation/screens/profile/widgets/profile_view_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../controllers/profile_activity_list_controller.dart';
import '../../../controllers/profile_controller.dart';
import 'profile_header/avatar_source_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────

class _Sz {
  final bool isTablet;
  final double paddingH;
  final double avatarSize;

  const _Sz._({
    required this.isTablet,
    required this.paddingH,
    required this.avatarSize,
  });

  factory _Sz.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sz._(isTablet: true, paddingH: 24, avatarSize: 88);
    }
    return const _Sz._(isTablet: false, paddingH: 16, avatarSize: 80);
  }
}

class ProfileViewWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileViewWidget({super.key, required this.controller});

  String get _userId {
    if (controller.isOwnProfile) {
      return Get.find<AuthRepository>().currentUserId ?? '';
    }
    return controller.targetUserId ?? '';
  }

  void _nav(ProfileActivityType t) => Get.toNamed(
        AppRoutes.profileActivityList,
        arguments: {
          'type': t,
          'userId': _userId,
          'isOwnProfile': controller.isOwnProfile,
        },
      );



  @override
  Widget build(BuildContext context) {
    final sz = _Sz.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs),
      body: RefreshIndicator(
        color: cs.primary,
        backgroundColor: cs.surfaceContainerHigh,
        onRefresh: controller.refreshProfile,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AuraProfileCard(controller: controller, sz: sz),
              SizedBox(height: 0.h),
              _MetricsStrip(controller: controller, sz: sz, onNav: _nav),
              SizedBox(height: 16.h),
              _WeeklyPulse(sz: sz),
              SizedBox(height: 16.h),
              _ActivitySection(
                controller: controller,
                sz: sz,
                onNav: _nav,
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs) {
    return AppBar(
      backgroundColor: cs.surface.withValues(alpha: 0.90),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 52.w,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Icons.play_circle_rounded, color: cs.primary, size: 24.sp),
        ),
      ),
      titleSpacing: 8.w,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Üni',
                  style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600)),
              Text('TV',
                  style: TextStyle(
                      color: cs.primary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Text(
            'KAMPÜS YAYINI',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.sensors_rounded,
              color: cs.onSurfaceVariant, size: 22.sp),
          tooltip: 'Canlı Yayınlar',
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: cs.onSurfaceVariant, size: 22.sp),
          tooltip: 'Bildirimler',
          onPressed: () {},
        ),
        Container(
          width: 32.w,
          height: 32.w,
          margin: EdgeInsets.only(right: 16.w, left: 4.w),
          decoration:
              BoxDecoration(color: cs.primary, shape: BoxShape.circle),
          child: Icon(Icons.person_rounded,
              color: cs.onPrimary, size: 18.sp),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AURA + PROFILE CARD
// ═══════════════════════════════════════════════════════════════════════════

class _AuraProfileCard extends StatelessWidget {
  final ProfileController controller;
  final _Sz sz;
  const _AuraProfileCard({required this.controller, required this.sz});

  void _navEdit() => Get.toNamed(AppRoutes.editProfile);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final profile = controller.profile.value;
      final isOwn = controller.isOwnProfile;
      final name = (profile?.fullName?.isNotEmpty ?? false)
          ? profile!.fullName!
          : (profile?.username ?? 'Kullanıcı');
      final handle = profile?.username ?? 'kullanici';
      final since = _memberSince(profile?.createdAt);
      final avatarUrl = profile?.avatarUrl;

      return ClipRect(
        child: Stack(
          children: [
            // ── Aura blob 1 (merkez üst) ──
            Positioned(
              top: -60.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 320.w,
                  height: 220.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            // ── Aura blob 2 (sağ üst) ──
            Positioned(
              top: 20.h,
              right: -20.w,
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.secondaryContainer.withValues(alpha: 0.08),
                ),
              ),
            ),

            // ── İçerik ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                  sz.paddingH.w, 8.h, sz.paddingH.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Sub-bar ──
                  Padding(
                    padding:
                        EdgeInsets.only(top: 4.h, bottom: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kulüp rozeti
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh
                                .withValues(alpha: 0.80),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                                  .animate(
                                      onPlay: (c) =>
                                          c.repeat(reverse: true))
                                  .scaleXY(
                                    begin: 0.6,
                                    end: 1.5,
                                    duration: 1000.ms,
                                    curve: Curves.easeInOut,
                                  ),
                              SizedBox(width: 6.w),
                              Text(
                                'İTÜ Bilişim Kulübü',
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Hızlı aksiyonlar
                        if (isOwn)
                          Row(
                            children: [
                              _QuickBtn(
                                icon: Icons.insights_rounded,
                                tooltip: 'İstatistiklerim',
                                onTap: () => Get.toNamed(AppRoutes.stats),
                              ),
                              SizedBox(width: 8.w),
                              _QuickBtn(
                                icon: Icons.settings_outlined,
                                tooltip: 'Ayarlar',
                                onTap: () =>
                                    Get.toNamed(AppRoutes.settings),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // ── Profil kartı ──
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.60),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLg * 1.3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar + isim satırı
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AvatarBlock(
                              avatarUrl: avatarUrl,
                              handle: handle,
                              isOwn: isOwn,
                              avatarSize: sz.avatarSize.w,
                              controller: controller,
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 2.h),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // İsim + verified
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              color: cs.onSurface,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.3,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 4.w),
                                        Icon(Icons.verified_rounded,
                                            color: cs.primary,
                                            size: 18.sp),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    // Handle
                                    Text(
                                      '@$handle',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    // Üyelik tarihi
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today_rounded,
                                            color: cs.primary, size: 13.sp),
                                        SizedBox(width: 4.w),
                                        Expanded(
                                          child: Text(
                                            since,
                                            style: TextStyle(
                                              color: cs.onSurfaceVariant,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.04,
                                            ),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Edit / Share row (yalnızca kendi profil)
                        if (isOwn) ...[
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              // Profili Düzenle (4/5 genişlik)
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 44.h,
                                  child: Material(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: InkWell(
                                      onTap: _navEdit,
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.edit_note_rounded,
                                              color: cs.onSurface,
                                              size: 18.sp),
                                          SizedBox(width: 6.w),
                                          Text(
                                            'Profili Düzenle',
                                            style: TextStyle(
                                              color: cs.onSurface,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              // Paylaş (1/5 genişlik)
                              SizedBox(
                                width: 44.h,
                                height: 44.h,
                                child: Material(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Icon(Icons.ios_share_rounded,
                                        color: cs.onSurfaceVariant,
                                        size: 20.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _memberSince(DateTime? d) {
    if (d == null) return 'Kampüs üyesi';
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
    ];
    return "${months[(d.month - 1).clamp(0, 11)]} ${d.year}'den beri üye";
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AVATAR BLOCK
// ═══════════════════════════════════════════════════════════════════════════

class _AvatarBlock extends StatelessWidget {
  final String? avatarUrl;
  final String handle;
  final bool isOwn;
  final double avatarSize;
  final ProfileController controller;

  const _AvatarBlock({
    required this.avatarUrl,
    required this.handle,
    required this.isOwn,
    required this.avatarSize,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    final badgeOff = 6.w;

    return GestureDetector(
      onTap: isOwn ? () => showAvatarSourceSheet(context, controller) : null,
      child: SizedBox(
        // Ek alan: badge taşması için
        width: avatarSize + badgeOff,
        height: avatarSize + badgeOff,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Avatar kutu ──
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: hasImage
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (ctx, url, _) =>
                              _InitialLetter(handle: handle, size: avatarSize),
                        )
                      : _InitialLetter(handle: handle, size: avatarSize),
                ),
              ),
            ),

            // ── Online ping — sağ üst köşe ──
            Positioned(
              top: -4.h,
              right: 0,
              child: SizedBox(
                width: 16.w,
                height: 16.w,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primary.withValues(alpha: 0.75),
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat())
                          .scaleXY(
                            begin: 0.5,
                            end: 1.6,
                            duration: 1200.ms,
                            curve: Curves.easeOut,
                          )
                          .fade(begin: 0.75, end: 0.0),
                    ),
                    Center(
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: Center(
                          child: Container(
                            width: 7.w,
                            height: 7.w,
                            decoration: BoxDecoration(
                              color: cs.onPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Kamera badge — sağ alt köşe ──
            if (isOwn)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => showAvatarSourceSheet(context, controller),
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.photo_camera_rounded,
                        color: cs.onSurface, size: 15.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InitialLetter extends StatelessWidget {
  final String handle;
  final double size;
  const _InitialLetter({required this.handle, required this.size});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHighest,
      child: Center(
        child: Text(
          handle.isNotEmpty ? handle[0].toUpperCase() : 'U',
          style: TextStyle(
            color: cs.primary,
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QUICK BUTTON
// ═══════════════════════════════════════════════════════════════════════════

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _QuickBtn(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Icon(icon, color: cs.onSurfaceVariant, size: 20.sp),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// METRICS STRIP
// ═══════════════════════════════════════════════════════════════════════════

class _MetricsStrip extends StatelessWidget {
  final ProfileController controller;
  final _Sz sz;
  final void Function(ProfileActivityType) onNav;

  const _MetricsStrip({
    required this.controller,
    required this.sz,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final stats = controller.stats.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sz.paddingH.w),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              _MetricCell(
                icon: Icons.smart_display_rounded,
                iconColor: cs.primary,
                count: stats?.totalWatched ?? 0,
                label: 'İzlenen',
                onTap: () => onNav(ProfileActivityType.viewed),
              ),
              SizedBox(width: 4.w),
              _MetricCell(
                icon: Icons.thumb_up_rounded,
                iconColor: cs.secondary,
                count: stats?.totalLiked ?? 0,
                label: 'Beğeni',
                onTap: () => onNav(ProfileActivityType.liked),
              ),
              SizedBox(width: 4.w),
              _MetricCell(
                icon: Icons.star_rounded,
                iconColor: cs.primaryFixed,
                count: stats?.totalFavorited ?? 0,
                label: 'Favori',
                onTap: () => onNav(ProfileActivityType.favorites),
              ),
              SizedBox(width: 4.w),
              _MetricCell(
                icon: Icons.forum_rounded,
                iconColor: cs.onSurfaceVariant,
                count: stats?.totalCommented ?? 0,
                label: 'Yorum',
                onTap: () => onNav(ProfileActivityType.commented),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MetricCell extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _MetricCell({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 16.sp),
                SizedBox(height: 2.h),
                Text(
                  '$count',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04,
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

// ═══════════════════════════════════════════════════════════════════════════
// WEEKLY PULSE WIDGET
// ═══════════════════════════════════════════════════════════════════════════

class _WeeklyPulse extends StatelessWidget {
  final _Sz sz;
  const _WeeklyPulse({required this.sz});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sz.paddingH.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surfaceContainerHigh, cs.surfaceContainer],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ateş ikonu
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.local_fire_department_rounded,
                  color: cs.primary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            // Metin
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '5 Günlük Yayın Serisi',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(
                              AppTheme.radiusFull.r),
                        ),
                        child: Text(
                          'Harika!',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Bu hafta 6 saat 40 dk kampüs yayını izledin',
                    style: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 12.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Sparkline (HTML SVG path ile aynı)
            CustomPaint(
              size: Size(64.w, 32.h),
              painter: _SparklinePainter(color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTIVITY SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _ActivitySection extends StatelessWidget {
  final ProfileController controller;
  final _Sz sz;
  final void Function(ProfileActivityType) onNav;

  const _ActivitySection({
    required this.controller,
    required this.sz,
    required this.onNav,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Obx(() {
      final stats = controller.stats.value;
      final favCount = stats?.totalFavorited ?? 0;
      final likedCount = stats?.totalLiked ?? 0;
      final watchedCount = stats?.totalWatched ?? 0;
      final commentCount = stats?.totalCommented ?? 0;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sz.paddingH.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'KÜTÜPHANEM & HAREKETLER',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onNav(ProfileActivityType.favorites),
                    child: Text(
                      'Tümünü Yönet',
                      style: TextStyle(
                          color: cs.primary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // 1. Favorilerim
            _NavTile(
              icon: Icons.star_rounded,
              iconColor: cs.primary,
              iconBg: cs.primary.withValues(alpha: 0.10),
              title: 'Favorilerim',
              subtitle: '$favCount kayıtlı video ve üniversite',
              trailing: _CountBadge(text: '$favCount', textColor: cs.primary),
              onTap: () => onNav(ProfileActivityType.favorites),
            ),
            SizedBox(height: 4.h),

            // 2. Beğendiklerim
            _NavTile(
              icon: Icons.thumb_up_rounded,
              iconColor: cs.secondary,
              iconBg: cs.secondary.withValues(alpha: 0.10),
              title: 'Beğendiklerim',
              subtitle: '$likedCount beğendiğin içerik',
              trailing:
                  _CountBadge(text: '$likedCount', textColor: cs.secondary),
              onTap: () => onNav(ProfileActivityType.liked),
            ),
            SizedBox(height: 4.h),

            // 3. İzleme Geçmişi
            _NavTile(
              icon: Icons.history_rounded,
              iconColor: cs.primaryFixed,
              iconBg: cs.surfaceContainerHighest,
              title: 'İzleme Geçmişi',
              subtitle: '$watchedCount video izlendi',
              trailing: Text(
                'Son: İTÜ Güneş Arabası',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontSize: 10.sp),
              ),
              onTap: () => onNav(ProfileActivityType.viewed),
            ),
            SizedBox(height: 4.h),

            // 4. Yorumlarım
            _NavTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: cs.onSurface,
              iconBg: cs.surfaceContainerHighest,
              title: 'Yorumlarım',
              subtitle: '$commentCount katkı ve yanıt',
              trailing:
                  _CountBadge(text: '$commentCount', textColor: cs.onSurface),
              onTap: () => onNav(ProfileActivityType.commented),
            ),
            SizedBox(height: 4.h),

            // 5. Detaylı İstatistiklerim
            _NavTile(
              icon: Icons.query_stats_rounded,
              iconColor: cs.primary,
              iconBg: cs.primaryContainer.withValues(alpha: 0.20),
              title: 'Detaylı İstatistiklerim',
              titleTag: 'YENİ',
              subtitle: 'Haftalık izleme süreleri ve keşif grafiği',
              trailing: null,
              onTap: () => Get.toNamed(AppRoutes.stats),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Nav Tile ─────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? titleTag;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.titleTag,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 64.h),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                // İkon kutu
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 24.sp),
                ),
                SizedBox(width: 14.w),
                // Metin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (titleTag != null) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5.w, vertical: 1.h),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer
                                    .withValues(alpha: 0.30),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                titleTag!,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                            color: cs.onSurfaceVariant, fontSize: 12.sp),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                ?trailing,
                SizedBox(width: 2.w),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                    size: 20.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Count Badge ──────────────────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final String text;
  final Color textColor;
  const _CountBadge({required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull.r),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: textColor, fontSize: 10.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SPARKLINE PAINTER — HTML SVG path M2 24L12 18L24 21L36 10L48 14L62 4
// ═══════════════════════════════════════════════════════════════════════════

class _SparklinePainter extends CustomPainter {
  final Color color;
  const _SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 64;
    final sy = size.height / 28;

    final pts = [
      Offset(2 * sx, 24 * sy),
      Offset(12 * sx, 18 * sy),
      Offset(24 * sx, 21 * sy),
      Offset(36 * sx, 10 * sy),
      Offset(48 * sx, 14 * sy),
      Offset(62 * sx, 4 * sy),
    ];

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Son nokta dolu daire
    canvas.drawCircle(pts.last, 2.5 * sx,
        linePaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.color != color;
}