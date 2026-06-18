// lib/presentation/screens/home/widgets/tabs/home_tab/videos/video_horizontal_section_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/video_engagement_model.dart';
import 'video_horizontal_card_widget.dart';
import 'video_sections_config.dart';

class VideoHorizontalSection extends StatelessWidget {
  final VideoSectionConfig config;
  final List<VideoEngagementModel> items;
  final bool isLoading;

  const VideoHorizontalSection({
    super.key,
    required this.config,
    required this.items,
    required this.isLoading,
  });

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          config.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPri(context),
          ),
        ),
        content: Text(
          config.description,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.textSec(context),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Anladım',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Yüklenme bitmişse ve boşsa hiç yer kaplamaz
    if (!isLoading && items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Başlık Satırı ────────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 8.w, 10.h),
          child: Row(
            children: [
              // Başlık metni
              Expanded(
                child: Text(
                  config.title,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ℹ️ Bilgi butonu
              IconButton(
                onPressed: () => _showInfoDialog(context),
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 18.sp,
                  color: AppTheme.textSec(context),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                constraints: const BoxConstraints(),
                splashRadius: 20,
                tooltip: 'Bu liste hakkında',
              ),
              // "Tümünü Gör" her zaman gösterilir
              TextButton(
                onPressed: () => Get.toNamed(
                  AppRoutes.videoSectionDetail,
                  arguments: {'type': config.type, 'title': config.title},
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Tümünü Gör',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Yatay Liste ──────────────────────────────────────────────────
        SizedBox(
          height: 220.h,
          child: isLoading
              ? _buildShimmer(context)
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return VideoHorizontalCard(
                      video: items[index],
                      statLabelBuilder: config.statLabelBuilder,
                      statIcon: config.statIcon,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface(context),
      highlightColor: AppTheme.card(context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 5,
        itemBuilder: (_, _) => Container(
          width: 160.w,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}
