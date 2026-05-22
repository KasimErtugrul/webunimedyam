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

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerController _controller;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlayerController>();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_controller.isPlayerReady.value) {
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

      // YoutubePlayerScaffold fullscreen'i tamamen kendi yönetir.
      // Orientation, sistem UI, geri butonu — hepsi pakete ait.
      return YoutubePlayerScaffold(
        controller: _controller.youtubeController,
        aspectRatio: 16 / 9,
        autoFullScreen: true,
        builder: (context, player) {
          return Scaffold(
            backgroundColor: AppTheme.bg(context),
            body: Column(
              children: [
                // ── Video oynatıcı + geri butonu ──────────────────────────
                _buildPlayerWithBackButton(context, player),

                // ── Kaydırılabilir içerik ─────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Başlık
                        Text(
                          _controller.currentVideo?.title ?? '',
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // ── YouTube meta (görüntülenme · tarih · süre)
                        if (_controller.currentVideo != null)
                          YoutubeMetaWidget(
                            video: _controller.currentVideo!,
                          ),

                        // ── Üniversite bilgisi
                        if (_controller
                                .currentVideo
                                ?.universityName
                                ?.isNotEmpty ==
                            true) ...[
                          SizedBox(height: 10.h),
                          UniversityRowWidget(
                            universityName:
                                _controller.currentVideo!.universityName!,
                          ),
                        ],

                        SizedBox(height: 14.h),

                        // ── Aksiyon + Uygulama istatistikleri
                        EngagementBarWidget(controller: _controller),

                        SizedBox(height: 16.h),

                        // ── Açıklama
                        if (_controller
                                .currentVideo
                                ?.description
                                .isNotEmpty ==
                            true)
                          ExpandableDescriptionWidget(
                            text: _controller.currentVideo!.description,
                          ),

                        // ── Etiketler
                        if (_controller.currentVideo?.tags.isNotEmpty ==
                            true) ...[
                          SizedBox(height: 14.h),
                          TagsRowWidget(
                            tags: _controller.currentVideo!.tags,
                          ),
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
                            count: _controller.appCommentCount.value,
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // ── Yorum giriş
                        CommentInputWidget(
                          textController: _commentController,
                          onSend: () {
                            _controller.addComment(_commentController.text);
                            _commentController.clear();
                          },
                        ),

                        SizedBox(height: 16.h),

                        // ── Yorum listesi
                        Obx(() {
                          if (_controller.isCommentsLoading.value) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.h),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  strokeWidth: 2.w,
                                ),
                              ),
                            );
                          }
                          if (_controller.comments.isEmpty) {
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
                            itemCount: _controller.comments.length,
                            separatorBuilder: (_, _) => Divider(
                              color: AppTheme.surface(context),
                              height: 1.h,
                              thickness: 1.h,
                            ),
                            itemBuilder: (context, index) =>
                                CommentTileWidget(
                                  comment: _controller.comments[index],
                                  onDelete: () => _controller.deleteComment(
                                    _controller.comments[index].id,
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
          );
        },
      );
    });
  }

  /// Player üzerine geri butonu koyar.
  /// YoutubePlayerScaffold fullscreen'e girince zaten tüm ekranı kaplar,
  /// bu widget sadece normal (portrait) modda görünür.
  Widget _buildPlayerWithBackButton(BuildContext context, Widget player) {
    return Stack(
      children: [
        player,
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
    );
  }
}