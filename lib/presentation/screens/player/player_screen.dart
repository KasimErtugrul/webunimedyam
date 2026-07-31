// lib/presentation/screens/player/player_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/player_controller.dart';
import 'player_screen_widgets/comment_header_widget.dart';
import 'player_screen_widgets/comment_input_widget.dart';
import 'player_screen_widgets/comment_tile_widget.dart';
import 'player_screen_widgets/engagement_bar/engagement_bar_widget.dart';
import 'player_screen_widgets/expandable_description_widget.dart';
import 'player_screen_widgets/tag_row_widget.dart';
import 'player_screen_widgets/university_row_widget.dart';
import 'player_screen_widgets/suggested_videos_section_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Player
  static const double miniW = 192.0;
  static const double miniH = 108.0;
  static const double miniPad = 14.0;
  static const double miniBorderRadius = 10.0;
  static const double miniShadowBlur = 18.0;
  static const Duration animDur = Duration(milliseconds: 280);
  static const Curve animCurve = Curves.easeInOutCubic;
  static const double dragTapThreshold = 6.0;

  // Back button
  static const double backButtonLeft = 4.0;
  static const double backButtonTop = 8.0;
  static const double backButtonPadding = 8.0;
  static const double backButtonRadius = 20.0;
  static const double backButtonSize = 18.0;
  static const double backButtonAlpha = 0.55;

  // Content
  static const double contentPaddingLeft = 16.0;
  static const double contentPaddingTop = 14.0;
  static const double contentPaddingRight = 16.0;
  static const double contentPaddingBottom = 16.0;
  static const double dateFontSize = 11.0;
  static const double dateDurationDotSpacing = 6.0;
  static const double titleFontSize = 15.0;
  static const double titleLineHeight = 1.4;
  static const double titleSpacing = 6.0;
  static const double universitySpacing = 4.0;
  static const double engagementSpacing = 14.0;
  static const double engagementBottomSpacing = 20.0;
  static const double descriptionSpacing = 12.0;
  static const double tagsSpacing = 14.0;
  static const double tagsBottomSpacing = 20.0;
  static const double suggestedSpacing = 20.0;
  static const double dividerSpacing = 16.0;
  static const double commentsHeaderSpacing = 12.0;
  static const double commentsInputSpacing = 16.0;
  static const double commentsLoadingSpacing = 24.0;
  static const double commentsEmptySpacing = 20.0;
  static const double commentsEmptyFontSize = 13.0;
  static const double bottomSpacing = 32.0;

  // Loading
  static const double loadingStrokeWidth = 3.0;

  // Auth dialog
  static const double dialogBorderRadius = 16.0;
  static const double dialogButtonRadius = 8.0;
}

class _TabletSizes {
  // Player - tablet için daha büyük
  static const double miniW = 320.0;
  static const double miniH = 180.0;
  static const double miniPad = 20.0;
  static const double miniBorderRadius = 12.0;
  static const double miniShadowBlur = 24.0;
  static const Duration animDur = Duration(milliseconds: 300);
  static const Curve animCurve = Curves.easeInOutCubic;
  static const double dragTapThreshold = 8.0;

  // Back button - tablet için daha büyük
  static const double backButtonLeft = 8.0;
  static const double backButtonTop = 12.0;
  static const double backButtonPadding = 10.0;
  static const double backButtonRadius = 24.0;
  static const double backButtonSize = 22.0;
  static const double backButtonAlpha = 0.55;

  // Content - tablet için daha büyük
  static const double contentPaddingLeft = 24.0;
  static const double contentPaddingTop = 18.0;
  static const double contentPaddingRight = 24.0;
  static const double contentPaddingBottom = 24.0;
  static const double dateFontSize = 13.0;
  static const double dateDurationDotSpacing = 8.0;
  static const double titleFontSize = 20.0;
  static const double titleLineHeight = 1.45;
  static const double titleSpacing = 8.0;
  static const double universitySpacing = 6.0;
  static const double engagementSpacing = 18.0;
  static const double engagementBottomSpacing = 24.0;
  static const double descriptionSpacing = 16.0;
  static const double tagsSpacing = 18.0;
  static const double tagsBottomSpacing = 24.0;
  static const double suggestedSpacing = 24.0;
  static const double dividerSpacing = 20.0;
  static const double commentsHeaderSpacing = 16.0;
  static const double commentsInputSpacing = 20.0;
  static const double commentsLoadingSpacing = 30.0;
  static const double commentsEmptySpacing = 24.0;
  static const double commentsEmptyFontSize = 15.0;
  static const double bottomSpacing = 40.0;

  // Loading - tablet için daha büyük
  static const double loadingStrokeWidth = 3.5;

  // Auth dialog - tablet için daha büyük
  static const double dialogBorderRadius = 20.0;
  static const double dialogButtonRadius = 10.0;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerController _controller;
  late final ScrollController _scrollController;

  Worker? _authWorker;
  Worker? _snackbarWorker;

  OverlayEntry? _overlayEntry;

  double _bigH = 0;
  bool _isMini = false;
  Offset? _miniPosition;
  double _dragTotal = 0;
  bool _isPanningMini = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlayerController>(
      tag: Get.parameters['videoId'] ?? '123',
    );
    _scrollController = ScrollController()..addListener(_onScroll);

    _authWorker = ever(_controller.showAuthRequired, (v) {
      if (v) {
        _showAuthDialog();
        _controller.showAuthRequired.value = false;
      }
    });
    _snackbarWorker = ever(_controller.snackbarMessage, (msg) {
      if (msg != null) {
        Get.snackbar(
          'Bilgi',
          msg,
          backgroundColor: const Color(0xFF1E1E2E),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(12),
        );
        _controller.snackbarMessage.value = null;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final h = MediaQuery.of(context).size.width * 9 / 16;
      setState(() => _bigH = h);
      _insertOverlay();
    });
  }

  void _insertOverlay() {
    final isTablet = Responsive.isTablet(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => isTablet
          ? _OverlayButtonsTablet(
              isMini: _isMini,
              bigH: _bigH,
              miniW: _TabletSizes.miniW,
              miniH: _TabletSizes.miniH,
              miniPad: _TabletSizes.miniPad,
              animDur: _TabletSizes.animDur,
              animCurve: _TabletSizes.animCurve,
              miniPosition: _miniPosition,
              isDragging: _dragTotal > _TabletSizes.dragTapThreshold,
              isPanning: _isPanningMini,
              onBack: () => Get.back(),
              onPanStart: _onMiniPanStart,
              onPanUpdate: _onMiniPanUpdate,
              onPanEnd: _onMiniPanEnd,
            )
          : _OverlayButtonsPhone(
              isMini: _isMini,
              bigH: _bigH,
              miniW: _PhoneSizes.miniW,
              miniH: _PhoneSizes.miniH,
              miniPad: _PhoneSizes.miniPad,
              animDur: _PhoneSizes.animDur,
              animCurve: _PhoneSizes.animCurve,
              miniPosition: _miniPosition,
              isDragging: _dragTotal > _PhoneSizes.dragTapThreshold,
              isPanning: _isPanningMini,
              onBack: () => Get.back(),
              onPanStart: _onMiniPanStart,
              onPanUpdate: _onMiniPanUpdate,
              onPanEnd: _onMiniPanEnd,
            ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onScroll() {
    if (_bigH == 0) return;
    final shouldBeMini = _scrollController.offset >= _bigH;
    if (shouldBeMini != _isMini) {
      setState(() {
        _isMini = shouldBeMini;
        if (_isMini) {
          _miniPosition = null;
        }
      });
      _overlayEntry?.markNeedsBuild();
    }
  }

  double _defaultMiniLeft(double screenW) {
    final isTablet = Responsive.isTablet(context);
    final miniW = isTablet ? _TabletSizes.miniW : _PhoneSizes.miniW;
    final miniPad = isTablet ? _TabletSizes.miniPad : _PhoneSizes.miniPad;
    return screenW - miniW - miniPad;
  }

  double _defaultMiniTop(double screenH, double botPad) {
    final isTablet = Responsive.isTablet(context);
    final miniH = isTablet ? _TabletSizes.miniH : _PhoneSizes.miniH;
    final miniPad = isTablet ? _TabletSizes.miniPad : _PhoneSizes.miniPad;
    return screenH - miniH - miniPad - botPad - 56;
  }

  void _onMiniPanStart(DragStartDetails details) {
    if (!_isMini) return;
    _dragTotal = 0;
    _isPanningMini = true;
    if (_miniPosition == null) {
      final mq = MediaQuery.of(context);
      _miniPosition = Offset(
        _defaultMiniLeft(mq.size.width),
        _defaultMiniTop(mq.size.height, mq.padding.bottom),
      );
    }
  }

  void _onMiniPanUpdate(DragUpdateDetails details) {
    if (!_isMini || _miniPosition == null) return;
    final isTablet = Responsive.isTablet(context);
    final miniW = isTablet ? _TabletSizes.miniW : _PhoneSizes.miniW;
    final miniH = isTablet ? _TabletSizes.miniH : _PhoneSizes.miniH;

    _dragTotal += details.delta.distance;

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final newX = (_miniPosition!.dx + details.delta.dx).clamp(
      0.0,
      screenW - miniW,
    );
    final newY = (_miniPosition!.dy + details.delta.dy).clamp(
      topPad,
      screenH - miniH - botPad,
    );

    setState(() {
      _miniPosition = Offset(newX, newY);
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onMiniPanEnd(DragEndDetails details) {
    if (!_isMini) return;
    final isTablet = Responsive.isTablet(context);
    final threshold = isTablet
        ? _TabletSizes.dragTapThreshold
        : _PhoneSizes.dragTapThreshold;
    if (_dragTotal < threshold) {
      _scrollToTop();
    }
    _dragTotal = 0;
    _isPanningMini = false;
    _overlayEntry?.markNeedsBuild();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: _PhoneSizes.animDur,
      curve: _PhoneSizes.animCurve,
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _scrollController.dispose();
    _authWorker?.dispose();
    _snackbarWorker?.dispose();
    super.dispose();
  }

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
      body: Obx(() {
        if (!_controller.isPlayerReady.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
            ),
          );
        }
        return _buildBodyPhone(context);
      }),
    );
  }

  Widget _buildBodyPhone(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;
    final bigH = _bigH > 0 ? _bigH : screenW * 9 / 16;

    final double targetLeft = _isMini
        ? (_miniPosition?.dx ?? _defaultMiniLeft(screenW))
        : 0;
    final double targetTop = _isMini
        ? (_miniPosition?.dy ?? _defaultMiniTop(screenH, botPad))
        : topPad;
    final double targetW = _isMini ? _PhoneSizes.miniW : screenW;
    final double targetH = _isMini ? _PhoneSizes.miniH : bigH;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry?.markNeedsBuild();
    });

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topPad + bigH)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _PhoneSizes.contentPaddingLeft.w,
                _PhoneSizes.contentPaddingTop.h,
                _PhoneSizes.contentPaddingRight.w,
                _PhoneSizes.contentPaddingBottom.h,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildContentItemsPhone(context),
                ),
              ),
            ),
          ],
        ),
        AnimatedPositioned(
          duration: _isPanningMini ? Duration.zero : _PhoneSizes.animDur,
          curve: _PhoneSizes.animCurve,
          left: targetLeft,
          top: targetTop,
          width: targetW,
          height: targetH,
          child: AnimatedContainer(
            duration: _PhoneSizes.animDur,
            curve: _PhoneSizes.animCurve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _isMini ? _PhoneSizes.miniBorderRadius.r : 0,
              ),
              boxShadow: _isMini
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: _PhoneSizes.miniShadowBlur.r,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                _isMini ? _PhoneSizes.miniBorderRadius.r : 0,
              ),
              child: YoutubePlayer(
                controller: _controller.youtubeController!,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContentItemsPhone(BuildContext context) {
    return [
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v == null) return const SizedBox.shrink();
        final d = v.publishedAt;
        final tarih =
            '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        final sure = v.formattedDuration;
        return Padding(
          padding: EdgeInsets.only(bottom: _PhoneSizes.universitySpacing.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tarih,
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.6),
                  fontSize: _PhoneSizes.dateFontSize.sp,
                ),
              ),
              if (sure.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _PhoneSizes.dateDurationDotSpacing.w,
                  ),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.6),
                      fontSize: _PhoneSizes.dateFontSize.sp,
                    ),
                  ),
                ),
                Text(
                  sure,
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.6),
                    fontSize: _PhoneSizes.dateFontSize.sp,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      Obx(
        () => Text(
          _controller.currentVideo.value?.title ?? '',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: _PhoneSizes.titleFontSize.sp,
            fontWeight: FontWeight.w700,
            height: _PhoneSizes.titleLineHeight,
          ),
        ),
      ),
      SizedBox(height: _PhoneSizes.titleSpacing.h),
      Obx(() {
        if (_controller.currentVideo.value?.universityName?.isNotEmpty ==
            true) {
          return Padding(
            padding: EdgeInsets.only(top: _PhoneSizes.universitySpacing.h),
            child: UniversityRowWidget(
              universityName: _controller.currentVideo.value!.universityName!,
              // BUG FIX: Üniversite adına basılınca player ekranı stack'te
              // kalmamalı — Get.toNamed yerine Get.offNamed kullanılarak
              // player rotası kaldırılıp üniversite detayına geçiliyor.
              // Geri tuşuna basınca kullanıcı player'a değil, player'dan
              // önceki ekrana döner.
              onTap: _controller.currentVideo.value!.universityId != null
                  ? () => Get.offNamed(
                      AppRoutes.universityDetail,
                      arguments: _controller.currentVideo.value!.universityId,
                    )
                  : null,
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: _PhoneSizes.engagementSpacing.h),
      EngagementBarWidget(controller: _controller),
      SizedBox(height: _PhoneSizes.engagementBottomSpacing.h),
      Obx(() {
        if (_controller.currentVideo.value?.description.isNotEmpty == true) {
          return ExpandableDescriptionWidget(
            text: _controller.currentVideo.value!.description,
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: _PhoneSizes.descriptionSpacing.h),
      Obx(() {
        if (_controller.currentVideo.value?.tags.isNotEmpty == true) {
          return Padding(
            padding: EdgeInsets.only(top: _PhoneSizes.tagsSpacing.h),
            child: TagsRowWidget(tags: _controller.currentVideo.value!.tags),
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: _PhoneSizes.tagsBottomSpacing.h),
      const SuggestedVideosSectionWidget(),
      SizedBox(height: _PhoneSizes.suggestedSpacing.h),
      Divider(color: AppTheme.surface(context), height: 1.h, thickness: 1.h),
      SizedBox(height: _PhoneSizes.dividerSpacing.h),
      Obx(() => CommentsHeaderWidget(count: _controller.appCommentCount.value)),
      SizedBox(height: _PhoneSizes.commentsHeaderSpacing.h),
      CommentInputWidget(
        onSend: (String text) {
          _controller.addComment(text);
        },
      ),
      SizedBox(height: _PhoneSizes.commentsInputSpacing.h),
      Obx(() {
        if (_controller.isCommentsLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: _PhoneSizes.commentsLoadingSpacing.h,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: _PhoneSizes.loadingStrokeWidth.w,
              ),
            ),
          );
        }
        if (_controller.comments.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: _PhoneSizes.commentsEmptySpacing.h,
            ),
            child: Center(
              child: Text(
                'Henüz yorum yok. İlk yorumu sen yap!',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _PhoneSizes.commentsEmptyFontSize.sp,
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.comments.length,
          separatorBuilder: (_, _) =>
              Divider(color: AppTheme.surface(context), height: 1.h),
          itemBuilder: (ctx, i) => CommentTileWidget(
            comment: _controller.comments[i],
            canDelete:
                _controller.comments[i].userId == _controller.currentUserId,
            onDelete: () =>
                _controller.deleteComment(_controller.comments[i].id),
          ),
        );
      }),
      SizedBox(height: _PhoneSizes.bottomSpacing.h),
    ];
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Obx(() {
        if (!_controller.isPlayerReady.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: _TabletSizes.loadingStrokeWidth,
            ),
          );
        }
        return _buildBodyTablet(context);
      }),
    );
  }

  Widget _buildBodyTablet(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;
    final bigH = _bigH > 0 ? _bigH : screenW * 9 / 16;

    final double targetLeft = _isMini
        ? (_miniPosition?.dx ?? _defaultMiniLeft(screenW))
        : 0;
    final double targetTop = _isMini
        ? (_miniPosition?.dy ?? _defaultMiniTop(screenH, botPad))
        : topPad;
    final double targetW = _isMini ? _TabletSizes.miniW : screenW;
    final double targetH = _isMini ? _TabletSizes.miniH : bigH;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry?.markNeedsBuild();
    });

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topPad + bigH)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                _TabletSizes.contentPaddingLeft,
                _TabletSizes.contentPaddingTop,
                _TabletSizes.contentPaddingRight,
                _TabletSizes.contentPaddingBottom,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildContentItemsTablet(context),
                ),
              ),
            ),
          ],
        ),
        AnimatedPositioned(
          duration: _isPanningMini ? Duration.zero : _TabletSizes.animDur,
          curve: _TabletSizes.animCurve,
          left: targetLeft,
          top: targetTop,
          width: targetW,
          height: targetH,
          child: AnimatedContainer(
            duration: _TabletSizes.animDur,
            curve: _TabletSizes.animCurve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _isMini ? _TabletSizes.miniBorderRadius : 0,
              ),
              boxShadow: _isMini
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: _TabletSizes.miniShadowBlur,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                _isMini ? _TabletSizes.miniBorderRadius : 0,
              ),
              child: YoutubePlayer(
                controller: _controller.youtubeController!,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContentItemsTablet(BuildContext context) {
    return [
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v == null) return const SizedBox.shrink();
        final d = v.publishedAt;
        final tarih =
            '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        final sure = v.formattedDuration;
        return Padding(
          padding: EdgeInsets.only(bottom: _TabletSizes.universitySpacing),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tarih,
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.6),
                  fontSize: _TabletSizes.dateFontSize,
                ),
              ),
              if (sure.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _TabletSizes.dateDurationDotSpacing,
                  ),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.6),
                      fontSize: _TabletSizes.dateFontSize,
                    ),
                  ),
                ),
                Text(
                  sure,
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.6),
                    fontSize: _TabletSizes.dateFontSize,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
      Obx(
        () => Text(
          _controller.currentVideo.value?.title ?? '',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: _TabletSizes.titleFontSize,
            fontWeight: FontWeight.w700,
            height: _TabletSizes.titleLineHeight,
          ),
        ),
      ),
      SizedBox(height: _TabletSizes.titleSpacing),
      Obx(() {
        if (_controller.currentVideo.value?.universityName?.isNotEmpty ==
            true) {
          return Padding(
            padding: EdgeInsets.only(top: _TabletSizes.universitySpacing),
            child: UniversityRowWidget(
              universityName: _controller.currentVideo.value!.universityName!,
              // BUG FIX: bkz. telefon dalındaki aynı not — Get.offNamed ile
              // player rotası stack'ten kaldırılıp üniversite detayına geçiliyor.
              onTap: _controller.currentVideo.value!.universityId != null
                  ? () => Get.offNamed(
                      AppRoutes.universityDetail,
                      arguments: _controller.currentVideo.value!.universityId,
                    )
                  : null,
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: _TabletSizes.engagementSpacing),
      EngagementBarWidget(controller: _controller),
      SizedBox(height: _TabletSizes.engagementBottomSpacing),
      Obx(() {
        if (_controller.currentVideo.value?.description.isNotEmpty == true) {
          return ExpandableDescriptionWidget(
            text: _controller.currentVideo.value!.description,
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: _TabletSizes.descriptionSpacing),
      Obx(() {
        if (_controller.currentVideo.value?.tags.isNotEmpty == true) {
          return Padding(
            padding: EdgeInsets.only(top: _TabletSizes.tagsSpacing),
            child: TagsRowWidget(tags: _controller.currentVideo.value!.tags),
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: _TabletSizes.tagsBottomSpacing),
      const SuggestedVideosSectionWidget(),
      SizedBox(height: _TabletSizes.suggestedSpacing),
      Divider(color: AppTheme.surface(context), height: 1, thickness: 1),
      SizedBox(height: _TabletSizes.dividerSpacing),
      Obx(() => CommentsHeaderWidget(count: _controller.appCommentCount.value)),
      SizedBox(height: _TabletSizes.commentsHeaderSpacing),
      CommentInputWidget(
        onSend: (String text) {
          _controller.addComment(text);
        },
      ),
      SizedBox(height: _TabletSizes.commentsInputSpacing),
      Obx(() {
        if (_controller.isCommentsLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: _TabletSizes.commentsLoadingSpacing,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: _TabletSizes.loadingStrokeWidth,
              ),
            ),
          );
        }
        if (_controller.comments.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: _TabletSizes.commentsEmptySpacing,
            ),
            child: Center(
              child: Text(
                'Henüz yorum yok. İlk yorumu sen yap!',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: _TabletSizes.commentsEmptyFontSize,
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.comments.length,
          separatorBuilder: (_, _) =>
              Divider(color: AppTheme.surface(context), height: 1),
          itemBuilder: (ctx, i) => CommentTileWidget(
            comment: _controller.comments[i],
            canDelete:
                _controller.comments[i].userId == _controller.currentUserId,
            onDelete: () =>
                _controller.deleteComment(_controller.comments[i].id),
          ),
        );
      }),
      SizedBox(height: _TabletSizes.bottomSpacing),
    ];
  }

  void _showAuthDialog() {
    final isTablet = Responsive.isTablet(context);
    final borderRadius = isTablet
        ? _TabletSizes.dialogBorderRadius
        : _PhoneSizes.dialogBorderRadius.r;
    final buttonRadius = isTablet
        ? _TabletSizes.dialogButtonRadius
        : _PhoneSizes.dialogButtonRadius.r;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        title: const Text(
          'Giriş Gerekiyor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu özelliği kullanmak için giriş yapmanız gerekiyor.',
          style: TextStyle(color: Color(0xFF9E9EB8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Vazgeç',
              style: TextStyle(color: Color(0xFF9E9EB8)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
            ),
            onPressed: () {
              Get.back();
              Get.toNamed('/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _OverlayButtonsPhone extends StatelessWidget {
  const _OverlayButtonsPhone({
    required this.isMini,
    required this.bigH,
    required this.miniW,
    required this.miniH,
    required this.miniPad,
    required this.animDur,
    required this.animCurve,
    required this.onBack,
    this.miniPosition,
    this.isDragging = false,
    this.isPanning = false,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  final bool isMini;
  final double bigH;
  final double miniW;
  final double miniH;
  final double miniPad;
  final Duration animDur;
  final Curve animCurve;
  final VoidCallback onBack;
  final Offset? miniPosition;
  final bool isDragging;
  final bool isPanning;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final double defaultLeft = screenW - miniW - miniPad;
    final double defaultTop = screenH - miniH - miniPad - botPad - 56;

    final double targetLeft = isMini ? (miniPosition?.dx ?? defaultLeft) : 0;
    final double targetTop = isMini ? (miniPosition?.dy ?? defaultTop) : topPad;
    final double targetW = isMini ? miniW : screenW;
    final Duration effectiveDur = isPanning ? Duration.zero : animDur;

    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          if (!isMini)
            AnimatedPositioned(
              duration: effectiveDur,
              curve: animCurve,
              left: targetLeft + _PhoneSizes.backButtonLeft.w,
              top: targetTop + _PhoneSizes.backButtonTop.h,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    _PhoneSizes.backButtonRadius.r,
                  ),
                  onTap: onBack,
                  child: Container(
                    padding: EdgeInsets.all(_PhoneSizes.backButtonPadding.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: _PhoneSizes.backButtonAlpha,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: _PhoneSizes.backButtonSize.sp,
                    ),
                  ),
                ),
              ),
            )
          else
            AnimatedPositioned(
              duration: effectiveDur,
              curve: animCurve,
              left: targetLeft,
              top: targetTop,
              width: targetW,
              height: miniH,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                child: const ColoredBox(color: Colors.transparent),
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

class _OverlayButtonsTablet extends StatelessWidget {
  const _OverlayButtonsTablet({
    required this.isMini,
    required this.bigH,
    required this.miniW,
    required this.miniH,
    required this.miniPad,
    required this.animDur,
    required this.animCurve,
    required this.onBack,
    this.miniPosition,
    this.isDragging = false,
    this.isPanning = false,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  final bool isMini;
  final double bigH;
  final double miniW;
  final double miniH;
  final double miniPad;
  final Duration animDur;
  final Curve animCurve;
  final VoidCallback onBack;
  final Offset? miniPosition;
  final bool isDragging;
  final bool isPanning;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final double defaultLeft = screenW - miniW - miniPad;
    final double defaultTop = screenH - miniH - miniPad - botPad - 56;

    final double targetLeft = isMini ? (miniPosition?.dx ?? defaultLeft) : 0;
    final double targetTop = isMini ? (miniPosition?.dy ?? defaultTop) : topPad;
    final double targetW = isMini ? miniW : screenW;
    final Duration effectiveDur = isPanning ? Duration.zero : animDur;

    return IgnorePointer(
      ignoring: false,
      child: Stack(
        children: [
          if (!isMini)
            AnimatedPositioned(
              duration: effectiveDur,
              curve: animCurve,
              left: targetLeft + _TabletSizes.backButtonLeft,
              top: targetTop + _TabletSizes.backButtonTop,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    _TabletSizes.backButtonRadius,
                  ),
                  onTap: onBack,
                  child: Container(
                    padding: EdgeInsets.all(_TabletSizes.backButtonPadding),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(
                        alpha: _TabletSizes.backButtonAlpha,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: _TabletSizes.backButtonSize,
                    ),
                  ),
                ),
              ),
            )
          else
            AnimatedPositioned(
              duration: effectiveDur,
              curve: animCurve,
              left: targetLeft,
              top: targetTop,
              width: targetW,
              height: miniH,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: onPanStart,
                onPanUpdate: onPanUpdate,
                onPanEnd: onPanEnd,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
        ],
      ),
    );
  }
}
