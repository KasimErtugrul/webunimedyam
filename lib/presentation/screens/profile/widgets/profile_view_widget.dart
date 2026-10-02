// lib/presentation/screens/profile/widgets/profile_view_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../core/widgets/hover_tap.dart';
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
    // Üçlü ölçek: web (masaüstü tarayıcı) → tablet → telefon.
    if (Responsive.isWeb(context)) {
      return const _Sz._(isTablet: true, paddingH: 32, avatarSize: 96);
    }
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
              const SizedBox(height: 0),
              _MetricsStrip(controller: controller, sz: sz, onNav: _nav),
              const SizedBox(height: 16),
              _WeeklyPulse(sz: sz),
              const SizedBox(height: 16),
              _ActivitySection(controller: controller, sz: sz, onNav: _nav),
              const SizedBox(height: 40),
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
      centerTitle: false,
      titleSpacing: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: cs.onSurface,
            size: 20,
          ),
          tooltip: 'Geri',
          onPressed: () {
            if (Get.key.currentState?.canPop() ?? false) {
              Get.back();
            }
          },
        ),
      ),
      title: Text(
        'Profil',
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      actions: const [],
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
              top: -60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 320,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            // ── Aura blob 2 (sağ üst) ──
            Positioned(
              top: 20,
              right: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cs.secondaryContainer.withValues(alpha: 0.08),
                ),
              ),
            ),

            // ── İçerik ──
            Padding(
              padding: EdgeInsets.fromLTRB(sz.paddingH, 8, sz.paddingH, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Sub-bar ──
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Kulüp rozeti
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh.withValues(
                                alpha: 0.80,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                    .animate(
                                      onPlay: (c) => c.repeat(reverse: true),
                                    )
                                    .scaleXY(
                                      begin: 0.6,
                                      end: 1.5,
                                      duration: 1000.ms,
                                      curve: Curves.easeInOut,
                                    ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'İTÜ Bilişim Kulübü',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: cs.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                              const SizedBox(width: 8),
                              _QuickBtn(
                                icon: Icons.settings_outlined,
                                tooltip: 'Ayarlar',
                                onTap: () => Get.toNamed(AppRoutes.settings),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // ── Profil kartı ──
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh.withValues(alpha: 0.60),
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusLg * 1.3,
                      ),
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
                              avatarSize: sz.avatarSize,
                              controller: controller,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // İsim + verified
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                              color: cs.onSurface,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.verified_rounded,
                                          color: cs.primary,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    // Handle
                                    Text(
                                      '@$handle',
                                      style: TextStyle(
                                        color: cs.onSurfaceVariant,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    // Üyelik tarihi
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          color: cs.primary,
                                          size: 13,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            since,
                                            style: TextStyle(
                                              color: cs.onSurfaceVariant,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.04,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Profili Düzenle (4/5 genişlik)
                              Expanded(
                                flex: 4,
                                child: SizedBox(
                                  height: 44,
                                  child: Material(
                                    color: cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    child: InkWell(
                                      onTap: _navEdit,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.edit_note_rounded,
                                                color: cs.onSurface,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Profili Düzenle',
                                                style: TextStyle(
                                                  color: cs.onSurface,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              // Paylaş (1/5 genişlik)
                              SizedBox(
                                width: 44,
                                height: 44,
                                child: Material(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {},
                                    borderRadius: BorderRadius.circular(12),
                                    child: Icon(
                                      Icons.ios_share_rounded,
                                      color: cs.onSurfaceVariant,
                                      size: 20,
                                    ),
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
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
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
    const badgeOff = 6;

    return TapCursor(
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
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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
              top: -4,
              right: 0,
              child: SizedBox(
                width: 16,
                height: 16,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child:
                          Container(
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
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.primaryContainer,
                        ),
                        child: Center(
                          child: Container(
                            width: 7,
                            height: 7,
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
                child: TapCursor(
                  onTap: () => showAvatarSourceSheet(context, controller),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.photo_camera_rounded,
                      color: cs.onSurface,
                      size: 15,
                    ),
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
  const _QuickBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, color: cs.onSurfaceVariant, size: 20),
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
        padding: EdgeInsets.symmetric(horizontal: sz.paddingH),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
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
              const SizedBox(width: 4),
              _MetricCell(
                icon: Icons.thumb_up_rounded,
                iconColor: cs.secondary,
                count: stats?.totalLiked ?? 0,
                label: 'Beğeni',
                onTap: () => onNav(ProfileActivityType.liked),
              ),
              const SizedBox(width: 4),
              _MetricCell(
                icon: Icons.star_rounded,
                iconColor: cs.primaryFixed,
                count: stats?.totalFavorited ?? 0,
                label: 'Favori',
                onTap: () => onNav(ProfileActivityType.favorites),
              ),
              const SizedBox(width: 4),
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
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: iconColor, size: 16),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
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
      padding: EdgeInsets.symmetric(horizontal: sz.paddingH),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surfaceContainerHigh, cs.surfaceContainer],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: cs.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          'Harika!',
                          style: TextStyle(
                            color: cs.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bu hafta 6 saat 40 dk kampüs yayını izledin',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Sparkline (HTML SVG path ile aynı)
            CustomPaint(
              size: const Size(64, 32),
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
        padding: EdgeInsets.symmetric(horizontal: sz.paddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'KÜTÜPHANEM & HAREKETLER',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  TapCursor(
                    onTap: () => onNav(ProfileActivityType.favorites),
                    child: Text(
                      'Tümünü Yönet',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

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
            const SizedBox(height: 4),

            // 2. Beğendiklerim
            _NavTile(
              icon: Icons.thumb_up_rounded,
              iconColor: cs.secondary,
              iconBg: cs.secondary.withValues(alpha: 0.10),
              title: 'Beğendiklerim',
              subtitle: '$likedCount beğendiğin içerik',
              trailing: _CountBadge(
                text: '$likedCount',
                textColor: cs.secondary,
              ),
              onTap: () => onNav(ProfileActivityType.liked),
            ),
            const SizedBox(height: 4),

            // 3. İzleme Geçmişi
            _NavTile(
              icon: Icons.history_rounded,
              iconColor: cs.primaryFixed,
              iconBg: cs.surfaceContainerHighest,
              title: 'İzleme Geçmişi',
              subtitle: '$watchedCount video izlendi',
              trailing: Text(
                'Son: İTÜ Güneş Arabası',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
              ),
              onTap: () => onNav(ProfileActivityType.viewed),
            ),
            const SizedBox(height: 4),

            // 4. Yorumlarım
            _NavTile(
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: cs.onSurface,
              iconBg: cs.surfaceContainerHighest,
              title: 'Yorumlarım',
              subtitle: '$commentCount katkı ve yanıt',
              trailing: _CountBadge(
                text: '$commentCount',
                textColor: cs.onSurface,
              ),
              onTap: () => onNav(ProfileActivityType.commented),
            ),
            const SizedBox(height: 4),

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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                // İkon kutu
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (titleTag != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(
                                  alpha: 0.30,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                titleTag!,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (trailing != null)
                  Flexible(fit: FlexFit.loose, child: trailing!),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  size: 20,
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
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
    canvas.drawCircle(
      pts.last,
      2.5 * sx,
      linePaint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.color != color;
}
