// lib/presentation/screens/home/tabs/home_tab/widgets/wheel_video_card_widget.dart
//
// ═══════════════════════════════════════════════════════════════════════
// SABİT YÜKSEKLİK STRATEJİSİ (ÖNEMLİ)
// ═══════════════════════════════════════════════════════════════════════
// Bu kart, parent tarafından SizedBox(height: kWheelCardHeight.h) ile
// SABİT bir yüksekliğe zorlanıyor (bkz. home_feed_wheel_widget.dart).
// Kartın içindeki bölümler şu şekilde davranır:
//
//   • Header      -> sabit yükseklik (tek satır uni adı + tek satır zaman)
//   • Thumbnail   -> sabit yükseklik (aspect-ratio'ya bakmaksızın SABİT)
//   • Stats Row   -> sabit yükseklik (ikon + sayı satırı her zaman aynı)
//   • Divider     -> sabit yükseklik (1px çizgi + padding)
//   • Content     -> Expanded! Kalan TÜM alanı kaplar.
//        ├─ Başlık   -> SizedBox(height: sabit 2 satır payı) + Align(topLeft)
//        │             1 satır da olsa 2 satır da olsa KUTU BOYU DEĞİŞMEZ.
//        └─ Açıklama -> Expanded (kalan alanın tamamı) + Align(topLeft)
//                      1 satır da olsa 4 satır da olsa KUTU BOYU DEĞİŞMEZ,
//                      metin sadece üstte gösterilir, taşan kısım ellipsis.
//
// Sonuç: video başlığı veya açıklaması ister 1 satır ister maksimum
// satır sayısı kadar olsun, KART YÜKSEKLİĞİ ASLA KIRPILMAZ / OYNAMAZ.
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

  // ── Sabit boyut sabitleri (satır sayısı ne olursa olsun DEĞİŞMEZ) ──
  static double get _headerHeight => 44.h;
  static double get _thumbnailHeight => 128.h;
  static double get _statsHeight => 34.h;
  static double get _dividerBlockHeight => 13.h;

  // Başlık: fontSize 12.5.sp, line-height 1.3 => satır başına ~16.25.sp
  static double get _titleFontSize => 12.5.sp;
  static const double _titleLineHeight = 1.3;
  static double get _titleBoxHeight =>
      _titleFontSize * _titleLineHeight * 2; // 2 satır sabit pay

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppTheme.textSec(context).withOpacity(0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              AppTheme.isDark(context) ? 0.22 : 0.05,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      // mainAxisSize.max (varsayılan): kart parent'tan gelen sabit
      // yüksekliği doldurur; Content bölümü Expanded olduğu için
      // artan/eksilen tüm boşluğu o karşılar.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _headerHeight,
            child: _buildHeader(context, controller),
          ),
          SizedBox(height: _thumbnailHeight, child: _buildThumbnail(context)),
          SizedBox(
            height: _statsHeight,
            child: _buildStatsRow(context, controller),
          ),
          SizedBox(height: _dividerBlockHeight, child: _buildDivider(context)),
          Expanded(child: _buildContent(context)),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // HEADER
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 10.w, 4.h),
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
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    university?.name ??
                        video.universityName ??
                        video.channelTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPri(context),
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    timeago.format(video.publishedAt, locale: 'tr'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: AppTheme.textSec(context),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildFollowButton(context, controller),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.all(1.6.w),
      child: ClipOval(
        child: (university?.logoUrl == null || university!.logoUrl!.isEmpty)
            ? Container(
                color: AppTheme.surface(context),
                child: Icon(
                  Icons.school_rounded,
                  size: 15.sp,
                  color: AppTheme.textSec(context),
                ),
              )
            : CachedNetworkImage(
                imageUrl: university!.logoUrl!,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => Icon(
                  Icons.school_rounded,
                  size: 15.sp,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isFav
                ? AppTheme.primaryColor.withOpacity(0.12)
                : AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFav ? Icons.check_rounded : Icons.add_rounded,
                size: 13.sp,
                color: isFav ? AppTheme.primaryColor : Colors.white,
              ),
              SizedBox(width: 2.w),
              Text(
                isFav ? 'Takipte' : 'Takip Et',
                style: TextStyle(
                  fontSize: 9.5.sp,
                  fontWeight: FontWeight.w700,
                  color: isFav ? AppTheme.primaryColor : Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  // THUMBNAIL — yükseklik SABİT (_thumbnailHeight), aspect-ratio yok sayılır
  // ════════════════════════════════════════════════════════════════
  Widget _buildThumbnail(BuildContext context) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GestureDetector(
        onTap: isUpcoming
            ? () => _showUpcomingDialog(context)
            : () => Get.toNamed(
                AppRoutes.player,
                arguments: video,
                parameters: {'videoId': video.videoId},
              ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
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
              // Hafif alttan-üste gradient — pill/badge okunurluğu için
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 44.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLive && !isUpcoming)
                Center(
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26.sp,
                    ),
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
                  child: _pillLabel(video.formattedDuration),
                ),
              if (video.isHd)
                Positioned(
                  bottom: 8.h,
                  left: 8.w,
                  child: _pillLabel('HD', small: true),
                ),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
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
        color: Colors.black.withOpacity(0.75),
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
  // STATS ROW — sabit yükseklik
  // ════════════════════════════════════════════════════════════════
  Widget _buildStatsRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 2.h, 8.w, 0),
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
  // DIVIDER
  // ════════════════════════════════════════════════════════════════
  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Divider(
        height: 1,
        thickness: 0.6,
        color: AppTheme.textSec(context).withOpacity(0.08),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CONTENT — Expanded! Başlık sabit kutu (2 satır payı) + Açıklama
  // Expanded kutu (4 satır max). Metin az olsa da kutu boyu SABİT kalır.
  // ════════════════════════════════════════════════════════════════
  Widget _buildContent(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    final descriptionText = hasDescription
        ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
        : 'Bu video için açıklama bulunmuyor.';

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık: SABİT yükseklik (2 satır payı), her zaman aynı ──
          SizedBox(
            height: _titleBoxHeight,
            width: double.infinity,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.w700,
                  height: _titleLineHeight,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),

          // ── Açıklama kutusu: Expanded -> kalan TÜM alanı kaplar ──
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppTheme.isDark(context)
                    ? Colors.white.withOpacity(0.04)
                    : AppTheme.primaryColor.withOpacity(0.045),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppTheme.textSec(context).withOpacity(0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  // Kalan alanı dolduran, üstten hizalı, 4 satır max metin.
                  // Expanded olduğu için 1 satırlık açıklama da 4 satırlık
                  // açıklama da KUTUYU AYNI YÜKSEKLİKTE tutar.
                  Expanded(
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        descriptionText,
                        maxLines: 4,
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
                    ),
                  ),
                ],
              ),
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
