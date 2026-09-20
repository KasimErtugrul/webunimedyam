// lib/presentation/screens/player/player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/player/player_controller.dart';
import 'player_layout_spec.dart';
import 'player_screen_widgets/comment_header_widget.dart';
import 'player_screen_widgets/comment_input_widget.dart';
import 'player_screen_widgets/comment_tile_widget.dart';
import 'player_screen_widgets/engagement_bar/engagement_bar_widget.dart';
import 'player_screen_widgets/expandable_description_widget.dart';
import 'player_screen_widgets/suggested_videos_section_widget.dart';
import 'player_screen_widgets/tag_row_widget.dart';
import 'player_screen_widgets/university_row_widget.dart';

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
    final spec = PlayerLayoutSpec.of(context);
    _overlayEntry = OverlayEntry(
      builder: (_) => _OverlayButtons(
        isMini: _isMini,
        bigH: _bigH,
        spec: spec,
        miniPosition: _miniPosition,
        isDragging: _dragTotal > spec.dragTapThreshold,
        isPanning: _isPanningMini,
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

  double _defaultMiniLeft(double screenW, PlayerLayoutSpec spec) {
    return screenW - spec.miniW - spec.miniPad;
  }

  double _defaultMiniTop(
    double screenH,
    double botPad,
    PlayerLayoutSpec spec, [
    double keyboardInset = 0,
  ]) {
    return screenH -
        spec.miniH -
        spec.miniPad -
        botPad -
        spec.miniBottomOffset -
        keyboardInset;
  }

  void _onMiniPanStart(DragStartDetails details) {
    if (!_isMini) return;
    _dragTotal = 0;
    _isPanningMini = true;
    if (_miniPosition == null) {
      final mq = MediaQuery.of(context);
      final spec = PlayerLayoutSpec.of(context);
      _miniPosition = Offset(
        _defaultMiniLeft(mq.size.width, spec),
        _defaultMiniTop(
          mq.size.height,
          mq.padding.bottom,
          spec,
          mq.viewInsets.bottom,
        ),
      );
    }
  }

  void _onMiniPanUpdate(DragUpdateDetails details) {
    if (!_isMini || _miniPosition == null) return;
    final spec = PlayerLayoutSpec.of(context);

    _dragTotal += details.delta.distance;

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final newX = (_miniPosition!.dx + details.delta.dx).clamp(
      0.0,
      screenW - spec.miniW,
    );
    final newY = (_miniPosition!.dy + details.delta.dy).clamp(
      topPad,
      screenH - spec.miniH - botPad,
    );

    setState(() {
      _miniPosition = Offset(newX, newY);
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onMiniPanEnd(DragEndDetails details) {
    if (!_isMini) return;
    final spec = PlayerLayoutSpec.of(context);
    if (_dragTotal < spec.dragTapThreshold) {
      _scrollToTop(spec);
    }
    _dragTotal = 0;
    _isPanningMini = false;
    _overlayEntry?.markNeedsBuild();
  }

  void _scrollToTop(PlayerLayoutSpec spec) {
    _scrollController.animateTo(
      0,
      duration: spec.animDur,
      curve: spec.animCurve,
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
    final spec = PlayerLayoutSpec.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Obx(() {
        if (!_controller.isPlayerReady.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: spec.loadingStrokeWidth,
            ),
          );
        }
        return _buildBody(context, spec);
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // BODY
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, PlayerLayoutSpec spec) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;
    final keyboardInset = mq.viewInsets.bottom;
    final bigH = _bigH > 0 ? _bigH : screenW * 9 / 16;

    final double targetLeft = _isMini
        ? (_miniPosition?.dx ?? _defaultMiniLeft(screenW, spec))
        : 0;
    final double targetTop = _isMini
        ? (_miniPosition == null
              ? _defaultMiniTop(screenH, botPad, spec, keyboardInset)
              : (_miniPosition!.dy - keyboardInset).clamp(
                  topPad,
                  screenH - spec.miniH - botPad,
                ))
        : topPad;
    final double targetW = _isMini ? spec.miniW : screenW;
    final double targetH = _isMini ? spec.miniH : bigH;

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
                spec.contentPaddingLeft.w,
                spec.contentPaddingTop.h,
                spec.contentPaddingRight.w,
                spec.contentPaddingBottom.h,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  _buildContentItems(context, spec),
                ),
              ),
            ),
          ],
        ),
        AnimatedPositioned(
          duration: _isPanningMini ? Duration.zero : spec.animDur,
          curve: spec.animCurve,
          left: targetLeft,
          top: targetTop,
          width: targetW,
          height: targetH,
          child: AnimatedContainer(
            duration: spec.animDur,
            curve: spec.animCurve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                _isMini ? spec.miniBorderRadius.r : 0,
              ),
              boxShadow: _isMini
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: spec.miniShadowBlur.r,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : const [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                _isMini ? spec.miniBorderRadius.r : 0,
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

  // ─────────────────────────────────────────────────────────────────────
  // CONTENT
  // ─────────────────────────────────────────────────────────────────────

  List<Widget> _buildContentItems(BuildContext context, PlayerLayoutSpec spec) {
    return [
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v == null) return const SizedBox.shrink();
        final d = v.publishedAt;
        final tarih =
            '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        final sure = v.formattedDuration;
        return Padding(
          padding: EdgeInsets.only(bottom: spec.universitySpacing.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tarih,
                style: TextStyle(
                  color: AppTheme.textSec(context).withValues(alpha: 0.6),
                  fontSize: spec.dateFontSize.sp,
                ),
              ),
              if (sure.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spec.dateDurationDotSpacing.w,
                  ),
                  child: Text(
                    '•',
                    style: TextStyle(
                      color: AppTheme.textSec(context).withValues(alpha: 0.6),
                      fontSize: spec.dateFontSize.sp,
                    ),
                  ),
                ),
                Text(
                  sure,
                  style: TextStyle(
                    color: AppTheme.textSec(context).withValues(alpha: 0.6),
                    fontSize: spec.dateFontSize.sp,
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
            fontSize: spec.titleFontSize.sp,
            fontWeight: FontWeight.w700,
            height: spec.titleLineHeight,
          ),
        ),
      ),
      SizedBox(height: spec.titleSpacing.h),
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v?.universityName?.isNotEmpty == true) {
          return Padding(
            padding: EdgeInsets.only(top: spec.universitySpacing.h),
            child: UniversityRowWidget(
              universityName: v!.universityName!,
              onTap: v.universityId != null
                  ? () => Get.offNamed(
                      AppRoutes.universityDetail,
                      arguments: v.universityId,
                    )
                  : null,
            ),
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: spec.engagementSpacing.h),
      EngagementBarWidget(controller: _controller),
      SizedBox(height: spec.engagementBottomSpacing.h),
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v?.description.isNotEmpty == true) {
          return ExpandableDescriptionWidget(text: v!.description);
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: spec.descriptionSpacing.h),
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v?.tags.isNotEmpty == true) {
          return Padding(
            padding: EdgeInsets.only(top: spec.tagsSpacing.h),
            child: TagsRowWidget(tags: v!.tags),
          );
        }
        return const SizedBox.shrink();
      }),
      SizedBox(height: spec.tagsBottomSpacing.h),
      // Tasarımdaki sıra: önce Yorumlar, en altta Önerilen Kampüs Yayınları.
      // (Önceden bu iki bölüm ters sıradaydı — Önerilenler Yorumlar'ın
      // üzerinde çıkıyordu, tasarımla eşleşmiyordu.)
      Obx(() => CommentsHeaderWidget(count: _controller.appCommentCount.value)),
      SizedBox(height: spec.commentsHeaderSpacing.h),
      CommentInputWidget(onSend: (String text) => _controller.addComment(text)),
      SizedBox(height: spec.commentsInputSpacing.h),
      Obx(() {
        if (_controller.isCommentsLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: spec.commentsLoadingSpacing.h,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: spec.loadingStrokeWidth,
              ),
            ),
          );
        }
        if (_controller.comments.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: spec.commentsEmptySpacing.h,
            ),
            child: Center(
              child: Text(
                'Henüz yorum yok. İlk yorumu sen yap!',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: spec.commentsEmptyFontSize.sp,
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
      SizedBox(height: spec.suggestedSpacing.h),
      Divider(color: AppTheme.surface(context), height: 1, thickness: 1),
      SizedBox(height: spec.dividerSpacing.h),
      const SuggestedVideosSectionWidget(),
      SizedBox(height: spec.bottomSpacing.h),
    ];
  }

  // ─────────────────────────────────────────────────────────────────────
  // AUTH DIALOG
  // ─────────────────────────────────────────────────────────────────────

  void _showAuthDialog() {
    final spec = PlayerLayoutSpec.of(context);

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spec.dialogBorderRadius.r),
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
                borderRadius: BorderRadius.circular(spec.dialogButtonRadius.r),
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
// Overlay buttons (phone + tablet tek widget)
// Non-mini modda artık hiçbir ikon gösterilmiyor; sadece mini modda
// video üzerinde sürükleme alanı var.
// ═══════════════════════════════════════════════════════════════════════

class _OverlayButtons extends StatelessWidget {
  const _OverlayButtons({
    required this.isMini,
    required this.bigH,
    required this.spec,
    this.miniPosition,
    this.isDragging = false,
    this.isPanning = false,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
  });

  final bool isMini;
  final double bigH;
  final PlayerLayoutSpec spec;
  final Offset? miniPosition;
  final bool isDragging;
  final bool isPanning;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  @override
  Widget build(BuildContext context) {
    if (!isMini) {
      // Non-mini modda video üzerinde hiçbir overlay ikon yok.
      return const SizedBox.shrink();
    }

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final botPad = mq.padding.bottom;

    final double defaultLeft = screenW - spec.miniW - spec.miniPad;
    final double defaultTop =
        screenH - spec.miniH - spec.miniPad - botPad - spec.miniBottomOffset;

    final double targetLeft = miniPosition?.dx ?? defaultLeft;
    final double targetTop = miniPosition?.dy ?? defaultTop;
    final Duration effectiveDur = isPanning ? Duration.zero : spec.animDur;

    return AnimatedPositioned(
      duration: effectiveDur,
      curve: spec.animCurve,
      left: targetLeft,
      top: targetTop,
      width: spec.miniW,
      height: spec.miniH,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}
