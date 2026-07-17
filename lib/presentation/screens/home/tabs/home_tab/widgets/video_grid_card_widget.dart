// lib/presentation/screens/home/tabs/home_tab/widgets/video_grid_card_widget.dart
//
// TABLET ANA SAYFA — GRID KART
// ─────────────────────────────────────────────────────────────────────────
// "İzlemeye Devam Et" bölümünün altında, üniversitelerin son videolarının
// listelendiği ana feed'de kullanılır. Amaç: VideoCardWidget (telefon
// boyutlarında, tam genişlik, çok sayıda satırlı) tasarımın tablette
// ekranı tek bir kartla doldurmasını engellemek — YouTube/Netflix
// benzeri, birden çok sütunlu, kompakt bir kart sunmak.
//
// Bu widget SADECE tablet için kullanılır (VideoCardWidget'ın phone
// tasarımına dokunulmaz).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';

// ═══════════════════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════════════════

class _Sizes {
  static const double cardBorderRadius = 18;
  static const double thumbBadgeTop = 10;
  static const double thumbBadgeLeft = 10;
  static const double badgePadH = 8;
  static const double badgePadV = 4;
  static const double badgeBorderRadius = 6;
  static const double badgeDotSize = 6;
  static const double badgeDotSpacing = 4;
  static const double badgeFontSize = 10;

  static const double durationBottom = 10;
  static const double durationRight = 10;
  static const double durationPadH = 6;
  static const double durationPadV = 3;
  static const double durationBorderRadius = 5;
  static const double durationFontSize = 11;

  static const double bodyPad = 14;
  static const double avatarSize = 30;
  static const double avatarSpacing = 10;
  static const double titleFontSize = 14.5;
  static const double titleLineHeight = 1.28;
  static const double titleToChannelSpacing = 10;
  static const double channelRowSpacing = 12;
  static const double metaFontSize = 12;
  static const double menuIconSize = 19;

  static const double actionRowSpacing = 14;
  static const double actionIconSize = 16.5;
  static const double actionTextFontSize = 11.5;
  static const double actionIconTextSpacing = 4;
  static const double dividerHeight = 1;
}

// Gövde yüksekliği — kartın gerçek içerik yüksekliğinin toplamı:
// bodyPad(14+14) + başlık(2 satır, ~37) + boşluk(10) + kanal satırı
// (avatar 30) + boşluk(12) + ayırıcı(1) + boşluk(12) + istatistik
// satırı(~19) + güvenlik payı.
const double kGridCardBodyHeight = 172;

String _formatCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
  return count.toString();
}

// ═══════════════════════════════════════════════════════════════════════
// ANA WIDGET
// ═══════════════════════════════════════════════════════════════════════

class VideoGridCardWidget extends StatelessWidget {
  final VideoModel video;

  const VideoGridCardWidget({super.key, required this.video});

  void _navigateToUniversityDetail(HomeController controller) {
    final uni = controller.universities.firstWhereOrNull(
      (u) => u.id == video.universityId,
    );
    if (uni != null) {
      Get.toNamed(AppRoutes.universityDetail, arguments: uni);
    }
  }

  void _openPlayer() {
    if (video.isUpcoming) return;
    Get.toNamed(
      AppRoutes.player,
      arguments: video,
      parameters: {'videoId': video.videoId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final isLive = video.isLiveBroadcast;
    final isUpcoming = video.isUpcoming;

    timeago.setLocaleMessages('tr', timeago.TrMessages());

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.circular(_Sizes.cardBorderRadius),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.28 : 0.06,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Küçük Resim ─────────────────────────────────────
          GestureDetector(
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
                : _openPlayer,
            child: AspectRatio(
              aspectRatio: 16 / 9,
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
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: 36,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 40,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0),
                              Colors.black.withValues(alpha: 0.45),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isLive)
                    Positioned(
                      top: _Sizes.thumbBadgeTop,
                      left: _Sizes.thumbBadgeLeft,
                      child: _Badge(
                        label: 'CANLI',
                        color: const Color(0xFFE53935),
                      ),
                    ),
                  if (isUpcoming)
                    Positioned(
                      top: _Sizes.thumbBadgeTop,
                      left: _Sizes.thumbBadgeLeft,
                      child: _Badge(
                        label: 'YAKINDA',
                        color: const Color(0xFF5C6BC0),
                      ),
                    ),
                  if (!isLive)
                    Positioned(
                      bottom: _Sizes.durationBottom,
                      right: _Sizes.durationRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: _Sizes.durationPadH,
                          vertical: _Sizes.durationPadV,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(
                            _Sizes.durationBorderRadius,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: _Sizes.durationFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Gövde: Başlık → Kanal Satırı → Ayırıcı → İstatistikler ─────
          Padding(
            padding: const EdgeInsets.all(_Sizes.bodyPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Başlık — kartın en üstünde, tam genişlikte, öne çıkan öge.
                Text(
                  video.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _Sizes.titleFontSize,
                    fontWeight: FontWeight.w700,
                    height: _Sizes.titleLineHeight,
                  ),
                ),
                SizedBox(height: _Sizes.titleToChannelSpacing),

                // Kanal satırı: avatar + üniversite adı/zaman + üç nokta menü.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _navigateToUniversityDetail(controller),
                      child: ClipOval(
                        child: SizedBox(
                          width: _Sizes.avatarSize,
                          height: _Sizes.avatarSize,
                          child: _buildAvatar(context, controller),
                        ),
                      ),
                    ),
                    SizedBox(width: _Sizes.avatarSpacing),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToUniversityDetail(controller),
                        child: Text(
                          '${video.universityName ?? video.channelTitle} • ${timeago.format(video.publishedAt, locale: 'tr')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: _Sizes.metaFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: _Sizes.avatarSpacing / 2),
                    GestureDetector(
                      onTap: () => _showVideoOptionsSheet(context, controller),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: AppTheme.textSec(context),
                        size: _Sizes.menuIconSize,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: _Sizes.channelRowSpacing),
                Container(
                  height: _Sizes.dividerHeight,
                  color: AppTheme.textSec(context).withValues(alpha: 0.12),
                ),
                SizedBox(height: _Sizes.channelRowSpacing),

                // İstatistik satırı: görüntülenme, beğeni, yorum ve
                // en sağda kaydet — eşit boşluklarla, sabit sıralı.
                Row(
                  children: [
                    Obx(() {
                      final override =
                          controller.viewCountOverrides[video.videoId];
                      final liveVideo = controller.videos.firstWhereOrNull(
                        (v) => v.videoId == video.videoId,
                      );
                      final viewCount =
                          override ??
                          liveVideo?.appViewCount ??
                          video.appViewCount;
                      return _MiniStat(
                        icon: Icons.visibility_outlined,
                        color: AppTheme.textSec(context),
                        text: _formatCount(viewCount),
                      );
                    }),
                    SizedBox(width: _Sizes.actionRowSpacing),
                    Obx(() {
                      final liked = controller.likedVideoIds.contains(
                        video.videoId,
                      );
                      final liveVideo = controller.videos.firstWhereOrNull(
                        (v) => v.videoId == video.videoId,
                      );
                      final likeCount =
                          liveVideo?.appLikeCount ?? video.appLikeCount;
                      return GestureDetector(
                        onTap: () => controller.toggleLike(video.videoId),
                        child: _MiniStat(
                          icon: liked
                              ? Icons.thumb_up_rounded
                              : Icons.thumb_up_outlined,
                          color: liked
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(context),
                          text: _formatCount(likeCount),
                        ),
                      );
                    }),
                    SizedBox(width: _Sizes.actionRowSpacing),
                    GestureDetector(
                      onTap: _openPlayer,
                      child: Obx(() {
                        final hasCommented = controller.commentedVideoIds
                            .contains(video.videoId);
                        final extra = controller.extraCommentCountFor(
                          video.videoId,
                        );
                        return _MiniStat(
                          icon: hasCommented
                              ? Icons.mode_comment_rounded
                              : Icons.mode_comment_outlined,
                          color: hasCommented
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(context),
                          text: _formatCount(video.appCommentCount + extra),
                        );
                      }),
                    ),
                    const Spacer(),
                    Obx(() {
                      final isFav = controller.favoriteIds.contains(
                        video.videoId,
                      );
                      return GestureDetector(
                        onTap: () => controller.toggleFavorite(video.videoId),
                        child: Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          size: _Sizes.actionIconSize,
                          color: isFav
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(context),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, HomeController controller) {
    return Obx(() {
      final uni = controller.universities.firstWhereOrNull(
        (u) => u.id == video.universityId,
      );
      final logoUrl = uni?.logoUrl;
      final hasLogo = logoUrl != null && logoUrl.isNotEmpty;
      return hasLogo
          ? CachedNetworkImage(
              imageUrl: logoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(color: AppTheme.surface(context)),
              errorWidget: (_, __, ___) => _AvatarFallback(context: context),
            )
          : _AvatarFallback(context: context);
    });
  }

  void _showVideoOptionsSheet(BuildContext context, HomeController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.card(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSec(context).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(
                  Icons.school_rounded,
                  color: AppTheme.textPri(context),
                ),
                title: Text(
                  'Üniversiteye Git',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _navigateToUniversityDetail(controller);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.share_rounded,
                  color: AppTheme.textPri(context),
                ),
                title: Text(
                  'Paylaş',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  controller.shareVideo(video);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ALT WIDGETLAR
// ═══════════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _Sizes.badgePadH,
        vertical: _Sizes.badgePadV,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_Sizes.badgeBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: _Sizes.badgeDotSize),
          SizedBox(width: _Sizes.badgeDotSpacing),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: _Sizes.badgeFontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _MiniStat({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: _Sizes.actionIconSize, color: color),
        SizedBox(width: _Sizes.actionIconTextSpacing),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: _Sizes.actionTextFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final BuildContext context;
  const _AvatarFallback({required this.context});

  @override
  Widget build(BuildContext ctx) {
    return Container(
      color: AppTheme.surface(context),
      child: Icon(
        Icons.school_rounded,
        color: AppTheme.textSec(context),
        size: 18,
      ),
    );
  }
}
