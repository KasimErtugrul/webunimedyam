// lib/presentation/screens/player/video_viewers_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../../data/models/video_viewer_model.dart';
import '../../controllers/video_viewers_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // AppBar
  static const double appBarTitleSize = 16;
  static const double appBarSubtitleSize = 11;
  //static const double appBarSubtitleWeight = 400;

  // List tile
  static const double tileContentPaddingHorizontal = 16;
  static const double tileContentPaddingVertical = 4;
  static const double tileAvatarRadius = 22;
  static const double tileAvatarIconSize = 20;
  static const double tileTitleFontSize = 14;
  //static const double tileTitleWeight = 500;
  static const double tileSubtitleFontSize = 12;
  static const double tileTrailingFontSize = 11;

  // Hidden row
  static const double hiddenRowPaddingHorizontal = 16;
  static const double hiddenRowPaddingVertical = 12;
  static const double hiddenRowIconSize = 16;
  static const double hiddenRowSpacing = 8;
  static const double hiddenRowFontSize = 12;

  // Empty state
  static const double emptyIconSize = 48;
  static const double emptySpacing = 12;
  static const double emptyFontSize = 14;

  // Loading
  static const double loadingPadding = 16;
  static const double loadingStrokeWidth = 3;

  // List padding
  static const double listVerticalPadding = 8;
}

class _TabletSizes {
  // AppBar
  static const double appBarTitleSize = 20;
  static const double appBarSubtitleSize = 14;
 // static const double appBarSubtitleWeight = 400;

  // List tile
  static const double tileContentPaddingHorizontal = 24;
  static const double tileContentPaddingVertical = 6;
  static const double tileAvatarRadius = 28;
  static const double tileAvatarIconSize = 24;
  static const double tileTitleFontSize = 16;
 // static const double tileTitleWeight = 500;
  static const double tileSubtitleFontSize = 14;
  static const double tileTrailingFontSize = 13;

  // Hidden row
  static const double hiddenRowPaddingHorizontal = 24;
  static const double hiddenRowPaddingVertical = 16;
  static const double hiddenRowIconSize = 20;
  static const double hiddenRowSpacing = 10;
  static const double hiddenRowFontSize = 14;

  // Empty state
  static const double emptyIconSize = 56;
  static const double emptySpacing = 16;
  static const double emptyFontSize = 16;

  // Loading
  static const double loadingPadding = 20;
  static const double loadingStrokeWidth = 3.5;

  // List padding
  static const double listVerticalPadding = 12;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class VideoViewersScreen extends StatefulWidget {
  const VideoViewersScreen({super.key});

  @override
  State<VideoViewersScreen> createState() => _VideoViewersScreenState();
}

class _VideoViewersScreenState extends State<VideoViewersScreen> {
  late final VideoViewersController _ctrl;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _ctrl = Get.put(
      VideoViewersController(
        engagementRepository: Get.find(),
        videoId: args['videoId'] as String? ?? '',
        totalViewCount: args['totalViewCount'] as int? ?? 0,
      ),
    );
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _ctrl.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 5 — TEK DALLANMA NOKTASI
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İzleyenler',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _PhoneSizes.appBarTitleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_ctrl.isLoading.value)
                Text(
                  '${_ctrl.totalViewCount} görüntülenme',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _PhoneSizes.appBarSubtitleSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPri(context)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_ctrl.viewers.isEmpty && _ctrl.hiddenCount.value == 0) {
          return _EmptyStatePhone();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: _PhoneSizes.listVerticalPadding),
          itemCount:
              _ctrl.viewers.length +
              (_ctrl.hiddenCount.value > 0 ? 1 : 0) +
              (_ctrl.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _ctrl.viewers.length &&
                _ctrl.hiddenCount.value > 0 &&
                !_ctrl.isLoadingMore.value) {
              return _HiddenViewersRowPhone(count: _ctrl.hiddenCount.value);
            }

            if (_ctrl.isLoadingMore.value &&
                index == _ctrl.viewers.length + (_ctrl.hiddenCount.value > 0 ? 1 : 0)) {
              return const Padding(
                padding: EdgeInsets.all(_PhoneSizes.loadingPadding),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: _PhoneSizes.loadingStrokeWidth,
                  ),
                ),
              );
            }

            final viewer = _ctrl.viewers[index];
            return _ViewerTilePhone(viewer: viewer);
          },
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      appBar: AppBar(
        backgroundColor: AppTheme.bg(context),
        elevation: 0,
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'İzleyenler',
                style: TextStyle(
                  color: AppTheme.textPri(context),
                  fontSize: _TabletSizes.appBarTitleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!_ctrl.isLoading.value)
                Text(
                  '${_ctrl.totalViewCount} görüntülenme',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: _TabletSizes.appBarSubtitleSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textPri(context)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_ctrl.viewers.isEmpty && _ctrl.hiddenCount.value == 0) {
          return _EmptyStateTablet();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: _TabletSizes.listVerticalPadding),
          itemCount:
              _ctrl.viewers.length +
              (_ctrl.hiddenCount.value > 0 ? 1 : 0) +
              (_ctrl.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _ctrl.viewers.length &&
                _ctrl.hiddenCount.value > 0 &&
                !_ctrl.isLoadingMore.value) {
              return _HiddenViewersRowTablet(count: _ctrl.hiddenCount.value);
            }

            if (_ctrl.isLoadingMore.value &&
                index == _ctrl.viewers.length + (_ctrl.hiddenCount.value > 0 ? 1 : 0)) {
              return const Padding(
                padding: EdgeInsets.all(_TabletSizes.loadingPadding),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: _TabletSizes.loadingStrokeWidth,
                  ),
                ),
              );
            }

            final viewer = _ctrl.viewers[index];
            return _ViewerTileTablet(viewer: viewer);
          },
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _ViewerTilePhone extends StatelessWidget {
  final VideoViewerModel viewer;
  const _ViewerTilePhone({required this.viewer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.toNamed(
        AppRoutes.profile,
        arguments: {'userId': viewer.userId},
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _PhoneSizes.tileContentPaddingHorizontal,
        vertical: _PhoneSizes.tileContentPaddingVertical,
      ),
      leading: CircleAvatar(
        radius: _PhoneSizes.tileAvatarRadius,
        backgroundColor: AppTheme.surface(context),
        backgroundImage: viewer.avatarUrl != null
            ? NetworkImage(viewer.avatarUrl!)
            : null,
        child: viewer.avatarUrl == null
            ? Icon(
                Icons.person,
                color: AppTheme.textSec(context),
                size: _PhoneSizes.tileAvatarIconSize,
              )
            : null,
      ),
      title: Text(
        viewer.displayName,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: _PhoneSizes.tileTitleFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: viewer.username != null
          ? Text(
              '@${viewer.username}',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.tileSubtitleFontSize,
              ),
            )
          : null,
      trailing: Text(
        _timeAgo(viewer.viewedAt),
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _PhoneSizes.tileTrailingFontSize,
        ),
      ),
    );
  }
}

class _HiddenViewersRowPhone extends StatelessWidget {
  final int count;
  const _HiddenViewersRowPhone({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _PhoneSizes.hiddenRowPaddingHorizontal,
        vertical: _PhoneSizes.hiddenRowPaddingVertical,
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_outlined,
            color: AppTheme.textSec(context),
            size: _PhoneSizes.hiddenRowIconSize,
          ),
          const SizedBox(width: _PhoneSizes.hiddenRowSpacing),
          Expanded(
            child: Text(
              '$count kişi profilini gizli tuttuğu için gösterilmiyor.',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _PhoneSizes.hiddenRowFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStatePhone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: _PhoneSizes.emptyIconSize,
            color: AppTheme.textSec(context),
          ),
          const SizedBox(height: _PhoneSizes.emptySpacing),
          Text(
            'Henüz kimse izlemedi',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _PhoneSizes.emptyFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _ViewerTileTablet extends StatelessWidget {
  final VideoViewerModel viewer;
  const _ViewerTileTablet({required this.viewer});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.toNamed(
        AppRoutes.profile,
        arguments: {'userId': viewer.userId},
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: _TabletSizes.tileContentPaddingHorizontal,
        vertical: _TabletSizes.tileContentPaddingVertical,
      ),
      leading: CircleAvatar(
        radius: _TabletSizes.tileAvatarRadius,
        backgroundColor: AppTheme.surface(context),
        backgroundImage: viewer.avatarUrl != null
            ? NetworkImage(viewer.avatarUrl!)
            : null,
        child: viewer.avatarUrl == null
            ? Icon(
                Icons.person,
                color: AppTheme.textSec(context),
                size: _TabletSizes.tileAvatarIconSize,
              )
            : null,
      ),
      title: Text(
        viewer.displayName,
        style: TextStyle(
          color: AppTheme.textPri(context),
          fontSize: _TabletSizes.tileTitleFontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: viewer.username != null
          ? Text(
              '@${viewer.username}',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.tileSubtitleFontSize,
              ),
            )
          : null,
      trailing: Text(
        _timeAgo(viewer.viewedAt),
        style: TextStyle(
          color: AppTheme.textSec(context),
          fontSize: _TabletSizes.tileTrailingFontSize,
        ),
      ),
    );
  }
}

class _HiddenViewersRowTablet extends StatelessWidget {
  final int count;
  const _HiddenViewersRowTablet({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _TabletSizes.hiddenRowPaddingHorizontal,
        vertical: _TabletSizes.hiddenRowPaddingVertical,
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_off_outlined,
            color: AppTheme.textSec(context),
            size: _TabletSizes.hiddenRowIconSize,
          ),
          const SizedBox(width: _TabletSizes.hiddenRowSpacing),
          Expanded(
            child: Text(
              '$count kişi profilini gizli tuttuğu için gösterilmiyor.',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: _TabletSizes.hiddenRowFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateTablet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.visibility_outlined,
            size: _TabletSizes.emptyIconSize,
            color: AppTheme.textSec(context),
          ),
          const SizedBox(height: _TabletSizes.emptySpacing),
          Text(
            'Henüz kimse izlemedi',
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.emptyFontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ORTAK YARDIMCI FUNKSİYON
// ═══════════════════════════════════════════════════════════════════════

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}dk önce';
  if (diff.inHours < 24) return '${diff.inHours}s önce';
  if (diff.inDays < 7) return '${diff.inDays}g önce';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}hf önce';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}ay önce';
  return '${(diff.inDays / 365).floor()}y önce';
}