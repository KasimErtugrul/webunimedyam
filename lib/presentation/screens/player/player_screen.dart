import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/player_controller.dart';
import 'player_screen_widgets/comment_header_widget.dart';
import 'player_screen_widgets/comment_input_widget.dart';
import 'player_screen_widgets/comment_tile_widget.dart';
import 'player_screen_widgets/engagement_bar/engagement_bar_widget.dart';
import 'player_screen_widgets/expandable_description_widget.dart';
import 'player_screen_widgets/tag_row_widget.dart';
import 'player_screen_widgets/youtube_meta_widget.dart';
import 'player_screen_widgets/university_row_widget.dart';
import 'player_screen_widgets/suggested_videos_section_widget.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late final PlayerController _controller;
  late final TextEditingController _commentController;
  late final ScrollController _scrollController;

  Worker? _authWorker;
  Worker? _snackbarWorker;

  // Overlay: WebView'ın üzerine çıkmak için tek güvenilir yol
  OverlayEntry? _overlayEntry;

  static const double _miniW = 192.0;
  static const double _miniH = 108.0;
  static const double _miniPad = 14.0;
  static const Duration _animDur = Duration(milliseconds: 280);
  static const Curve _animCurve = Curves.easeInOutCubic;

  double _bigH = 0;
  bool _isMini = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlayerController>();
    _commentController = TextEditingController();
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

  // ── Overlay oluştur ──────────────────────────────────────────────────────
  void _insertOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (_) => _OverlayButtons(
        isMini: _isMini,
        bigH: _bigH,
        miniW: _miniW,
        miniH: _miniH,
        miniPad: _miniPad,
        animDur: _animDur,
        animCurve: _animCurve,
        onBack: () => Get.back(),
        onExpand: _scrollToTop,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onScroll() {
    if (_bigH == 0) return;
    final shouldBeMini = _scrollController.offset >= _bigH;
    if (shouldBeMini != _isMini) {
      setState(() => _isMini = shouldBeMini);
      // Overlay'i de yeniden çiz
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: _animDur, curve: _animCurve);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _commentController.dispose();
    _scrollController.dispose();
    _authWorker?.dispose();
    _snackbarWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Obx(() {
        if (!_controller.isPlayerReady.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
              strokeWidth: 3.w,
            ),
          );
        }
        return _buildBody(context);
      }),
    );
  }

  Widget _buildBody(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;
    final bigH = _bigH > 0 ? _bigH : screenW * 9 / 16;

    final double targetLeft = _isMini ? screenW - _miniW - _miniPad : 0;
    final double targetTop = _isMini
        ? screenH - _miniH - _miniPad - botPad - 56
        : topPad;
    final double targetW = _isMini ? _miniW : screenW;
    final double targetH = _isMini ? _miniH : bigH;

    // Overlay'deki state'i güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayEntry?.markNeedsBuild();
    });

    return Stack(
      children: [
        // ── Scroll içeriği ───────────────────────────────────────────────
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topPad + bigH)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate(_buildContentItems(context)),
              ),
            ),
          ],
        ),

        // ── Player — sadece video, butonlar Overlay'de ──────────────────
        AnimatedPositioned(
          duration: _animDur,
          curve: _animCurve,
          left: targetLeft,
          top: targetTop,
          width: targetW,
          height: targetH,
          child: GestureDetector(
            onTap: _isMini ? _scrollToTop : null,
            child: AnimatedContainer(
              duration: _animDur,
              curve: _animCurve,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_isMini ? 10 : 0),
                boxShadow: _isMini
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isMini ? 10 : 0),
                child: YoutubePlayer(
                  controller: _controller.youtubeController!,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildContentItems(BuildContext context) {
    return [
      Obx(
        () => Text(
          _controller.currentVideo.value?.title ?? '',
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
      ),

      SizedBox(height: 6.h),

      Obx(() {
        if (_controller.currentVideo.value != null) {
          return YoutubeMetaWidget(video: _controller.currentVideo.value!);
        }
        return const SizedBox.shrink();
      }),

      Obx(() {
        if (_controller.currentVideo.value?.universityName?.isNotEmpty ==
            true) {
          return Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: UniversityRowWidget(
              universityName: _controller.currentVideo.value!.universityName!,
            ),
          );
        }
        return const SizedBox.shrink();
      }),

      SizedBox(height: 14.h),
      EngagementBarWidget(controller: _controller),
      SizedBox(height: 16.h),

      Obx(() {
        if (_controller.currentVideo.value?.description.isNotEmpty == true) {
          return ExpandableDescriptionWidget(
            text: _controller.currentVideo.value!.description,
          );
        }
        return const SizedBox.shrink();
      }),

      Obx(() {
        if (_controller.currentVideo.value?.tags.isNotEmpty == true) {
          return Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: TagsRowWidget(tags: _controller.currentVideo.value!.tags),
          );
        }
        return const SizedBox.shrink();
      }),

      SizedBox(height: 20.h),
const SuggestedVideosSectionWidget(),   // ← YENİ
SizedBox(height: 20.h),
Divider(color: AppTheme.surface(context), height: 1.h, thickness: 1.h),
      SizedBox(height: 16.h),

      Obx(() => CommentsHeaderWidget(count: _controller.appCommentCount.value)),
      SizedBox(height: 12.h),

      CommentInputWidget(
        textController: _commentController,
        onSend: () {
          _controller.addComment(_commentController.text);
          _commentController.clear();
        },
      ),

      SizedBox(height: 16.h),

      Obx(() {
        if (_controller.isCommentsLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 2.w,
              ),
            ),
          );
        }
        
        if (_controller.comments.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Center(
              child: Text(
                'Henüz yorum yok. İlk yorumu sen yap!',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: 13.sp,
                ),
              ),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _controller.comments.length,
          separatorBuilder: (_, __) =>
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

      SizedBox(height: 32.h),
    ];
  }

  void _showAuthDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                borderRadius: BorderRadius.circular(8),
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

// ── Overlay widget — tüm widget ağacının dışında, WebView'ın kesinlikle üzerinde
class _OverlayButtons extends StatelessWidget {
  const _OverlayButtons({
    required this.isMini,
    required this.bigH,
    required this.miniW,
    required this.miniH,
    required this.miniPad,
    required this.animDur,
    required this.animCurve,
    required this.onBack,
    required this.onExpand,
  });

  final bool isMini;
  final double bigH;
  final double miniW;
  final double miniH;
  final double miniPad;
  final Duration animDur;
  final Curve animCurve;
  final VoidCallback onBack;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final double targetLeft = isMini ? screenW - miniW - miniPad : 0;
    final double targetTop = isMini
        ? screenH - miniH - miniPad - botPad - 56
        : topPad;
    final double targetW = isMini ? miniW : screenW;

    return IgnorePointer(
      // Butonların dışındaki alanlara dokunuşu geçir
      ignoring: false,
      child: Stack(
        children: [
          if (!isMini)
            // ── Büyük mod: geri butonu ──────────────────────────────────
            AnimatedPositioned(
              duration: animDur,
              curve: animCurve,
              left: targetLeft + 4,
              top: targetTop + 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            )
          else
            // ── Mini mod: üst bar ───────────────────────────────────────
            AnimatedPositioned(
              duration: animDur,
              curve: animCurve,
              left: targetLeft,
              top: targetTop,
              width: targetW,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onExpand,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBack,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
