import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/video_model.dart';
import '../../../controllers/favorites_controller.dart';

class FavoriteCardWidget extends StatelessWidget {
  final VideoModel video;

  const FavoriteCardWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Dismissible(
      key: Key(video.videoId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(
          Icons.delete_rounded,
          color: Colors.white,
          size: 24.sp,
        ),
      ),
      onDismissed: (_) => controller.removeFavorite(video.videoId),
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.player, arguments: video),
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
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
                  errorWidget: (_, __, ___) => Container(
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
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: TextStyle(
                          color: AppTheme.textPri(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${video.viewCount} görüntülenme',
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
      ),
    );
  }
}