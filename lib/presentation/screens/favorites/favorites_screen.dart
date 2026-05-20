import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/favorites_controller.dart';
import 'widgets/favorite_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FavoritesController>();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        title: Text(
          'Favorilerim',
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3.w,
            ),
          );
        }

        if (controller.favoriteVideos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: 64.sp,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Henüz favori eklemediniz',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Beğendiğiniz videoları favorilere ekleyin',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.favoriteVideos.length,
          itemBuilder: (context, index) {
            return FavoriteCardWidget(video: controller.favoriteVideos[index]);
          },
        );
      }),
    );
  }
}