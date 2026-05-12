import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/home_controller.dart';
import '../../../data/models/video_model.dart';
import '../../../data/models/playlist_model.dart';
import '../favorites/favorites_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() => Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: IndexedStack(
            index: controller.selectedIndex.value,
            children: const [
              _HomeTab(),
              FavoritesScreen(),
              ProfileScreen(),
              SettingsScreen(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.selectedIndex.value,
            onTap: controller.changeTab,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Ana Sayfa',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Favoriler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Ayarlar',
              ),
            ],
          ),
        ));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Ana Sekme
// ═══════════════════════════════════════════════════════════════════════════

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Obx(() {
          return RefreshIndicator(
            color: AppTheme.primaryColor,
            onRefresh: () async {
              await controller.refreshVideos();
              await controller.loadPlaylists();
            },
            child: CustomScrollView(
              slivers: [
                // ── AppBar ───────────────────────────────────────────────
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: AppTheme.backgroundColor,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('ÇOMÜ TV'),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () {},
                    ),
                  ],
                ),

                // ── Oynatma Listeleri Şeridi ──────────────────────────────
                SliverToBoxAdapter(child: _PlaylistStrip()),

                // ── "Son Videolar" Başlığı ────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                    child: Text(
                      'Son Videolar',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // ── Video Listesi ─────────────────────────────────────────
                if (controller.isLoading.value)
                  SliverToBoxAdapter(child: _buildVideoShimmer())
                else if (controller.errorMessage.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppTheme.textSecondary, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                                color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.loadVideos,
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _VideoCard(video: controller.videos[index]),
                      childCount: controller.videos.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVideoShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surfaceColor,
      highlightColor: AppTheme.cardColor,
      child: Column(
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                    height: 16, width: double.infinity, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 14, width: 200, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yatay Kayan Oynatma Listeleri Şeridi
// ═══════════════════════════════════════════════════════════════════════════

class _PlaylistStrip extends StatelessWidget {
  const _PlaylistStrip();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      if (controller.isPlaylistsLoading.value) {
        return _buildShimmer();
      }

      // Hata veya boşsa şeridi gizle
      if (controller.playlistsError.isNotEmpty ||
          controller.playlists.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık satırı
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Oynatma Listeleri',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'Tümünü Gör',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded,
                          color: AppTheme.primaryColor, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Yatay kayan kartlar
          SizedBox(
            height: 182,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.playlists.length,
              itemBuilder: (context, index) {
                return _PlaylistCard(playlist: controller.playlists[index]);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Container(
            height: 18,
            width: 160,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        SizedBox(
          height: 182,
          child: Shimmer.fromColors(
            baseColor: AppTheme.surfaceColor,
            highlightColor: AppTheme.cardColor,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Oynatma Listesi Kartı (yatay şerit)
// ═══════════════════════════════════════════════════════════════════════════

class _PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;

  const _PlaylistCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.playlistDetail, arguments: playlist),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kapak resmi
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: playlist.thumbnailUrl,
                    width: 160,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 160,
                      height: 100,
                      color: AppTheme.surfaceColor,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 160,
                      height: 100,
                      color: AppTheme.surfaceColor,
                      child: const Icon(
                        Icons.playlist_play_rounded,
                        color: AppTheme.textSecondary,
                        size: 36,
                      ),
                    ),
                  ),
                  // Alt degrade
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Video sayısı
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.playlist_play_rounded,
                              color: Colors.white, size: 13),
                          const SizedBox(width: 3),
                          Text(
                            '${playlist.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Başlık alanı
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${playlist.itemCount} video',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
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

// ═══════════════════════════════════════════════════════════════════════════
// Video Kartı
// ═══════════════════════════════════════════════════════════════════════════

class _VideoCard extends StatelessWidget {
  final VideoModel video;

  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.player, arguments: video),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: AppTheme.cardColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: AppTheme.cardColor,
                      child: const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSecondary,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() => GestureDetector(
                        onTap: () =>
                            controller.toggleFavorite(video.videoId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            controller.isFavorite(video.videoId)
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            color: controller.isFavorite(video.videoId)
                                ? AppTheme.primaryColor
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              video.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${video.viewCount} görüntülenme · ${_timeAgo(video.publishedAt)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
    if (diff.inDays > 0) return '${diff.inDays} gün önce';
    if (diff.inHours > 0) return '${diff.inHours} saat önce';
    return '${diff.inMinutes} dakika önce';
  }
}
