// lib/presentation/screens/profile/widgets/profile_header/profile_header_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/profile_controller.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;

      return Container(
        color: AppTheme.bg(context),
        // padding: EdgeInsets.fromLTRB(20.w, 80.h, 20.w, 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            _AvatarWidget(
              avatarUrl: profile?.avatarUrl,
              username: profile?.username ?? 'U',
              isOwnProfile: controller.isOwnProfile,
              isUploading: controller.isUploadingAvatar.value,
              onTap: () => _showAvatarSourceSheet(context, controller),
            ),

            SizedBox(height: 14.h),

            // ── Kullanıcı adı ────────────────────────────────────────────────
            Text(
              profile?.username ?? 'Kullanıcı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            // ── Tam isim (varsa) ─────────────────────────────────────────────
            if ((profile?.fullName ?? '').isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                profile!.fullName!,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 14.sp,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

Future<void> _pickAndNotify(ProfileController controller, ImageSource source) async {
  await controller.pickAndUploadAvatar(source: source);
  if (controller.successMessage.value != null) {
    Get.snackbar('Başarılı', controller.successMessage.value!);
    controller.successMessage.value = null;
  } else if (controller.errorMessage.value != null) {
    Get.snackbar('Hata', controller.errorMessage.value!);
    controller.errorMessage.value = null;
  }
}

// ─── Avatar Kaynağı Seçim Sheet'i ───────────────────────────────────────────

void _showAvatarSourceSheet(BuildContext context, ProfileController controller) {
  if (!controller.isOwnProfile || controller.isUploadingAvatar.value) return;

  Get.bottomSheet(
    SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Text(
              'Profil Fotoğrafı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: AppTheme.textPri(context)),
              title: Text('Kameradan Çek', style: TextStyle(color: AppTheme.textPri(context), fontSize: 14.sp)),
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppTheme.textPri(context)),
              title: Text('Galeriden Seç', style: TextStyle(color: AppTheme.textPri(context), fontSize: 14.sp)),
              onTap: () {
                Get.back();
                _pickAndNotify(controller, ImageSource.gallery);
              },
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    ),
  );
}

// ─── Avatar Widget ─────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final bool isOwnProfile;
  final bool isUploading;
  final VoidCallback onTap;

  const _AvatarWidget({
    required this.avatarUrl,
    required this.username,
    required this.isOwnProfile,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;

    return GestureDetector(
      onTap: isOwnProfile ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF158a3e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 18.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: hasImage
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      width: 80.w,
                      height: 80.h,
                      errorWidget: (_, __, ___) => _InitialLetter(username: username),
                    ),
                  )
                : _InitialLetter(username: username),
          ),

          // ── Yükleniyor overlay'i ─────────────────────────────────────────
          if (isUploading)
            Positioned.fill(
              child: ClipOval(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: SizedBox(
                      width: 26.w,
                      height: 26.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Kamera rozeti (sadece kendi profilimizde) ─────────────────────
          if (isOwnProfile && !isUploading)
            Positioned(
              right: -2.w,
              bottom: -2.h,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                  border: Border.all(color: AppTheme.bg(context), width: 2.w),
                ),
                child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14.sp),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialLetter extends StatelessWidget {
  final String username;
  const _InitialLetter({required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
