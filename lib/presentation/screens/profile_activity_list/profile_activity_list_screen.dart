// lib/presentation/screens/profile_activity_list/profile_activity_list_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/profile_activity_list_controller.dart';

class ProfileActivityListScreen extends StatefulWidget {
  const ProfileActivityListScreen({super.key});

  @override
  State<ProfileActivityListScreen> createState() =>
      _ProfileActivityListScreenState();
}

class _ProfileActivityListScreenState extends State<ProfileActivityListScreen> {
  late final ProfileActivityListController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileActivityListController>();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
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
      appBar: AppBar(
        title: Text(
          controller.pageTitle,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
              strokeWidth: 3.w,
            ),
          );
        }

        if (controller.videos.isEmpty) {
          return _EmptyView(
            emptyText: controller.emptyText,
            emptySubtext: controller.emptySubtext,
            activityType: controller.activityType,
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.loadInitial,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            itemCount:
                controller.videos.length + (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.videos.length) {
                return _LoadMoreIndicator();
              }
              return _VideoCard(video: controller.videos[index]);
            },
          ),
        );
      }),
    );
  }
}

// ─── Video Kartı ────────────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                bottomLeft: Radius.circular(14.r),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: 118.w,
                    height: 72.h,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 118.w,
                      height: 72.h,
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 118.w,
                      height: 72.h,
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: 28.sp,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 5.h,
                      right: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 5.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bilgiler
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 4.h),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
    if (diff.inDays > 0) return '${diff.inDays} gün önce';
    if (diff.inHours > 0) return '${diff.inHours} saat önce';
    return '${diff.inMinutes} dakika önce';
  }
}

// ─── Boş Durum ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String emptyText;
  final String emptySubtext;
  final ProfileActivityType activityType;

  const _EmptyView({
    required this.emptyText,
    required this.emptySubtext,
    required this.activityType,
  });

  IconData get _icon {
    switch (activityType) {
      case ProfileActivityType.favorites:
        return Icons.favorite_outline_rounded;
      case ProfileActivityType.viewed:
        return Icons.play_circle_outline_rounded;
      case ProfileActivityType.commented:
        return Icons.chat_bubble_outline_rounded;
      case ProfileActivityType.shared:
        return Icons.share_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: AppTheme.textSec(context),
              size: 56.sp,
            ),
            SizedBox(height: 16.h),
            Text(
              emptyText,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              emptySubtext,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daha Fazla Yükle Göstergesi ────────────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2.5.w,
        ),
      ),
    );
  }
}
