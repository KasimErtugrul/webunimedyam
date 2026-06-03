// lib/presentation/screens/profile/widgets/profile_header/profile_header_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/profile_controller.dart';
import '../../../follow/widgets/follow_button_widget.dart';
import 'stat_chip_widget.dart';
import 'stat_divider_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile     = controller.profile.value;
      final isOwnProfile = controller.isOwnProfile;

      return Container(
        color: AppTheme.bg(context),
        padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 12.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Avatar ──────────────────────────────────────────────────────
            _AvatarWidget(
              avatarUrl: profile?.avatarUrl,
              username:  profile?.username ?? 'U',
            ),

            SizedBox(height: 12.h),

            // ── Kullanıcı adı ────────────────────────────────────────────────
            Text(
              profile?.username ?? 'Kullanıcı',
              style: TextStyle(
                color:      AppTheme.textPri(context),
                fontSize:   19.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            // ── Tam isim (varsa) ─────────────────────────────────────────────
            if ((profile?.fullName ?? '').isNotEmpty) ...[
              SizedBox(height: 2.h),
              Text(
                profile!.fullName!,
                style: TextStyle(
                  color:    AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
            ],

            // ── Takipçi / Takip sayıları ──────────────────────────────────
            if (profile != null) ...[
              SizedBox(height: 12.h),
              FollowCountsWidget(userId: profile.id),
            ],

            SizedBox(height: 16.h),

            // ── İstatistik chipleri ──────────────────────────────────────────
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatChipWidget(
                    icon:  Icons.favorite_rounded,
                    count: controller.favoriteVideos.length,
                    label: 'Favori',
                  ),
                  const StatDividerWidget(),
                  StatChipWidget(
                    icon:  Icons.play_circle_rounded,
                    count: controller.viewedVideos.length,
                    label: 'İzlenen',
                  ),
                  const StatDividerWidget(),
                  StatChipWidget(
                    icon:  Icons.chat_bubble_rounded,
                    count: controller.commentedVideos.length,
                    label: 'Yorum',
                  ),
                  const StatDividerWidget(),
                  StatChipWidget(
                    icon:  Icons.share_rounded,
                    count: controller.sharedVideos.length,
                    label: 'Paylaşım',
                  ),
                ],
              ),
            ),

            // ── Takip butonu (başkasının profili) ────────────────────────────
            if (!isOwnProfile && profile != null) ...[
              SizedBox(height: 16.h),
              FollowButtonWidget(targetProfile: profile),
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
  final String  username;

  const _AvatarWidget({required this.avatarUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Container(
      width:  78.w,
      height: 78.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF158a3e)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color:      AppTheme.primaryColor.withValues(alpha: 0.35),
            blurRadius: 18.r,
            offset:     Offset(0, 6.h),
          ),
        ],
      ),
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit:      BoxFit.cover,
                width:    78.w,
                height:   78.h,
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
          color:      Colors.white,
          fontSize:   30.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}