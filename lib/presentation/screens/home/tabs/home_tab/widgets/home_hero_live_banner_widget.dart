// lib/presentation/screens/home/tabs/home_tab/widgets/home_hero_live_banner_widget.dart
//
// Tasarımdaki büyük "Canlı Yayın" hero banner'ı — SADECE tablet/geniş
// ekranda ve SADECE gerçekten canlı yayında olan bir video varken
// gösterilir (bkz. home_tab_widget.dart: controller.videos içinde
// isLiveBroadcast == true olan ilk video).
//
// DÜRÜST NOT: Tasarımdaki "14.2K Canlı İzleyici" / "4K 60FPS" gibi
// rakamlar orada SABİT (mockup) metinlerdi. Burada onun yerine
// video.appViewCount / video.viewCount gibi GERÇEK alanlar kullanılıyor;
// "4K 60FPS" gibi elimizde hiç karşılığı olmayan bir bilgi UYDURULMADI —
// sadece video.isHd true ise küçük bir "HD" rozeti gösteriliyor.
// Canlı yayın hiç yoksa bu widget'ın kendisi build edilmiyor (çağıran
// tarafta kontrol ediliyor), böylece boş/yalan bir banner asla görünmez.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/routes/app_routes.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home/home_controller.dart';

String _fmtViewerCount(int count) {
  if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
  if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}B';
  return count.toString();
}

class HomeHeroLiveBannerWidget extends StatelessWidget {
  const HomeHeroLiveBannerWidget({
    super.key,
    required this.video,
    this.height = 380,
  });

  final VideoModel video;
  final double height;

  void _openPlayer() {
    Get.toNamed(
      AppRoutes.player,
      arguments: video,
      parameters: {'videoId': video.videoId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controller = Get.find<HomeController>();
    final uni = controller.universities.firstWhereOrNull(
      (u) => u.id == video.universityId,
    );
    final viewerCount = video.appViewCount > 0
        ? video.appViewCount
        : video.viewCount;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Arkaplan görsel ──────────────────────────────────────
            CachedNetworkImage(
              imageUrl: video.bestThumbnail,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(color: scheme.surfaceContainerHigh),
              errorWidget: (_, _, _) =>
                  Container(color: scheme.surfaceContainerHigh),
            ),
            // ── Koyu okunabilirlik gradyanı ──────────────────────────
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    scheme.surfaceContainerLowest.withValues(alpha: 0.10),
                    scheme.surfaceContainerLowest.withValues(alpha: 0.55),
                    scheme.surfaceContainerLowest.withValues(alpha: 0.94),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Üst satır: rozetler + paylaş/tam ekran ─────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _LiveBadge(scheme: scheme),
                            _PillBadge(
                              icon: Icons.visibility_rounded,
                              label: '${_fmtViewerCount(viewerCount)} Canlı İzleyici',
                              scheme: scheme,
                            ),
                            if (video.isHd)
                              _PillBadge(
                                icon: Icons.hd_rounded,
                                label: 'HD',
                                scheme: scheme,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _IconGhostButton(
                        icon: Icons.share_rounded,
                        tooltip: 'Paylaş',
                        onTap: () => controller.engagement.shareVideo(video),
                      ),
                      const SizedBox(width: 8),
                      _IconGhostButton(
                        icon: Icons.fullscreen_rounded,
                        tooltip: 'İzle',
                        onTap: _openPlayer,
                      ),
                    ],
                  ),
                  const Spacer(),
                  // ── Kanal meta ──────────────────────────────────────
                  Row(
                    children: [
                      _UniAvatar(name: video.channelTitle, logoUrl: uni?.logoUrl),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                video.channelTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified_rounded,
                              size: 15,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      height: 1.2,
                    ),
                  ),
                  if (video.description.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _openPlayer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text(
                          'Şimdi İzle',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      OutlinedButton.icon(
                        // DÜRÜST NOT: Canlı yayın hatırlatması için henüz bir
                        // backend/bildirim aboneliği yok (bkz. dosyanın
                        // başındaki not) — tıklanınca kullanıcıya bunu
                        // açıkça söylüyoruz, sessizce hiçbir şey yapmıyoruz.
                        onPressed: () {
                          Get.snackbar(
                            'Çok Yakında',
                            'Canlı yayın hatırlatmaları yakında burada olacak.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: scheme.surfaceContainerHigh,
                            colorText: scheme.onSurface,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.notifications_active_outlined),
                        label: const Text(
                          'Bildirim Kur',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'CANLI YAYIN',
            style: TextStyle(
              color: scheme.onError,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.icon,
    required this.label,
    required this.scheme,
  });

  final IconData icon;
  final String label;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconGhostButton extends StatelessWidget {
  const _IconGhostButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _UniAvatar extends StatelessWidget {
  const _UniAvatar({required this.name, this.logoUrl});

  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final hasLogo = logoUrl != null && logoUrl!.isNotEmpty;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 34,
      height: 34,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      alignment: Alignment.center,
      child: hasLogo
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => _initialText(initial),
            )
          : _initialText(initial),
    );
  }

  Widget _initialText(String initial) {
    return Text(
      initial,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 13,
      ),
    );
  }
}
