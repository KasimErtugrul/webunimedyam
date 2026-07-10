// lib/presentation/screens/home/tabs/home_tab/widgets/wheel_video_card_widget.dart
//
// ═══════════════════════════════════════════════════════════════════════
// MEDIA-FIRST KART (v3 — üniversite adı + takip butonu kart içine döndü)
// ═══════════════════════════════════════════════════════════════════════
//   • Media Block -> thumbnail edge-to-edge. Sol üstte üniversite adı +
//                    hemen altında takip butonu (glass pill). Sağ üstte
//                    CANLI/YAKINDA rozeti + süre/HD. Altta başlık + zaman
//                    (gradient üzerinde, poster mantığı).
//   • Stats Row   -> düz, çerçevesiz, ikon + sayı.
//   • Description -> Expanded, kutu/çerçeve yok, sade tipografi.
// ═══════════════════════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';

class WheelVideoCardWidget extends StatelessWidget {
  final VideoModel video;
  final UniversityModel? university;

  const WheelVideoCardWidget({super.key, required this.video, this.university});

  static double get _mediaHeight => 196.h;
  static double get _statsHeight => 36.h;
  static double get _topGradientHeight => 68.h;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              AppTheme.isDark(context) ? 0.28 : 0.06,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _mediaHeight,
            child: _buildMedia(context, controller),
          ),
          SizedBox(
            height: _statsHeight,
            child: _buildStatsRow(context, controller),
          ),
          Expanded(child: _buildDescription(context)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // MEDIA — thumbnail edge-to-edge + gradient içinde uni/başlık/rozet
  // ════════════════════════════════════════════════════════════════
  Widget _buildMedia(BuildContext context, HomeController controller) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: isUpcoming
              ? () => _showUpcomingDialog(context)
              : () => Get.toNamed(
                  AppRoutes.player,
                  arguments: video,
                  parameters: {'videoId': video.videoId},
                ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: video.bestThumbnail,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppTheme.surface(context),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: 2.w,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: 30.sp,
                  ),
                ),
              ),

              // Üstten karartma — sol/sağ üst bilgiler için okunurluk
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _topGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Alttan güçlü gradient — başlığın oturduğu zemin
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 108.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.82),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // Ortada oynat ikonu (canlı/yakında değilse)
              /*  if (!isLive && !isUpcoming)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.32),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
                  ),
                ),
 */
              // Alt — başlık + yayın zamanı (gradient üstünde)
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 10.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 4),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      timeago.format(video.publishedAt, locale: 'tr'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Sol üst — üniversite adı + takip butonu (tıklamalar ayrı,
        // GestureDetector medya tıklamasının üstünde ama IgnorePointer yok
        // çünkü kendi Material/InkWell'leri var).
        Positioned(
          top: 10.h,
          left: 10.w,
          right: 92.w,
          child: _buildUniversityBlock(context, controller),
        ),

        // Sağ üst — CANLI/YAKINDA rozeti + süre/HD
        Positioned(
          top: 10.h,
          right: 10.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLive) _badge('CANLI', const Color(0xFFE53935)),
              if (isUpcoming) _badge('YAKINDA', const Color(0xFF5C6BC0)),
              if (isLive || isUpcoming) SizedBox(height: 4.h),
              Row(
                children: [
                  if (video.isHd) ...[
                    _pillLabel('HD', small: true),
                    SizedBox(width: 4.w),
                  ],
                  if (!isLive) _pillLabel(video.formattedDuration),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // Sol üst — üniversite adı + takip butonu (glass pill, görsel üzerinde)
  // ════════════════════════════════════════════════════════════════
  Widget _buildUniversityBlock(
    BuildContext context,
    HomeController controller,
  ) {
    final uni = university;
    final name = uni?.name ?? video.universityName ?? video.channelTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: uni == null
              ? null
              : () => Get.toNamed(AppRoutes.universityDetail, arguments: uni),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Obx(() {
          final uniId = uni?.id ?? video.universityId;
          final isFav = controller.favoriteUniversityIds.contains(uniId);
          return GestureDetector(
            onTap: uni == null
                ? null
                : () => controller.toggleUniversityFavorite(uni),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.white.withOpacity(0.16)
                    : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20.r),
                border: isFav
                    ? Border.all(color: Colors.white.withOpacity(0.5))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFav ? Icons.check_rounded : Icons.add_rounded,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    isFav ? 'Takipte' : 'Takip Et',
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showUpcomingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Yakında Yayında'),
        content: const Text(
          'Bu yayın henüz başlamadı. Başladığında izleyebilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.45),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 5.sp),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillLabel(String label, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 5.w : 7.w,
        vertical: small ? 2.h : 3.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 8.sp : 9.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // STATS ROW — düz, çerçevesiz, sade ikon + sayı
  // ════════════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 6.h, 10.w, 0),
      child: Obx(() {
        final liveVideo = controller.videos.firstWhereOrNull(
          (v) => v.videoId == video.videoId,
        );
        final override = controller.viewCountOverrides[video.videoId];
        final views = override ?? liveVideo?.appViewCount ?? video.appViewCount;
        final likes = liveVideo?.appLikeCount ?? video.appLikeCount;
        final shares = liveVideo?.appShareCount ?? video.appShareCount;
        final favCount = liveVideo?.appFavoriteCount ?? video.appFavoriteCount;
        final extra = controller.extraCommentCountFor(video.videoId);
        final comments = video.appCommentCount + extra;

        final liked = controller.likedVideoIds.contains(video.videoId);
        final hasCommented = controller.commentedVideoIds.contains(
          video.videoId,
        );
        final isFav = controller.favoriteIds.contains(video.videoId);
        final isShareLoading = controller.shareLoadingVideoIds.contains(
          video.videoId,
        );
        final hasShared = controller.sharedVideoIds.contains(video.videoId);

        return Row(
          children: [
            _statItem(context, icon: Icons.visibility_outlined, count: views),
            _statItem(
              context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              count: likes,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            ),
            _statItem(
              context,
              icon: hasCommented
                  ? Icons.mode_comment_rounded
                  : Icons.mode_comment_outlined,
              count: comments,
              isActive: hasCommented,
              onTap: () => Get.toNamed(
                AppRoutes.player,
                arguments: video,
                parameters: {'videoId': video.videoId},
              ),
            ),
            if (isShareLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: SizedBox(
                  width: 13.sp,
                  height: 13.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textSec(context),
                  ),
                ),
              )
            else
              _statItem(
                context,
                icon: hasShared ? Icons.send_rounded : Icons.send_outlined,
                count: shares,
                isActive: hasShared,
                onTap: () => controller.shareVideo(video),
              ),
            const Spacer(),
            _statItem(
              context,
              icon: isFav
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              count: favCount,
              isActive: isFav,
              onTap: () => controller.toggleFavorite(video.videoId),
            ),
          ],
        );
      }),
    );
  }

  Widget _statItem(
    BuildContext context, {
    required IconData icon,
    required int count,
    VoidCallback? onTap,
    bool isActive = false,
  }) {
    final color = isActive ? AppTheme.primaryColor : AppTheme.textSec(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: color),
        if (count > 0) ...[
          SizedBox(width: 3.w),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: color,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          child: content,
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DESCRIPTION — kutu/çerçeve yok, sade tipografi
  // ════════════════════════════════════════════════════════════════
  Widget _buildDescription(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    final descriptionText = hasDescription
        ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
        : 'Bu video için açıklama bulunmuyor.';

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          descriptionText,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: 11.5.sp,
            height: 1.45,
            fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HELPER
  // ════════════════════════════════════════════════════════════════
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}B';
    }
    return count.toString();
  }
}
