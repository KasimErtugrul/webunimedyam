import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';
import '../../../../player/player_screen_widgets/comment_input_widget.dart';

class VideoCardWidget extends StatefulWidget {
  final VideoModel video;

  const VideoCardWidget({super.key, required this.video});

  @override
  State<VideoCardWidget> createState() => _VideoCardWidgetState();
}

class _VideoCardWidgetState extends State<VideoCardWidget> {
  VideoModel get video => widget.video;

  void _navigateToUniversityDetail(HomeController controller) {
    final uni = controller.universities.firstWhereOrNull(
      (u) => u.id == video.universityId,
    );
    if (uni != null) {
      Get.toNamed(AppRoutes.universityDetail, arguments: uni);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ÜÇ NOKTA MENÜSÜ
  // ═══════════════════════════════════════════════════════════════════════════
  void _showVideoOptionsSheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppTheme.textSec(context).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 8.h),

              // ── Hızlı Yorum Gönder ──
              _optionTile(
                context: context,
                icon: Icons.bolt_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                label: 'Hızlı Yorum Gönder',
                subtitle: 'Videoyu açmadan yorum yap',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showQuickCommentSheet(context, controller);
                },
              ),

              // ── Yorumları Gör (Videoya Git) ──
              _optionTile(
                context: context,
                icon: Icons.mode_comment_outlined,
                label: 'Tüm Yorumları Gör',
                onTap: () {
                  Navigator.pop(sheetContext);
                  Get.toNamed(
                    AppRoutes.player,
                    arguments: video,
                    parameters: {'videoId': video.videoId},
                  );
                },
              ),

              // ── Favori ──
              Obx(() {
                final isFav = controller.favoriteIds.contains(video.videoId);
                return _optionTile(
                  context: context,
                  icon: isFav
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  label: isFav ? 'Favorilerden Çıkar' : 'Favorilere Ekle',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    controller.toggleFavorite(video.videoId);
                  },
                );
              }),

              // ── Paylaş ──
              _optionTile(
                context: context,
                icon: Icons.send_outlined,
                label: 'Paylaş',
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.shareVideo(video);
                },
              ),
              SizedBox(height: 6.h),
            ],
          ),
        );
      },
    );
  }

  Widget _optionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    String? subtitle,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22.sp,
              color: iconColor ?? AppTheme.textPri(context),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HIZLI YORUM COMPOSER — videoya girmeden anında yorum gönderme
  // ═══════════════════════════════════════════════════════════════════════════
  void _showQuickCommentSheet(BuildContext context, HomeController controller) {
    // final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Başlık kısmı aynı kalıyor ──
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 18.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          video.universityName ?? video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: AppTheme.textSec(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ── Güncellenmiş CommentInputWidget kullanımı ──
                  Obx(() {
                    final isSending = controller.quickCommentSendingIds
                        .contains(video.videoId);
                    return AbsorbPointer(
                      absorbing: isSending,
                      child: Opacity(
                        opacity: isSending ? 0.5 : 1,
                        child: CommentInputWidget(
                          // ✅ ARTIK CONTROLLER GEÇMİYORUZ
                          onSend: (String text) async {
                            // ✅ TEXT PARAMETRE OLARAK GELİYOR
                            final ok = await controller.sendQuickComment(
                              video,
                              text,
                            );
                            if (ok) {
                              // ❌ SIL: textController.clear();
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              Get.snackbar(
                                'Gönderildi 🎉',
                                'Yorumun videoya eklendi.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.card(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            _buildThumbnail(context, isLive, isUpcoming),
            _buildActionRow(context, controller),
            _buildContent(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Divider(
                height: 1,
                thickness: 0.6,
                color: AppTheme.textSec(context).withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADER — Sadece Üniversite Adı TextButton ile Tıklanabilir
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          // GRADYAN LOGO ÇERÇEVESİ (Artık tıklanamaz, düz görsel)
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.card(context),
              ),
              child: _buildAvatarInner(context, controller),
            ),
          ),

          SizedBox(width: 10.w),

          // ÜNİVERSİTE ADI (TEXTBUTTON) VE ZAMAN ALANI
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () => _navigateToUniversityDetail(controller),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    video.universityName ?? video.channelTitle,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  timeago.format(video.publishedAt, locale: 'tr'),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),

          // TAKİP ET BUTONU
          Obx(() {
            final isFav = controller.favoriteUniversityIds.contains(
              video.universityId,
            );
            return TextButton(
              onPressed: () {
                final uni = controller.universities.firstWhereOrNull(
                  (u) => u.id == video.universityId,
                );
                if (uni != null) controller.toggleUniversityFavorite(uni);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: isFav
                  ? Icon(
                      Icons.check_rounded,
                      size: 18.sp,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Text(
                      'Takip Et',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          }),

          // ÜÇ NOKTA MENÜ
          GestureDetector(
            onTap: () => _showVideoOptionsSheet(context, controller),
            child: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Icon(
                Icons.more_horiz_rounded,
                color: AppTheme.textPri(context),
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInner(BuildContext context, HomeController controller) {
    return Obx(() {
      final uni = controller.universities.firstWhereOrNull(
        (u) => u.id == video.universityId,
      );
      final logoUrl = uni?.logoUrl;
      final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

      return SizedBox(
        width: 34.w,
        height: 34.w,
        child: ClipOval(
          child: hasLogo
              ? CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      Container(color: AppTheme.surface(context)),
                  errorWidget: (_, _, _) => _avatarFallback(context),
                )
              : _avatarFallback(context),
        ),
      );
    });
  }

  Widget _avatarFallback(BuildContext context) {
    return Container(
      color: AppTheme.surface(context),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(context),
        size: 18.sp,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THUMBNAIL
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildThumbnail(BuildContext context, bool isLive, bool isUpcoming) {
    return GestureDetector(
      onTap: isUpcoming
          ? () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Yakında Yayında'),
                content: const Text(
                  'Bu yayın henüz başlamadı. Başladığında buradan izleyebilirsiniz.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tamam'),
                  ),
                ],
              ),
            )
          : () => Get.toNamed(
              AppRoutes.player,
              arguments: video,
              parameters: {'videoId': video.videoId},
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: video.bestThumbnail,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: AppTheme.surface(context),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 2.w,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppTheme.surface(context),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppTheme.textSec(context),
                      size: 48.sp,
                    ),
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: _liveBadge('CANLI', const Color(0xFFE53935)),
                  ),
                if (isUpcoming)
                  Positioned(
                    top: 10.h,
                    left: 10.w,
                    child: _liveBadge('YAKINDA', const Color(0xFF5C6BC0)),
                  ),
                if (!isLive)
                  Positioned(
                    bottom: 8.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTION ROW — Görüntülenme · Beğeni · Yorum · Paylaş | Favori
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActionRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          // ── Görüntülenme (buton yok) ──
          Obx(() {
            // BUG FIX: Önce global viewCountOverrides'a bak — bu video
            // HomeController.videos listesinde olmasa da (örn. üniversite
            // detay ekranından açılmışsa) PlayerController.onClose() burayı
            // güncelliyor. Bulunamazsa eski mantığa (liveVideo / statik
            // video.appViewCount) düş.
            final override = controller.viewCountOverrides[video.videoId];
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final viewCount =
                override ?? liveVideo?.appViewCount ?? video.appViewCount;
            return Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 20.sp,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    _formatCount(viewCount),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            );
          }),

          // ── Beğeni ──
          Obx(() {
            // likedVideoIds (RxList) → like durumu reactive
            // videos (RxList) → appLikeCount reactive: toggleLike anında
            // videos[idx] copyWith ile güncellendiği için sayaç anında değişir.
            final liked = controller.likedVideoIds.contains(video.videoId);
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final likeCount = liveVideo?.appLikeCount ?? video.appLikeCount;
            return _igActionBtn(
              context: context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              color: liked
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              count: likeCount,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            );
          }),

          // ── Yorum ──
          Obx(() {
            final hasCommented = controller.commentedVideoIds.contains(
              video.videoId,
            );
            final extra = controller.extraCommentCountFor(video.videoId);
            return _igActionBtn(
              context: context,
              icon: hasCommented
                  ? Icons.mode_comment_rounded
                  : Icons.mode_comment_outlined,
              color: hasCommented
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              count: video.appCommentCount + extra,
              isActive: hasCommented,
              onTap: () => Get.toNamed(
                AppRoutes.player,
                arguments: video,
                parameters: {'videoId': video.videoId},
              ),
            );
          }),

          // ── Paylaş ──
          Obx(() {
            final isLoading = controller.shareLoadingVideoIds.contains(
              video.videoId,
            );
            final hasShared = controller.sharedVideoIds.contains(video.videoId);
            if (isLoading) {
              return Padding(
                padding: EdgeInsets.all(8.w),
                child: SizedBox(
                  width: 20.sp,
                  height: 20.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textSec(context),
                  ),
                ),
              );
            }
            final liveVideoShare = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final shareCount =
                liveVideoShare?.appShareCount ?? video.appShareCount;
            return _igActionBtn(
              context: context,
              icon: hasShared ? Icons.send_rounded : Icons.send_outlined,
              color: hasShared
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              count: shareCount,
              isActive: hasShared,
              onTap: () => controller.shareVideo(video),
            );
          }),

          const Spacer(),

          // ── Favori ──
          Obx(() {
            final isFav = controller.favoriteIds.contains(video.videoId);
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final favCount =
                liveVideo?.appFavoriteCount ?? video.appFavoriteCount;
            return _igActionBtn(
              context: context,
              icon: isFav
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: isFav
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              count: favCount,
              isActive: isFav,
              onTap: () => controller.toggleFavorite(video.videoId),
            );
          }),
        ],
      ),
    );
  }

  Widget _igActionBtn({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int count = 0,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 17.sp),
              if (count > 0) ...[
                SizedBox(width: 3.w),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textSec(context),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT — Başlık · Açıklama
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (video.description.isNotEmpty) ...[
            SizedBox(height: 4.h),
            RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: video.description.replaceAll(RegExp(r'\n+'), ' '),
                  ),
                  TextSpan(
                    text: ' devamı',
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
    return count.toString();
  }

  Widget _liveBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 7.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
