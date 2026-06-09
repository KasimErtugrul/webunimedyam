import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../../app/routes/app_routes.dart';
import '../../../../../../../app/themes/app_theme.dart';
import '../../../../../../../data/models/video_model.dart';
import '../../../../../../controllers/home_controller.dart';

class VideoCardWidget extends StatelessWidget {
  final VideoModel video;

  const VideoCardWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isLive = video.formattedDuration.isEmpty;

    // timeago Türkçe dil ayarı
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(
              AppRoutes.player,
              arguments: video,
              parameters: {'videoId': video.videoId},
            ),
            splashColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
            highlightColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Thumbnail & Overlay Bilgileri ────────────────────────────
                _buildThumbnail(context, controller, isLive),

                // ── İçerik Bilgi Alanı ──────────────────────────────────────
                _buildContentInfo(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // THUMBNAIL ALANI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildThumbnail(
    BuildContext context,
    HomeController controller,
    bool isLive,
  ) {
    return SizedBox(
      height: 200.h,
      width: double.infinity,
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

          // Alt Gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Üst Gradient
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 60.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.60),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // CANLI Etiketi
          if (isLive)
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 8.r,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 7.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'CANLI',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // HD Etiketi
          if (video.isHd && !isLive)
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 0.5.w,
                  ),
                ),
                child: Text(
                  'HD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.w,
                  ),
                ),
              ),
            ),

          // Süre Etiketi
          if (!isLive)
            Positioned(
              bottom: 8.h,
              right: 10.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(5.r),
                ),
                child: Text(
                  video.formattedDuration,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Favori Butonu
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Obx(
              () => Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => controller.toggleFavorite(video.videoId),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Icon(
                      controller.isFavorite(video.videoId)
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: controller.isFavorite(video.videoId)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // İÇERİK BİLGİ ALANI
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContentInfo(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ve Üniversite Adı ────────────────────────────────────
          Row(
            children: [
              _buildUniversityAvatar(context, controller),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  video.universityName ?? video.channelTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // ── Video Başlığı (4 Satır) ──────────────────────────────────
          Text(
            video.title,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          // ── Açıklama (4 Satır) ───────────────────────────────────────
          if (video.description.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              video.description.replaceAll(RegExp(r'\n+'), ' '),
              style: TextStyle(
                color: AppTheme.textSec(context).withValues(alpha: 0.85),
                fontSize: 13.sp,
                height: 1.45,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          SizedBox(height: 14.h),

          // ── İstatistik Çubuğu (Sol: İkonlar, Sağ: Zaman) ─────────────
          _buildStatsAndTimeRow(context),
        ],
      ),
    );
  }

  // ── Üniversite Avatarı ────────────────────────────────────────────────────
  Widget _buildUniversityAvatar(
    BuildContext context,
    HomeController controller,
  ) {
    return Obx(() {
      final uni = controller.universities.firstWhereOrNull(
        (u) => u.id == video.universityId,
      );
      final logoUrl = uni?.logoUrl;
      final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

      return Container(
        width: 38.w,
        height: 38.h,
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: AppTheme.textSec(context).withValues(alpha: 0.08),
            width: 1.w,
          ),
        ),
        child: hasLogo
            ? ClipRRect(
                borderRadius: BorderRadius.circular(9.r),
                child: CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const SizedBox.shrink(),
                  errorWidget: (_, _, _) => Icon(
                    Icons.school_rounded,
                    color: AppTheme.textSec(context),
                    size: 20.sp,
                  ),
                ),
              )
            : Icon(
                Icons.school_rounded,
                color: AppTheme.textSec(context),
                size: 20.sp,
              ),
      );
    });
  }

  // ── İstatistikler (Sol) ve Zaman (Sağ) ────────────────────────────────────
  Widget _buildStatsAndTimeRow(BuildContext context) {
    // Uygulama verileri varsa onları kullan, yoksa YouTube verilerini göster
    final hasAppData = video.appViewCount > 0 ||
        video.appLikeCount > 0 ||
        video.appFavoriteCount > 0 ||
        video.appShareCount > 0 ||
        video.appCommentCount > 0;

    final viewCount =
        hasAppData ? video.appViewCount : video.viewCount;
    final likeCount =
        hasAppData ? video.appLikeCount : video.likeCount;
    final favCount = video.appFavoriteCount;
    final commentCount =
        hasAppData ? video.appCommentCount : video.commentCount;
    final shareCount = video.appShareCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Üst satır: görüntülenme · beğeni · favori
        Row(
          children: [
            _statChip(context, Icons.visibility_outlined, viewCount),
            SizedBox(width: 14.w),
            _statChip(context, Icons.thumb_up_off_alt_rounded, likeCount),
            SizedBox(width: 14.w),
            _statChip(context, Icons.bookmark_outline_rounded, favCount),
            const Spacer(),
            Text(
              timeago.format(video.publishedAt, locale: 'tr'),
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        // Alt satır: yorum · paylaşım
        Row(
          children: [
            _statChip(context, Icons.mode_comment_outlined, commentCount),
            SizedBox(width: 14.w),
            _statChip(context, Icons.share_outlined, shareCount),
            if (hasAppData) ...[
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(6.r),
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
          ],
        ),
      ],
    );
  }

  Widget _statChip(BuildContext context, IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.sp, color: AppTheme.textSec(context)),
        SizedBox(width: 4.w),
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

  // ── Sayı Formatlama Yardımcısı ────────────────────────────────────────────
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}B';
    }
    return count.toString();
  }
}
