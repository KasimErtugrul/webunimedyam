import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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

class _PlayerScreenState extends State<PlayerScreen>
    with WidgetsBindingObserver {
  late final PlayerController _controller;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = Get.find<PlayerController>();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _commentController.dispose();
    // Ekrandan çıkarken sistem UI'ını garantiye al
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  /// Uygulama foreground/background geçişlerinde sistem UI'ını koru.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller.isFullscreen.value) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
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

      // Fullscreen modunda AppBar'ı gizle, Scaffold'u siyah yap
      final bool isFs = _controller.isFullscreen.value;

      return PopScope(
        // Fullscreen'deyken geri tuşu tam ekrandan çıksın, uygulamadan değil
        canPop: !isFs,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && isFs) {
            _controller.youtubeController.toggleFullScreenMode();
          }
        },
        child: Scaffold(
          backgroundColor: isFs ? Colors.black : AppTheme.bg(context),
          // Fullscreen'de AppBar gizlenir
          /*  appBar: isFs
              ? null
              : AppBar(
                  title: Text(
                    _controller.currentVideo?.channelTitle ?? '',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ), */
          // Fullscreen'de SafeArea kapatılır (sistem çubuklarını gizledik)
          body: SafeArea(
            top: !isFs,
            bottom: !isFs,
            left: !isFs,
            right: !isFs,
            child: Column(
              children: [
                // ── Video oynatıcı ──────────────────────────────────────────
                // youtube_player_flutter fullscreen modunda kendi boyutunu
                // alır; normal modda 16:9 AspectRatio kullanıyoruz.
                isFs
                    ? Expanded(
                        child: YoutubePlayer(
                          controller: _controller.youtubeController,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          progressColors: ProgressBarColors(
                            playedColor: Theme.of(context).colorScheme.primary,
                            handleColor: Theme.of(context).colorScheme.primary,
                          ),
                          onReady: () {
                            _controller.youtubeController.addListener(() {});
                          },
                        ),
                      )
                    : _buildNormalPlayer(context),

                // ── İçerik (fullscreen'de gizlenir) ───────────────────────
                if (!isFs)
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
                            YoutubeMetaWidget(video: _controller.currentVideo!),

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
                            TagsRowWidget(tags: _controller.currentVideo!.tags),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
          ),
        ),
      );
    });
  }

  /// Normal (dikey) modda 16:9 AspectRatio içinde oynatıcı + geri butonu
  Widget _buildNormalPlayer(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller.youtubeController,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Theme.of(context).colorScheme.primary,
            progressColors: ProgressBarColors(
              playedColor: Theme.of(context).colorScheme.primary,
              handleColor: Theme.of(context).colorScheme.primary,
            ),
            onReady: () {
              // Oynatıcı hazır — ek işlem gerekmiyorsa boş bırakılabilir
            },
          ),
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
    );
  }
}
