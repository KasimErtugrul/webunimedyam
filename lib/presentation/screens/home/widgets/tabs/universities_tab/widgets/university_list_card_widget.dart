// ── Liste kartı ──────────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../../app/routes/app_routes.dart';
import '../../../../../../../app/themes/app_theme.dart';
import '../../../../../../../data/models/playlist_model.dart';

class UniversityListCardWidget extends StatelessWidget {
  final PlaylistModel playlist;
  const UniversityListCardWidget({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final hasLogo = playlist.logoUrl != null && playlist.logoUrl!.isNotEmpty;
    final hasThumbnail = playlist.thumbnailUrl.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Card(
        color: AppTheme.card(context),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: AppTheme.isDark(context)
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              Get.toNamed(AppRoutes.playlistDetail, arguments: playlist),
          splashColor: AppTheme.primaryColor.withValues(alpha: 0.08),
          highlightColor: AppTheme.primaryColor.withValues(alpha: 0.04),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // ── Logo ─────────────────────────────────────────────────
                Container(
                  width: 56.w,
                  height: 56.w,
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.1),
                        AppTheme.secondaryColor.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: hasLogo
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: playlist.logoUrl!,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Center(
                        child: SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.school_rounded,
                        color: AppTheme.primaryColor,
                        size: 24.sp,
                      ),
                    ),
                  )
                      : Icon(
                    Icons.school_rounded,
                    color: AppTheme.primaryColor,
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 14.w),

                // ── Ad + video sayısı ─────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.title,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color:
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppTheme.primaryColor,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${playlist.itemCount} video',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 12.w),

                // ── Thumbnail önizleme veya İkon ──────────────────────────
                if (hasThumbnail)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CachedNetworkImage(
                          imageUrl: playlist.thumbnailUrl,
                          width: 68.w,
                          height: 52.w,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 68.w,
                            height: 52.w,
                            color: AppTheme.surface(context),
                            child: Icon(
                              Icons.image_outlined,
                              color: AppTheme.textSec(context),
                              size: 20.sp,
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 68.w,
                            height: 52.w,
                            color: AppTheme.surface(context),
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppTheme.textSec(context),
                              size: 20.sp,
                            ),
                          ),
                        ),
                        // Hafif karartma katmanı
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                        // Play ikonu
                        Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 22.sp,
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppTheme.surface(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textSec(context),
                      size: 14.sp,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}