import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../controllers/profile_controller.dart';
import '../../../data/models/video_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      }

      if (!controller.isLoggedIn) {
        return _NotLoggedInView();
      }

      return _ProfileView(controller: controller);
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Giriş yapılmamış ekranı
// ═══════════════════════════════════════════════════════════════════════════

class _NotLoggedInView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.textSec(context),
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Hesabına Giriş Yap',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Favorilerini, izleme geçmişini ve tüm aktivitelerini\ngörmek için giriş yap.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.login),
                  child: const Text('Giriş Yap'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPri(context),
                    side: BorderSide(color: AppTheme.surface(context)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Get.toNamed(AppRoutes.register),
                  child: const Text('Kayıt Ol'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Ana profil görünümü
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileView extends StatelessWidget {
  final ProfileController controller;
  const _ProfileView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 250,
              pinned: true,
              floating: false,
              surfaceTintColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.settings_outlined,
                    color: AppTheme.textPri(context),
                  ),
                  tooltip: 'Ayarlar',
                  onPressed: () => Get.toNamed(AppRoutes.settings),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppTheme.textPri(context),
                  ),
                  tooltip: 'Profili Düzenle',
                  onPressed: () => _showEditProfileDialog(context, controller),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _ProfileHeader(controller: controller),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppTheme.bg(context),
                  child: TabBar(
                    isScrollable: false,
                    indicatorColor: AppTheme.primaryColor,
                    indicatorWeight: 2.5,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: AppTheme.textSec(context),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(icon: Icon(Icons.favorite_rounded, size: 18), text: 'Favoriler'),
                      Tab(icon: Icon(Icons.play_circle_rounded, size: 18), text: 'İzlenenler'),
                      Tab(icon: Icon(Icons.chat_bubble_rounded, size: 18), text: 'Yorumlar'),
                      Tab(icon: Icon(Icons.share_rounded, size: 18), text: 'Paylaşılan'),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _VideoActivityTab(
                videos: controller.favoriteVideos,
                isLoading: controller.isFavoritesLoading,
                emptyIcon: Icons.favorite_outline_rounded,
                emptyText: 'Henüz favori eklemedin',
                emptySubtext: 'Beğendiğin videoları favorilere ekle',
                onRefresh: () => controller.loadFavorites(),
              ),
              _VideoActivityTab(
                videos: controller.viewedVideos,
                isLoading: controller.isViewedLoading,
                emptyIcon: Icons.play_circle_outline_rounded,
                emptyText: 'Henüz video izlemedin',
                emptySubtext: 'İzlediğin videolar burada görünür',
                onRefresh: () => controller.loadViewedVideos(),
              ),
              _VideoActivityTab(
                videos: controller.commentedVideos,
                isLoading: controller.isCommentedLoading,
                emptyIcon: Icons.chat_bubble_outline_rounded,
                emptyText: 'Henüz yorum yapmadın',
                emptySubtext: 'Yorum yaptığın videolar burada görünür',
                onRefresh: () => controller.loadCommentedVideos(),
              ),
              _VideoActivityTab(
                videos: controller.sharedVideos,
                isLoading: controller.isSharedLoading,
                emptyIcon: Icons.share_outlined,
                emptyText: 'Henüz paylaşım yapmadın',
                emptySubtext: 'Paylaştığın videolar burada görünür',
                onRefresh: () => controller.loadSharedVideos(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, ProfileController controller) {
    final usernameCtrl = TextEditingController(
      text: controller.profile.value?.username ?? '',
    );
    final fullNameCtrl = TextEditingController(
      text: controller.profile.value?.fullName ?? '',
    );

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Profili Düzenle',
          style: TextStyle(color: AppTheme.textPri(context)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameCtrl,
              style: TextStyle(color: AppTheme.textPri(context)),
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.textSec(context)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fullNameCtrl,
              style: TextStyle(color: AppTheme.textPri(context)),
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.textSec(context)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal', style: TextStyle(color: AppTheme.textSec(context))),
          ),
          ElevatedButton(
            onPressed: () {
              controller.updateProfile(
                username: usernameCtrl.text.trim(),
                fullName: fullNameCtrl.text.trim(),
              );
              Get.back();
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Profil başlığı
// ═══════════════════════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final ProfileController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile.value;

      return Container(
        color: AppTheme.bg(context),
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 78,
                  height: 78,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, Color(0xFF158a3e)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: profile.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            (profile?.username ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              profile?.username ?? 'Kullanıcı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            if ((profile?.fullName ?? '').isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                profile!.fullName!,
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(icon: Icons.favorite_rounded, count: controller.favoriteVideos.length, label: 'Favori'),
                  _StatDivider(),
                  _StatChip(icon: Icons.play_circle_rounded, count: controller.viewedVideos.length, label: 'İzlenen'),
                  _StatDivider(),
                  _StatChip(icon: Icons.chat_bubble_rounded, count: controller.commentedVideos.length, label: 'Yorum'),
                  _StatDivider(),
                  _StatChip(icon: Icons.share_rounded, count: controller.sharedVideos.length, label: 'Paylaşım'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final String label;

  const _StatChip({required this.icon, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppTheme.textSec(context), fontSize: 11)),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: AppTheme.surface(context));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Aktivite sekmesi
// ═══════════════════════════════════════════════════════════════════════════

class _VideoActivityTab extends StatelessWidget {
  final RxList<VideoModel> videos;
  final RxBool isLoading;
  final IconData emptyIcon;
  final String emptyText;
  final String emptySubtext;
  final Future<void> Function() onRefresh;

  const _VideoActivityTab({
    required this.videos,
    required this.isLoading,
    required this.emptyIcon,
    required this.emptyText,
    required this.emptySubtext,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
      }

      if (videos.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(emptyIcon, color: AppTheme.textSec(context), size: 56),
              const SizedBox(height: 16),
              Text(
                emptyText,
                style: TextStyle(color: AppTheme.textPri(context), fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                emptySubtext,
                style: TextStyle(color: AppTheme.textSec(context), fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        color: AppTheme.primaryColor,
        onRefresh: onRefresh,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          itemCount: videos.length,
          itemBuilder: (context, index) => _ActivityVideoCard(video: videos[index]),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Video kartı
// ═══════════════════════════════════════════════════════════════════════════

class _ActivityVideoCard extends StatelessWidget {
  final VideoModel video;
  const _ActivityVideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.player, arguments: video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: 118,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => Container(
                      width: 118, height: 72, color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, _, _) => Container(
                      width: 118,
                      height: 72,
                      color: AppTheme.surface(context),
                      child: Icon(Icons.play_circle_outline_rounded,
                          color: AppTheme.textSec(context), size: 28),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: const TextStyle(
                          color: AppTheme.primaryColor, fontSize: 11, fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(color: AppTheme.textSec(context), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right_rounded, color: AppTheme.textSec(context), size: 18),
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
