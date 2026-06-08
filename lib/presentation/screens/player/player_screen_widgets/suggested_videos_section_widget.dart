// lib/presentation/screens/player/player_screen_widgets/suggested_videos_section_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/player_controller.dart';
import 'suggested_video_card_widget.dart';

class SuggestedVideosSectionWidget extends StatelessWidget {
  const SuggestedVideosSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();

    return Obx(() {
      // Yükleniyorsa shimmer satırı
      if (controller.isSuggestedLoading.value) {
        return _buildShimmer(context);
      }

      // Boşsa hiçbir şey gösterme
      if (controller.suggestedVideos.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık ────────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                Icon(
                  Icons.recommend_rounded,
                  size: 16.sp,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 6.w),
                Text(
                  'Önerilen Videolar',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ── Yatay ListView ────────────────────────────────────────────
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.suggestedVideos.length,
              itemBuilder: (_, i) => SuggestedVideoCard(
                video: controller.suggestedVideos[i],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık placeholder
        Container(
          width: 140.w,
          height: 14.h,
          decoration: BoxDecoration(
            color: AppTheme.surface(context),
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 200.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (_, __) => Container(
              width: 160.w,
              margin: EdgeInsets.only(right: 12.w),
              decoration: BoxDecoration(
                color: AppTheme.surface(context),
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}