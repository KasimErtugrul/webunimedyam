// ═══════════════════════════════════════════════════════════════════════════
// Ana profil görünümü
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../controllers/profile_controller.dart';
import 'activity_video_tab/video_activity_tab_widget.dart';
import 'profile_header/profile_header_widget.dart';

class ProfileViewWidget extends StatelessWidget {
  final ProfileController controller;
  const ProfileViewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 250.h,
              pinned: true,
              floating: false,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPri(context),
                    size: 24.sp,
                  ),
                  tooltip: 'Ayarlar',
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textPri(context),
                    size: 24.sp,
                  ),
                  tooltip: 'Profili Düzenle',
                  onPressed: () => _showEditProfileDialog(context, controller),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: ProfileHeaderWidget(controller: controller),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(48.h),
                child: Container(
                  color: AppTheme.bg(context),
                  child: TabBar(
                    isScrollable: false,
                    indicatorColor: AppTheme.primaryColor,
                    indicatorWeight: 2.5.w,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSec(context),
                    labelStyle: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.favorite_rounded, size: 18.sp),
                        text: 'Favoriler',
                      ),
                      Tab(
                        icon: Icon(Icons.play_circle_rounded, size: 18.sp),
                        text: 'İzlenenler',
                      ),
                      Tab(
                        icon: Icon(Icons.chat_bubble_rounded, size: 18.sp),
                        text: 'Yorumlar',
                      ),
                      Tab(
                        icon: Icon(Icons.share_rounded, size: 18.sp),
                        text: 'Paylaşılan',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              VideoActivityTabWidget(
                videos: controller.favoriteVideos,
                isLoading: controller.isFavoritesLoading,
                emptyIcon: Icons.favorite_outline_rounded,
                emptyText: 'Henüz favori eklemedin',
                emptySubtext: 'Beğendiğin videoları favorilere ekle',
                onRefresh: () => controller.loadFavorites(),
              ),
              VideoActivityTabWidget(
                videos: controller.viewedVideos,
                isLoading: controller.isViewedLoading,
                emptyIcon: Icons.play_circle_outline_rounded,
                emptyText: 'Henüz video izlemedin',
                emptySubtext: 'İzlediğin videolar burada görünür',
                onRefresh: () => controller.loadViewedVideos(),
              ),
              VideoActivityTabWidget(
                videos: controller.commentedVideos,
                isLoading: controller.isCommentedLoading,
                emptyIcon: Icons.chat_bubble_outline_rounded,
                emptyText: 'Henüz yorum yapmadın',
                emptySubtext: 'Yorum yaptığın videolar burada görünür',
                onRefresh: () => controller.loadCommentedVideos(),
              ),
              VideoActivityTabWidget(
                videos: controller.sharedVideos,
                isLoading: controller.isSharedLoading,
                emptyIcon: Icons.share_outlined,
                emptyText: 'Henüz paylaşım yapmadın',
                emptySubtext: 'Paylaştığın videolar burada görünür',
                onRefresh: () => controller.loadSharedVideos(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    ProfileController controller,
  ) {
    final usernameCtrl = TextEditingController(
      text: controller.profile.value?.username ?? '',
    );
    final fullNameCtrl = TextEditingController(
      text: controller.profile.value?.fullName ?? '',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Profili Düzenle',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 20.sp,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                labelStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: AppTheme.textSec(context),
                  size: 20.sp,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: fullNameCtrl,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
              ),
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                labelStyle: TextStyle(fontSize: 14.sp),
                prefixIcon: Icon(
                  Icons.badge_outlined,
                  color: AppTheme.textSec(context),
                  size: 20.sp,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'İptal',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(80.w, 40.h),
            ),
            onPressed: () async {
              Get.back();
              await controller.updateProfile(
                username: usernameCtrl.text.trim(),
                fullName: fullNameCtrl.text.trim(),
              );
              if (controller.successMessage.value != null) {
                Get.snackbar('Başarılı', controller.successMessage.value!);
                controller.successMessage.value = null;
              } else if (controller.errorMessage.value != null) {
                Get.snackbar('Hata', controller.errorMessage.value!);
                controller.errorMessage.value = null;
              }
            },
            child: Text(
              'Kaydet',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}