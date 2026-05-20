import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/player_controller.dart';
import 'player_screen_widgets/comment_header_widget.dart';
import 'player_screen_widgets/comment_input_widget.dart';
import 'player_screen_widgets/comment_tile_widget.dart';
import 'player_screen_widgets/engagement_bar/engagement_bar_widget.dart';
import 'player_screen_widgets/expandable_description_widget.dart';
import 'player_screen_widgets/tag_row_widget.dart';
import 'player_screen_widgets/youtube_meta_widget.dart';
import 'player_screen_widgets/university_row_widget.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlayerController>();
    final commentController = TextEditingController();

    return Obx(() {
      if (!controller.isPlayerReady.value) {
        return Scaffold(
          backgroundColor: AppTheme.bg(context),
          body: Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3.w,
            ),
          ),
        );
      }

      // youtube_player_iframe fullscreen'ı kendi yönetir:
      // • Tam ekran butonuna basılırsa → otomatik geçiş
      // • Cihaz yatay dönerse → autoFullScreen ile geçiş
      // • Geri tuşu / sistem jesti → fullscreenden çıkış
      // Bu yüzden PopScope'a gerek yok; varsayılan geri navigasyonu yeterli.

      return YoutubePlayerControllerProvider(
        controller: controller.youtubeController,
        child: Scaffold(
          backgroundColor: AppTheme.bg(context),
          appBar: AppBar(
            title: Text(
              controller.currentVideo?.channelTitle ?? '',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: Column(
              children: [
                // ── Video oynatıcı
                Stack(
                  children: [
                    YoutubePlayer(
                      controller: controller.youtubeController,
                      aspectRatio: 16 / 9,
                      autoFullScreen: true,
                    ),
                    Positioned(
                      top: 8.h,
                      left: 4.w,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20.r),
                          onTap: () => Get.back(),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ── İçerik
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Başlık
                        Text(
                          controller.currentVideo?.title ?? '',
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // ── YouTube meta (görüntülenme · tarih · süre)
                        if (controller.currentVideo != null)
                          YoutubeMetaWidget(video: controller.currentVideo!),

                        // ── Üniversite bilgisi
                        if (controller.currentVideo?.universityName?.isNotEmpty == true) ...[
                          SizedBox(height: 10.h),
                          UniversityRowWidget(
                            universityName: controller.currentVideo!.universityName!,
                          ),
                        ],

                        SizedBox(height: 14.h),

                        // ── Aksiyon + Uygulama istatistikleri tek satır
                        EngagementBarWidget(controller: controller),

                        SizedBox(height: 16.h),

                        // ── Açıklama
                        if (controller.currentVideo?.description.isNotEmpty == true)
                          ExpandableDescriptionWidget(
                            text: controller.currentVideo!.description,
                          ),

                        // ── Etiketler
                        if (controller.currentVideo?.tags.isNotEmpty == true) ...[
                          SizedBox(height: 14.h),
                          TagsRowWidget(tags: controller.currentVideo!.tags),
                        ],

                        SizedBox(height: 20.h),
                        Divider(
                          color: AppTheme.surface(context),
                          height: 1.h,
                          thickness: 1.h,
                        ),
                        SizedBox(height: 16.h),

                        // ── Yorumlar başlık
                        Obx(
                          () => CommentsHeaderWidget(
                            count: controller.appCommentCount.value,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // ── Yorum giriş
                        CommentInputWidget(
                          textController: commentController,
                          onSend: () {
                            controller.addComment(commentController.text);
                            commentController.clear();
                          },
                        ),

                        SizedBox(height: 16.h),

                        // ── Yorum listesi
                        Obx(() {
                          if (controller.isCommentsLoading.value) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                  strokeWidth: 2.w,
                                ),
                              ),
                            );
                          }
                          if (controller.comments.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: Text(
                                  'Henüz yorum yok. İlk yorumu sen yap!',
                                  style: TextStyle(
                                    color: AppTheme.textSec(context),
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.comments.length,
                            separatorBuilder: (_, __) => Divider(
                              color: AppTheme.surface(context),
                              height: 1.h,
                              thickness: 1.h,
                            ),
                            itemBuilder: (context, index) => CommentTileWidget(
                              comment: controller.comments[index],
                              onDelete: () => controller.deleteComment(
                                controller.comments[index].id,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}