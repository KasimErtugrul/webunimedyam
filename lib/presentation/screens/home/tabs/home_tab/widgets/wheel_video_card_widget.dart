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
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../core/widgets/hover_tap.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home/home_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Kart
  static const double cardBorderRadius = 20;
  static const double mediaHeight = 196;
  static const double statsHeight = 36;
  static const double topGradientHeight = 68;
  static const double bottomGradientHeight = 108;
  static const double bottomGradientOpacity = 0.82;

  // Box shadow
  static const double shadowBlurRadius = 20;

  // Thumbnail
  static const double errorIconSize = 30;
  static const double progressIndicatorStrokeWidth = 2;

  // Play icon
  //static const double playIconPadding = 10;
  // static const double playIconSize = 26;

  // Title & time (alt)
  static const double titleLeft = 12;
  static const double titleRight = 12;
  static const double titleBottom = 10;
  static const double titleFontSize = 13.5;
  static const double titleLineHeight = 1.25;
  static const double titleSpacing = 3;
  static const double timeFontSize = 9.5;

  // University block (sol üst)
  static const double uniBlockTop = 10;
  static const double uniBlockLeft = 10;
  static const double uniBlockRight = 92;
  static const double uniNameFontSize = 11.5;
  static const double uniButtonSpacing = 5;
  static const double followButtonPaddingHorizontal = 9;
  static const double followButtonPaddingVertical = 4;
  static const double followButtonRadius = 20;
  static const double followIconSize = 12;
  static const double followTextSize = 9;
  static const double followSpacing = 3;

  // Badge (sağ üst)
  static const double badgeTop = 10;
  static const double badgeRight = 10;
  static const double badgePaddingHorizontal = 7;
  static const double badgePaddingVertical = 3;
  static const double badgeRadius = 7;
  static const double badgeIconSize = 5;
  static const double badgeSpacing = 3;
  static const double badgeFontSize = 8;
  static const double badgeShadowBlur = 6;
  static const double badgeSpacingBetween = 4;

  // Pill label
  static const double pillPaddingHorizontal = 7;
  static const double pillPaddingVertical = 3;
  static const double pillPaddingHorizontalSmall = 5;
  static const double pillPaddingVerticalSmall = 2;
  static const double pillRadius = 6;
  static const double pillFontSize = 9;
  static const double pillFontSizeSmall = 8;
  static const double pillSpacing = 4;

  // Stats row
  static const double statsPaddingLeft = 10;
  static const double statsPaddingTop = 6;
  static const double statsPaddingRight = 10;
  static const double statsPaddingBottom = 0;
  static const double statIconSize = 15;
  static const double statFontSize = 9.5;
  static const double statSpacing = 3;
  static const double statPaddingHorizontal = 6;
  static const double statPaddingVertical = 6;
  static const double statRadius = 10;
  static const double statLoadingSize = 13;
  static const double statLoadingStrokeWidth = 2;

  // Description
  static const double descPaddingLeft = 12;
  static const double descPaddingTop = 8;
  static const double descPaddingRight = 12;
  static const double descPaddingBottom = 12;
  static const double descFontSize = 11.5;
  static const double descLineHeight = 1.45;
}

class _TabletSizes {
  // Kart - tablet için daha büyük
  static const double cardBorderRadius = 24;
  static const double mediaHeight = 260;
  static const double statsHeight = 44;
  static const double topGradientHeight = 80;
  static const double bottomGradientHeight = 130;
  static const double bottomGradientOpacity = 0.85;

  // Box shadow
  static const double shadowBlurRadius = 24;

  // Thumbnail
  static const double errorIconSize = 40;
  static const double progressIndicatorStrokeWidth = 2.5;

  // Play icon
  // static const double playIconPadding = 14;
  // static const double playIconSize = 34;

  // Title & time (alt)
  static const double titleLeft = 16;
  static const double titleRight = 16;
  static const double titleBottom = 14;
  static const double titleFontSize = 17;
  static const double titleLineHeight = 1.3;
  static const double titleSpacing = 4;
  static const double timeFontSize = 12;

  // University block (sol üst)
  static const double uniBlockTop = 14;
  static const double uniBlockLeft = 14;
  static const double uniBlockRight = 120;
  static const double uniNameFontSize = 15;
  static const double uniButtonSpacing = 6;
  static const double followButtonPaddingHorizontal = 12;
  static const double followButtonPaddingVertical = 6;
  static const double followButtonRadius = 24;
  static const double followIconSize = 16;
  static const double followTextSize = 12;
  static const double followSpacing = 4;

  // Badge (sağ üst)
  static const double badgeTop = 14;
  static const double badgeRight = 14;
  static const double badgePaddingHorizontal = 10;
  static const double badgePaddingVertical = 5;
  static const double badgeRadius = 8;
  static const double badgeIconSize = 7;
  static const double badgeSpacing = 4;
  static const double badgeFontSize = 10;
  static const double badgeShadowBlur = 8;
  static const double badgeSpacingBetween = 6;

  // Pill label
  static const double pillPaddingHorizontal = 10;
  static const double pillPaddingVertical = 4;
  static const double pillPaddingHorizontalSmall = 7;
  static const double pillPaddingVerticalSmall = 3;
  static const double pillRadius = 8;
  static const double pillFontSize = 11;
  static const double pillFontSizeSmall = 10;
  static const double pillSpacing = 6;

  // Stats row
  static const double statsPaddingLeft = 14;
  static const double statsPaddingTop = 8;
  static const double statsPaddingRight = 14;
  static const double statsPaddingBottom = 0;
  static const double statIconSize = 19;
  static const double statFontSize = 12;
  static const double statSpacing = 4;
  static const double statPaddingHorizontal = 8;
  static const double statPaddingVertical = 8;
  static const double statRadius = 12;
  static const double statLoadingSize = 17;
  static const double statLoadingStrokeWidth = 2.5;

  // Description
  static const double descPaddingLeft = 16;
  static const double descPaddingTop = 10;
  static const double descPaddingRight = 16;
  static const double descPaddingBottom = 16;
  static const double descFontSize = 15;
  static const double descLineHeight = 1.5;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════

class WheelVideoCardWidget extends StatelessWidget {
  final VideoModel video;
  final UniversityModel? university;

  const WheelVideoCardWidget({super.key, required this.video, this.university});

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI (üçlü ölçek: web → tablet → telefon)
    if (Responsive.isWeb(context)) return _buildWeb(context);
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final controller = Get.find<HomeController>();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_PhoneSizes.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.28 : 0.06,
            ),
            blurRadius: _PhoneSizes.shadowBlurRadius,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _PhoneSizes.mediaHeight,
            child: _buildMediaPhone(context, controller),
          ),
          SizedBox(
            height: _PhoneSizes.statsHeight,
            child: _buildStatsRowPhone(context, controller),
          ),
          Expanded(child: _buildDescriptionPhone(context)),
        ],
      ),
    );
  }

  // ── Phone Media ──
  Widget _buildMediaPhone(BuildContext context, HomeController controller) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return Stack(
      fit: StackFit.expand,
      children: [
        TapCursor(
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
                placeholder: (_, _) => Container(
                  color: AppTheme.surface(context),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: _PhoneSizes.progressIndicatorStrokeWidth,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: _PhoneSizes.errorIconSize,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _PhoneSizes.topGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _PhoneSizes.bottomGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(
                          alpha: _PhoneSizes.bottomGradientOpacity,
                        ),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _PhoneSizes.titleLeft,
                right: _PhoneSizes.titleRight,
                bottom: _PhoneSizes.titleBottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: _PhoneSizes.titleFontSize,
                        fontWeight: FontWeight.w700,
                        height: _PhoneSizes.titleLineHeight,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: _PhoneSizes.titleSpacing),
                    Text(
                      timeago.format(video.publishedAt, locale: 'tr'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: _PhoneSizes.timeFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: _PhoneSizes.uniBlockTop,
          left: _PhoneSizes.uniBlockLeft,
          right: _PhoneSizes.uniBlockRight,
          child: _buildUniversityBlockPhone(context, controller),
        ),
        Positioned(
          top: _PhoneSizes.badgeTop,
          right: _PhoneSizes.badgeRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLive) _badgePhone('CANLI', const Color(0xFFE53935)),
              if (isUpcoming) _badgePhone('YAKINDA', const Color(0xFF5C6BC0)),
              if (isLive || isUpcoming)
                const SizedBox(height: _PhoneSizes.badgeSpacingBetween),
              Row(
                children: [
                  if (video.isHd) ...[
                    _pillLabelPhone('HD', small: true),
                    const SizedBox(width: _PhoneSizes.pillSpacing),
                  ],
                  if (!isLive) _pillLabelPhone(video.formattedDuration),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Phone University Block ──
  Widget _buildUniversityBlockPhone(
    BuildContext context,
    HomeController controller,
  ) {
    final uni = university;
    final name = uni?.name ?? video.universityName ?? video.channelTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TapCursor(
          onTap: uni == null
              ? null
              : () => Get.toNamed(AppRoutes.universityDetail, arguments: uni),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _PhoneSizes.uniNameFontSize,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
        const SizedBox(height: _PhoneSizes.uniButtonSpacing),
        Obx(() {
          final uniId = uni?.id ?? video.universityId;
          final isFav = controller.favoriteUniversityIds.contains(uniId);
          return TapCursor(
            onTap: uni == null
                ? null
                : () => controller.toggleUniversityFavorite(uni),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: _PhoneSizes.followButtonPaddingHorizontal,
                vertical: _PhoneSizes.followButtonPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.white.withValues(alpha: 0.16)
                    : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(
                  _PhoneSizes.followButtonRadius,
                ),
                border: isFav
                    ? Border.all(color: Colors.white.withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFav ? Icons.check_rounded : Icons.add_rounded,
                    size: _PhoneSizes.followIconSize,
                    color: Colors.white,
                  ),
                  const SizedBox(width: _PhoneSizes.followSpacing),
                  Text(
                    isFav ? 'Takipte' : 'Takip Et',
                    style: const TextStyle(
                      fontSize: _PhoneSizes.followTextSize,
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

  Widget _badgePhone(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _PhoneSizes.badgePaddingHorizontal,
        vertical: _PhoneSizes.badgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_PhoneSizes.badgeRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: _PhoneSizes.badgeShadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.white,
            size: _PhoneSizes.badgeIconSize,
          ),
          const SizedBox(width: _PhoneSizes.badgeSpacing),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _PhoneSizes.badgeFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillLabelPhone(String label, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small
            ? _PhoneSizes.pillPaddingHorizontalSmall
            : _PhoneSizes.pillPaddingHorizontal,
        vertical: small
            ? _PhoneSizes.pillPaddingVerticalSmall
            : _PhoneSizes.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(_PhoneSizes.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small
              ? _PhoneSizes.pillFontSizeSmall
              : _PhoneSizes.pillFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Phone Stats Row ──
  // FIX: 5 istatistik (görüntülenme/beğeni/yorum/paylaş/kaydet) + sabit
  // padding'ler, küçük telefon genişliklerinde veya erişilebilirlik
  // textScaler > ~1.4 değerlerinde yatayda taşabiliyordu. Sol istatistik
  // grubu `Expanded + FittedBox(scaleDown)` içine alındı; alan yetmezse
  // yalnızca bu grup oransal olarak küçülür, sağdaki kaydet ikonu sağ
  // kenardaki konumunu korur. Sayılar ellipsis ile anlamsızca
  // kırpılmak yerine küçültüldüğü için okunabilirlik korunur.
  Widget _buildStatsRowPhone(BuildContext context, HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _PhoneSizes.statsPaddingLeft,
        _PhoneSizes.statsPaddingTop,
        _PhoneSizes.statsPaddingRight,
        _PhoneSizes.statsPaddingBottom,
      ),
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
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _statItemPhone(
                      context,
                      icon: Icons.visibility_outlined,
                      count: views,
                    ),
                    _statItemPhone(
                      context,
                      icon: liked
                          ? Icons.thumb_up_rounded
                          : Icons.thumb_up_outlined,
                      count: likes,
                      isActive: liked,
                      onTap: () => controller.toggleLike(video.videoId),
                    ),
                    _statItemPhone(
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: _PhoneSizes.statPaddingHorizontal,
                        ),
                        child: SizedBox(
                          width: _PhoneSizes.statLoadingSize,
                          height: _PhoneSizes.statLoadingSize,
                          child: CircularProgressIndicator(
                            strokeWidth: _PhoneSizes.statLoadingStrokeWidth,
                            color: AppTheme.textSec(context),
                          ),
                        ),
                      )
                    else
                      _statItemPhone(
                        context,
                        icon: hasShared
                            ? Icons.send_rounded
                            : Icons.send_outlined,
                        count: shares,
                        isActive: hasShared,
                        onTap: () => controller.shareVideo(video),
                      ),
                  ],
                ),
              ),
            ),
            _statItemPhone(
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

  Widget _statItemPhone(
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
        Icon(icon, size: _PhoneSizes.statIconSize, color: color),
        if (count > 0) ...[
          const SizedBox(width: _PhoneSizes.statSpacing),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: color,
              fontSize: _PhoneSizes.statFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _PhoneSizes.statPaddingHorizontal,
        ),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_PhoneSizes.statRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _PhoneSizes.statPaddingHorizontal,
            vertical: _PhoneSizes.statPaddingVertical,
          ),
          child: content,
        ),
      ),
    );
  }

  // ── Phone Description ──
  Widget _buildDescriptionPhone(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    final descriptionText = hasDescription
        ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
        : 'Bu video için açıklama bulunmuyor.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _PhoneSizes.descPaddingLeft,
        _PhoneSizes.descPaddingTop,
        _PhoneSizes.descPaddingRight,
        _PhoneSizes.descPaddingBottom,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          descriptionText,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _PhoneSizes.descFontSize,
            height: _PhoneSizes.descLineHeight,
            fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final controller = Get.find<HomeController>();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_TabletSizes.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.28 : 0.06,
            ),
            blurRadius: _TabletSizes.shadowBlurRadius,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _TabletSizes.mediaHeight,
            child: _buildMediaTablet(context, controller),
          ),
          SizedBox(
            height: _TabletSizes.statsHeight,
            child: _buildStatsRowTablet(context, controller),
          ),
          Expanded(child: _buildDescriptionTablet(context)),
        ],
      ),
    );
  }

  // ── Tablet Media ──
  Widget _buildMediaTablet(BuildContext context, HomeController controller) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return Stack(
      fit: StackFit.expand,
      children: [
        TapCursor(
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
                placeholder: (_, _) => Container(
                  color: AppTheme.surface(context),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: _TabletSizes.progressIndicatorStrokeWidth,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: _TabletSizes.errorIconSize,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _TabletSizes.topGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _TabletSizes.bottomGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(
                          alpha: _TabletSizes.bottomGradientOpacity,
                        ),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _TabletSizes.titleLeft,
                right: _TabletSizes.titleRight,
                bottom: _TabletSizes.titleBottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: _TabletSizes.titleFontSize,
                        fontWeight: FontWeight.w700,
                        height: _TabletSizes.titleLineHeight,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: _TabletSizes.titleSpacing),
                    Text(
                      timeago.format(video.publishedAt, locale: 'tr'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: _TabletSizes.timeFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: _TabletSizes.uniBlockTop,
          left: _TabletSizes.uniBlockLeft,
          right: _TabletSizes.uniBlockRight,
          child: _buildUniversityBlockTablet(context, controller),
        ),
        Positioned(
          top: _TabletSizes.badgeTop,
          right: _TabletSizes.badgeRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLive) _badgeTablet('CANLI', const Color(0xFFE53935)),
              if (isUpcoming) _badgeTablet('YAKINDA', const Color(0xFF5C6BC0)),
              if (isLive || isUpcoming)
                const SizedBox(height: _TabletSizes.badgeSpacingBetween),
              Row(
                children: [
                  if (video.isHd) ...[
                    _pillLabelTablet('HD', small: true),
                    const SizedBox(width: _TabletSizes.pillSpacing),
                  ],
                  if (!isLive) _pillLabelTablet(video.formattedDuration),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tablet University Block ──
  Widget _buildUniversityBlockTablet(
    BuildContext context,
    HomeController controller,
  ) {
    final uni = university;
    final name = uni?.name ?? video.universityName ?? video.channelTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TapCursor(
          onTap: uni == null
              ? null
              : () => Get.toNamed(AppRoutes.universityDetail, arguments: uni),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _TabletSizes.uniNameFontSize,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
        const SizedBox(height: _TabletSizes.uniButtonSpacing),
        Obx(() {
          final uniId = uni?.id ?? video.universityId;
          final isFav = controller.favoriteUniversityIds.contains(uniId);
          return TapCursor(
            onTap: uni == null
                ? null
                : () => controller.toggleUniversityFavorite(uni),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: _TabletSizes.followButtonPaddingHorizontal,
                vertical: _TabletSizes.followButtonPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.white.withValues(alpha: 0.16)
                    : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(
                  _TabletSizes.followButtonRadius,
                ),
                border: isFav
                    ? Border.all(color: Colors.white.withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFav ? Icons.check_rounded : Icons.add_rounded,
                    size: _TabletSizes.followIconSize,
                    color: Colors.white,
                  ),
                  const SizedBox(width: _TabletSizes.followSpacing),
                  Text(
                    isFav ? 'Takipte' : 'Takip Et',
                    style: const TextStyle(
                      fontSize: _TabletSizes.followTextSize,
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

  Widget _badgeTablet(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _TabletSizes.badgePaddingHorizontal,
        vertical: _TabletSizes.badgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_TabletSizes.badgeRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: _TabletSizes.badgeShadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.white,
            size: _TabletSizes.badgeIconSize,
          ),
          const SizedBox(width: _TabletSizes.badgeSpacing),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _TabletSizes.badgeFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillLabelTablet(String label, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small
            ? _TabletSizes.pillPaddingHorizontalSmall
            : _TabletSizes.pillPaddingHorizontal,
        vertical: small
            ? _TabletSizes.pillPaddingVerticalSmall
            : _TabletSizes.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(_TabletSizes.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small
              ? _TabletSizes.pillFontSizeSmall
              : _TabletSizes.pillFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Tablet Stats Row ──
  Widget _buildStatsRowTablet(BuildContext context, HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _TabletSizes.statsPaddingLeft,
        _TabletSizes.statsPaddingTop,
        _TabletSizes.statsPaddingRight,
        _TabletSizes.statsPaddingBottom,
      ),
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
            _statItemTablet(
              context,
              icon: Icons.visibility_outlined,
              count: views,
            ),
            _statItemTablet(
              context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              count: likes,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            ),
            _statItemTablet(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: _TabletSizes.statPaddingHorizontal,
                ),
                child: SizedBox(
                  width: _TabletSizes.statLoadingSize,
                  height: _TabletSizes.statLoadingSize,
                  child: CircularProgressIndicator(
                    strokeWidth: _TabletSizes.statLoadingStrokeWidth,
                    color: AppTheme.textSec(context),
                  ),
                ),
              )
            else
              _statItemTablet(
                context,
                icon: hasShared ? Icons.send_rounded : Icons.send_outlined,
                count: shares,
                isActive: hasShared,
                onTap: () => controller.shareVideo(video),
              ),
            const Spacer(),
            _statItemTablet(
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

  Widget _statItemTablet(
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
        Icon(icon, size: _TabletSizes.statIconSize, color: color),
        if (count > 0) ...[
          const SizedBox(width: _TabletSizes.statSpacing),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: color,
              fontSize: _TabletSizes.statFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _TabletSizes.statPaddingHorizontal,
        ),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_TabletSizes.statRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _TabletSizes.statPaddingHorizontal,
            vertical: _TabletSizes.statPaddingVertical,
          ),
          child: content,
        ),
      ),
    );
  }

  // ── Tablet Description ──
  Widget _buildDescriptionTablet(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    final descriptionText = hasDescription
        ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
        : 'Bu video için açıklama bulunmuyor.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _TabletSizes.descPaddingLeft,
        _TabletSizes.descPaddingTop,
        _TabletSizes.descPaddingRight,
        _TabletSizes.descPaddingBottom,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          descriptionText,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _TabletSizes.descFontSize,
            height: _TabletSizes.descLineHeight,
            fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2b — WEB TASARIMI (tablet ağacının web ölçeği)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildWeb(BuildContext context) {
    final controller = Get.find<HomeController>();
    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_WebSizes.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.28 : 0.06,
            ),
            blurRadius: _WebSizes.shadowBlurRadius,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _WebSizes.mediaHeight,
            child: _buildMediaWeb(context, controller),
          ),
          SizedBox(
            height: _WebSizes.statsHeight,
            child: _buildStatsRowWeb(context, controller),
          ),
          Expanded(child: _buildDescriptionWeb(context)),
        ],
      ),
    );
  }

  // ── Tablet Media ──
  Widget _buildMediaWeb(BuildContext context, HomeController controller) {
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    return Stack(
      fit: StackFit.expand,
      children: [
        TapCursor(
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
                placeholder: (_, _) => Container(
                  color: AppTheme.surface(context),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                      strokeWidth: _WebSizes.progressIndicatorStrokeWidth,
                    ),
                  ),
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppTheme.surface(context),
                  child: Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.textSec(context),
                    size: _WebSizes.errorIconSize,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: _WebSizes.topGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _WebSizes.bottomGradientHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(
                          alpha: _WebSizes.bottomGradientOpacity,
                        ),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: _WebSizes.titleLeft,
                right: _WebSizes.titleRight,
                bottom: _WebSizes.titleBottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: _WebSizes.titleFontSize,
                        fontWeight: FontWeight.w700,
                        height: _WebSizes.titleLineHeight,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                    const SizedBox(height: _WebSizes.titleSpacing),
                    Text(
                      timeago.format(video.publishedAt, locale: 'tr'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: _WebSizes.timeFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: _WebSizes.uniBlockTop,
          left: _WebSizes.uniBlockLeft,
          right: _WebSizes.uniBlockRight,
          child: _buildUniversityBlockWeb(context, controller),
        ),
        Positioned(
          top: _WebSizes.badgeTop,
          right: _WebSizes.badgeRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isLive) _badgeWeb('CANLI', const Color(0xFFE53935)),
              if (isUpcoming) _badgeWeb('YAKINDA', const Color(0xFF5C6BC0)),
              if (isLive || isUpcoming)
                const SizedBox(height: _WebSizes.badgeSpacingBetween),
              Row(
                children: [
                  if (video.isHd) ...[
                    _pillLabelWeb('HD', small: true),
                    const SizedBox(width: _WebSizes.pillSpacing),
                  ],
                  if (!isLive) _pillLabelWeb(video.formattedDuration),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Tablet University Block ──
  Widget _buildUniversityBlockWeb(
    BuildContext context,
    HomeController controller,
  ) {
    final uni = university;
    final name = uni?.name ?? video.universityName ?? video.channelTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TapCursor(
          onTap: uni == null
              ? null
              : () => Get.toNamed(AppRoutes.universityDetail, arguments: uni),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _WebSizes.uniNameFontSize,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
        const SizedBox(height: _WebSizes.uniButtonSpacing),
        Obx(() {
          final uniId = uni?.id ?? video.universityId;
          final isFav = controller.favoriteUniversityIds.contains(uniId);
          return TapCursor(
            onTap: uni == null
                ? null
                : () => controller.toggleUniversityFavorite(uni),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: _WebSizes.followButtonPaddingHorizontal,
                vertical: _WebSizes.followButtonPaddingVertical,
              ),
              decoration: BoxDecoration(
                color: isFav
                    ? Colors.white.withValues(alpha: 0.16)
                    : AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(
                  _WebSizes.followButtonRadius,
                ),
                border: isFav
                    ? Border.all(color: Colors.white.withValues(alpha: 0.5))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFav ? Icons.check_rounded : Icons.add_rounded,
                    size: _WebSizes.followIconSize,
                    color: Colors.white,
                  ),
                  const SizedBox(width: _WebSizes.followSpacing),
                  Text(
                    isFav ? 'Takipte' : 'Takip Et',
                    style: const TextStyle(
                      fontSize: _WebSizes.followTextSize,
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

  Widget _badgeWeb(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _WebSizes.badgePaddingHorizontal,
        vertical: _WebSizes.badgePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_WebSizes.badgeRadius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: _WebSizes.badgeShadowBlur,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.white,
            size: _WebSizes.badgeIconSize,
          ),
          const SizedBox(width: _WebSizes.badgeSpacing),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _WebSizes.badgeFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillLabelWeb(String label, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small
            ? _WebSizes.pillPaddingHorizontalSmall
            : _WebSizes.pillPaddingHorizontal,
        vertical: small
            ? _WebSizes.pillPaddingVerticalSmall
            : _WebSizes.pillPaddingVertical,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(_WebSizes.pillRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: small
              ? _WebSizes.pillFontSizeSmall
              : _WebSizes.pillFontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ── Tablet Stats Row ──
  Widget _buildStatsRowWeb(BuildContext context, HomeController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _WebSizes.statsPaddingLeft,
        _WebSizes.statsPaddingTop,
        _WebSizes.statsPaddingRight,
        _WebSizes.statsPaddingBottom,
      ),
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
            _statItemWeb(
              context,
              icon: Icons.visibility_outlined,
              count: views,
            ),
            _statItemWeb(
              context,
              icon: liked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
              count: likes,
              isActive: liked,
              onTap: () => controller.toggleLike(video.videoId),
            ),
            _statItemWeb(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: _WebSizes.statPaddingHorizontal,
                ),
                child: SizedBox(
                  width: _WebSizes.statLoadingSize,
                  height: _WebSizes.statLoadingSize,
                  child: CircularProgressIndicator(
                    strokeWidth: _WebSizes.statLoadingStrokeWidth,
                    color: AppTheme.textSec(context),
                  ),
                ),
              )
            else
              _statItemWeb(
                context,
                icon: hasShared ? Icons.send_rounded : Icons.send_outlined,
                count: shares,
                isActive: hasShared,
                onTap: () => controller.shareVideo(video),
              ),
            const Spacer(),
            _statItemWeb(
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

  Widget _statItemWeb(
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
        Icon(icon, size: _WebSizes.statIconSize, color: color),
        if (count > 0) ...[
          const SizedBox(width: _WebSizes.statSpacing),
          Text(
            _formatCount(count),
            style: TextStyle(
              color: color,
              fontSize: _WebSizes.statFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _WebSizes.statPaddingHorizontal,
        ),
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_WebSizes.statRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _WebSizes.statPaddingHorizontal,
            vertical: _WebSizes.statPaddingVertical,
          ),
          child: content,
        ),
      ),
    );
  }

  // ── Tablet Description ──
  Widget _buildDescriptionWeb(BuildContext context) {
    final hasDescription = video.description.trim().isNotEmpty;
    final descriptionText = hasDescription
        ? video.description.replaceAll(RegExp(r'\n{2,}'), '\n')
        : 'Bu video için açıklama bulunmuyor.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _WebSizes.descPaddingLeft,
        _WebSizes.descPaddingTop,
        _WebSizes.descPaddingRight,
        _WebSizes.descPaddingBottom,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          descriptionText,
          overflow: TextOverflow.fade,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: _WebSizes.descFontSize,
            height: _WebSizes.descLineHeight,
            fontStyle: hasDescription ? FontStyle.normal : FontStyle.italic,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ORTAK YARDIMCI METODLAR
  // ═══════════════════════════════════════════════════════════════════════

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

// ═══════════════════════════════════════════════════════════
// WEB SABİTLERİ — masaüstü tarayıcı (≥1024px). Tablet ölçülerini
// temel alır; medya yüksekliği ve tipografi masaüstüne büyütülür.
// ═══════════════════════════════════════════════════════════
class _WebSizes {
  // Kart - tablet için daha büyük
  static const double cardBorderRadius = 24;
  static const double mediaHeight = 300;
  static const double statsHeight = 48;
  static const double topGradientHeight = 88;
  static const double bottomGradientHeight = 140;
  static const double bottomGradientOpacity = 0.85;

  // Box shadow
  static const double shadowBlurRadius = 24;

  // Thumbnail
  static const double errorIconSize = 40;
  static const double progressIndicatorStrokeWidth = 2.5;

  // Play icon
  // static const double playIconPadding = 14;
  // static const double playIconSize = 34;

  // Title & time (alt)
  static const double titleLeft = 16;
  static const double titleRight = 16;
  static const double titleBottom = 14;
  static const double titleFontSize = 19;
  static const double titleLineHeight = 1.3;
  static const double titleSpacing = 4;
  static const double timeFontSize = 13;

  // University block (sol üst)
  static const double uniBlockTop = 14;
  static const double uniBlockLeft = 14;
  static const double uniBlockRight = 120;
  static const double uniNameFontSize = 16.5;
  static const double uniButtonSpacing = 6;
  static const double followButtonPaddingHorizontal = 12;
  static const double followButtonPaddingVertical = 6;
  static const double followButtonRadius = 24;
  static const double followIconSize = 17;
  static const double followTextSize = 13;
  static const double followSpacing = 4;

  // Badge (sağ üst)
  static const double badgeTop = 14;
  static const double badgeRight = 14;
  static const double badgePaddingHorizontal = 10;
  static const double badgePaddingVertical = 5;
  static const double badgeRadius = 8;
  static const double badgeIconSize = 7;
  static const double badgeSpacing = 4;
  static const double badgeFontSize = 11;
  static const double badgeShadowBlur = 8;
  static const double badgeSpacingBetween = 6;

  // Pill label
  static const double pillPaddingHorizontal = 10;
  static const double pillPaddingVertical = 4;
  static const double pillPaddingHorizontalSmall = 7;
  static const double pillPaddingVerticalSmall = 3;
  static const double pillRadius = 8;
  static const double pillFontSize = 12;
  static const double pillFontSizeSmall = 11;
  static const double pillSpacing = 6;

  // Stats row
  static const double statsPaddingLeft = 14;
  static const double statsPaddingTop = 8;
  static const double statsPaddingRight = 14;
  static const double statsPaddingBottom = 0;
  static const double statIconSize = 21;
  static const double statFontSize = 13;
  static const double statSpacing = 4;
  static const double statPaddingHorizontal = 8;
  static const double statPaddingVertical = 8;
  static const double statRadius = 12;
  static const double statLoadingSize = 17;
  static const double statLoadingStrokeWidth = 2.5;

  // Description
  static const double descPaddingLeft = 16;
  static const double descPaddingTop = 10;
  static const double descPaddingRight = 16;
  static const double descPaddingBottom = 16;
  static const double descFontSize = 16.5;
  static const double descLineHeight = 1.5;
}
