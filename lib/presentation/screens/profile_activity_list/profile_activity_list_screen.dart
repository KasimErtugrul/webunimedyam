// lib/presentation/screens/profile_activity_list/profile_activity_list_screen.dart

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

  String _sortLabel(ActivitySortOption option) {
    switch (option) {
      case ActivitySortOption.dateDesc:
        return 'Tarihe Göre (Yeni)';
      case ActivitySortOption.universityAsc:
        return 'Üniversite (A-Z)';
      case ActivitySortOption.universityDesc:
        return 'Üniversite (Z-A)';
    }
  }

  IconData _sortIcon(ActivitySortOption option) {
    switch (option) {
      case ActivitySortOption.dateDesc:
        return Icons.schedule_rounded;
      case ActivitySortOption.universityAsc:
        return Icons.arrow_downward_rounded;
      case ActivitySortOption.universityDesc:
        return Icons.arrow_upward_rounded;
    }
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
          // ─── Sıralama butonu ──────────────────────────────────────────
          Obx(() {
            return PopupMenuButton<ActivitySortOption>(
              icon: Icon(_sortIcon(controller.sortOption.value),
                  size: 22.sp, color: AppTheme.textPri(context)),
              tooltip: 'Sırala',
              onSelected: controller.changeSortOption,
              itemBuilder: (context) => ActivitySortOption.values
                  .map(
                    (option) => PopupMenuItem<ActivitySortOption>(
                      value: option,
                      child: Row(
                        children: [
                          Icon(
                            _sortIcon(option),
                            size: 18.sp,
                            color: controller.sortOption.value == option
                                ? AppTheme.primaryColor
                                : AppTheme.textSec(context),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            _sortLabel(option),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: controller.sortOption.value == option
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: controller.sortOption.value == option
                                  ? AppTheme.primaryColor
                                  : AppTheme.textPri(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
          // ─── Görünüm değiştirme butonu ────────────────────────────────
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
      body: Obx(() {
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

        final isGrouped = controller.sortOption.value != ActivitySortOption.dateDesc;
        final isGrid = controller.viewMode.value == ActivityViewMode.grid;

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: controller.loadInitial,
          child: isGrouped
              ? _GroupedContent(
                  controller: controller,
                  scrollController: _scrollController,
                  isGrid: isGrid,
                )
              : _FlatContent(
                  controller: controller,
                  scrollController: _scrollController,
                  isGrid: isGrid,
                ),
        );
      }),
    );
  }
}

// ─── Düz Liste / Izgara (Tarihe göre) ──────────────────────────────────────

class _FlatContent extends StatelessWidget {
  final ProfileActivityListController controller;
  final ScrollController scrollController;
  final bool isGrid;

  const _FlatContent({
    required this.controller,
    required this.scrollController,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    final videos = controller.videos;
    final extraCount = controller.hasMore.value ? 1 : 0;

    if (isGrid) {
      return GridView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 0.82,
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

  Widget _buildItem(BuildContext context, VideoModel video, {required bool isGrid}) {
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

// ─── Gruplu İçerik (Üniversiteye göre) ─────────────────────────────────────

class _GroupedContent extends StatelessWidget {
  final ProfileActivityListController controller;
  final ScrollController scrollController;
  final bool isGrid;

  const _GroupedContent({
    required this.controller,
    required this.scrollController,
    required this.isGrid,
  });

  List<MapEntry<String, List<VideoModel>>> _buildGroups() {
    final groups = <MapEntry<String, List<VideoModel>>>[];
    String? currentKey;
    List<VideoModel>? currentList;

    for (final video in controller.videos) {
      final key = (video.universityName?.trim().isNotEmpty ?? false)
          ? video.universityName!.trim()
          : 'Diğer';
      if (key != currentKey) {
        currentKey = key;
        currentList = <VideoModel>[];
        groups.add(MapEntry(key, currentList));
      }
      currentList!.add(video);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _buildGroups();

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final group = groups[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: group.key,
                        count: group.value.length,
                      ),
                      SizedBox(height: 8.h),
                      if (isGrid)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10.h,
                            crossAxisSpacing: 10.w,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: group.value.length,
                          itemBuilder: (context, i) =>
                              _buildItem(context, group.value[i], isGrid: true),
                        )
                      else
                        Column(
                          children: group.value
                              .map((video) => _buildItem(context, video, isGrid: false))
                              .toList(),
                        ),
                    ],
                  ),
                );
              },
              childCount: groups.length,
            ),
          ),
        ),
        if (controller.hasMore.value)
          const SliverToBoxAdapter(child: _LoadMoreIndicator()),
      ],
    );
  }

  Widget _buildItem(BuildContext context, VideoModel video, {required bool isGrid}) {
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPri(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSec(context),
          ),
        ),
      ],
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
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24.sp),
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                bottomLeft: Radius.circular(14.r),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: 118.w,
                    height: 72.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 118.w,
                      height: 72.h,
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 118.w,
                      height: 72.h,
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
                            horizontal: 5.w, vertical: 2.h),
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 10.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    SizedBox(height: 6.h),
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
                    SizedBox(height: 4.h),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 8.w),
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppTheme.surface(context)),
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
                            horizontal: 5.w, vertical: 2.h),
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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

String _timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} yıl önce';
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} ay önce';
  if (diff.inDays > 0) return '${diff.inDays} gün önce';
  if (diff.inHours > 0) return '${diff.inHours} saat önce';
  return '${diff.inMinutes} dakika önce';
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
            Icon(
              _icon,
              color: AppTheme.textSec(context),
              size: 56.sp,
            ),
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
