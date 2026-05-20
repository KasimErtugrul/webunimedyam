import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import 'highlight_text_widget.dart';

// ── Video sonuç kartı ─────────────────────────────────────────────────────────

class VideoResultCardWidget extends StatelessWidget {
  final VideoModel video;
  final String query;
  final VoidCallback onTap;

  const VideoResultCardWidget({
    super.key,
    required this.video,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                bottomLeft: Radius.circular(12.r),
              ),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl,
                width: 120.w,
                height: 80.h,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => Container(
                  width: 120.w,
                  height: 80.h,
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: 32.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightTextWidget(
                      text: video.title,
                      highlight: query,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 4.h),
                    if (video.universityName != null)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 2.h),
                    Text(
                      video.formattedViewCount,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }
}