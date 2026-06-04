
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/follow_model.dart';
import '../../controllers/notification_controller.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationsController _ctrl;
  Worker? _errorWorker;
  Worker? _successWorker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<NotificationsController>();

    _errorWorker = ever(_ctrl.errorMessage, (msg) {
      if (msg != null && mounted) {
        Get.snackbar('Hata', msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withValues(alpha: 0.9),
            colorText: Colors.white);
        _ctrl.errorMessage.value = null;
      }
    });

    _successWorker = ever(_ctrl.successMessage, (msg) {
      if (msg != null && mounted) {
        Get.snackbar('✓', msg,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withValues(alpha: 0.9),
            colorText: Colors.white,
            duration: const Duration(seconds: 2));
        _ctrl.successMessage.value = null;
      }
    });
  }

  @override
  void dispose() {
    _errorWorker?.dispose();
    _successWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bildirimler', style: TextStyle(fontSize: 20.sp)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_outlined, size: 22.sp),
            tooltip: 'Yenile',
            onPressed: _ctrl.loadPendingRequests,
          ),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_ctrl.pendingRequests.isEmpty) {
          return _EmptyState();
        }

        return RefreshIndicator(
          onRefresh: _ctrl.loadPendingRequests,
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            children: [
              // Bölüm başlığı
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                child: Text(
                  'TAKİP İSTEKLERİ (${_ctrl.pendingRequests.length})',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              ..._ctrl.pendingRequests.map(
                (req) => _FollowRequestTile(
                  request: req,
                  onAccept: () => _ctrl.acceptRequest(req),
                  onReject: () => _showRejectConfirm(context, req),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showRejectConfirm(BuildContext context, FollowModel req) {
    final name = req.followerUsername ?? 'Bu kullanıcı';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('İsteği Reddet'),
        content: Text('$name adlı kullanıcının takip isteğini reddetmek istiyor musun?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Vazgeç',
                style: TextStyle(color: AppTheme.textSec(context))),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ctrl.rejectRequest(req);
            },
            child: const Text('Reddet',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─── Takip İsteği Tile ────────────────────────────────────────────────────────

class _FollowRequestTile extends StatelessWidget {
  final FollowModel request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _FollowRequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final username  = request.followerUsername ?? 'Bilinmeyen';
    final avatarUrl = request.followerAvatarUrl;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: () => Get.toNamed(
              AppRoutes.profile,
              arguments: {'userId': request.followerId},
            ),
            child: CircleAvatar(
              radius: 24.r,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl) : null,
              child: avatarUrl == null
                  ? Text(
                      username.isNotEmpty
                          ? username[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
          ),
          SizedBox(width: 12.w),

          // Bilgi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(
                    AppRoutes.profile,
                    arguments: {'userId': request.followerId},
                  ),
                  child: Text(
                    username,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Seni takip etmek istiyor',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _timeAgo(request.createdAt),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),

          // Butonlar
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Onayla
              SizedBox(
                width: 88.w,
                height: 34.h,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('Onayla',
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 6.h),
              // Reddet
              SizedBox(
                width: 88.w,
                height: 34.h,
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 0.8),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text('Reddet',
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours   < 24) return '${diff.inHours} sa önce';
    if (diff.inDays    < 7)  return '${diff.inDays} gün önce';
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}

// ─── Boş Durum ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64.sp, color: AppTheme.textSec(context)),
          SizedBox(height: 16.h),
          Text(
            'Yeni bildirim yok',
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Bekleyen takip isteği bulunmuyor.',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
