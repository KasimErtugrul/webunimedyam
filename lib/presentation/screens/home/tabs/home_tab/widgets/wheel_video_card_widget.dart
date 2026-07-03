// lib/presentation/screens/home/tabs/home_tab/widgets/wheel_video_card_widget.dart
//
// GÜNCEL TASARIM:
// - Açıklama, bölücü, takip butonu ve 2 satır başlık GERİ GETİRİLDİ.
// - Thumbnail max yüksekliği 140.h'a düşürüldü (oldukça küçüldü).
// - Tüm kart artık çok daha dengeli ve orijinal tasarıma sadık.

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppTheme.textSec(context).withOpacity(0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // HEADER (logo, üniversite, zaman, TAKİP BUTONU)
          _buildHeader(context, controller),
          // THUMBNAIL (max 140.h ile daha küçük)
          _buildThumbnail(context, controller),
          // STATS ROW
          _buildStatsRow(context, controller),
          // DIVIDER (geri eklendi)
          _buildDivider(context),
          // CONTENT (Başlık 2 satır + Açıklama 2 satır)
          _buildContent(context),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 4.h),
      child: Row(
        children: [
          _buildLogo(context),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: university == null
                  ? null
                  : () => Get.toNamed(
                      AppRoutes.universityDetail,
                      arguments: university,
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    university?.name ??
                        video.universityName ??
                        video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                    ),
                  ),
                  Text(
                    timeago.format(video.publishedAt, locale: 'tr'),
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: AppTheme.textSec(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ─── TAKİP BUTONU (geri eklendi) ───
          _buildFollowButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.all(1.5.w),
      child: ClipOval(
        child: (university?.logoUrl == null || university!.logoUrl!.isEmpty)
            ? Container(
                color: AppTheme.surface(context),
                child: Icon(
                  Icons.school_rounded,
                  size: 14.sp,
                  color: AppTheme.textSec(context),
                ),
              )
            : CachedNetworkImage(
                imageUrl: university!.logoUrl!,
                fit: BoxFit.contain,
                errorWidget: (_, _, __) => Icon(
                  Icons.school_rounded,
                  size: 14.sp,
                  color: AppTheme.textSec(context),
                ),
                placeholder: (_, __) =>
                    Container(color: AppTheme.surface(context)),
              ),
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, HomeController controller) {
    return Obx(() {
      final uniId = university?.id ?? video.universityId;
      final isFav = controller.favoriteUniversityIds.contains(uniId);
      return GestureDetector(
        onTap: university == null
            ? null
            : () => controller.toggleUniversityFavorite(university!),
        child: Icon(
          isFav ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
          size: 20.sp,
          color: isFav ? AppTheme.primaryColor : AppTheme.textSec(context),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  // THUMBNAIL – max yükseklik 140.h (KÜÇÜLDÜ)
  // ════════════════════════════════════════════════════════════════
  Widget _buildThumbnail(BuildContext context, HomeController controller) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return GestureDetector(
      onTap: isUpcoming
          ? () => _showUpcomingDialog(context)
          : () => Get.toNamed(
              AppRoutes.player,
              arguments: video,
              parameters: {'videoId': video.videoId},
            ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final aspectHeight = width * 9 / 16;
              final maxH = 140.h; // ÖNEMLİ: 140.h'a düşürüldü
              final height = aspectHeight < maxH ? aspectHeight : maxH;

              return SizedBox(
                width: double.infinity,
                height: height,
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
                          size: 28.sp,
                        ),
                      ),
                    ),
                    if (!isLive && !isUpcoming)
                      Center(
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 28.sp,
                        ),
                      ),
                    if (isLive)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: _badge('CANLI', const Color(0xFFE53935)),
                      ),
                    if (isUpcoming)
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: _badge('YAKINDA', const Color(0xFF5C6BC0)),
                      ),
                    if (!isLive)
                      Positioned(
                        bottom: 6.h,
                        right: 6.w,
                        child: _pillLabel(video.formattedDuration),
                      ),
                    if (video.isHd)
                      Positioned(
                        bottom: 6.h,
                        left: 6.w,
                        child: _pillLabel('HD', small: true),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
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
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 5.sp),
          SizedBox(width: 2.w),
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
        horizontal: small ? 4.w : 6.w,
        vertical: small ? 1.h : 2.h,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4.r),
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
  // STATS ROW
  // ════════════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 4.h, 8.w, 2.h),
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
            _statChip(context, icon: Icons.visibility_outlined, count: views),
            _statButton(
              context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              count: likes,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            ),
            _statButton(
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
                padding: EdgeInsets.all(6.w),
                child: SizedBox(
                  width: 14.sp,
                  height: 14.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.textSec(context),
                  ),
                ),
              )
            else
              _statButton(
                context,
                icon: hasShared ? Icons.send_rounded : Icons.send_outlined,
                count: shares,
                isActive: hasShared,
                onTap: () => controller.shareVideo(video),
              ),
            const Spacer(),
            _statButton(
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

  Widget _statChip(
    BuildContext context, {
    required IconData icon,
    required int count,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: AppTheme.textSec(context)),
          SizedBox(width: 2.w),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 9.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statButton(
    BuildContext context, {
    required IconData icon,
    required int count,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final color = isActive ? AppTheme.primaryColor : AppTheme.textPri(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 4.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.sp, color: color),
              if (count > 0) ...[
                SizedBox(width: 2.w),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textSec(context),
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DIVIDER (geri eklendi)
  // ════════════════════════════════════════════════════════════════
  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: AppTheme.textSec(context).withOpacity(0.08),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CONTENT – Başlık (2 satır) + Açıklama (2 satır) GERİ EKLENDİ
  // ════════════════════════════════════════════════════════════════
  Widget _buildContent(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    final text = hasDescription
        ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
        : 'Bu video için açıklama bulunmuyor.';

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Başlık (2 satır) ──
          Text(
            video.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
          SizedBox(height: 6.h),

          // ── Açıklama kutusu (2 satır, daha kompakt padding) ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? Colors.white.withOpacity(0.04)
                  : AppTheme.primaryColor.withOpacity(0.045),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.textSec(context).withOpacity(0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 12.sp,
                      color: AppTheme.textSec(context),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Açıklama',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  text,
                  maxLines: 4, // 2 satıra düşürüldü (yer tasarrufu)
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 11.sp,
                    height: 1.4,
                    fontStyle: hasDescription
                        ? FontStyle.normal
                        : FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
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
