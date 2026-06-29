import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/profile_activity_list_controller.dart';

class ProfileActivityListScreen extends StatefulWidget {
  const ProfileActivityListScreen({super.key});

  @override
  State<ProfileActivityListScreen> createState() =>
      _ProfileActivityListScreenState();
}

class _ProfileActivityListScreenState extends State<ProfileActivityListScreen> {
  late final ProfileActivityListController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileActivityListController>();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.pageTitle,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            final isGrid = controller.viewMode.value == ActivityViewMode.grid;
            return IconButton(
              tooltip: isGrid ? 'Liste Görünümü' : 'Izgara Görünümü',
              icon: Icon(
                isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: 22.sp,
                color: AppTheme.textPri(context),
              ),
              onPressed: () => controller.changeViewMode(
                isGrid ? ActivityViewMode.list : ActivityViewMode.grid,
              ),
            );
          }),
          SizedBox(width: 4.w),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                    strokeWidth: 3.w,
                  ),
                );
              }

              if (controller.videos.isEmpty) {
                return _EmptyView(
                  emptyText: controller.emptyText,
                  emptySubtext: controller.emptySubtext,
                  activityType: controller.activityType,
                );
              }

              final displayVideos = controller.filteredVideos;

              if (displayVideos.isEmpty) {
                return _NoSearchResultsView(
                  query: controller.searchQuery.value,
                );
              }

              final isGrid = controller.viewMode.value == ActivityViewMode.grid;

              return RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: controller.loadInitial,
                child: _FlatContent(
                  controller: controller,
                  videos: displayVideos,
                  scrollController: _scrollController,
                  isGrid: isGrid,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Düz Liste / Izgara (Tarihe göre) ──────────────────────────────────────

class _FlatContent extends StatelessWidget {
  final ProfileActivityListController controller;
  final List<VideoModel> videos;
  final ScrollController scrollController;
  final bool isGrid;

  const _FlatContent({
    required this.controller,
    required this.videos,
    required this.scrollController,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    final extraCount =
        controller.hasMore.value && controller.searchQuery.value.isEmpty
        ? 1
        : 0;

    if (isGrid) {
      return GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 0.68,
        ),
        itemCount: videos.length + extraCount,
        itemBuilder: (context, index) {
          if (index == videos.length) return const _LoadMoreIndicator();
          final video = videos[index];
          return _buildItem(context, video, isGrid: true);
        },
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      itemCount: videos.length + extraCount,
      itemBuilder: (context, index) {
        if (index == videos.length) return const _LoadMoreIndicator();
        final video = videos[index];
        return _buildItem(context, video, isGrid: false);
      },
    );
  }

  Widget _buildItem(
    BuildContext context,
    VideoModel video, {
    required bool isGrid,
  }) {
    if (!controller.isOwnProfile) {
      return isGrid ? _VideoGridCard(video: video) : _VideoCard(video: video);
    }
    return _DismissibleVideo(
      controller: controller,
      video: video,
      child: isGrid ? _VideoGridCard(video: video) : _VideoCard(video: video),
    );
  }
}

// ─── Silinebilir Sarmalayıcı ────────────────────────────────────────────────

class _DismissibleVideo extends StatelessWidget {
  final ProfileActivityListController controller;
  final VideoModel video;
  final Widget child;

  const _DismissibleVideo({
    required this.controller,
    required this.video,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(video.videoId),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(14.r),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.card(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                title: Text(
                  'Kaydı Sil',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Bu kayıt listenden kaldırılacak. Emin misin?',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 14.sp,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: Size(72.w, 36.h),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text('Sil', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) => controller.removeVideo(video.videoId),
      child: child,
    );
  }
}

// ─── Video Kartı (Liste) ────────────────────────────────────────────────────

class _VideoCard extends StatelessWidget {
  final VideoModel video;
  const _VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                bottomLeft: Radius.circular(14.r),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: 140.w,
                    height: 84.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 140.w,
                      height: 84.h,
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 140.w,
                      height: 84.h,
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: 28.sp,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 5.h,
                      right: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(4.r),
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
                ],
              ),
            ),

            // ── İçerik ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5.h),

                    // Üniversite adı
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((video.universityName ?? '').isNotEmpty)
                      SizedBox(height: 4.h),

                    // Tarih
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 11.sp,
                      ),
                    ),

                    // ── İstatistikler ───────────────────────────────────────
                    SizedBox(height: 8.h),
                    _StatRowCompact(video: video),
                  ],
                ),
              ),
            ),

            // ── Ok ikonu ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(right: 8.w, top: 36.h),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Video Kartı (Izgara) ───────────────────────────────────────────────────

class _VideoGridCard extends StatelessWidget {
  final VideoModel video;
  const _VideoGridCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(14.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ──────────────────────────────────────────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: 28.sp,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: 5.h,
                      right: 5.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── İçerik ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Üniversite adı
                    if ((video.universityName ?? '').isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          video.universityName!,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const Spacer(),

                    // ── İstatistikler ───────────────────────────────────────
                    _StatRowGrid(video: video),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── İstatistik Satırı – Liste (Yatay, kompakt) ────────────────────────────

class _StatRowCompact extends StatelessWidget {
  final VideoModel video;
  const _StatRowCompact({required this.video});

  @override
  Widget build(BuildContext context) {
    final items = <_StatItem>[
      if (video.appViewCount > 0)
        _StatItem(icon: Icons.visibility_outlined, value: video.appViewCount),
      if (video.appLikeCount > 0)
        _StatItem(icon: Icons.thumb_up_outlined, value: video.appLikeCount),
      if (video.appCommentCount > 0)
        _StatItem(
          icon: Icons.chat_bubble_outline_rounded,
          value: video.appCommentCount,
        ),
      if (video.appFavoriteCount > 0)
        _StatItem(
          icon: Icons.favorite_outline_rounded,
          value: video.appFavoriteCount,
        ),
      if (video.appShareCount > 0)
        _StatItem(icon: Icons.share_outlined, value: video.appShareCount),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10.w,
      runSpacing: 4.h,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, size: 13.sp, color: AppTheme.textSec(context)),
                SizedBox(width: 3.w),
                Text(
                  _compactNumber(item.value),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

// ─── İstatistik Satırı – Izgara (İki satıra bölünmüş) ──────────────────────

class _StatRowGrid extends StatelessWidget {
  final VideoModel video;
  const _StatRowGrid({required this.video});

  @override
  Widget build(BuildContext context) {
    final row1 = <_StatItem>[];
    final row2 = <_StatItem>[];

    if (video.appViewCount > 0) {
      row1.add(
        _StatItem(icon: Icons.visibility_outlined, value: video.appViewCount),
      );
    }
    if (video.appLikeCount > 0) {
      row1.add(
        _StatItem(icon: Icons.thumb_up_outlined, value: video.appLikeCount),
      );
    }
    if (video.appFavoriteCount > 0) {
      row1.add(
        _StatItem(
          icon: Icons.favorite_outline_rounded,
          value: video.appFavoriteCount,
        ),
      );
    }
    if (video.appCommentCount > 0) {
      row2.add(
        _StatItem(
          icon: Icons.chat_bubble_outline_rounded,
          value: video.appCommentCount,
        ),
      );
    }
    if (video.appShareCount > 0) {
      row2.add(
        _StatItem(icon: Icons.share_outlined, value: video.appShareCount),
      );
    }

    if (row1.isEmpty && row2.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (row1.isNotEmpty) _buildGridStatLine(context, row1),
        if (row1.isNotEmpty && row2.isNotEmpty) SizedBox(height: 3.h),
        if (row2.isNotEmpty) _buildGridStatLine(context, row2),
      ],
    );
  }

  Widget _buildGridStatLine(BuildContext context, List<_StatItem> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                items[i].icon,
                size: 11.sp,
                color: AppTheme.textSec(context),
              ),
              SizedBox(width: 2.w),
              Text(
                _compactNumber(items[i].value),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
        const Spacer(),
      ],
    );
  }
}

// ─── İstatistik Veri Sınıfı ─────────────────────────────────────────────────

class _StatItem {
  final IconData icon;
  final int value;
  const _StatItem({required this.icon, required this.value});
}

// ─── Sayı Formatla ──────────────────────────────────────────────────────────

String _compactNumber(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1).replaceAllMapped(RegExp(r'\.0$'), (_) => '')}M';
  }
  if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1).replaceAllMapped(RegExp(r'\.0$'), (_) => '')}B';
  }
  return '$count';
}

// ─── Zaman ──────────────────────────────────────────────────────────────────

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
  if (diff.inDays > 0) return '${diff.inDays} gün önce';
  if (diff.inHours > 0) return '${diff.inHours} saat önce';
  return '${diff.inMinutes} dakika önce';
}

// ─── Arama Sonucu Bulunamadı ────────────────────────────────────────────────

class _NoSearchResultsView extends StatelessWidget {
  final String query;
  const _NoSearchResultsView({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppTheme.textSec(context),
              size: 48.sp,
            ),
            SizedBox(height: 14.h),
            Text(
              '"$query" için sonuç bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Üniversite adını veya video başlığını kontrol et',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Boş Durum ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final String emptyText;
  final String emptySubtext;
  final ProfileActivityType activityType;

  const _EmptyView({
    required this.emptyText,
    required this.emptySubtext,
    required this.activityType,
  });

  IconData get _icon {
    switch (activityType) {
      case ProfileActivityType.favorites:
        return Icons.favorite_outline_rounded;
      case ProfileActivityType.viewed:
        return Icons.play_circle_outline_rounded;
      case ProfileActivityType.commented:
        return Icons.chat_bubble_outline_rounded;
      case ProfileActivityType.shared:
        return Icons.share_outlined;
      case ProfileActivityType.liked:
        return Icons.thumb_up_alt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, color: AppTheme.textSec(context), size: 56.sp),
            SizedBox(height: 16.h),
            Text(
              emptyText,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              emptySubtext,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Daha Fazla Yükle Göstergesi ────────────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: 2.5.w,
        ),
      ),
    );
  }
}
