// lib/presentation/screens/profile/widgets/profile_header/avatar_widget.dart
//
// Profil avatarı — hem profil başlığında (ProfileHeaderWidget) hem de
// "Profili Düzenle" ekranında (edit_profile_screen.dart) kullanılıyor.
// Tek yerden yönetiliyor ki ikisi birbirinden sapmasın.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final bool isOwnProfile;
  final bool isUploading;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.isOwnProfile,
    required this.isUploading,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    final badgeSize = size * 0.32;

    return GestureDetector(
      onTap: isOwnProfile ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bg(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 14.r,
                  offset: Offset(0, 5.h),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF158a3e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: hasImage
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl!,
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                        errorWidget: (_, __, ___) =>
                            _InitialLetter(username: username, size: size),
                      ),
                    )
                  : _InitialLetter(username: username, size: size),
            ),
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
          if (isOwnProfile && !isUploading && onTap != null)
            Positioned(
              right: -2.w,
              bottom: -2.h,
              child: Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                  border: Border.all(color: AppTheme.bg(context), width: 2.w),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: badgeSize * 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialLetter extends StatelessWidget {
  final String username;
  final double size;
  const _InitialLetter({required this.username, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
