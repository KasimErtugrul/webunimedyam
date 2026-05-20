// ═══════════════════════════════════════════════════════════════════════════
// Aktivite sekmesi
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../data/models/video_model.dart';
import 'activity_video_card_widget.dart';

class VideoActivityTabWidget extends StatelessWidget {
  final RxList<VideoModel> videos;
  final RxBool isLoading;
  final IconData emptyIcon;
  final String emptyText;
  final String emptySubtext;
  final Future<void> Function() onRefresh;

  const VideoActivityTabWidget({
    super.key,
    required this.videos,
    required this.isLoading,
    required this.emptyIcon,
    required this.emptyText,
    required this.emptySubtext,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryColor,
            strokeWidth: 3.w,
          ),
        );
      }

      if (videos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                emptyIcon,
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
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          itemCount: videos.length,
          itemBuilder: (context, index) => ActivityVideoCardWidget(video: videos[index]),
        ),
      );
    });
  }
}