// lib/presentation/screens/home/widgets/tabs/home_tab/videos/video_horizontal_section_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../../app/routes/app_routes.dart';
import '../../../../../../../app/themes/app_theme.dart';
import '../../../../../../../data/models/video_engagement_model.dart';
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                config.title,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
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
