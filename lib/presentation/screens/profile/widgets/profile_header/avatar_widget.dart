// lib/presentation/screens/profile/widgets/profile_header/avatar_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final bool isTablet;
  final double outerBorderWidth;
  final double innerPadding;
  final double shadowBlur;
  final double shadowOffsetY;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final double badgeSizeRatio;
  final double badgeBorderWidth;
  final double badgeIconRatio;

  const _Sizes._({
    required this.isTablet,
    required this.outerBorderWidth,
    required this.innerPadding,
    required this.shadowBlur,
    required this.shadowOffsetY,
    required this.loadingIndicatorSize,
    required this.loadingStrokeWidth,
    required this.badgeSizeRatio,
    required this.badgeBorderWidth,
    required this.badgeIconRatio,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        isTablet: true,
        outerBorderWidth: 2.5,
        innerPadding: 4,
        shadowBlur: 20,
        shadowOffsetY: 6,
        loadingIndicatorSize: 32,
        loadingStrokeWidth: 3,
        badgeSizeRatio: 0.32,
        badgeBorderWidth: 2.5,
        badgeIconRatio: 0.5,
      );
    }
    return const _Sizes._(
      isTablet: false,
      outerBorderWidth: 2,
      innerPadding: 3,
      shadowBlur: 16,
      shadowOffsetY: 5,
      loadingIndicatorSize: 26,
      loadingStrokeWidth: 2.5,
      badgeSizeRatio: 0.32,
      badgeBorderWidth: 2,
      badgeIconRatio: 0.5,
    );
  }
}

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
    final spec = _Sizes.of(context);
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;
    final badgeSize = size * spec.badgeSizeRatio;

    double w(double v) => spec.isTablet ? v : v.w;
    double h(double v) => spec.isTablet ? v : v.h;

    return GestureDetector(
      onTap: isOwnProfile ? onTap : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Dış ring + shadow ──
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.bg(context),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: w(spec.shadowBlur),
                  offset: Offset(0, h(spec.shadowOffsetY)),
                ),
              ],
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.25),
                width: w(spec.outerBorderWidth),
              ),
            ),
            padding: EdgeInsets.all(w(spec.innerPadding)),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF158a3e)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipOval(
                child: hasImage
                    ? CachedNetworkImage(
                        imageUrl: avatarUrl!,
                        fit: BoxFit.cover,
                        width: size,
                        height: size,
                        errorWidget: (_, _, _) =>
                            _InitialLetter(username: username, size: size),
                      )
                    : _InitialLetter(username: username, size: size),
              ),
            ),
          ),

          // ── Yükleniyor overlay ──
          if (isUploading)
            Positioned.fill(
              child: ClipOval(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: SizedBox(
                      width: w(spec.loadingIndicatorSize),
                      height: w(spec.loadingIndicatorSize),
                      child: CircularProgressIndicator(
                        strokeWidth: spec.loadingStrokeWidth,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // ── Kamera badge (kendi profil, pulse) ──
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
                    width: w(spec.badgeBorderWidth),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: badgeSize * spec.badgeIconRatio,
                ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  )
                  .scaleXY(
                    begin: 1,
                    end: 1.08,
                    duration: 1400.ms,
                    curve: Curves.easeInOut,
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
          letterSpacing: -1,
        ),
      ),
    );
  }
}