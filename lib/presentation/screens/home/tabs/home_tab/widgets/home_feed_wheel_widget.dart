// lib/presentation/screens/home/tabs/home_tab/widgets/home_feed_wheel_widget.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../../data/models/video_model.dart';
import '../../../../../controllers/home_controller.dart';
import 'wheel_video_card_widget.dart';

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
    if (v.isEmpty || !_ctrl.hasMoreVideos.value || _ctrl.isLoadingMore.value)
      return;
    if (i >= v.length - _threshold) _ctrl.loadMoreVideos();
  }

  void _onChanged(int i) {
    setState(() => _activeIndex = i);
    _maybeLoadMore(i);
  }

  UniversityModel? _uniFor(VideoModel v) =>
      widget.universities.firstWhereOrNull((u) => u.id == v.universityId);

  @override
  Widget build(BuildContext context) {
    double kWheelCardHeight = 340;

    final videos = widget.videos;
    if (videos.isEmpty) return const SizedBox.shrink();

    final idx = _activeIndex.clamp(0, videos.length - 1);
    final active = videos[idx];
    final activeUni = _uniFor(active);

    return Obx(() {
      final tail = _ctrl.hasMoreVideos.value || _ctrl.isLoadingMore.value;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kart — kWheelCardHeight.h ile sabit
            SizedBox(
              height: kWheelCardHeight.h,
              child: WheelVideoCardWidget(
                key: ValueKey(active.videoId),
                video: active,
                university: activeUni,
              ),
            ),
            SizedBox(height: 14.h),

            // Logo wheel — yeri sabit, kaymaz
            SizedBox(
              height: 112.h,
              child: _LogoWheel(
                key: ValueKey('lw_${videos.length}'),
                videos: videos,
                universities: widget.universities,
                activeIndex: idx,
                showTail: tail,
                isLoading: _ctrl.isLoadingMore.value,
                onChanged: _onChanged,
              ),
            ),
            SizedBox(height: 10.h),

            // Wheel altı — üniversite adı + takip butonu (klasik yapı)
            // _buildUniversityBar(context, active, activeUni),
          ],
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  LOGO WHEEL — Yatay şerit (RotatedBox tekniği)
//  NOT: Aktif slot çerçevesi kaldırıldı — sadece opaklık/boyut ile
//  aktif öğe vurgulanıyor (klasik/sade görünüm).
// ═══════════════════════════════════════════════════════════════════════
class _LogoWheel extends StatefulWidget {
  final List<VideoModel> videos;
  final List<UniversityModel> universities;
  final int activeIndex;
  final bool showTail;
  final bool isLoading;
  final ValueChanged<int> onChanged;

  const _LogoWheel({
    super.key,
    required this.videos,
    required this.universities,
    required this.activeIndex,
    required this.showTail,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  State<_LogoWheel> createState() => _LogoWheelState();
}

class _LogoWheelState extends State<_LogoWheel> {
  static double get _extent => 78.w;
  static double get _active => 62.w;
  static double get _inactive => 42.w;
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

    // Wheel — useMagnifier: false (bkz. önceki not)
    return RotatedBox(
      quarterTurns: 3,
      child: ListWheelScrollView.useDelegate(
        controller: _sc,
        itemExtent: _extent,
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
                        width: 22.w,
                        height: 22.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    )
                  : Center(
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: AppTheme.textSec(context).withValues(alpha: 0.4),
                        size: 20.sp,
                      ),
                    );
            } else {
              final uni = _uniFor(widget.videos[i]);
              final isActive = i == widget.activeIndex;
              final size = isActive ? _active : _inactive;
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
                    padding: EdgeInsets.all(6.w),
                    child: ClipOval(
                      child: hasLogo
                          ? CachedNetworkImage(
                              imageUrl: uni.logoUrl!,
                              fit: BoxFit.contain,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              errorWidget: (_, __, ___) => Icon(
                                Icons.school_rounded,
                                color: AppTheme.textSec(context),
                                size: size * 0.5,
                              ),
                              placeholder: (_, __) => Container(color: bg),
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
