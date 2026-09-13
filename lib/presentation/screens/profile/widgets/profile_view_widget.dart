// lib/presentation/screens/profile/widgets/profile_view_widget.dart
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
import 'profile_header/profile_header_widget.dart';

class _Sizes {
  final bool isTablet;
  final double appBarTitleSize;
  final double appBarIconSize;
  final double contentPaddingH;
  final double contentPaddingV;
  final double sectionTitleFontSize;
  final double sectionTitleLetterSpacing;
  final double sectionTitleSpacing;
  final double buttonSpacing;
  final double buttonPaddingH;
  final double buttonPaddingV;
  final double buttonRadius;
  final double buttonIconContainerSize;
  final double buttonIconContainerRadius;
  final double buttonIconSize;
  final double buttonIconSpacing;
  final double buttonLabelFontSize;
  final double buttonChevronSize;

  const _Sizes._({
    required this.isTablet,
    required this.appBarTitleSize,
    required this.appBarIconSize,
    required this.contentPaddingH,
    required this.contentPaddingV,
    required this.sectionTitleFontSize,
    required this.sectionTitleLetterSpacing,
    required this.sectionTitleSpacing,
    required this.buttonSpacing,
    required this.buttonPaddingH,
    required this.buttonPaddingV,
    required this.buttonRadius,
    required this.buttonIconContainerSize,
    required this.buttonIconContainerRadius,
    required this.buttonIconSize,
    required this.buttonIconSpacing,
    required this.buttonLabelFontSize,
    required this.buttonChevronSize,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        appBarTitleSize: 24,
        appBarIconSize: 28,
        contentPaddingH: 24,
        contentPaddingV: 24,
        sectionTitleFontSize: 13,
        sectionTitleLetterSpacing: 0.9,
        sectionTitleSpacing: 14,
        buttonSpacing: 10,
        buttonPaddingH: 18,
        buttonPaddingV: 16,
        buttonRadius: 16,
        buttonIconContainerSize: 46,
        buttonIconContainerRadius: 12,
        buttonIconSize: 22,
        buttonIconSpacing: 14,
        buttonLabelFontSize: 16,
        buttonChevronSize: 22,
      );
    }
    return const _Sizes._(
      isTablet: false,
      appBarTitleSize: 20,
      appBarIconSize: 24,
      contentPaddingH: 16,
      contentPaddingV: 20,
      sectionTitleFontSize: 11.5,
      sectionTitleLetterSpacing: 0.8,
      sectionTitleSpacing: 12,
      buttonSpacing: 8,
      buttonPaddingH: 14,
      buttonPaddingV: 14,
      buttonRadius: 14,
      buttonIconContainerSize: 40,
      buttonIconContainerRadius: 11,
      buttonIconSize: 20,
      buttonIconSpacing: 12,
      buttonLabelFontSize: 14.5,
      buttonChevronSize: 20,
    );
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
    final spec = _Sizes.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isOwnProfile ? 'Profilim' : 'Profil',
          style: TextStyle(fontSize: spec.appBarTitleSize.sp),
        ),
        actions: controller.isOwnProfile
            ? [
                IconButton(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: AppTheme.textPri(context),
                    size: spec.appBarIconSize.sp,
                  ),
                  tooltip: 'İstatistiklerim',
                  onPressed: () => Get.toNamed(AppRoutes.stats),
                ),
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPri(context),
                    size: spec.appBarIconSize.sp,
                  ),
                  tooltip: 'Ayarlar',
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                ),
              ]
            : const [],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: controller.refreshProfile,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeaderWidget(controller: controller),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                spec.contentPaddingH.w,
                4.h,
                spec.contentPaddingH.w,
                spec.contentPaddingV.h,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: EdgeInsets.only(
                      left: 4.w,
                      bottom: spec.sectionTitleSpacing.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 3.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'AKTİVİTELER',
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: spec.sectionTitleFontSize.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: spec.sectionTitleLetterSpacing,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _ActivityButton(
                    icon: Icons.favorite_rounded,
                    label: 'Favoriler',
                    color: const Color(0xFFE53935),
                    spec: spec,
                    onTap: () => _navigateTo(ProfileActivityType.favorites),
                  ).animate(delay: 100.ms).fadeIn(duration: 300.ms).slideY(
                        begin: 0.1, end: 0, curve: Curves.easeOut),
                  SizedBox(height: spec.buttonSpacing.h),
                  _ActivityButton(
                    icon: Icons.thumb_up_alt_rounded,
                    label: 'Beğenilenler',
                    color: const Color(0xFF00ACC1),
                    spec: spec,
                    onTap: () => _navigateTo(ProfileActivityType.liked),
                  ).animate(delay: 150.ms).fadeIn(duration: 300.ms).slideY(
                        begin: 0.1, end: 0, curve: Curves.easeOut),
                  SizedBox(height: spec.buttonSpacing.h),
                  _ActivityButton(
                    icon: Icons.play_circle_rounded,
                    label: 'İzlenenler',
                    color: const Color(0xFF1E88E5),
                    spec: spec,
                    onTap: () => _navigateTo(ProfileActivityType.viewed),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms).slideY(
                        begin: 0.1, end: 0, curve: Curves.easeOut),
                  SizedBox(height: spec.buttonSpacing.h),
                  _ActivityButton(
                    icon: Icons.chat_bubble_rounded,
                    label: 'Yorum Yapılanlar',
                    color: const Color(0xFF43A047),
                    spec: spec,
                    onTap: () => _navigateTo(ProfileActivityType.commented),
                  ).animate(delay: 250.ms).fadeIn(duration: 300.ms).slideY(
                        begin: 0.1, end: 0, curve: Curves.easeOut),
                  SizedBox(height: spec.buttonSpacing.h),
                  _ActivityButton(
                    icon: Icons.share_rounded,
                    label: 'Paylaşılanlar',
                    color: const Color(0xFF8E24AA),
                    spec: spec,
                    onTap: () => _navigateTo(ProfileActivityType.shared),
                  ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(
                        begin: 0.1, end: 0, curve: Curves.easeOut),
                  SizedBox(height: spec.buttonSpacing.h),
                  _ActivityButton(
                    icon: Icons.account_balance_rounded,
                    label: 'Takip Edilen Üniversiteler',
                    color: const Color(0xFFF4511E),
                    spec: spec,
                    onTap: _navigateToUniversities,
                  ).animate(delay: 350.ms).fadeIn(duration: 300.ms).slideY(
                        begin: 0.1, end: 0, curve: Curves.easeOut),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final _Sizes spec;
  final VoidCallback onTap;

  const _ActivityButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.spec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card(context),
      borderRadius: BorderRadius.circular(spec.buttonRadius.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(spec.buttonRadius.r),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spec.buttonPaddingH.w,
            vertical: spec.buttonPaddingV.h,
          ),
          child: Row(
            children: [
              Container(
                width: spec.buttonIconContainerSize.w,
                height: spec.buttonIconContainerSize.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(spec.buttonIconContainerRadius.r),
                ),
                child: Icon(icon, color: color, size: spec.buttonIconSize.sp),
              ),
              SizedBox(width: spec.buttonIconSpacing.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: spec.buttonLabelFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context).withValues(alpha: 0.5),
                size: spec.buttonChevronSize.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}