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

  // GetX Workers (Dinleyiciler) - Memory leak olmaması için dispose edilmeli
  Worker? _authWorker;
  Worker? _snackbarWorker;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlayerController>();
    _commentController = TextEditingController();

    // ── Controller'daki UI Bayraklarını Dinle ──────────────────────────────

    // 1. Giriş yapılması gerektiğinde Dialog aç
    _authWorker = ever(_controller.showAuthRequired, (required) {
      if (required) {
        _showAuthDialog();
        // Bayrağı hemen sıfırla ki bir daha tetiklenmesin
        _controller.showAuthRequired.value = false;
      }
    });

    // 2. Snackbar mesajı geldiğinde göster
    _snackbarWorker = ever(_controller.snackbarMessage, (message) {
      if (message != null) {
        Get.snackbar(
          'Bilgi',
          message,
          backgroundColor: const Color(0xFF1E1E2E),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        // Mesajı sıfırla
        _controller.snackbarMessage.value = null;
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    // Dinleyicileri temizle
    _authWorker?.dispose();
    _snackbarWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold artık Obx dışında — yalnızca bir kez build edilir.
    // Obx yalnızca body içeriğini sarar; sadece o alan rebuild olur.
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
       /*  backgroundColor: AppTheme.bg(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textPri(context),
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ), */
      ),
      body: Obx(() {
        if (!_controller.isPlayerReady.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3.w,
            ),
          );
        }
        return _buildContent(context);
      }),
    );
  }

  // ── Ana içerik (video + bilgi + yorumlar) ─────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        // ── Video oynatıcı + geri butonu ──────────────────────────
        _buildPlayerWithBackButton(
          context,
          YoutubePlayer(
            controller: _controller.youtubeController!,
            aspectRatio: 16 / 9,
          ),
        ),

        // ── Kaydırılabilir içerik ─────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Başlık
                Obx(() {
                  return Text(
                    _controller.currentVideo.value?.title ?? '',
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  );
                }),

                SizedBox(height: 6.h),

                // ── YouTube meta (görüntülenme · tarih · süre)
                Obx(() {
                  if (_controller.currentVideo.value != null) {
                    return YoutubeMetaWidget(
                      video: _controller.currentVideo.value!,
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // ── Üniversite bilgisi
                Obx(() {
                  if (_controller
                          .currentVideo
                          .value
                          ?.universityName
                          ?.isNotEmpty ==
                      true) {
                    return Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: UniversityRowWidget(
                        universityName:
                            _controller.currentVideo.value!.universityName!,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: 14.h),

                // ── Aksiyon + Uygulama istatistikleri
                EngagementBarWidget(controller: _controller),

                SizedBox(height: 16.h),

                // ── Açıklama
                Obx(() {
                  if (_controller.currentVideo.value?.description.isNotEmpty ==
                      true) {
                    return ExpandableDescriptionWidget(
                      text: _controller.currentVideo.value!.description,
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // ── Etiketler
                Obx(() {
                  if (_controller.currentVideo.value?.tags.isNotEmpty == true) {
                    return Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: TagsRowWidget(
                        tags: _controller.currentVideo.value!.tags,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                SizedBox(height: 20.h),
                Divider(
                  color: AppTheme.surface(context),
                  height: 1.h,
                  thickness: 1.h,
                ),
                SizedBox(height: 16.h),

                // ── Yorumlar başlık
                Obx(() {
                  return CommentsHeaderWidget(
                    count: _controller.appCommentCount.value,
                  );
                }),

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
                          color: Theme.of(context).colorScheme.primary,
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
                    separatorBuilder: (_, __) => Divider(
                      color: AppTheme.surface(context),
                      height: 1.h,
                      thickness: 1.h,
                    ),
                    itemBuilder: (context, index) {
                      return CommentTileWidget(
                        comment: _controller.comments[index],
                        canDelete:
                            _controller.comments[index].userId ==
                            _controller.currentUserId,
                        onDelete: () => _controller.deleteComment(
                          _controller.comments[index].id,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Player üzerine geri butonu koyar.
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

  // ── Auth Dialog (Artık UI katmanında yaşıyor!) ──────────────────────────
  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
          style: TextStyle(color: Color(0xFF9E9EB8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF9E9EB8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}
