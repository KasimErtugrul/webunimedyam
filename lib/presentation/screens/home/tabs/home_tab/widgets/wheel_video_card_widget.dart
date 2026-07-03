// lib/presentation/screens/home/tabs/home_tab/widgets/wheel_video_card_widget.dart
//
// Wheel görünümü için ÖZEL video kartı.
// VideoCardWidget (listview kartı) tam genişlik + IG-tarzı geniş action row
// varsayımıyla tasarlanmıştı; wheel'in yanındaki dar (Expanded) alanda
// kullanılınca taşma/orantısızlık oluşuyordu. Bu widget aynı veriyi
// (VideoModel) wheel'e özgü bir sırayla sunar:
//
//   1) Üniversite logosu + adı + zaman
//   2) Video görseli (thumbnail)
//   3) Etkileşim butonları (görüntülenme · beğeni · yorum · paylaş · favori)
//   4) Video başlığı
//   5) Video açıklaması (genişleyebilir — ReadMoreText)
//
// Kart, wheel ile aynı yüksekliğe (parent'tan gelen sabit height) sahip
// olacak şekilde kullanılır; açıklama alanı kalan boşluğu doldurmak için
// esnek/scrollable bırakılmıştır — böylece altta boş alan kalmaz.
//
// Not: Bu dosya video verisini DEĞİŞTİRMEZ, sadece görünümü farklıdır.
// Favori / beğeni / oynat gibi eylemler yine HomeController üzerinden yürütülür.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
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
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.08),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1) ── Üniversite logosu + adı + zaman ──────────────────────
          _buildHeader(context, controller),

          // 2) ── Video görseli ─────────────────────────────────────────
          _buildThumbnail(context, controller),

          // 3) ── Etkileşim butonları ───────────────────────────────────
          _buildStatsRow(context, controller),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Divider(
              height: 14.h,
              thickness: 0.6,
              color: AppTheme.textSec(context).withValues(alpha: 0.08),
            ),
          ),

          // 4) + 5) ── Başlık + açıklama (kalan alanı doldurur) ─────────
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(context),
                  SizedBox(height: 6.h),
                  _buildDescription(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 1) HEADER — Logo · Üniversite Adı · Zaman
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.6.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: SizedBox(
              width: 26.w,
              height: 26.w,
              child: ClipOval(
                child:
                    (university?.logoUrl == null ||
                        university!.logoUrl!.isEmpty)
                    ? Container(
                        color: AppTheme.surface(context),
                        child: Icon(
                          Icons.school_rounded,
                          color: AppTheme.textSec(context),
                          size: 14.sp,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: university!.logoUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, _, _) => Icon(
                          Icons.school_rounded,
                          color: AppTheme.textSec(context),
                          size: 14.sp,
                        ),
                        placeholder: (_, _) =>
                            Container(color: AppTheme.surface(context)),
                      ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (university != null) {
                  Get.toNamed(
                    AppRoutes.universityDetail,
                    arguments: university,
                  );
                }
              },
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
                      color: AppTheme.textPri(context),
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    timeago.format(video.publishedAt, locale: 'tr'),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Takip et kısayolu
          Obx(() {
            final uniId = university?.id ?? video.universityId;
            final isFav = controller.favoriteUniversityIds.contains(uniId);
            return GestureDetector(
              onTap: university == null
                  ? null
                  : () => controller.toggleUniversityFavorite(university!),
              child: Icon(
                isFav
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                size: 20.sp,
                color: isFav
                    ? AppTheme.primaryColor
                    : AppTheme.textSec(context),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 2) THUMBNAIL — 16:9, oynat + canlı/yakında rozeti + süre
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildThumbnail(BuildContext context, HomeController controller) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

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
          borderRadius: BorderRadius.circular(12.r),
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
                        color: AppTheme.primaryColor,
                        strokeWidth: 2.w,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppTheme.surface(context),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppTheme.textSec(context),
                      size: 34.sp,
                    ),
                  ),
                ),
                if (!isLive && !isUpcoming)
                  Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 32.sp,
                    ),
                  ),
                if (isLive)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: _badge('CANLI', const Color(0xFFE53935)),
                  ),
                if (isUpcoming)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: _badge('YAKINDA', const Color(0xFF5C6BC0)),
                  ),
                if (!isLive)
                  Positioned(
                    bottom: 8.h,
                    right: 8.w,
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
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                if (video.isHd)
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'HD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w800,
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

  Widget _badge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
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
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 3) ETKİLEŞİM BUTONLARI — görüntülenme · beğeni · yorum · paylaş · favori
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 0),
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
            isShareLoading
                ? Padding(
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
                : _statButton(
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
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15.sp, color: AppTheme.textSec(context)),
          SizedBox(width: 3.w),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: 10.5.sp,
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
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15.sp, color: color),
              if (count > 0) ...[
                SizedBox(width: 3.w),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textSec(context),
                    fontSize: 10.5.sp,
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

  // ═══════════════════════════════════════════════════════════════════
  // 4) BAŞLIK
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildTitle(BuildContext context) {
    return Text(
      video.title,
      style: TextStyle(
        color: AppTheme.textPri(context),
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // 5) AÇIKLAMA — genişleyebilir (ReadMoreText)
  // ═══════════════════════════════════════════════════════════════════
  Widget _buildDescription(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    return ReadMoreText(
      hasDescription
          ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
          : 'Bu video için açıklama bulunmuyor.',
      trimMode: TrimMode.Line,
      trimLines: 4,
      trimCollapsedText: ' Daha fazla',
      trimExpandedText: ' Daha az',
      moreStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
      ),
      lessStyle: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
      ),
      style: TextStyle(
        color: AppTheme.textSec(context),
        fontSize: 12.sp,
        height: 1.5,
        fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
    return count.toString();
  }
}
