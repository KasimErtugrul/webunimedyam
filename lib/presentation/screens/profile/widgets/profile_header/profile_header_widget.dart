// ═══════════════════════════════════════════════════════════════════════════
// Profil başlığı
// ═══════════════════════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/profile_controller.dart';
import 'stat_chip_widget.dart';
import 'stat_divider_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileHeaderWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;

      return Container(
        color: AppTheme.bg(context),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 78,
                  height: 78,
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
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            (profile?.username ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile?.username ?? 'Kullanıcı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            if ((profile?.fullName ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                profile!.fullName!,
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatChipWidget(icon: Icons.favorite_rounded, count: controller.favoriteVideos.length, label: 'Favori'),
                  StatDividerWidget(),
                  StatChipWidget(icon: Icons.play_circle_rounded, count: controller.viewedVideos.length, label: 'İzlenen'),
                  StatDividerWidget(),
                  StatChipWidget(icon: Icons.chat_bubble_rounded, count: controller.commentedVideos.length, label: 'Yorum'),
                  StatDividerWidget(),
                  StatChipWidget(icon: Icons.share_rounded, count: controller.sharedVideos.length, label: 'Paylaşım'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}