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

    return Obx(
      () => Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: IndexedStack(
          index: controller.selectedIndex.value,
          children: const [
            _HomeTab(),
            _UniversitiesTab(),
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
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Üniversiteler',
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
      ),
    );
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
                      Obx(() => Text(controller.appBarTitle)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () => Get.toNamed(AppRoutes.search),
                    ),
                  ],
                ),

                // ── Üniversite Filtre Şeridi ──────────────────────────────
                // ── Video Listesi Başlığı ───────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppTheme.textSecondary,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
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
                else if (controller.videos.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          'Henüz video yok.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
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
                  height: 16,
                  width: double.infinity,
                  color: Colors.white,
                ),
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
// Üniversite Filtre Chip Şeridi
// ═══════════════════════════════════════════════════════════════════════════

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
                    placeholder: (_, _) => Container(
                      height: 200,
                      color: AppTheme.cardColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    errorWidget: (_, _, _) => Container(
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

                // Süre etiketi
                if (video.formattedDuration.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        video.formattedDuration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (video.formattedDuration.isEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'CANLI YAYIN',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 245, 124, 116),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favori butonu
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(
                    () => GestureDetector(
                      onTap: () => controller.toggleFavorite(video.videoId),
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              final uni = controller.universities
                  .firstWhereOrNull((u) => u.name == video.universityName);
              final logoUrl = uni?.logoUrl;
              final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

              return Row(
                children: [
                  if (hasLogo) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: logoUrl,
                        width: 28,
                        height: 28,
                        fit: BoxFit.contain,
                        placeholder: (_, _) =>
                            const SizedBox(width: 28, height: 28),
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      video.universityName ?? '',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 252, 0),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 2),
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
              _timeAgo(video.publishedAt),
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
// ════════════════════════════════════════════════════════════════════════════════
// Üniversiteler Sekmesi
// ════════════════════════════════════════════════════════════════════════════════

class _UniversitiesTab extends StatelessWidget {
  const _UniversitiesTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Üniversiteler',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isPlaylistsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  );
                }
                if (controller.playlists.isEmpty) {
                  return const Center(
                    child: Text(
                      'Üniversite bulunamadı.',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: controller.loadPlaylists,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: controller.playlists.length,
                    itemBuilder: (_, i) =>
                        _UniversityGridCard(playlist: controller.playlists[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _UniversityGridCard extends StatelessWidget {
  final PlaylistModel playlist;

  const _UniversityGridCard({required this.playlist});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.playlistDetail, arguments: playlist),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: playlist.thumbnailUrl,
                    width: double.infinity,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(height: 110, color: AppTheme.surfaceColor),
                    errorWidget: (_, _, _) => Container(
                      height: 110,
                      color: AppTheme.surfaceColor,
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppTheme.textSecondary,
                        size: 36,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
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
                  const SizedBox(height: 4),
                  Text(
                    '${playlist.itemCount} video',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
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
