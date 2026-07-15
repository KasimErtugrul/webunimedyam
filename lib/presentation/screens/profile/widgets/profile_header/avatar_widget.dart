// lib/presentation/screens/profile/widgets/profile_header/avatar_widget.dart
//
// Profil avatarı — hem profil başlığında (ProfileHeaderWidget) hem de
// "Profili Düzenle" ekranında (edit_profile_screen.dart) kullanılıyor.
// Tek yerden yönetiliyor ki ikisi birbirinden sapmasın.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double avatarPadding = 3;
  static const double shadowBlurRadius = 14;
  static const double shadowOffsetY = 5;
  static const double loadingIndicatorSize = 26;
  static const double loadingStrokeWidth = 2.5;
  static const double badgeBorderWidth = 2;
  static const double badgeIconScale = 0.5;
}

class _TabletSizes {
  static const double avatarPadding = 4;
  static const double shadowBlurRadius = 18;
  static const double shadowOffsetY = 6;
  static const double loadingIndicatorSize = 30;
  static const double loadingStrokeWidth = 3;
  static const double badgeBorderWidth = 2.5;
  static const double badgeIconScale = 0.5;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

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
    final isTablet = Responsive.isTablet(context);
  //  final sizes = isTablet ? _TabletSizes() : _PhoneSizes();
    
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
            padding: EdgeInsets.all(
              isTablet ? _TabletSizes.avatarPadding : _PhoneSizes.avatarPadding.w,
            ),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bg(context),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: isTablet ? _TabletSizes.shadowBlurRadius : _PhoneSizes.shadowBlurRadius.r,
                  offset: Offset(0, isTablet ? _TabletSizes.shadowOffsetY : _PhoneSizes.shadowOffsetY.h),
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
          if (isUploading)
            Positioned.fill(
              child: ClipOval(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.45),
                  child: Center(
                    child: SizedBox(
                      width: isTablet ? _TabletSizes.loadingIndicatorSize : _PhoneSizes.loadingIndicatorSize.w,
                      height: isTablet ? _TabletSizes.loadingIndicatorSize : _PhoneSizes.loadingIndicatorSize.w,
                      child: CircularProgressIndicator(
                        strokeWidth: isTablet ? _TabletSizes.loadingStrokeWidth : _PhoneSizes.loadingStrokeWidth,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
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
                  border: Border.all(
                    color: AppTheme.bg(context),
                    width: isTablet ? _TabletSizes.badgeBorderWidth : _PhoneSizes.badgeBorderWidth.w,
                  ),
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: badgeSize * (isTablet ? _TabletSizes.badgeIconScale : _PhoneSizes.badgeIconScale),
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