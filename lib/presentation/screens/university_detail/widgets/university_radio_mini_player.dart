// lib/presentation/screens/university_detail/widgets/university_radio_mini_player.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/university_radio_controller.dart';
import '../university_detail_layout_spec.dart';

class UniversityRadioMiniPlayer extends StatelessWidget {
  final UniversityDetailLayoutSpec spec;
  final UniversityRadioController radioController;

  const UniversityRadioMiniPlayer({
    super.key,
    required this.spec,
    required this.radioController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!radioController.isRadioActive) return const SizedBox.shrink();

      final meta = radioController.metadata.value;
      final title =
          meta?.title ?? radioController.currentPlayingName.value ?? 'Yayın';
      final artist = meta?.artist ?? 'Canlı Yayın';

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spec.miniPaddingH.w,
              vertical: spec.miniPaddingV.h,
            ),
            child: Row(
              children: [
                // Logo
                Container(
                  width: spec.miniLogoSize.w,
                  height: spec.miniLogoSize.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(spec.miniLogoRadius.r),
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.15),
                        AppTheme.primaryColor.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: radioController.currentPlayingLogo.value != null
                      ? CachedNetworkImage(
                          imageUrl: radioController.currentPlayingLogo.value!,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.radio_rounded,
                          color: AppTheme.primaryColor,
                          size: spec.miniLogoSize.w * 0.55,
                        ),
                ),
                SizedBox(width: 12.w),
                // Başlık
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: spec.miniTitleFontSize.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            child: Text(
                              artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: spec.miniSubtitleFontSize.sp,
                                color: AppTheme.textSec(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (radioController.isBuffering)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  )
                else ...[
                  IconButton(
                    icon: Icon(
                      radioController.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppTheme.primaryColor,
                      size: spec.miniPlayIconSize.sp,
                    ),
                    onPressed: () => radioController.togglePlayPause(
                      url: radioController.currentPlayingUrl.value!,
                      name: radioController.currentPlayingName.value!,
                      logoUrl: radioController.currentPlayingLogo.value,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.stop_circle_outlined,
                      color: AppTheme.textSec(context),
                      size: spec.miniStopIconSize.sp,
                    ),
                    onPressed: radioController.stopRadio,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}