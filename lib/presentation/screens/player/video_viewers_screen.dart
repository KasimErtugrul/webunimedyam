// lib/presentation/screens/player/video_viewers_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_viewer_model.dart';
import '../../controllers/video_viewers_controller.dart';

class VideoViewersScreen extends StatefulWidget {
  const VideoViewersScreen({super.key});

  @override
  State<VideoViewersScreen> createState() => _VideoViewersScreenState();
}

class _VideoViewersScreenState extends State<VideoViewersScreen> {
  late final VideoViewersController _ctrl;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _ctrl = Get.put(
      VideoViewersController(
        engagementRepository: Get.find(),
        videoId: args['videoId'] as String? ?? '',
        totalViewCount: args['totalViewCount'] as int? ?? 0,
      ),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _ctrl.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İzleyenler',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_ctrl.isLoading.value)
                Text(
                  '${_ctrl.totalViewCount} görüntülenme',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPri(context)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_ctrl.viewers.isEmpty && _ctrl.hiddenCount.value == 0) {
          return _EmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          itemCount:
              _ctrl.viewers.length +
              (_ctrl.hiddenCount.value > 0 ? 1 : 0) +
              (_ctrl.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Gizli kullanıcılar satırı — en sona ekle
            if (index == _ctrl.viewers.length &&
                _ctrl.hiddenCount.value > 0 &&
                !_ctrl.isLoadingMore.value) {
              return _HiddenViewersRow(count: _ctrl.hiddenCount.value);
            }

            // Loading more spinner
            if (_ctrl.isLoadingMore.value &&
                index == _ctrl.viewers.length + (_ctrl.hiddenCount.value > 0 ? 1 : 0)) {
              return Padding(
                padding: EdgeInsets.all(16.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            final viewer = _ctrl.viewers[index];
            return _ViewerTile(viewer: viewer);
          },
        );
      }),
    );
  }
}

class _ViewerTile extends StatelessWidget {
  final VideoViewerModel viewer;
  const _ViewerTile({required this.viewer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.toNamed(
        AppRoutes.profile,
        arguments: {'userId': viewer.userId},
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 22.r,
        backgroundColor: AppTheme.surface(context),
        backgroundImage: viewer.avatarUrl != null
            ? NetworkImage(viewer.avatarUrl!)
            : null,
        child: viewer.avatarUrl == null
            ? Icon(Icons.person, color: AppTheme.textSec(context), size: 20.sp)
            : null,
      ),
      title: Text(
        viewer.displayName,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: viewer.username != null
          ? Text(
              '@${viewer.username}',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 12.sp,
              ),
            )
          : null,
      trailing: Text(
        _timeAgo(viewer.viewedAt),
        style: TextStyle(color: AppTheme.textSec(context), fontSize: 11.sp),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
    if (diff.inHours < 24) return '${diff.inHours}s önce';
    if (diff.inDays < 7) return '${diff.inDays}g önce';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}hf önce';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}ay önce';
    return '${(diff.inDays / 365).floor()}y önce';
  }
}

class _HiddenViewersRow extends StatelessWidget {
  final int count;
  const _HiddenViewersRow({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.visibility_off_outlined,
              color: AppTheme.textSec(context), size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            '$count kişi profilini gizli tuttuğu için gösterilmiyor.',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_outlined,
              size: 48.sp, color: AppTheme.textSec(context)),
          SizedBox(height: 12.h),
          Text(
            'Henüz kimse izlemedi',
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