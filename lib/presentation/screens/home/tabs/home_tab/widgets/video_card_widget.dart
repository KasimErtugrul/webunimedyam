// lib/presentation/screens/home/widgets/tabs/home_tab/widgets/video_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';

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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isLive = video.formattedDuration.isEmpty;

    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.card(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller),
            _buildThumbnail(context, isLive),
            _buildActionRow(context, controller),
            _buildStats(context),
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
                    padding:
                        EdgeInsets.zero, // Etrafındaki boşlukları sıfırladık
                    minimumSize:
                        Size.zero, // Butonun ekstra büyük yer kaplamasını önler
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
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Takip Et',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),

          // ÜÇ NOKTA MENÜ
          GestureDetector(
            onTap: () {},
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
  Widget _buildThumbnail(BuildContext context, bool isLive) {
    return GestureDetector(
      onTap: () => Get.toNamed(
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
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 7.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'CANLI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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
  // ACTION ROW — Like · Yorum · Paylaş | Favori
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildActionRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          Obx(
            () => _igActionBtn(
              context: context,
              icon: controller.isLiked(video.videoId)
                  ? Icons.thumb_up_rounded
                  : Icons.thumb_up_outlined,
              color: controller.isLiked(video.videoId)
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              onTap: () => controller.toggleLike(video.videoId),
              label: 'Beğen',
            ),
          ),
          SizedBox(width: 4.w),
          _igActionBtn(
            context: context,
            icon: Icons.mode_comment_outlined,
            color: AppTheme.textPri(context),
            onTap: () => Get.toNamed(
              AppRoutes.player,
              arguments: video,
              parameters: {'videoId': video.videoId},
            ),
            label: 'Yorum',
          ),
          SizedBox(width: 4.w),
          Obx(
            () => controller.isShareLoading(video.videoId)
                ? Padding(
                    padding: EdgeInsets.all(8.w),
                    child: SizedBox(
                      width: 20.sp,
                      height: 20.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.textSec(context),
                      ),
                    ),
                  )
                : _igActionBtn(
                    context: context,
                    icon: Icons.send_outlined,
                    color: AppTheme.textPri(context),
                    onTap: () => controller.shareVideo(video),
                    label: 'Paylaş',
                  ),
          ),
          const Spacer(),
          Obx(
            () => _igActionBtn(
              context: context,
              icon: controller.isFavorite(video.videoId)
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_outline_rounded,
              color: controller.isFavorite(video.videoId)
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              onTap: () => controller.toggleFavorite(video.videoId),
              label: 'Kaydet',
            ),
          ),
        ],
      ),
    );
  }

  Widget _igActionBtn({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Icon(icon, color: color, size: 24.sp, semanticLabel: label),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildStats(BuildContext context) {
    final hasAppData =
        video.appViewCount > 0 ||
        video.appLikeCount > 0 ||
        video.appFavoriteCount > 0 ||
        video.appShareCount > 0 ||
        video.appCommentCount > 0;

    final viewCount = hasAppData ? video.appViewCount : video.viewCount;
    final likeCount = hasAppData ? video.appLikeCount : video.likeCount;
    final commentCount = hasAppData
        ? video.appCommentCount
        : video.commentCount;
    final shareCount = video.appShareCount;
    final favCount = video.appFavoriteCount;

    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 4.h),
      child: Wrap(
        spacing: 14.w,
        runSpacing: 4.h,
        children: [
          _statChip(context, Icons.visibility_outlined, viewCount),
          _statChip(context, Icons.thumb_up_off_alt_rounded, likeCount),
          _statChip(context, Icons.bookmark_outline_rounded, favCount),
          _statChip(context, Icons.mode_comment_outlined, commentCount),
          _statChip(context, Icons.send_outlined, shareCount),
          if (hasAppData)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Text(
                'uygulama verisi',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: AppTheme.textSec(context)),
        SizedBox(width: 3.w),
        Text(
          _formatCount(count),
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
}
