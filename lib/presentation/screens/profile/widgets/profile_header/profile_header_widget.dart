// lib/presentation/screens/profile/widgets/profile_header/profile_header_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        padding: EdgeInsets.fromLTRB(20.w, 80.h, 20.w, 20.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            _AvatarWidget(
              avatarUrl: profile?.avatarUrl,
              username: profile?.username ?? 'U',
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

// ─── Avatar Widget ─────────────────────────────────────────────────────────

class _AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String username;

  const _AvatarWidget({required this.avatarUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
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
