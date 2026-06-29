// lib/presentation/screens/profile/widgets/profile_view_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/datasources/remote/supabase_datasource.dart';
import '../../../controllers/profile_activity_list_controller.dart';
import '../../../controllers/profile_controller.dart';
import 'profile_header/profile_header_widget.dart';

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
      arguments: {
        'userId': _userId,
        'isOwnProfile': controller.isOwnProfile,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320.h,
            pinned: true,
            floating: false,
            surfaceTintColor: Colors.transparent,
            actions: controller.isOwnProfile
                ? [
                    IconButton(
                      icon: Icon(
                        Icons.bar_chart_rounded,
                        color: AppTheme.textPri(context),
                        size: 24.sp,
                      ),
                      tooltip: 'İstatistiklerim',
                      onPressed: () => Get.toNamed(AppRoutes.stats),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: AppTheme.textPri(context),
                        size: 24.sp,
                      ),
                      tooltip: 'Ayarlar',
                      onPressed: () => Get.toNamed(AppRoutes.settings),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppTheme.textPri(context),
                        size: 24.sp,
                      ),
                      tooltip: 'Profili Düzenle',
                      onPressed: () =>
                          _showEditProfileDialog(context, controller),
                    ),
                  ]
                : [],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: ProfileHeaderWidget(controller: controller),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Bölüm başlığı ──────────────────────────────────────────
                Text(
                  'Aktiviteler',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 12.h),

                // ── Butonlar ───────────────────────────────────────────────
                _ActivityButton(
                  icon: Icons.favorite_rounded,
                  label: 'Favoriler',
                  color: const Color(0xFFE53935),
                  onTap: () => _navigateTo(ProfileActivityType.favorites),
                ),
                SizedBox(height: 10.h),
                _ActivityButton(
                  icon: Icons.thumb_up_alt_rounded,
                  label: 'Beğenilenler',
                  color: const Color(0xFF00ACC1),
                  onTap: () => _navigateTo(ProfileActivityType.liked),
                ),
                SizedBox(height: 10.h),
                _ActivityButton(
                  icon: Icons.play_circle_rounded,
                  label: 'İzlenenler',
                  color: const Color(0xFF1E88E5),
                  onTap: () => _navigateTo(ProfileActivityType.viewed),
                ),
                SizedBox(height: 10.h),
                _ActivityButton(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Yorum Yapılanlar',
                  color: const Color(0xFF43A047),
                  onTap: () => _navigateTo(ProfileActivityType.commented),
                ),
                SizedBox(height: 10.h),
                _ActivityButton(
                  icon: Icons.share_rounded,
                  label: 'Paylaşılanlar',
                  color: const Color(0xFF8E24AA),
                  onTap: () => _navigateTo(ProfileActivityType.shared),
                ),
                SizedBox(height: 10.h),
                _ActivityButton(
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
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    if (!controller.isOwnProfile) return;

    final usernameCtrl = TextEditingController(
      text: controller.profile.value?.username ?? '',
    );
    final fullNameCtrl = TextEditingController(
      text: controller.profile.value?.fullName ?? '',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Profili Düzenle',
          style: TextStyle(color: AppTheme.textPri(context), fontSize: 20.sp),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                labelStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppTheme.textSec(context),
                  size: 20.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: fullNameCtrl,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                labelStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.badge_outlined,
                  color: AppTheme.textSec(context),
                  size: 20.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: Size(80.w, 40.h)),
            onPressed: () async {
              Get.back();
              await controller.updateProfile(
                username: usernameCtrl.text.trim(),
                fullName: fullNameCtrl.text.trim(),
              );
              if (controller.successMessage.value != null) {
                Get.snackbar('Başarılı', controller.successMessage.value!);
                controller.successMessage.value = null;
              } else if (controller.errorMessage.value != null) {
                Get.snackbar('Hata', controller.errorMessage.value!);
                controller.errorMessage.value = null;
              }
            },
            child: Text('Kaydet', style: TextStyle(fontSize: 14.sp)),
          ),
        ],
      ),
    );
  }
}

// ─── Aktivite Butonu ────────────────────────────────────────────────────────

class _ActivityButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActivityButton({
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSec(context),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
