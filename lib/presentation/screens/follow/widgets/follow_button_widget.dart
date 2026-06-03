// lib/presentation/screens/follow/widgets/follow_button_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/follow_model.dart';
import '../../../../data/models/profile_model.dart';
import '../../../controllers/follow_controller.dart';

/// Tag'li FollowController'ı bulur.
/// [userId]: hedef kullanıcının ID'si (tag olarak kullanılır).
FollowController? _findCtrl(String userId) {
  if (Get.isRegistered<FollowController>(tag: userId)) {
    return Get.find<FollowController>(tag: userId);
  }
  return null;
}

/// Profil ekranında gösterilen Takip Et / Takibi Bırak / İstek Gönderildi butonu.
class FollowButtonWidget extends StatelessWidget {
  final ProfileModel targetProfile;

  const FollowButtonWidget({super.key, required this.targetProfile});

  @override
  Widget build(BuildContext context) {
    final ctrl = _findCtrl(targetProfile.id);
    if (ctrl == null) return const SizedBox.shrink();

    return Obx(() {
      final isLoading      = ctrl.isFollowLoading.value;
      final follow         = ctrl.currentProfileFollow.value;
      final isPending      = follow?.status == FollowStatus.pending;
      final isFollowingUser = follow?.status == FollowStatus.accepted;

      if (isLoading) {
        return SizedBox(
          width: 120.w,
          height: 36.h,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (isPending) {
        return _FollowChip(
          label: 'İstek Gönderildi',
          icon: Icons.hourglass_top_rounded,
          isPrimary: false,
          onTap: () => ctrl.toggleFollow(targetProfile),
        );
      }

      if (isFollowingUser) {
        return _FollowChip(
          label: 'Takip Ediliyor',
          icon: Icons.check_rounded,
          isPrimary: false,
          onTap: () => _confirmUnfollow(context, ctrl),
        );
      }

      return _FollowChip(
        label: 'Takip Et',
        icon: Icons.person_add_alt_1_outlined,
        isPrimary: true,
        onTap: () => ctrl.toggleFollow(targetProfile),
      );
    });
  }

  void _confirmUnfollow(BuildContext context, FollowController ctrl) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Takibi bırak'),
        content: Text(
          '${targetProfile.username ?? 'bu kullanıcıyı'} takip etmeyi bırakmak istiyor musun?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.toggleFollow(targetProfile);
            },
            child: const Text('Bırak', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _FollowChip({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: isPrimary
              ? null
              : Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isPrimary ? Colors.white : AppTheme.primaryColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profil başlığında gösterilen takipçi/takip sayıları widget'ı.
/// [userId]: hedef kullanıcının ID'si (FollowController tag'i).
class FollowCountsWidget extends StatelessWidget {
  final String userId;

  const FollowCountsWidget({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ctrl = _findCtrl(userId);
    if (ctrl == null) return const SizedBox.shrink();

    return Obx(() {
      final counts = ctrl.followCounts.value;
      if (counts == null) return const SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CountChip(
            count: counts.followersCount,
            label: 'Takipçi',
            onTap: () => Get.toNamed(
              '/followers',
              arguments: {'userId': userId, 'initialTab': 0},
            ),
          ),
          SizedBox(width: 24.w),
          _CountChip(
            count: counts.followingCount,
            label: 'Takip',
            onTap: () => Get.toNamed(
              '/followers',
              arguments: {'userId': userId, 'initialTab': 1},
            ),
          ),
        ],
      );
    });
  }
}

class _CountChip extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onTap;

  const _CountChip({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPri(context),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSec(context),
            ),
          ),
        ],
      ),
    );
  }
}
