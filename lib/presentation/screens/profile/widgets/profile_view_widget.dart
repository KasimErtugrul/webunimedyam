// lib/presentation/screens/profile/widgets/profile_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';
import '../../../../data/datasources/remote/supabase_datasource.dart';
import '../../../controllers/profile_activity_list_controller.dart';
import '../../../controllers/profile_controller.dart';
import 'profile_header/profile_header_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 20;
  static const double appBarIconSize = 24;
  
  // Content
  static const double contentPaddingHorizontal = 16;
  static const double contentPaddingVertical = 20;
  static const double sectionTitleFontSize = 12;
  static const double sectionTitleLetterSpacing = 0.8;
  static const double sectionTitleSpacing = 12;
  static const double buttonSpacing = 10;
  
  // Activity Button
  static const double buttonPaddingHorizontal = 16;
  static const double buttonPaddingVertical = 14;
  static const double buttonBorderRadius = 14;
  static const double buttonIconContainerSize = 38;
  static const double buttonIconContainerRadius = 10;
  static const double buttonIconSize = 20;
  static const double buttonIconSpacing = 14;
  static const double buttonLabelFontSize = 14;
  static const double buttonChevronSize = 20;
  static const double buttonAlpha = 0.12;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double appBarTitleSize = 24;
  static const double appBarIconSize = 28;
  
  // Content - tablet için daha büyük
  static const double contentPaddingHorizontal = 24;
  static const double contentPaddingVertical = 28;
  static const double sectionTitleFontSize = 14;
  static const double sectionTitleLetterSpacing = 0.9;
  static const double sectionTitleSpacing = 14;
  static const double buttonSpacing = 12;
  
  // Activity Button - tablet için daha büyük
  static const double buttonPaddingHorizontal = 20;
  static const double buttonPaddingVertical = 18;
  static const double buttonBorderRadius = 16;
  static const double buttonIconContainerSize = 46;
  static const double buttonIconContainerRadius = 12;
  static const double buttonIconSize = 24;
  static const double buttonIconSpacing = 16;
  static const double buttonLabelFontSize = 16;
  static const double buttonChevronSize = 24;
  static const double buttonAlpha = 0.12;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class ProfileViewWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileViewWidget({super.key, required this.controller});

  String get _userId {
    if (controller.isOwnProfile) {
      final supabase = Get.find<SupabaseDataSource>();
      return supabase.currentUser?.id ?? '';
    }
    return controller.targetUserId ?? '';
  }

  void _navigateTo(ProfileActivityType type) {
    Get.toNamed(
      AppRoutes.profileActivityList,
      arguments: {
        'type': type,
        'userId': _userId,
        'isOwnProfile': controller.isOwnProfile,
      },
    );
  }

  void _navigateToUniversities() {
    Get.toNamed(
      AppRoutes.followedUniversitiesList,
      arguments: {'userId': _userId, 'isOwnProfile': controller.isOwnProfile},
    );
  }

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isOwnProfile ? 'Profilim' : 'Profil',
          style: TextStyle(fontSize: _PhoneSizes.appBarTitleSize.sp),
        ),
        actions: controller.isOwnProfile
            ? [
                IconButton(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: AppTheme.textPri(context),
                    size: _PhoneSizes.appBarIconSize.sp,
                  ),
                  tooltip: 'İstatistiklerim',
                  onPressed: () => Get.toNamed(AppRoutes.stats),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPri(context),
                    size: _PhoneSizes.appBarIconSize.sp,
                  ),
                  tooltip: 'Ayarlar',
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                ),
              ]
            : [],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: controller.refreshProfile,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(controller: controller),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.contentPaddingHorizontal.w,
                vertical: _PhoneSizes.contentPaddingVertical.h,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Aktiviteler',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.sectionTitleFontSize.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _PhoneSizes.sectionTitleLetterSpacing,
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.sectionTitleSpacing.h),
                  _ActivityButtonPhone(
                    icon: Icons.favorite_rounded,
                    label: 'Favoriler',
                    color: const Color(0xFFE53935),
                    onTap: () => _navigateTo(ProfileActivityType.favorites),
                  ),
                  SizedBox(height: _PhoneSizes.buttonSpacing.h),
                  _ActivityButtonPhone(
                    icon: Icons.thumb_up_alt_rounded,
                    label: 'Beğenilenler',
                    color: const Color(0xFF00ACC1),
                    onTap: () => _navigateTo(ProfileActivityType.liked),
                  ),
                  SizedBox(height: _PhoneSizes.buttonSpacing.h),
                  _ActivityButtonPhone(
                    icon: Icons.play_circle_rounded,
                    label: 'İzlenenler',
                    color: const Color(0xFF1E88E5),
                    onTap: () => _navigateTo(ProfileActivityType.viewed),
                  ),
                  SizedBox(height: _PhoneSizes.buttonSpacing.h),
                  _ActivityButtonPhone(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Yorum Yapılanlar',
                    color: const Color(0xFF43A047),
                    onTap: () => _navigateTo(ProfileActivityType.commented),
                  ),
                  SizedBox(height: _PhoneSizes.buttonSpacing.h),
                  _ActivityButtonPhone(
                    icon: Icons.share_rounded,
                    label: 'Paylaşılanlar',
                    color: const Color(0xFF8E24AA),
                    onTap: () => _navigateTo(ProfileActivityType.shared),
                  ),
                  SizedBox(height: _PhoneSizes.buttonSpacing.h),
                  _ActivityButtonPhone(
                    icon: Icons.account_balance_rounded,
                    label: 'Takip Edilen Üniversiteler',
                    color: const Color(0xFFF4511E),
                    onTap: _navigateToUniversities,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isOwnProfile ? 'Profilim' : 'Profil',
          style: TextStyle(fontSize: _TabletSizes.appBarTitleSize),
        ),
        actions: controller.isOwnProfile
            ? [
                IconButton(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: AppTheme.textPri(context),
                    size: _TabletSizes.appBarIconSize,
                  ),
                  tooltip: 'İstatistiklerim',
                  onPressed: () => Get.toNamed(AppRoutes.stats),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPri(context),
                    size: _TabletSizes.appBarIconSize,
                  ),
                  tooltip: 'Ayarlar',
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                ),
              ]
            : [],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: controller.refreshProfile,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(controller: controller),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.contentPaddingHorizontal,
                vertical: _TabletSizes.contentPaddingVertical,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Aktiviteler',
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.sectionTitleFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: _TabletSizes.sectionTitleLetterSpacing,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.sectionTitleSpacing),
                  _ActivityButtonTablet(
                    icon: Icons.favorite_rounded,
                    label: 'Favoriler',
                    color: const Color(0xFFE53935),
                    onTap: () => _navigateTo(ProfileActivityType.favorites),
                  ),
                  SizedBox(height: _TabletSizes.buttonSpacing),
                  _ActivityButtonTablet(
                    icon: Icons.thumb_up_alt_rounded,
                    label: 'Beğenilenler',
                    color: const Color(0xFF00ACC1),
                    onTap: () => _navigateTo(ProfileActivityType.liked),
                  ),
                  SizedBox(height: _TabletSizes.buttonSpacing),
                  _ActivityButtonTablet(
                    icon: Icons.play_circle_rounded,
                    label: 'İzlenenler',
                    color: const Color(0xFF1E88E5),
                    onTap: () => _navigateTo(ProfileActivityType.viewed),
                  ),
                  SizedBox(height: _TabletSizes.buttonSpacing),
                  _ActivityButtonTablet(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Yorum Yapılanlar',
                    color: const Color(0xFF43A047),
                    onTap: () => _navigateTo(ProfileActivityType.commented),
                  ),
                  SizedBox(height: _TabletSizes.buttonSpacing),
                  _ActivityButtonTablet(
                    icon: Icons.share_rounded,
                    label: 'Paylaşılanlar',
                    color: const Color(0xFF8E24AA),
                    onTap: () => _navigateTo(ProfileActivityType.shared),
                  ),
                  SizedBox(height: _TabletSizes.buttonSpacing),
                  _ActivityButtonTablet(
                    icon: Icons.account_balance_rounded,
                    label: 'Takip Edilen Üniversiteler',
                    color: const Color(0xFFF4511E),
                    onTap: _navigateToUniversities,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _ActivityButtonPhone extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActivityButtonPhone({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.buttonPaddingHorizontal.w,
          vertical: _PhoneSizes.buttonPaddingVertical.h,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.buttonBorderRadius.r),
        ),
        child: Row(
          children: [
            Container(
              width: _PhoneSizes.buttonIconContainerSize.w,
              height: _PhoneSizes.buttonIconContainerSize.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: _PhoneSizes.buttonAlpha),
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.buttonIconContainerRadius.r,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: _PhoneSizes.buttonIconSize.sp,
              ),
            ),
            SizedBox(width: _PhoneSizes.buttonIconSpacing.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _PhoneSizes.buttonLabelFontSize.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: _PhoneSizes.buttonChevronSize.sp,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _ActivityButtonTablet extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActivityButtonTablet({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.buttonPaddingHorizontal,
          vertical: _TabletSizes.buttonPaddingVertical,
        ),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(_TabletSizes.buttonBorderRadius),
        ),
        child: Row(
          children: [
            Container(
              width: _TabletSizes.buttonIconContainerSize,
              height: _TabletSizes.buttonIconContainerSize,
              decoration: BoxDecoration(
                color: color.withValues(alpha: _TabletSizes.buttonAlpha),
                borderRadius: BorderRadius.circular(
                  _TabletSizes.buttonIconContainerRadius,
                ),
              ),
              child: Icon(
                icon,
                color: color,
                size: _TabletSizes.buttonIconSize,
              ),
            ),
            SizedBox(width: _TabletSizes.buttonIconSpacing),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _TabletSizes.buttonLabelFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: _TabletSizes.buttonChevronSize,
            ),
          ],
        ),
      ),
    );
  }
}