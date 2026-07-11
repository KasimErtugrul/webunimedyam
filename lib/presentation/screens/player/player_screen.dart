import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../app/routes/app_routes.dart';
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
  // ❌ SILINDI: late final TextEditingController _commentController;
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
  // Sürükleme mi yoksa dokunma mı olduğunu ayırt etmek için eşik değeri (px)
  static const double _dragTapThreshold = 6.0;

  double _bigH = 0;
  bool _isMini = false;

  // Kullanıcının mini player'ı sürükleyerek taşıdığı özel konum.
  // null => varsayılan (sağ-alt) konum kullanılır.
  Offset? _miniPosition;
  double _dragTotal = 0;
  bool _isPanningMini = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlayerController>(
      tag: Get.parameters['videoId'] ?? '123',
    );
    // ❌ SILINDI: _commentController = TextEditingController();
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
        miniPosition: _miniPosition,
        isDragging: _dragTotal > _dragTapThreshold,
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
          // Küçültülen her seferinde varsayılan (sağ-alt) konumdan başlar,
          // kullanıcı sonrasında istediği yere sürükleyebilir.
          _miniPosition = null;
        }
      });
      // Overlay'i de yeniden çiz
      _overlayEntry?.markNeedsBuild();
    }
  }

  double _defaultMiniLeft(double screenW) => screenW - _miniW - _miniPad;

  double _defaultMiniTop(double screenH, double botPad) =>
      screenH - _miniH - _miniPad - botPad - 56;

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
    _dragTotal += details.delta.distance;

    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final topPad = mq.padding.top;
    final botPad = mq.padding.bottom;

    final newX = (_miniPosition!.dx + details.delta.dx)
        .clamp(0.0, screenW - _miniW);
    final newY = (_miniPosition!.dy + details.delta.dy)
        .clamp(topPad, screenH - _miniH - botPad);

    setState(() {
      _miniPosition = Offset(newX, newY);
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _onMiniPanEnd(DragEndDetails details) {
    if (!_isMini) return;
    // Kullanıcı neredeyse hiç sürüklemediyse bunu bir "dokunma" say
    // ve player'ı büyüt (eski onTap davranışının yerine geçer).
    if (_dragTotal < _dragTapThreshold) {
      _scrollToTop();
    }
    _dragTotal = 0;
    _isPanningMini = false;
    _overlayEntry?.markNeedsBuild();
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: _animDur, curve: _animCurve);
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // ❌ SILINDI: _commentController.dispose();
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

    final double targetLeft = _isMini
        ? (_miniPosition?.dx ?? _defaultMiniLeft(screenW))
        : 0;
    final double targetTop = _isMini
        ? (_miniPosition?.dy ?? _defaultMiniTop(screenH, botPad))
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
          duration: _isPanningMini ? Duration.zero : _animDur,
          curve: _animCurve,
          left: targetLeft,
          top: targetTop,
          width: targetW,
          height: targetH,
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
      ],
    );
  }

  List<Widget> _buildContentItems(BuildContext context) {
    return [
      // ── Yayınlanma Tarihi ─────────────────────────────────────────────
      Obx(() {
        final v = _controller.currentVideo.value;
        if (v == null) return const SizedBox.shrink();
        final d = v.publishedAt;
        final tarih =
            '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
        return Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Text(
            tarih,
            style: TextStyle(
              color: AppTheme.textSec(context).withValues(alpha: 0.6),
              fontSize: 11.sp,
            ),
          ),
        );
      }),

      // ── Başlık ────────────────────────────────────────────────────────
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

      // ── Üniversite Satırı ─────────────────────────────────────────────
      Obx(() {
        if (_controller.currentVideo.value?.universityName?.isNotEmpty ==
            true) {
          return Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: UniversityRowWidget(
              universityName: _controller.currentVideo.value!.universityName!,
              onTap: _controller.currentVideo.value!.universityId != null
                  ? () => Get.toNamed(
                      AppRoutes.universityDetail,
                      arguments: _controller.currentVideo.value!.universityId,
                    )
                  : null,
            ),
          );
        }
        return const SizedBox.shrink();
      }),

      SizedBox(height: 14.h),
      EngagementBarWidget(controller: _controller),
      SizedBox(height: 20.h),

      // ── Açıklama ──────────────────────────────────────────────────────
      Obx(() {
        if (_controller.currentVideo.value?.description.isNotEmpty == true) {
          return ExpandableDescriptionWidget(
            text: _controller.currentVideo.value!.description,
          );
        }
        return const SizedBox.shrink();
      }),

      SizedBox(height: 12.h),

      // ── YouTube İstatistikleri Bölümü ────────────────────────────────────
      Obx(() {
        if (_controller.currentVideo.value != null) {
          return YoutubeMetaWidget(video: _controller.currentVideo.value!);
        }
        return const SizedBox.shrink();
      }),

      SizedBox(height: 16.h),

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
      const SuggestedVideosSectionWidget(),
      SizedBox(height: 20.h),
      Divider(color: AppTheme.surface(context), height: 1.h, thickness: 1.h),
      SizedBox(height: 16.h),

      Obx(() => CommentsHeaderWidget(count: _controller.appCommentCount.value)),
      SizedBox(height: 12.h),

      // ✅ GÜNCELLENMİŞ KULLANIM
      CommentInputWidget(
        onSend: (String text) {
          _controller.addComment(text);
          // ❌ SILINDI: _commentController.clear();
          // Widget kendi controller'ını temizliyor
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
  // Kullanıcının sürükleyerek belirlediği özel mini konum (varsa)
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
            // ── Büyük mod: geri butonu ──────────────────────────────────
            AnimatedPositioned(
              duration: effectiveDur,
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
            // ── Mini mod: sadece sürükleme/dokunma yakalayıcısı ──────────
            // Not: youtube_player_iframe native bir WebView (platform view)
            // kullanır ve dokunuşları doğrudan kendisi yutar. Sadece
            // Flutter'ın gerçek Overlay katmanı (bu widget) WebView'ın
            // GERÇEKTEN üzerinde durduğu için dokunuşları yakalayabilir.
            // Görünür buton yok — tüm miniH x miniW alanı görünmez bir
            // sürükleme/dokunma yakalayıcısı. Az hareketle bırakılırsa
            // (bkz. _onMiniPanEnd) dokunma sayılır ve player büyür.
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