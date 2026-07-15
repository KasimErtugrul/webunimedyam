// lib/presentation/screens/profile/profile_activity_list_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/video_model.dart';
import '../../controllers/profile_activity_list_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 18;
  static const double appBarIconSize = 22;
  static const double appBarIconPadding = 4;

  // Loading
  static const double loadingStrokeWidth = 3;

  // Grid
  static const double gridPaddingHorizontal = 14;
  static const double gridPaddingVertical = 12;
  static const double gridMainSpacing = 10;
  static const double gridCrossSpacing = 10;
  static const double gridChildAspectRatio = 0.68;

  // List
  static const double listPaddingHorizontal = 14;
  static const double listPaddingVertical = 12;
  static const double listCardBottomMargin = 10;
  static const double listCardBorderRadius = 14;
  static const double listThumbnailWidth = 140;
  static const double listThumbnailHeight = 84;
  static const double listThumbnailRadius = 14;
  static const double listThumbnailIconSize = 28;
  static const double listContentPaddingLeft = 12;
  static const double listContentPaddingTop = 10;
  static const double listContentPaddingRight = 8;
  static const double listContentPaddingBottom = 10;
  static const double listTitleFontSize = 13;
  static const double listTitleLineHeight = 1.35;
  static const double listUniFontSize = 11;
  static const double listDateFontSize = 11;
  static const double listStatSpacing = 10;
  static const double listStatIconSize = 13;
  static const double listStatFontSize = 11;
  static const double listChevronRight = 8;
  static const double listChevronTop = 36;
  static const double listChevronSize = 18;

  // Grid Card
  static const double gridCardBorderRadius = 14;
  static const double gridCardPaddingLeft = 8;
  static const double gridCardPaddingTop = 8;
  static const double gridCardPaddingRight = 8;
  static const double gridCardPaddingBottom = 6;
  static const double gridTitleFontSize = 12;
  static const double gridTitleLineHeight = 1.3;
  static const double gridUniFontSize = 10;
  static const double gridUniPaddingTop = 4;
  static const double gridStatIconSize = 11;
  static const double gridStatFontSize = 10;
  static const double gridStatSpacing = 8;
  static const double gridStatLineSpacing = 3;

  // Duration Badge
  static const double durationBadgePaddingHorizontal = 5;
  static const double durationBadgePaddingVertical = 2;
  static const double durationBadgeBorderRadius = 4;
  static const double durationBadgeFontSize = 10;
  static const double durationBadgeGridFontSize = 9;

  // Dismissible
  static const double dismissibleMarginBottom = 10;
  static const double dismissibleBorderRadius = 14;
  static const double dismissiblePaddingRight = 20;
  static const double dismissibleIconSize = 24;
  static const double dismissibleTextFontSize = 12;
  static const double dismissibleSpacing = 4;

  // Confirm Dialog
  static const double dialogBorderRadius = 16;
  static const double dialogTitleFontSize = 17;
  static const double dialogContentFontSize = 14;
  static const double dialogButtonWidth = 72;
  static const double dialogButtonHeight = 36;
  static const double dialogButtonFontSize = 14;

  // Empty View
  static const double emptyPaddingHorizontal = 32;
  static const double emptyIconSize = 56;
  static const double emptySpacingLarge = 16;
  static const double emptySpacingSmall = 6;
  static const double emptyTitleFontSize = 16;
  static const double emptySubtitleFontSize = 13;

  // No Search Results
  static const double noResultPaddingHorizontal = 32;
  static const double noResultIconSize = 48;
  static const double noResultSpacingLarge = 14;
  static const double noResultSpacingSmall = 6;
  static const double noResultTitleFontSize = 15;
  static const double noResultSubtitleFontSize = 13;

  // Load More
  static const double loadMorePaddingVertical = 20;
  static const double loadMoreStrokeWidth = 2.5;
}

class _TabletSizes {
  // AppBar - tablet için daha büyük
  static const double appBarTitleSize = 22;
  static const double appBarIconSize = 26;
  static const double appBarIconPadding = 6;

  // Loading - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;

  // Grid - tablet için daha büyük
  static const double gridPaddingHorizontal = 20;
  static const double gridPaddingVertical = 16;
  static const double gridMainSpacing = 14;
  static const double gridCrossSpacing = 14;
  static const double gridChildAspectRatio = 0.7;

  // List - tablet için daha büyük
  static const double listPaddingHorizontal = 20;
  static const double listPaddingVertical = 16;
  static const double listCardBottomMargin = 14;
  static const double listCardBorderRadius = 16;
  static const double listThumbnailWidth = 180;
  static const double listThumbnailHeight = 100;
  static const double listThumbnailRadius = 16;
  static const double listThumbnailIconSize = 34;
  static const double listContentPaddingLeft = 16;
  static const double listContentPaddingTop = 12;
  static const double listContentPaddingRight = 10;
  static const double listContentPaddingBottom = 12;
  static const double listTitleFontSize = 15;
  static const double listTitleLineHeight = 1.4;
  static const double listUniFontSize = 13;
  static const double listDateFontSize = 13;
  static const double listStatSpacing = 12;
  static const double listStatIconSize = 15;
  static const double listStatFontSize = 13;
  static const double listChevronRight = 10;
  static const double listChevronTop = 40;
  static const double listChevronSize = 22;

  // Grid Card - tablet için daha büyük
  static const double gridCardBorderRadius = 16;
  static const double gridCardPaddingLeft = 10;
  static const double gridCardPaddingTop = 10;
  static const double gridCardPaddingRight = 10;
  static const double gridCardPaddingBottom = 8;
  static const double gridTitleFontSize = 14;
  static const double gridTitleLineHeight = 1.35;
  static const double gridUniFontSize = 12;
  static const double gridUniPaddingTop = 5;
  static const double gridStatIconSize = 13;
  static const double gridStatFontSize = 12;
  static const double gridStatSpacing = 10;
  static const double gridStatLineSpacing = 4;

  // Duration Badge - tablet için daha büyük
  static const double durationBadgePaddingHorizontal = 6;
  static const double durationBadgePaddingVertical = 3;
  static const double durationBadgeBorderRadius = 5;
  static const double durationBadgeFontSize = 12;
  static const double durationBadgeGridFontSize = 10;

  // Dismissible - tablet için daha büyük
  static const double dismissibleMarginBottom = 14;
  static const double dismissibleBorderRadius = 16;
  static const double dismissiblePaddingRight = 24;
  static const double dismissibleIconSize = 28;
  static const double dismissibleTextFontSize = 14;
  static const double dismissibleSpacing = 5;

  // Confirm Dialog - tablet için daha büyük
  static const double dialogBorderRadius = 20;
  static const double dialogTitleFontSize = 20;
  static const double dialogContentFontSize = 16;
  static const double dialogButtonWidth = 80;
  static const double dialogButtonHeight = 40;
  static const double dialogButtonFontSize = 16;

  // Empty View - tablet için daha büyük
  static const double emptyPaddingHorizontal = 40;
  static const double emptyIconSize = 64;
  static const double emptySpacingLarge = 20;
  static const double emptySpacingSmall = 8;
  static const double emptyTitleFontSize = 20;
  static const double emptySubtitleFontSize = 15;

  // No Search Results - tablet için daha büyük
  static const double noResultPaddingHorizontal = 40;
  static const double noResultIconSize = 56;
  static const double noResultSpacingLarge = 16;
  static const double noResultSpacingSmall = 8;
  static const double noResultTitleFontSize = 18;
  static const double noResultSubtitleFontSize = 15;

  // Load More - tablet için daha büyük
  static const double loadMorePaddingVertical = 24;
  static const double loadMoreStrokeWidth = 3;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

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
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.pageTitle,
          style: TextStyle(
            fontSize: _PhoneSizes.appBarTitleSize.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            final isGrid = controller.viewMode.value == ActivityViewMode.grid;
            return IconButton(
              tooltip: isGrid ? 'Liste Görünümü' : 'Izgara Görünümü',
              icon: Icon(
                isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: _PhoneSizes.appBarIconSize.sp,
                color: AppTheme.textPri(context),
              ),
              onPressed: () => controller.changeViewMode(
                isGrid ? ActivityViewMode.list : ActivityViewMode.grid,
              ),
            );
          }),
          SizedBox(width: _PhoneSizes.appBarIconPadding.w),
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
                    strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
                  ),
                );
              }

              if (controller.videos.isEmpty) {
                return _EmptyViewPhone(
                  emptyText: controller.emptyText,
                  emptySubtext: controller.emptySubtext,
                  activityType: controller.activityType,
                );
              }

              final displayVideos = controller.filteredVideos;

              if (displayVideos.isEmpty) {
                return _NoSearchResultsViewPhone(
                  query: controller.searchQuery.value,
                );
              }

              final isGrid = controller.viewMode.value == ActivityViewMode.grid;

              return RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: controller.loadInitial,
                child: _FlatContentPhone(
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

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.pageTitle,
          style: TextStyle(
            fontSize: _TabletSizes.appBarTitleSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        actions: [
          Obx(() {
            final isGrid = controller.viewMode.value == ActivityViewMode.grid;
            return IconButton(
              tooltip: isGrid ? 'Liste Görünümü' : 'Izgara Görünümü',
              icon: Icon(
                isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
                size: _TabletSizes.appBarIconSize,
                color: AppTheme.textPri(context),
              ),
              onPressed: () => controller.changeViewMode(
                isGrid ? ActivityViewMode.list : ActivityViewMode.grid,
              ),
            );
          }),
          SizedBox(width: _TabletSizes.appBarIconPadding),
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
                    strokeWidth: _TabletSizes.loadingStrokeWidth,
                  ),
                );
              }

              if (controller.videos.isEmpty) {
                return _EmptyViewTablet(
                  emptyText: controller.emptyText,
                  emptySubtext: controller.emptySubtext,
                  activityType: controller.activityType,
                );
              }

              final displayVideos = controller.filteredVideos;

              if (displayVideos.isEmpty) {
                return _NoSearchResultsViewTablet(
                  query: controller.searchQuery.value,
                );
              }

              final isGrid = controller.viewMode.value == ActivityViewMode.grid;

              return RefreshIndicator(
                color: AppTheme.primaryColor,
                onRefresh: controller.loadInitial,
                child: _FlatContentTablet(
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

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

// ─── Düz Liste / Izgara (Phone) ──────────────────────────────────────────

class _FlatContentPhone extends StatelessWidget {
  final ProfileActivityListController controller;
  final List<VideoModel> videos;
  final ScrollController scrollController;
  final bool isGrid;

  const _FlatContentPhone({
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
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.gridPaddingHorizontal.w,
          vertical: _PhoneSizes.gridPaddingVertical.h,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: _PhoneSizes.gridMainSpacing.h,
          crossAxisSpacing: _PhoneSizes.gridCrossSpacing.w,
          childAspectRatio: _PhoneSizes.gridChildAspectRatio,
        ),
        itemCount: videos.length + extraCount,
        itemBuilder: (context, index) {
          if (index == videos.length) return const _LoadMoreIndicatorPhone();
          final video = videos[index];
          return _buildItemPhone(context, video, isGrid: true);
        },
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: _PhoneSizes.listPaddingHorizontal.w,
        vertical: _PhoneSizes.listPaddingVertical.h,
      ),
      itemCount: videos.length + extraCount,
      itemBuilder: (context, index) {
        if (index == videos.length) return const _LoadMoreIndicatorPhone();
        final video = videos[index];
        return _buildItemPhone(context, video, isGrid: false);
      },
    );
  }

  Widget _buildItemPhone(
    BuildContext context,
    VideoModel video, {
    required bool isGrid,
  }) {
    if (!controller.isOwnProfile) {
      return isGrid
          ? _VideoGridCardPhone(video: video)
          : _VideoCardPhone(video: video);
    }
    return _DismissibleVideoPhone(
      controller: controller,
      video: video,
      child: isGrid
          ? _VideoGridCardPhone(video: video)
          : _VideoCardPhone(video: video),
    );
  }
}

// ─── Silinebilir Sarmalayıcı (Phone) ──────────────────────────────────────

class _DismissibleVideoPhone extends StatelessWidget {
  final ProfileActivityListController controller;
  final VideoModel video;
  final Widget child;

  const _DismissibleVideoPhone({
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
        margin: EdgeInsets.only(bottom: _PhoneSizes.dismissibleMarginBottom.h),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(
            _PhoneSizes.dismissibleBorderRadius.r,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: _PhoneSizes.dismissiblePaddingRight.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: _PhoneSizes.dismissibleIconSize.sp,
            ),
            SizedBox(height: _PhoneSizes.dismissibleSpacing.h),
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.white,
                fontSize: _PhoneSizes.dismissibleTextFontSize.sp,
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
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.dialogBorderRadius.r,
                  ),
                ),
                title: Text(
                  'Kaydı Sil',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _PhoneSizes.dialogTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Bu kayıt listenden kaldırılacak. Emin misin?',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.dialogContentFontSize.sp,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _PhoneSizes.dialogButtonFontSize.sp,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        _PhoneSizes.dialogButtonWidth.w,
                        _PhoneSizes.dialogButtonHeight.h,
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      'Sil',
                      style: TextStyle(
                        fontSize: _PhoneSizes.dialogButtonFontSize.sp,
                      ),
                    ),
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

// ─── Video Kartı (Liste - Phone) ──────────────────────────────────────────

class _VideoCardPhone extends StatelessWidget {
  final VideoModel video;
  const _VideoCardPhone({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: _PhoneSizes.listCardBottomMargin.h),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(
            _PhoneSizes.listCardBorderRadius.r,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_PhoneSizes.listThumbnailRadius.r),
                bottomLeft: Radius.circular(_PhoneSizes.listThumbnailRadius.r),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: _PhoneSizes.listThumbnailWidth.w,
                    height: _PhoneSizes.listThumbnailHeight.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: _PhoneSizes.listThumbnailWidth.w,
                      height: _PhoneSizes.listThumbnailHeight.h,
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: _PhoneSizes.listThumbnailWidth.w,
                      height: _PhoneSizes.listThumbnailHeight.h,
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _PhoneSizes.listThumbnailIconSize.sp,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: _PhoneSizes.durationBadgePaddingVertical.h,
                      right: _PhoneSizes.durationBadgePaddingHorizontal.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              _PhoneSizes.durationBadgePaddingHorizontal.w,
                          vertical: _PhoneSizes.durationBadgePaddingVertical.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.durationBadgeBorderRadius.r,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.durationBadgeFontSize.sp,
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
                padding: EdgeInsets.fromLTRB(
                  _PhoneSizes.listContentPaddingLeft.w,
                  _PhoneSizes.listContentPaddingTop.h,
                  _PhoneSizes.listContentPaddingRight.w,
                  _PhoneSizes.listContentPaddingBottom.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.listTitleFontSize.sp,
                        fontWeight: FontWeight.w600,
                        height: _PhoneSizes.listTitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: _PhoneSizes.durationBadgePaddingVertical.h,
                    ),
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: _PhoneSizes.listUniFontSize.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((video.universityName ?? '').isNotEmpty)
                      SizedBox(
                        height: _PhoneSizes.durationBadgePaddingVertical.h,
                      ),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _PhoneSizes.listDateFontSize.sp,
                      ),
                    ),
                    SizedBox(height: _PhoneSizes.dismissibleSpacing.h),
                    _StatRowCompactPhone(video: video),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: _PhoneSizes.listChevronRight.w,
                top: _PhoneSizes.listChevronTop.h,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: _PhoneSizes.listChevronSize.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Video Kartı (Izgara - Phone) ─────────────────────────────────────────

class _VideoGridCardPhone extends StatelessWidget {
  final VideoModel video;
  const _VideoGridCardPhone({required this.video});

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
          borderRadius: BorderRadius.circular(
            _PhoneSizes.gridCardBorderRadius.r,
          ),
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
                    placeholder: (_, __) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _PhoneSizes.listThumbnailIconSize.sp,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: _PhoneSizes.durationBadgePaddingVertical.h,
                      right: _PhoneSizes.durationBadgePaddingHorizontal.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              _PhoneSizes.durationBadgePaddingHorizontal.w,
                          vertical: _PhoneSizes.durationBadgePaddingVertical.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.durationBadgeBorderRadius.r,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _PhoneSizes.durationBadgeGridFontSize.sp,
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
                padding: EdgeInsets.fromLTRB(
                  _PhoneSizes.gridCardPaddingLeft.w,
                  _PhoneSizes.gridCardPaddingTop.h,
                  _PhoneSizes.gridCardPaddingRight.w,
                  _PhoneSizes.gridCardPaddingBottom.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _PhoneSizes.gridTitleFontSize.sp,
                        fontWeight: FontWeight.w600,
                        height: _PhoneSizes.gridTitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((video.universityName ?? '').isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: _PhoneSizes.gridUniPaddingTop.h,
                        ),
                        child: Text(
                          video.universityName!,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: _PhoneSizes.gridUniFontSize.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    _StatRowGridPhone(video: video),
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

// ─── İstatistik Satırı – Liste (Phone) ────────────────────────────────────

class _StatRowCompactPhone extends StatelessWidget {
  final VideoModel video;
  const _StatRowCompactPhone({required this.video});

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
      spacing: _PhoneSizes.listStatSpacing.w,
      runSpacing: _PhoneSizes.dismissibleSpacing.h,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: _PhoneSizes.listStatIconSize.sp,
                  color: AppTheme.textSec(context),
                ),
                SizedBox(width: _PhoneSizes.durationBadgePaddingHorizontal.w),
                Text(
                  _compactNumber(item.value),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.listStatFontSize.sp,
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

// ─── İstatistik Satırı – Izgara (Phone) ──────────────────────────────────

class _StatRowGridPhone extends StatelessWidget {
  final VideoModel video;
  const _StatRowGridPhone({required this.video});

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
        if (row1.isNotEmpty) _buildGridStatLinePhone(context, row1),
        if (row1.isNotEmpty && row2.isNotEmpty)
          SizedBox(height: _PhoneSizes.gridStatLineSpacing.h),
        if (row2.isNotEmpty) _buildGridStatLinePhone(context, row2),
      ],
    );
  }

  Widget _buildGridStatLinePhone(BuildContext context, List<_StatItem> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: _PhoneSizes.gridStatSpacing.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                items[i].icon,
                size: _PhoneSizes.gridStatIconSize.sp,
                color: AppTheme.textSec(context),
              ),
              SizedBox(width: _PhoneSizes.durationBadgePaddingHorizontal.w),
              Text(
                _compactNumber(items[i].value),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.gridStatFontSize.sp,
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

// ─── Daha Fazla Yükle Göstergesi (Phone) ─────────────────────────────────

class _LoadMoreIndicatorPhone extends StatelessWidget {
  const _LoadMoreIndicatorPhone();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _PhoneSizes.loadMorePaddingVertical.h,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: _PhoneSizes.loadMoreStrokeWidth.w,
        ),
      ),
    );
  }
}

// ─── Boş Durum (Phone) ────────────────────────────────────────────────────

class _EmptyViewPhone extends StatelessWidget {
  final String emptyText;
  final String emptySubtext;
  final ProfileActivityType activityType;

  const _EmptyViewPhone({
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
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.emptyPaddingHorizontal.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: AppTheme.textSec(context),
              size: _PhoneSizes.emptyIconSize.sp,
            ),
            SizedBox(height: _PhoneSizes.emptySpacingLarge.h),
            Text(
              emptyText,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.emptyTitleFontSize.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _PhoneSizes.emptySpacingSmall.h),
            Text(
              emptySubtext,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.emptySubtitleFontSize.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Arama Sonucu Bulunamadı (Phone) ──────────────────────────────────────

class _NoSearchResultsViewPhone extends StatelessWidget {
  final String query;
  const _NoSearchResultsViewPhone({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _PhoneSizes.noResultPaddingHorizontal.w,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppTheme.textSec(context),
              size: _PhoneSizes.noResultIconSize.sp,
            ),
            SizedBox(height: _PhoneSizes.noResultSpacingLarge.h),
            Text(
              '"$query" için sonuç bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _PhoneSizes.noResultTitleFontSize.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _PhoneSizes.noResultSpacingSmall.h),
            Text(
              'Üniversite adını veya video başlığını kontrol et',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.noResultSubtitleFontSize.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

// ─── Düz Liste / Izgara (Tablet) ──────────────────────────────────────────

class _FlatContentTablet extends StatelessWidget {
  final ProfileActivityListController controller;
  final List<VideoModel> videos;
  final ScrollController scrollController;
  final bool isGrid;

  const _FlatContentTablet({
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
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.gridPaddingHorizontal,
          vertical: _TabletSizes.gridPaddingVertical,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: _TabletSizes.gridMainSpacing,
          crossAxisSpacing: _TabletSizes.gridCrossSpacing,
          childAspectRatio: _TabletSizes.gridChildAspectRatio,
        ),
        itemCount: videos.length + extraCount,
        itemBuilder: (context, index) {
          if (index == videos.length) return const _LoadMoreIndicatorTablet();
          final video = videos[index];
          return _buildItemTablet(context, video, isGrid: true);
        },
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: _TabletSizes.listPaddingHorizontal,
        vertical: _TabletSizes.listPaddingVertical,
      ),
      itemCount: videos.length + extraCount,
      itemBuilder: (context, index) {
        if (index == videos.length) return const _LoadMoreIndicatorTablet();
        final video = videos[index];
        return _buildItemTablet(context, video, isGrid: false);
      },
    );
  }

  Widget _buildItemTablet(
    BuildContext context,
    VideoModel video, {
    required bool isGrid,
  }) {
    if (!controller.isOwnProfile) {
      return isGrid
          ? _VideoGridCardTablet(video: video)
          : _VideoCardTablet(video: video);
    }
    return _DismissibleVideoTablet(
      controller: controller,
      video: video,
      child: isGrid
          ? _VideoGridCardTablet(video: video)
          : _VideoCardTablet(video: video),
    );
  }
}

// ─── Silinebilir Sarmalayıcı (Tablet) ──────────────────────────────────────

class _DismissibleVideoTablet extends StatelessWidget {
  final ProfileActivityListController controller;
  final VideoModel video;
  final Widget child;

  const _DismissibleVideoTablet({
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
        margin: EdgeInsets.only(bottom: _TabletSizes.dismissibleMarginBottom),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(
            _TabletSizes.dismissibleBorderRadius,
          ),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: _TabletSizes.dismissiblePaddingRight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: _TabletSizes.dismissibleIconSize,
            ),
            SizedBox(height: _TabletSizes.dismissibleSpacing),
            Text(
              'Sil',
              style: TextStyle(
                color: Colors.white,
                fontSize: _TabletSizes.dismissibleTextFontSize,
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
                  borderRadius: BorderRadius.circular(
                    _TabletSizes.dialogBorderRadius,
                  ),
                ),
                title: Text(
                  'Kaydı Sil',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: _TabletSizes.dialogTitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: Text(
                  'Bu kayıt listenden kaldırılacak. Emin misin?',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.dialogContentFontSize,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.dialogButtonFontSize,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        _TabletSizes.dialogButtonWidth,
                        _TabletSizes.dialogButtonHeight,
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      'Sil',
                      style: TextStyle(
                        fontSize: _TabletSizes.dialogButtonFontSize,
                      ),
                    ),
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

// ─── Video Kartı (Liste - Tablet) ──────────────────────────────────────────

class _VideoCardTablet extends StatelessWidget {
  final VideoModel video;
  const _VideoCardTablet({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.player,
        arguments: video,
        parameters: {'videoId': video.videoId},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: _TabletSizes.listCardBottomMargin),
        decoration: BoxDecoration(
          color: AppTheme.card(context),
          borderRadius: BorderRadius.circular(
            _TabletSizes.listCardBorderRadius,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_TabletSizes.listThumbnailRadius),
                bottomLeft: Radius.circular(_TabletSizes.listThumbnailRadius),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: _TabletSizes.listThumbnailWidth,
                    height: _TabletSizes.listThumbnailHeight,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: _TabletSizes.listThumbnailWidth,
                      height: _TabletSizes.listThumbnailHeight,
                      color: AppTheme.surface(context),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: _TabletSizes.listThumbnailWidth,
                      height: _TabletSizes.listThumbnailHeight,
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.listThumbnailIconSize,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: _TabletSizes.durationBadgePaddingVertical,
                      right: _TabletSizes.durationBadgePaddingHorizontal,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              _TabletSizes.durationBadgePaddingHorizontal,
                          vertical: _TabletSizes.durationBadgePaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.durationBadgeBorderRadius,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.durationBadgeFontSize,
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
                padding: EdgeInsets.fromLTRB(
                  _TabletSizes.listContentPaddingLeft,
                  _TabletSizes.listContentPaddingTop,
                  _TabletSizes.listContentPaddingRight,
                  _TabletSizes.listContentPaddingBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.listTitleFontSize,
                        fontWeight: FontWeight.w600,
                        height: _TabletSizes.listTitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: _TabletSizes.durationBadgePaddingVertical),
                    if ((video.universityName ?? '').isNotEmpty)
                      Text(
                        video.universityName!,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: _TabletSizes.listUniFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if ((video.universityName ?? '').isNotEmpty)
                      SizedBox(
                        height: _TabletSizes.durationBadgePaddingVertical,
                      ),
                    Text(
                      _timeAgo(video.publishedAt),
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: _TabletSizes.listDateFontSize,
                      ),
                    ),
                    SizedBox(height: _TabletSizes.dismissibleSpacing),
                    _StatRowCompactTablet(video: video),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                right: _TabletSizes.listChevronRight,
                top: _TabletSizes.listChevronTop,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSec(context),
                size: _TabletSizes.listChevronSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Video Kartı (Izgara - Tablet) ─────────────────────────────────────────

class _VideoGridCardTablet extends StatelessWidget {
  final VideoModel video;
  const _VideoGridCardTablet({required this.video});

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
          borderRadius: BorderRadius.circular(
            _TabletSizes.gridCardBorderRadius,
          ),
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
                    placeholder: (_, __) =>
                        Container(color: AppTheme.surface(context)),
                    errorWidget: (_, __, ___) => Container(
                      color: AppTheme.surface(context),
                      child: Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.textSec(context),
                        size: _TabletSizes.listThumbnailIconSize,
                      ),
                    ),
                  ),
                  if (video.formattedDuration.isNotEmpty)
                    Positioned(
                      bottom: _TabletSizes.durationBadgePaddingVertical,
                      right: _TabletSizes.durationBadgePaddingHorizontal,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              _TabletSizes.durationBadgePaddingHorizontal,
                          vertical: _TabletSizes.durationBadgePaddingVertical,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.durationBadgeBorderRadius,
                          ),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _TabletSizes.durationBadgeGridFontSize,
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
                padding: EdgeInsets.fromLTRB(
                  _TabletSizes.gridCardPaddingLeft,
                  _TabletSizes.gridCardPaddingTop,
                  _TabletSizes.gridCardPaddingRight,
                  _TabletSizes.gridCardPaddingBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: TextStyle(
                        color: AppTheme.textPri(context),
                        fontSize: _TabletSizes.gridTitleFontSize,
                        fontWeight: FontWeight.w600,
                        height: _TabletSizes.gridTitleLineHeight,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((video.universityName ?? '').isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: _TabletSizes.gridUniPaddingTop,
                        ),
                        child: Text(
                          video.universityName!,
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: _TabletSizes.gridUniFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    _StatRowGridTablet(video: video),
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

// ─── İstatistik Satırı – Liste (Tablet) ────────────────────────────────────

class _StatRowCompactTablet extends StatelessWidget {
  final VideoModel video;
  const _StatRowCompactTablet({required this.video});

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
      spacing: _TabletSizes.listStatSpacing,
      runSpacing: _TabletSizes.dismissibleSpacing,
      children: items
          .map(
            (item) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.icon,
                  size: _TabletSizes.listStatIconSize,
                  color: AppTheme.textSec(context),
                ),
                SizedBox(width: _TabletSizes.durationBadgePaddingHorizontal),
                Text(
                  _compactNumber(item.value),
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.listStatFontSize,
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

// ─── İstatistik Satırı – Izgara (Tablet) ──────────────────────────────────

class _StatRowGridTablet extends StatelessWidget {
  final VideoModel video;
  const _StatRowGridTablet({required this.video});

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
        if (row1.isNotEmpty) _buildGridStatLineTablet(context, row1),
        if (row1.isNotEmpty && row2.isNotEmpty)
          SizedBox(height: _TabletSizes.gridStatLineSpacing),
        if (row2.isNotEmpty) _buildGridStatLineTablet(context, row2),
      ],
    );
  }

  Widget _buildGridStatLineTablet(BuildContext context, List<_StatItem> items) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: _TabletSizes.gridStatSpacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                items[i].icon,
                size: _TabletSizes.gridStatIconSize,
                color: AppTheme.textSec(context),
              ),
              SizedBox(width: _TabletSizes.durationBadgePaddingHorizontal),
              Text(
                _compactNumber(items[i].value),
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.gridStatFontSize,
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

// ─── Daha Fazla Yükle Göstergesi (Tablet) ─────────────────────────────────

class _LoadMoreIndicatorTablet extends StatelessWidget {
  const _LoadMoreIndicatorTablet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: _TabletSizes.loadMorePaddingVertical,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
          strokeWidth: _TabletSizes.loadMoreStrokeWidth,
        ),
      ),
    );
  }
}

// ─── Boş Durum (Tablet) ────────────────────────────────────────────────────

class _EmptyViewTablet extends StatelessWidget {
  final String emptyText;
  final String emptySubtext;
  final ProfileActivityType activityType;

  const _EmptyViewTablet({
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
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.emptyPaddingHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icon,
              color: AppTheme.textSec(context),
              size: _TabletSizes.emptyIconSize,
            ),
            SizedBox(height: _TabletSizes.emptySpacingLarge),
            Text(
              emptyText,
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _TabletSizes.emptySpacingSmall),
            Text(
              emptySubtext,
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.emptySubtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Arama Sonucu Bulunamadı (Tablet) ──────────────────────────────────────

class _NoSearchResultsViewTablet extends StatelessWidget {
  final String query;
  const _NoSearchResultsViewTablet({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _TabletSizes.noResultPaddingHorizontal,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              color: AppTheme.textSec(context),
              size: _TabletSizes.noResultIconSize,
            ),
            SizedBox(height: _TabletSizes.noResultSpacingLarge),
            Text(
              '"$query" için sonuç bulunamadı',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: _TabletSizes.noResultTitleFontSize,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: _TabletSizes.noResultSpacingSmall),
            Text(
              'Üniversite adını veya video başlığını kontrol et',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.noResultSubtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ORTAK YARDIMCI FONKSİYONLAR
// ═══════════════════════════════════════════════════════════════════════

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
