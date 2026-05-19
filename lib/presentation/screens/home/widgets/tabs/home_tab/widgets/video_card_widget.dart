import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Get.toNamed(AppRoutes.player, arguments: video),
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
      height: 200,
      width: double.infinity,
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
                size: 48,
              ),
            ),
          ),

          // Alt Gradient
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 80,
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
            height: 60,
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
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 7,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'CANLI',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // HD Etiketi
          if (video.isHd && !isLive)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: const Text(
                  'HD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

          // Süre Etiketi
          if (!isLive)
            Positioned(
              bottom: 8,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  video.formattedDuration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          // Favori Butonu
          Positioned(
            top: 8,
            right: 8,
            child: Obx(
              () => Material(
                color: Colors.black.withValues(alpha: 0.45),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => controller.toggleFavorite(video.videoId),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      controller.isFavorite(video.videoId)
                          ? Icons.favorite_rounded
                          : Icons.favorite_outline_rounded,
                      color: controller.isFavorite(video.videoId)
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                      size: 20,
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
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ve Üniversite Adı ────────────────────────────────────
          Row(
            children: [
              _buildUniversityAvatar(context, controller),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  video.universityName ?? video.channelTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Video Başlığı (4 Satır) ──────────────────────────────────
          Text(
            video.title,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          // ── Açıklama (4 Satır) ───────────────────────────────────────
          if (video.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              video.description.replaceAll(RegExp(r'\n+'), ' '),
              style: TextStyle(
                color: AppTheme.textSec(context).withValues(alpha: 0.85),
                fontSize: 13,
                height: 1.45,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 14),

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
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.textSec(context).withValues(alpha: 0.08),
          ),
        ),
        child: hasLogo
            ? ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => Icon(
                    Icons.school_rounded,
                    color: AppTheme.textSec(context),
                    size: 20,
                  ),
                ),
              )
            : Icon(
                Icons.school_rounded,
                color: AppTheme.textSec(context),
                size: 20,
              ),
      );
    });
  }

  // ── İstatistikler (Sol) ve Zaman (Sağ) ────────────────────────────────────
  Widget _buildStatsAndTimeRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Görüntülenme
        Icon(
          Icons.visibility_outlined,
          size: 17,
          color: AppTheme.textSec(context),
        ),
        const SizedBox(width: 5),
        Text(
          _formatCount(video.viewCount),
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 16),

        // Beğeni
        Icon(
          Icons.thumb_up_off_alt_rounded,
          size: 17,
          color: AppTheme.textSec(context),
        ),
        const SizedBox(width: 5),
        Text(
          _formatCount(video.likeCount),
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(width: 16),

        // Yorum
        Icon(
          Icons.mode_comment_outlined,
          size: 17,
          color: AppTheme.textSec(context),
        ),
        const SizedBox(width: 5),
        Text(
          _formatCount(video.commentCount),
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Boşluğu doldurup timeago'yu en sağa itiyoruz
        const Spacer(),

        // Zaman (Sağa yaslı)
        Text(
          timeago.format(video.publishedAt, locale: 'tr'),
          style: TextStyle(color: AppTheme.textSec(context), fontSize: 12),
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
