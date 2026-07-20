// lib/presentation/screens/home/tabs/home_tab/widgets/video_card_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';
import '../../../../player/player_screen_widgets/comment_input_widget.dart';

// ═══════════════════════════════════════════════════════════════════════
// PHONE SABİTLERİ — ScreenUtil ile çarpılacak
// ═══════════════════════════════════════════════════════════════════════

class _PhoneSizes {
  // Dış Kart
  static const double cardOuterPadV = 6;

  // Başlık (Header)
  static const double headerPadH = 12;
  static const double headerPadV = 10;
  static const double logoPadding = 2;
  static const double logoInnerPadding = 2;
  static const double logoSize = 34;
  static const double logoSpacing = 10;
  static const double uniNameFontSize = 13;
  static const double timeSpacing = 2;
  static const double timeFontSize = 11;
  static const double followPadH = 12;
  static const double followPadV = 4;
  static const double followCheckIconSize = 18;
  static const double followTextFontSize = 12;
  static const double menuPaddingLeft = 4;
  static const double menuIconSize = 22;
  static const double avatarFallbackIconSize = 18;

  // Küçük Resim (Thumbnail)
  static const double thumbPadH = 10;
  static const double thumbBorderRadius = 14;
  static const double loadingStrokeWidth = 2;
  static const double thumbErrorIconSize = 48;
  static const double badgeTop = 10;
  static const double badgeLeft = 10;
  static const double badgePadH = 8;
  static const double badgePadV = 4;
  static const double badgeBorderRadius = 5;
  static const double badgeDotSize = 7;
  static const double badgeDotSpacing = 4;
  static const double badgeFontSize = 10;
  static const double badgeLetterSpacing = 0.5;
  static const double durationBottom = 8;
  static const double durationRight = 10;
  static const double durationPadH = 6;
  static const double durationPadV = 3;
  static const double durationBorderRadius = 5;
  static const double durationFontSize = 11;
  static const double durationBgAlpha = 0.82;

  // Aksiyon Satırı (Action Row)
  static const double actionRowPadH = 8;
  static const double actionRowPadV = 4;
  static const double actionBtnPadding = 8;
  static const double viewIconSize = 20;
  static const double actionIconSize = 17;
  static const double actionIconTextSpacing = 3;
  static const double actionTextFontSize = 12;
  static const double actionBtnBorderRadius = 20;
  static const double shareLoadingSize = 20;
  static const double shareLoadingStrokeWidth = 2;

  // İçerik (Content)
  static const double contentPadL = 14;
  static const double contentPadT = 4;
  static const double contentPadR = 14;
  static const double contentPadB = 14;
  static const double titleFontSize = 14;
  static const double titleLineHeight = 1.35;
  static const double descSpacing = 4;
  static const double descFontSize = 13;
  static const double descLineHeight = 1.4;
  static const double descContinueAlpha = 0.55;

  // Ayırıcı (Divider)
  static const double dividerPadH = 14;
  static const double dividerHeight = 1;
  static const double dividerThickness = 0.6;
  static const double dividerAlpha = 0.08;

  // Seçenekler Sayfası (Options Sheet)
  static const double sheetBorderRadius = 18;
  static const double handleTopSpacing = 10;
  static const double handleWidth = 36;
  static const double handleHeight = 4;
  static const double handleBorderRadius = 4;
  static const double handleBottomSpacing = 8;
  static const double handleAlpha = 0.25;
  static const double optTilePadH = 18;
  static const double optTilePadV = 12;
  static const double optIconSize = 22;
  static const double optIconSpacing = 14;
  static const double optLabelFontSize = 14;
  static const double optSubtitleSpacing = 2;
  static const double optSubtitleFontSize = 12;
  static const double optBottomSpacing = 6;

  // Hızlı Yorum Sayfası (Quick Comment Sheet)
  static const double qcPadL = 16;
  static const double qcPadT = 14;
  static const double qcPadR = 16;
  static const double qcPadB = 16;
  static const double qcHeaderIconSize = 18;
  static const double qcHeaderIconSpacing = 6;
  static const double qcHeaderTextFontSize = 13;
  static const double qcCloseIconSize = 20;
  static const double qcTitleSpacing = 4;
  static const double qcTitleFontSize = 12;
  static const double qcInputSpacing = 14;
}

// ═══════════════════════════════════════════════════════════════════════
// TABLET SABİTLERİ — Ham piksel, ScreenUtil yok
// ═══════════════════════════════════════════════════════════════════════

class _TabletSizes {
  // Dış Kart
  static const double cardOuterPadV = 4;

  // Başlık (Header)
  static const double headerPadH = 16;
  static const double headerPadV = 8;
  static const double logoPadding = 2;
  static const double logoInnerPadding = 2;
  static const double logoSize = 36;
  static const double logoSpacing = 12;
  static const double uniNameFontSize = 14;
  static const double timeSpacing = 2;
  static const double timeFontSize = 12;
  static const double followPadH = 14;
  static const double followPadV = 5;
  static const double followCheckIconSize = 20;
  static const double followTextFontSize = 13;
  static const double menuPaddingLeft = 6;
  static const double menuIconSize = 24;
  static const double avatarFallbackIconSize = 20;

  // Küçük Resim (Thumbnail)
  static const double thumbPadH = 16;
  static const double thumbBorderRadius = 12;
  static const double loadingStrokeWidth = 2;
  static const double thumbErrorIconSize = 48;
  static const double badgeTop = 12;
  static const double badgeLeft = 12;
  static const double badgePadH = 10;
  static const double badgePadV = 5;
  static const double badgeBorderRadius = 6;
  static const double badgeDotSize = 8;
  static const double badgeDotSpacing = 5;
  static const double badgeFontSize = 11;
  static const double badgeLetterSpacing = 0.5;
  static const double durationBottom = 10;
  static const double durationRight = 12;
  static const double durationPadH = 8;
  static const double durationPadV = 4;
  static const double durationBorderRadius = 6;
  static const double durationFontSize = 12;
  static const double durationBgAlpha = 0.82;

  // Aksiyon Satırı (Action Row)
  static const double actionRowPadH = 12;
  static const double actionRowPadV = 4;
  static const double actionBtnPadding = 10;
  static const double viewIconSize = 20;
  static const double actionIconSize = 18;
  static const double actionIconTextSpacing = 4;
  static const double actionTextFontSize = 13;
  static const double actionBtnBorderRadius = 24;
  static const double shareLoadingSize = 20;
  static const double shareLoadingStrokeWidth = 2;

  // İçerik (Content)
  static const double contentPadL = 16;
  static const double contentPadT = 6;
  static const double contentPadR = 16;
  static const double contentPadB = 12;
  static const double titleFontSize = 15;
  static const double titleLineHeight = 1.35;
  static const double descSpacing = 6;
  static const double descFontSize = 14;
  static const double descLineHeight = 1.4;
  static const double descContinueAlpha = 0.55;

  // Ayırıcı (Divider)
  static const double dividerPadH = 16;
  static const double dividerHeight = 1;
  static const double dividerThickness = 0.6;
  static const double dividerAlpha = 0.08;

  // Seçenekler Sayfası (Options Sheet)
  static const double sheetBorderRadius = 20;
  static const double handleTopSpacing = 12;
  static const double handleWidth = 40;
  static const double handleHeight = 4;
  static const double handleBorderRadius = 4;
  static const double handleBottomSpacing = 10;
  static const double handleAlpha = 0.25;
  static const double optTilePadH = 20;
  static const double optTilePadV = 14;
  static const double optIconSize = 24;
  static const double optIconSpacing = 16;
  static const double optLabelFontSize = 15;
  static const double optSubtitleSpacing = 2;
  static const double optSubtitleFontSize = 13;
  static const double optBottomSpacing = 8;

  // Hızlı Yorum Sayfası (Quick Comment Sheet)
  static const double qcPadL = 20;
  static const double qcPadT = 16;
  static const double qcPadR = 20;
  static const double qcPadB = 20;
  static const double qcHeaderIconSize = 20;
  static const double qcHeaderIconSpacing = 8;
  static const double qcHeaderTextFontSize = 14;
  static const double qcCloseIconSize = 22;
  static const double qcTitleSpacing = 4;
  static const double qcTitleFontSize = 13;
  static const double qcInputSpacing = 16;
}

// ═══════════════════════════════════════════════════════════════════════
// YARDIMCI FONKSİYON
// ═══════════════════════════════════════════════════════════════════════

String _formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
  return count.toString();
}

// ═══════════════════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════════════════

class VideoCardWidget extends StatefulWidget {
  final VideoModel video;

  const VideoCardWidget({super.key, required this.video});

  @override
  State<VideoCardWidget> createState() => _VideoCardWidgetState();
}

class _VideoCardWidgetState extends State<VideoCardWidget> {
  VideoModel get video => widget.video;
  bool _isTablet = false;

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
    _isTablet = Responsive.isTablet(context);
    return _isTablet ? _buildTablet(context) : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PHONE YAPISI
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: _PhoneSizes.cardOuterPadV.h,
      ),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.card(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhoneHeader(context, controller),
            _buildPhoneThumbnail(context, isLive, isUpcoming),
            _buildPhoneActionRow(context, controller),
            _buildPhoneContent(context),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _PhoneSizes.dividerPadH.w,
              ),
              child: Divider(
                height: _PhoneSizes.dividerHeight,
                thickness: _PhoneSizes.dividerThickness,
                color: AppTheme.textSec(
                  context,
                ).withValues(alpha: _PhoneSizes.dividerAlpha),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneHeader(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.headerPadH.w,
        vertical: _PhoneSizes.headerPadV.h,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(_PhoneSizes.logoPadding.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(_PhoneSizes.logoInnerPadding.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.card(context),
              ),
              child: _buildPhoneAvatarInner(context, controller),
            ),
          ),
          SizedBox(width: _PhoneSizes.logoSpacing.w),
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
                      fontSize: _PhoneSizes.uniNameFontSize.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: _PhoneSizes.timeSpacing.h),
                Text(
                  timeago.format(video.publishedAt, locale: 'tr'),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.timeFontSize.sp,
                  ),
                ),
              ],
            ),
          ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: _PhoneSizes.followPadH.w,
                  vertical: _PhoneSizes.followPadV.h,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: isFav
                  ? Icon(
                      Icons.check_rounded,
                      size: _PhoneSizes.followCheckIconSize.sp,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Text(
                      'Takip Et',
                      style: TextStyle(
                        fontSize: _PhoneSizes.followTextFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          }),
          GestureDetector(
            onTap: () => _showVideoOptionsSheet(context, controller),
            child: Padding(
              padding: EdgeInsets.only(left: _PhoneSizes.menuPaddingLeft.w),
              child: Icon(
                Icons.more_horiz_rounded,
                color: AppTheme.textPri(context),
                size: _PhoneSizes.menuIconSize.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneAvatarInner(
    BuildContext context,
    HomeController controller,
  ) {
    return Obx(() {
      final uni = controller.universities.firstWhereOrNull(
        (u) => u.id == video.universityId,
      );
      final logoUrl = uni?.logoUrl;
      final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
      return SizedBox(
        width: _PhoneSizes.logoSize.w,
        height: _PhoneSizes.logoSize.w,
        child: ClipOval(
          child: hasLogo
              ? CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      Container(color: AppTheme.surface(context)),
                  errorWidget: (_, _, _) =>
                      _AvatarFallbackPhone(themeContext: context),
                )
              : _AvatarFallbackPhone(themeContext: context),
        ),
      );
    });
  }

  Widget _buildPhoneThumbnail(
    BuildContext context,
    bool isLive,
    bool isUpcoming,
  ) {
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
        padding: EdgeInsets.symmetric(horizontal: _PhoneSizes.thumbPadH.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_PhoneSizes.thumbBorderRadius.r),
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
                        strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppTheme.surface(context),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppTheme.textSec(context),
                      size: _PhoneSizes.thumbErrorIconSize.sp,
                    ),
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: _PhoneSizes.badgeTop.h,
                    left: _PhoneSizes.badgeLeft.w,
                    child: _LiveBadgePhone(
                      label: 'CANLI',
                      color: const Color(0xFFE53935),
                    ),
                  ),
                if (isUpcoming)
                  Positioned(
                    top: _PhoneSizes.badgeTop.h,
                    left: _PhoneSizes.badgeLeft.w,
                    child: _LiveBadgePhone(
                      label: 'YAKINDA',
                      color: const Color(0xFF5C6BC0),
                    ),
                  ),
                if (!isLive)
                  Positioned(
                    bottom: _PhoneSizes.durationBottom.h,
                    right: _PhoneSizes.durationRight.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _PhoneSizes.durationPadH.w,
                        vertical: _PhoneSizes.durationPadV.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: _PhoneSizes.durationBgAlpha,
                        ),
                        borderRadius: BorderRadius.circular(
                          _PhoneSizes.durationBorderRadius.r,
                        ),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _PhoneSizes.durationFontSize.sp,
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

  Widget _buildPhoneActionRow(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.actionRowPadH.w,
        vertical: _PhoneSizes.actionRowPadV.h,
      ),
      child: Row(
        children: [
          Obx(() {
            final override = controller.viewCountOverrides[video.videoId];
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final viewCount =
                override ?? liveVideo?.appViewCount ?? video.appViewCount;
            return Padding(
              padding: EdgeInsets.all(_PhoneSizes.actionBtnPadding.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: _PhoneSizes.viewIconSize.sp,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: _PhoneSizes.actionIconTextSpacing.w),
                  Text(
                    _formatCount(viewCount),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.actionTextFontSize.sp,
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            final liked = controller.likedVideoIds.contains(video.videoId);
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final likeCount = liveVideo?.appLikeCount ?? video.appLikeCount;
            return _IgActionBtnPhone(
              themeContext: context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              color: liked
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              count: likeCount,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            );
          }),
          Obx(() {
            final hasCommented = controller.commentedVideoIds.contains(
              video.videoId,
            );
            final extra = controller.extraCommentCountFor(video.videoId);
            return _IgActionBtnPhone(
              themeContext: context,
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
          Obx(() {
            final isLoading = controller.shareLoadingVideoIds.contains(
              video.videoId,
            );
            final hasShared = controller.sharedVideoIds.contains(video.videoId);
            if (isLoading) {
              return Padding(
                padding: EdgeInsets.all(_PhoneSizes.actionBtnPadding.w),
                child: SizedBox(
                  width: _PhoneSizes.shareLoadingSize.sp,
                  height: _PhoneSizes.shareLoadingSize.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: _PhoneSizes.shareLoadingStrokeWidth,
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
            return _IgActionBtnPhone(
              themeContext: context,
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
          Obx(() {
            final isFav = controller.favoriteIds.contains(video.videoId);
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final favCount =
                liveVideo?.appFavoriteCount ?? video.appFavoriteCount;
            return _IgActionBtnPhone(
              themeContext: context,
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

  Widget _buildPhoneContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _PhoneSizes.contentPadL.w,
        _PhoneSizes.contentPadT.h,
        _PhoneSizes.contentPadR.w,
        _PhoneSizes.contentPadB.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _PhoneSizes.titleFontSize.sp,
              fontWeight: FontWeight.w600,
              height: _PhoneSizes.titleLineHeight,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (video.description.isNotEmpty) ...[
            SizedBox(height: _PhoneSizes.descSpacing.h),
            RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.descFontSize.sp,
                  height: _PhoneSizes.descLineHeight,
                ),
                children: [
                  TextSpan(
                    text: video.description.replaceAll(RegExp(r'\n+'), ' '),
                  ),
                  TextSpan(
                    text: ' devamı',
                    style: TextStyle(
                      color: AppTheme.textSec(
                        context,
                      ).withValues(alpha: _PhoneSizes.descContinueAlpha),
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

  // ═══════════════════════════════════════════════════════════════════════
  // TABLET YAPISI
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 0,
        vertical: _TabletSizes.cardOuterPadV,
      ),
      child: Container(
        decoration: BoxDecoration(color: AppTheme.card(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabletHeader(context, controller),
            _buildTabletThumbnail(context, isLive, isUpcoming),
            _buildTabletActionRow(context, controller),
            _buildTabletContent(context),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _TabletSizes.dividerPadH,
              ),
              child: Divider(
                height: _TabletSizes.dividerHeight,
                thickness: _TabletSizes.dividerThickness,
                color: AppTheme.textSec(
                  context,
                ).withValues(alpha: _TabletSizes.dividerAlpha),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletHeader(BuildContext context, HomeController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.headerPadH,
        vertical: _TabletSizes.headerPadV,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(_TabletSizes.logoPadding),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFE1306C), Color(0xFFFCAF45)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(_TabletSizes.logoInnerPadding),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.card(context),
              ),
              child: _buildTabletAvatarInner(context, controller),
            ),
          ),
          SizedBox(width: _TabletSizes.logoSpacing),
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
                      fontSize: _TabletSizes.uniNameFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: _TabletSizes.timeSpacing),
                Text(
                  timeago.format(video.publishedAt, locale: 'tr'),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.timeFontSize,
                  ),
                ),
              ],
            ),
          ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: _TabletSizes.followPadH,
                  vertical: _TabletSizes.followPadV,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: isFav
                  ? Icon(
                      Icons.check_rounded,
                      size: _TabletSizes.followCheckIconSize,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : Text(
                      'Takip Et',
                      style: TextStyle(
                        fontSize: _TabletSizes.followTextFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            );
          }),
          GestureDetector(
            onTap: () => _showVideoOptionsSheet(context, controller),
            child: Padding(
              padding: EdgeInsets.only(left: _TabletSizes.menuPaddingLeft),
              child: Icon(
                Icons.more_horiz_rounded,
                color: AppTheme.textPri(context),
                size: _TabletSizes.menuIconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletAvatarInner(
    BuildContext context,
    HomeController controller,
  ) {
    return Obx(() {
      final uni = controller.universities.firstWhereOrNull(
        (u) => u.id == video.universityId,
      );
      final logoUrl = uni?.logoUrl;
      final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
      return SizedBox(
        width: _TabletSizes.logoSize,
        height: _TabletSizes.logoSize,
        child: ClipOval(
          child: hasLogo
              ? CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, _) =>
                      Container(color: AppTheme.surface(context)),
                  errorWidget: (_, _, _) =>
                      _AvatarFallbackTablet(themeContext: context),
                )
              : _AvatarFallbackTablet(themeContext: context),
        ),
      );
    });
  }

  Widget _buildTabletThumbnail(
    BuildContext context,
    bool isLive,
    bool isUpcoming,
  ) {
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
        padding: EdgeInsets.symmetric(horizontal: _TabletSizes.thumbPadH),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_TabletSizes.thumbBorderRadius),
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
                        strokeWidth: _TabletSizes.loadingStrokeWidth,
                      ),
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: AppTheme.surface(context),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppTheme.textSec(context),
                      size: _TabletSizes.thumbErrorIconSize,
                    ),
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: _TabletSizes.badgeTop,
                    left: _TabletSizes.badgeLeft,
                    child: _LiveBadgeTablet(
                      label: 'CANLI',
                      color: const Color(0xFFE53935),
                    ),
                  ),
                if (isUpcoming)
                  Positioned(
                    top: _TabletSizes.badgeTop,
                    left: _TabletSizes.badgeLeft,
                    child: _LiveBadgeTablet(
                      label: 'YAKINDA',
                      color: const Color(0xFF5C6BC0),
                    ),
                  ),
                if (!isLive)
                  Positioned(
                    bottom: _TabletSizes.durationBottom,
                    right: _TabletSizes.durationRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _TabletSizes.durationPadH,
                        vertical: _TabletSizes.durationPadV,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(
                          alpha: _TabletSizes.durationBgAlpha,
                        ),
                        borderRadius: BorderRadius.circular(
                          _TabletSizes.durationBorderRadius,
                        ),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _TabletSizes.durationFontSize,
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

  Widget _buildTabletActionRow(
    BuildContext context,
    HomeController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.actionRowPadH,
        vertical: _TabletSizes.actionRowPadV,
      ),
      child: Row(
        children: [
          Obx(() {
            final override = controller.viewCountOverrides[video.videoId];
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final viewCount =
                override ?? liveVideo?.appViewCount ?? video.appViewCount;
            return Padding(
              padding: EdgeInsets.all(_TabletSizes.actionBtnPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: _TabletSizes.viewIconSize,
                    color: AppTheme.textSec(context),
                  ),
                  SizedBox(width: _TabletSizes.actionIconTextSpacing),
                  Text(
                    _formatCount(viewCount),
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.actionTextFontSize,
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            final liked = controller.likedVideoIds.contains(video.videoId);
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final likeCount = liveVideo?.appLikeCount ?? video.appLikeCount;
            return _IgActionBtnTablet(
              themeContext: context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              color: liked
                  ? Theme.of(context).colorScheme.primary
                  : AppTheme.textPri(context),
              count: likeCount,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            );
          }),
          Obx(() {
            final hasCommented = controller.commentedVideoIds.contains(
              video.videoId,
            );
            final extra = controller.extraCommentCountFor(video.videoId);
            return _IgActionBtnTablet(
              themeContext: context,
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
          Obx(() {
            final isLoading = controller.shareLoadingVideoIds.contains(
              video.videoId,
            );
            final hasShared = controller.sharedVideoIds.contains(video.videoId);
            if (isLoading) {
              return Padding(
                padding: EdgeInsets.all(_TabletSizes.actionBtnPadding),
                child: SizedBox(
                  width: _TabletSizes.shareLoadingSize,
                  height: _TabletSizes.shareLoadingSize,
                  child: CircularProgressIndicator(
                    strokeWidth: _TabletSizes.shareLoadingStrokeWidth,
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
            return _IgActionBtnTablet(
              themeContext: context,
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
          Obx(() {
            final isFav = controller.favoriteIds.contains(video.videoId);
            final liveVideo = controller.videos.firstWhereOrNull(
              (v) => v.videoId == video.videoId,
            );
            final favCount =
                liveVideo?.appFavoriteCount ?? video.appFavoriteCount;
            return _IgActionBtnTablet(
              themeContext: context,
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

  Widget _buildTabletContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        _TabletSizes.contentPadL,
        _TabletSizes.contentPadT,
        _TabletSizes.contentPadR,
        _TabletSizes.contentPadB,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _TabletSizes.titleFontSize,
              fontWeight: FontWeight.w600,
              height: _TabletSizes.titleLineHeight,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (video.description.isNotEmpty) ...[
            SizedBox(height: _TabletSizes.descSpacing),
            RichText(
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.descFontSize,
                  height: _TabletSizes.descLineHeight,
                ),
                children: [
                  TextSpan(
                    text: video.description.replaceAll(RegExp(r'\n+'), ' '),
                  ),
                  TextSpan(
                    text: ' devamı',
                    style: TextStyle(
                      color: AppTheme.textSec(
                        context,
                      ).withValues(alpha: _TabletSizes.descContinueAlpha),
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

  // ═══════════════════════════════════════════════════════════════════════
  // MODAL SAYFALAR (SHEET) YÖNLENDİRMESİ
  // ═══════════════════════════════════════════════════════════════════════

  void _showVideoOptionsSheet(BuildContext context, HomeController controller) {
    if (_isTablet) {
      _showTabletVideoOptionsSheet(context, controller);
    } else {
      _showPhoneVideoOptionsSheet(context, controller);
    }
  }

  void _showQuickCommentSheet(BuildContext context, HomeController controller) {
    if (_isTablet) {
      _showTabletQuickCommentSheet(context, controller);
    } else {
      _showPhoneQuickCommentSheet(context, controller);
    }
  }

  // ── PHONE SHEET'LER ──

  void _showPhoneVideoOptionsSheet(
    BuildContext context,
    HomeController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_PhoneSizes.sheetBorderRadius.r),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: _PhoneSizes.handleTopSpacing.h),
              Container(
                width: _PhoneSizes.handleWidth.w,
                height: _PhoneSizes.handleHeight.h,
                decoration: BoxDecoration(
                  color: AppTheme.textSec(
                    context,
                  ).withValues(alpha: _PhoneSizes.handleAlpha),
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.handleBorderRadius.r,
                  ),
                ),
              ),
              SizedBox(height: _PhoneSizes.handleBottomSpacing.h),
              _OptionTilePhone(
                themeContext: context,
                icon: Icons.bolt_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                label: 'Hızlı Yorum Gönder',
                subtitle: 'Videoyu açmadan yorum yap',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showQuickCommentSheet(context, controller);
                },
              ),
              _OptionTilePhone(
                themeContext: context,
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
              Obx(() {
                final isFav = controller.favoriteIds.contains(video.videoId);
                return _OptionTilePhone(
                  themeContext: context,
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
              _OptionTilePhone(
                themeContext: context,
                icon: Icons.send_outlined,
                label: 'Paylaş',
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.shareVideo(video);
                },
              ),
              SizedBox(height: _PhoneSizes.optBottomSpacing.h),
            ],
          ),
        );
      },
    );
  }

  void _showPhoneQuickCommentSheet(
    BuildContext context,
    HomeController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_PhoneSizes.sheetBorderRadius.r),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _PhoneSizes.qcPadL.w,
                _PhoneSizes.qcPadT.h,
                _PhoneSizes.qcPadR.w,
                _PhoneSizes.qcPadB.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: _PhoneSizes.qcHeaderIconSize.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: _PhoneSizes.qcHeaderIconSpacing.w),
                      Expanded(
                        child: Text(
                          video.universityName ?? video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: _PhoneSizes.qcHeaderTextFontSize.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close_rounded,
                          size: _PhoneSizes.qcCloseIconSize.sp,
                          color: AppTheme.textSec(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _PhoneSizes.qcTitleSpacing.h),
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _PhoneSizes.qcTitleFontSize.sp,
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.qcInputSpacing.h),
                  Obx(() {
                    final isSending = controller.quickCommentSendingIds
                        .contains(video.videoId);
                    return AbsorbPointer(
                      absorbing: isSending,
                      child: Opacity(
                        opacity: isSending ? 0.5 : 1,
                        child: CommentInputWidget(
                          onSend: (String text) async {
                            final ok = await controller.sendQuickComment(
                              video,
                              text,
                            );
                            if (ok) {
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

  // ── TABLET SHEET'LER ──

  void _showTabletVideoOptionsSheet(
    BuildContext context,
    HomeController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_TabletSizes.sheetBorderRadius),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: _TabletSizes.handleTopSpacing),
              Container(
                width: _TabletSizes.handleWidth,
                height: _TabletSizes.handleHeight,
                decoration: BoxDecoration(
                  color: AppTheme.textSec(
                    context,
                  ).withValues(alpha: _TabletSizes.handleAlpha),
                  borderRadius: BorderRadius.circular(
                    _TabletSizes.handleBorderRadius,
                  ),
                ),
              ),
              SizedBox(height: _TabletSizes.handleBottomSpacing),
              _OptionTileTablet(
                themeContext: context,
                icon: Icons.bolt_rounded,
                iconColor: Theme.of(context).colorScheme.primary,
                label: 'Hızlı Yorum Gönder',
                subtitle: 'Videoyu açmadan yorum yap',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showQuickCommentSheet(context, controller);
                },
              ),
              _OptionTileTablet(
                themeContext: context,
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
              Obx(() {
                final isFav = controller.favoriteIds.contains(video.videoId);
                return _OptionTileTablet(
                  themeContext: context,
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
              _OptionTileTablet(
                themeContext: context,
                icon: Icons.send_outlined,
                label: 'Paylaş',
                onTap: () {
                  Navigator.pop(sheetContext);
                  controller.shareVideo(video);
                },
              ),
              SizedBox(height: _TabletSizes.optBottomSpacing),
            ],
          ),
        );
      },
    );
  }

  void _showTabletQuickCommentSheet(
    BuildContext context,
    HomeController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(_TabletSizes.sheetBorderRadius),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.qcPadL,
                _TabletSizes.qcPadT,
                _TabletSizes.qcPadR,
                _TabletSizes.qcPadB,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: _TabletSizes.qcHeaderIconSize,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: _TabletSizes.qcHeaderIconSpacing),
                      Expanded(
                        child: Text(
                          video.universityName ?? video.channelTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: _TabletSizes.qcHeaderTextFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close_rounded,
                          size: _TabletSizes.qcCloseIconSize,
                          color: AppTheme.textSec(context),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: _TabletSizes.qcTitleSpacing),
                  Text(
                    video.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: _TabletSizes.qcTitleFontSize,
                    ),
                  ),
                  SizedBox(height: _TabletSizes.qcInputSpacing),
                  Obx(() {
                    final isSending = controller.quickCommentSendingIds
                        .contains(video.videoId);
                    return AbsorbPointer(
                      absorbing: isSending,
                      child: Opacity(
                        opacity: isSending ? 0.5 : 1,
                        child: CommentInputWidget(
                          onSend: (String text) async {
                            final ok = await controller.sendQuickComment(
                              video,
                              text,
                            );
                            if (ok) {
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
}

// ═══════════════════════════════════════════════════════════════════════
// ALT SEVİYE PHONE WIDGET'LARI
// ═══════════════════════════════════════════════════════════════════════

class _OptionTilePhone extends StatelessWidget {
  final BuildContext themeContext;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? subtitle;

  const _OptionTilePhone({
    required this.themeContext,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.optTilePadH.w,
          vertical: _PhoneSizes.optTilePadV.h,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: _PhoneSizes.optIconSize.sp,
              color: iconColor ?? AppTheme.textPri(themeContext),
            ),
            SizedBox(width: _PhoneSizes.optIconSpacing.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textPri(themeContext),
                      fontSize: _PhoneSizes.optLabelFontSize.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: _PhoneSizes.optSubtitleSpacing.h),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppTheme.textSec(themeContext),
                        fontSize: _PhoneSizes.optSubtitleFontSize.sp,
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
}

class _IgActionBtnPhone extends StatelessWidget {
  final BuildContext themeContext;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int count;
  final bool isActive;

  const _IgActionBtnPhone({
    required this.themeContext,
    required this.icon,
    required this.color,
    required this.onTap,
    this.count = 0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(
          _PhoneSizes.actionBtnBorderRadius.r,
        ),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(_PhoneSizes.actionBtnPadding.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: _PhoneSizes.actionIconSize.sp),
              if (count > 0) ...[
                SizedBox(width: _PhoneSizes.actionIconTextSpacing.w),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textSec(themeContext),
                    fontSize: _PhoneSizes.actionTextFontSize.sp,
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
}

class _LiveBadgePhone extends StatelessWidget {
  final String label;
  final Color color;

  const _LiveBadgePhone({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.badgePadH.w,
        vertical: _PhoneSizes.badgePadV.h,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_PhoneSizes.badgeBorderRadius.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: Colors.white,
            size: _PhoneSizes.badgeDotSize.sp,
          ),
          SizedBox(width: _PhoneSizes.badgeDotSpacing.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: _PhoneSizes.badgeFontSize.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: _PhoneSizes.badgeLetterSpacing,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallbackPhone extends StatelessWidget {
  final BuildContext themeContext;
  const _AvatarFallbackPhone({required this.themeContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface(themeContext),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(themeContext),
        size: _PhoneSizes.avatarFallbackIconSize.sp,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ALT SEVİYE TABLET WIDGET'LARI
// ═══════════════════════════════════════════════════════════════════════

class _OptionTileTablet extends StatelessWidget {
  final BuildContext themeContext;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final String? subtitle;

  const _OptionTileTablet({
    required this.themeContext,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.optTilePadH,
          vertical: _TabletSizes.optTilePadV,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: _TabletSizes.optIconSize,
              color: iconColor ?? AppTheme.textPri(themeContext),
            ),
            SizedBox(width: _TabletSizes.optIconSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppTheme.textPri(themeContext),
                      fontSize: _TabletSizes.optLabelFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: _TabletSizes.optSubtitleSpacing),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: AppTheme.textSec(themeContext),
                        fontSize: _TabletSizes.optSubtitleFontSize,
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
}

class _IgActionBtnTablet extends StatelessWidget {
  final BuildContext themeContext;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int count;
  final bool isActive;

  const _IgActionBtnTablet({
    required this.themeContext,
    required this.icon,
    required this.color,
    required this.onTap,
    this.count = 0,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_TabletSizes.actionBtnBorderRadius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(_TabletSizes.actionBtnPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: _TabletSizes.actionIconSize),
              if (count > 0) ...[
                SizedBox(width: _TabletSizes.actionIconTextSpacing),
                Text(
                  _formatCount(count),
                  style: TextStyle(
                    color: isActive ? color : AppTheme.textSec(themeContext),
                    fontSize: _TabletSizes.actionTextFontSize,
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
}

class _LiveBadgeTablet extends StatelessWidget {
  final String label;
  final Color color;

  const _LiveBadgeTablet({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.badgePadH,
        vertical: _TabletSizes.badgePadV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_TabletSizes.badgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            color: Colors.white,
            size: _TabletSizes.badgeDotSize,
          ),
          SizedBox(width: _TabletSizes.badgeDotSpacing),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: _TabletSizes.badgeFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: _TabletSizes.badgeLetterSpacing,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallbackTablet extends StatelessWidget {
  final BuildContext themeContext;
  const _AvatarFallbackTablet({required this.themeContext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface(themeContext),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(themeContext),
        size: _TabletSizes.avatarFallbackIconSize,
      ),
    );
  }
}
