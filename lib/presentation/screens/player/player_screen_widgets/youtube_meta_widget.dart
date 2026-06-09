// ═══════════════════════════════════════════════════════════════════════════
// YouTube istatistik satırı — ayrı bir bölüm olarak gösterilir
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';

class YoutubeMetaWidget extends StatelessWidget {
  final VideoModel video;
  const YoutubeMetaWidget({super.key, required this.video});

  String _fmtCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Divider + Başlık ──────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.surface(context),
                thickness: 1.h,
                height: 1.h,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: 13.sp,
                    color: AppTheme.textSec(context).withValues(alpha: 0.6),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'YouTube İstatistikleri',
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.6),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.surface(context),
                thickness: 1.h,
                height: 1.h,
              ),
            ),
          ],
        ),

        SizedBox(height: 10.h),

        // ── YouTube Verileri ──────────────────────────────────────────────
        Row(
          children: [
            // Görüntülenme
            if (video.viewCount > 0) ...[
              Icon(
                Icons.visibility_outlined,
                size: 14.sp,
                color: AppTheme.textSec(context).withValues(alpha: 0.7),
              ),
              SizedBox(width: 4.w),
              Text(
                '${_fmtCount(video.viewCount)} görüntülenme',
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.7),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 12.w),
            ],

            // Beğeni
            if (video.likeCount > 0) ...[
              Icon(
                Icons.thumb_up_off_alt_rounded,
                size: 14.sp,
                color: AppTheme.textSec(context).withValues(alpha: 0.7),
              ),
              SizedBox(width: 4.w),
              Text(
                _fmtCount(video.likeCount),
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.7),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(width: 12.w),
            ],

            const Spacer(),

            // Tarih + Süre
            Text(
              [
                if (video.formattedDuration.isNotEmpty) video.formattedDuration,
                _fmtDate(video.publishedAt),
              ].join('  ·  '),
              style: TextStyle(
                color: AppTheme.textSec(context).withValues(alpha: 0.7),
                fontSize: 12.sp,
              ),
            ),

            // HD Etiketi
            if (video.isHd) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.textSec(context).withValues(alpha: 0.35),
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  'HD',
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.7),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5.w,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
