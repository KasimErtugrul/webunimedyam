// lib/presentation/screens/home/tabs/home_tab/widgets/home_feed_wheel_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home/home_controller.dart';
import 'wheel_video_card_widget.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Wheel kart
  static const double wheelCardHeight = 340;

  // Logo wheel
  static const double logoWheelHeight = 112;
  static const double logoWheelItemExtent = 78;
  static const double logoWheelActiveSize = 62;
  static const double logoWheelInactiveSize = 42;

  // Spacing
  static const double horizontalPadding = 7;
  static const double cardBottomSpacing = 14;
  static const double wheelBottomSpacing = 10;

  // Loading
  static const double loadingIndicatorSize = 22;
  static const double loadingStrokeWidth = 2.2;
  static const double moreIconSize = 20;

  // Logo padding
  static const double logoPadding = 6;
}

class _TabletSizes {
  // Wheel kart — artık SABİT, genişliğe göre hesaplanmıyor.
  // Beğenmezsen sadece bu sayıyı değiştir.
  static const double wheelCardHeight = 400;
  static const double maxWidth = 720;
  static const double horizontalPadding = 24;
  static const double cardBottomSpacing = 18;
  static const double wheelBottomSpacing = 12;

  // Logo wheel — tablet için daha büyük
  static const double logoWheelHeight = 132;
  static const double logoWheelItemExtent = 96;
  static const double logoWheelActiveSize = 76;
  static const double logoWheelInactiveSize = 52;

  // Loading
  static const double loadingIndicatorSize = 24;
  static const double loadingStrokeWidth = 2.5;
  static const double moreIconSize = 22;

  // Logo padding
  static const double logoPadding = 8;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class HomeFeedWheelWidget extends StatefulWidget {
  final List<VideoModel> videos;
  final List<UniversityModel> universities;

  const HomeFeedWheelWidget({
    super.key,
    required this.videos,
    required this.universities,
  });

  @override
  State<HomeFeedWheelWidget> createState() => _HomeFeedWheelWidgetState();
}

class _HomeFeedWheelWidgetState extends State<HomeFeedWheelWidget> {
  int _activeIndex = 0;
  final HomeController _ctrl = Get.find<HomeController>();
  static const int _threshold = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeLoadMore(_activeIndex),
    );
  }

  @override
  void didUpdateWidget(covariant HomeFeedWheelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activeIndex >= widget.videos.length) {
      _activeIndex = widget.videos.isEmpty ? 0 : widget.videos.length - 1;
    }
  }

  void _maybeLoadMore(int i) {
    final v = widget.videos;
    if (v.isEmpty || !_ctrl.hasMoreVideos.value || _ctrl.isLoadingMore.value) {
      return;
    }
    if (i >= v.length - _threshold) _ctrl.loadMoreVideos();
  }

  void _onChanged(int i) {
    setState(() => _activeIndex = i);
    _maybeLoadMore(i);
  }

  UniversityModel? _uniFor(VideoModel v) =>
      widget.universities.firstWhereOrNull((u) => u.id == v.universityId);

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 5 — TEK DALLANMA NOKTASI
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final videos = widget.videos;
    if (videos.isEmpty) return const SizedBox.shrink();

    final idx = _activeIndex.clamp(0, videos.length - 1);
    final active = videos[idx];
    final activeUni = _uniFor(active);

    return Responsive.isTablet(context)
        ? _buildTablet(context, active, activeUni, idx, videos)
        : _buildPhone(context, active, activeUni, idx, videos);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(
    BuildContext context,
    VideoModel active,
    UniversityModel? activeUni,
    int idx,
    List<VideoModel> videos,
  ) {
    return Obx(() {
      final tail = _ctrl.hasMoreVideos.value || _ctrl.isLoadingMore.value;

      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _PhoneSizes.horizontalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _PhoneSizes.wheelCardHeight,
              child: WheelVideoCardWidget(
                key: ValueKey(active.videoId),
                video: active,
                university: activeUni,
              ),
            ),
            const SizedBox(height: _PhoneSizes.cardBottomSpacing),
            SizedBox(
              height: _PhoneSizes.logoWheelHeight,
              child: _LogoWheelPhone(
                key: ValueKey('lw_${videos.length}'),
                videos: videos,
                universities: widget.universities,
                activeIndex: idx,
                showTail: tail,
                isLoading: _ctrl.isLoadingMore.value,
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(height: _PhoneSizes.wheelBottomSpacing),
          ],
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(
    BuildContext context,
    VideoModel active,
    UniversityModel? activeUni,
    int idx,
    List<VideoModel> videos,
  ) {
    return Obx(() {
      final tail = _ctrl.hasMoreVideos.value || _ctrl.isLoadingMore.value;

      // NOT: LayoutBuilder ve genişliğe bağlı hesaplama kaldırıldı.
      // Kart yüksekliği artık _TabletSizes.wheelCardHeight — sabit.
      // Beğenmezsen sadece bu sayıyı değiştir, kod tarafına dokunma.
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _TabletSizes.maxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _TabletSizes.horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: _TabletSizes.wheelCardHeight,
                  child: WheelVideoCardWidget(
                    key: ValueKey(active.videoId),
                    video: active,
                    university: activeUni,
                  ),
                ),
                const SizedBox(height: _TabletSizes.cardBottomSpacing),
                SizedBox(
                  height: _TabletSizes.logoWheelHeight,
                  child: _LogoWheelTablet(
                    key: ValueKey('lw_tablet_${videos.length}'),
                    videos: videos,
                    universities: widget.universities,
                    activeIndex: idx,
                    showTail: tail,
                    isLoading: _ctrl.isLoadingMore.value,
                    onChanged: _onChanged,
                  ),
                ),
                const SizedBox(height: _TabletSizes.wheelBottomSpacing),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _LogoWheelPhone extends StatefulWidget {
  final List<VideoModel> videos;
  final List<UniversityModel> universities;
  final int activeIndex;
  final bool showTail;
  final bool isLoading;
  final ValueChanged<int> onChanged;

  const _LogoWheelPhone({
    super.key,
    required this.videos,
    required this.universities,
    required this.activeIndex,
    required this.showTail,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  State<_LogoWheelPhone> createState() => _LogoWheelPhoneState();
}

class _LogoWheelPhoneState extends State<_LogoWheelPhone> {
  late final FixedExtentScrollController _sc;

  @override
  void initState() {
    super.initState();
    _sc = FixedExtentScrollController(initialItem: widget.activeIndex);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  UniversityModel? _uniFor(VideoModel v) =>
      widget.universities.firstWhereOrNull((u) => u.id == v.universityId);

  void _select(int i) {
    HapticFeedback.selectionClick();
    final len = widget.videos.length;
    widget.onChanged(i >= len ? len - 1 : i);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.videos.length + (widget.showTail ? 1 : 0);

    return RotatedBox(
      quarterTurns: 3,
      child: ListWheelScrollView.useDelegate(
        controller: _sc,
        itemExtent: _PhoneSizes.logoWheelItemExtent,
        diameterRatio: 2.0,
        perspective: 0.0022,
        squeeze: 1.05,
        physics: const FixedExtentScrollPhysics(),
        useMagnifier: false,
        overAndUnderCenterOpacity: 1,
        onSelectedItemChanged: _select,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: total,
          builder: (context, i) {
            final Widget child;
            if (i >= widget.videos.length) {
              child = widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: _PhoneSizes.loadingIndicatorSize,
                        height: _PhoneSizes.loadingIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: _PhoneSizes.loadingStrokeWidth,
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.textSec(context).withValues(alpha: 0.4),
                        size: _PhoneSizes.moreIconSize,
                      ),
                    );
            } else {
              final uni = _uniFor(widget.videos[i]);
              final isActive = i == widget.activeIndex;
              final size = isActive
                  ? _PhoneSizes.logoWheelActiveSize
                  : _PhoneSizes.logoWheelInactiveSize;
              final hasLogo = uni?.logoUrl != null && uni!.logoUrl!.isNotEmpty;
              final bg = AppTheme.isDark(context)
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F0F0);

              child = AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1 : 0.45,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bg,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(_PhoneSizes.logoPadding),
                    child: ClipOval(
                      child: hasLogo
                          ? CachedNetworkImage(
                              imageUrl: uni.logoUrl!,
                              fit: BoxFit.contain,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              errorWidget: (_, _, _) => Icon(
                                Icons.school_rounded,
                                color: AppTheme.textSec(context),
                                size: size * 0.5,
                              ),
                              placeholder: (_, _) => Container(color: bg),
                            )
                          : Icon(
                              Icons.school_rounded,
                              color: AppTheme.textSec(context),
                              size: size * 0.5,
                            ),
                    ),
                  ),
                ),
              );
            }
            return RotatedBox(quarterTurns: 1, child: child);
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET'LAR (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _LogoWheelTablet extends StatefulWidget {
  final List<VideoModel> videos;
  final List<UniversityModel> universities;
  final int activeIndex;
  final bool showTail;
  final bool isLoading;
  final ValueChanged<int> onChanged;

  const _LogoWheelTablet({
    super.key,
    required this.videos,
    required this.universities,
    required this.activeIndex,
    required this.showTail,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  State<_LogoWheelTablet> createState() => _LogoWheelTabletState();
}

class _LogoWheelTabletState extends State<_LogoWheelTablet> {
  late final FixedExtentScrollController _sc;

  @override
  void initState() {
    super.initState();
    _sc = FixedExtentScrollController(initialItem: widget.activeIndex);
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  UniversityModel? _uniFor(VideoModel v) =>
      widget.universities.firstWhereOrNull((u) => u.id == v.universityId);

  void _select(int i) {
    HapticFeedback.selectionClick();
    final len = widget.videos.length;
    widget.onChanged(i >= len ? len - 1 : i);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.videos.length + (widget.showTail ? 1 : 0);

    return RotatedBox(
      quarterTurns: 3,
      child: ListWheelScrollView.useDelegate(
        controller: _sc,
        itemExtent: _TabletSizes.logoWheelItemExtent,
        diameterRatio: 2.0,
        perspective: 0.0022,
        squeeze: 1.05,
        physics: const FixedExtentScrollPhysics(),
        useMagnifier: false,
        overAndUnderCenterOpacity: 1,
        onSelectedItemChanged: _select,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: total,
          builder: (context, i) {
            final Widget child;
            if (i >= widget.videos.length) {
              child = widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: _TabletSizes.loadingIndicatorSize,
                        height: _TabletSizes.loadingIndicatorSize,
                        child: CircularProgressIndicator(
                          strokeWidth: _TabletSizes.loadingStrokeWidth,
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.textSec(context).withValues(alpha: 0.4),
                        size: _TabletSizes.moreIconSize,
                      ),
                    );
            } else {
              final uni = _uniFor(widget.videos[i]);
              final isActive = i == widget.activeIndex;
              final size = isActive
                  ? _TabletSizes.logoWheelActiveSize
                  : _TabletSizes.logoWheelInactiveSize;
              final hasLogo = uni?.logoUrl != null && uni!.logoUrl!.isNotEmpty;
              final bg = AppTheme.isDark(context)
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F0F0);

              child = AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isActive ? 1 : 0.45,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: bg,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(_TabletSizes.logoPadding),
                    child: ClipOval(
                      child: hasLogo
                          ? CachedNetworkImage(
                              imageUrl: uni.logoUrl!,
                              fit: BoxFit.contain,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              errorWidget: (_, _, _) => Icon(
                                Icons.school_rounded,
                                color: AppTheme.textSec(context),
                                size: size * 0.5,
                              ),
                              placeholder: (_, _) => Container(color: bg),
                            )
                          : Icon(
                              Icons.school_rounded,
                              color: AppTheme.textSec(context),
                              size: size * 0.5,
                            ),
                    ),
                  ),
                ),
              );
            }
            return RotatedBox(quarterTurns: 1, child: child);
          },
        ),
      ),
    );
  }
}