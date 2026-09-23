// lib/presentation/screens/auth/widgets/login_live_teaser.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

/// Canlı Yayın Teaser — surface-container-low kart, podcasts ikonu +
/// ping noktası, "ŞU AN YAYINDA" etiketi ve izleyici sayacı
class LoginLiveTeaser extends StatelessWidget {
  const LoginLiveTeaser({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      padding: EdgeInsets.all(s.teaserPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(s.teaserRadius),
      ),
      child: Row(
        children: [
          // İkon kutusu + ping noktası
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: s.teaserIconBoxSize,
                height: s.teaserIconBoxSize,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(s.teaserIconBoxRadius),
                ),
                child: Icon(
                  Icons.podcasts_rounded,
                  size: s.teaserIconSize,
                  color: scheme.primary,
                ),
              ),
              Positioned(
                top: s.teaserPingOffset,
                right: s.teaserPingOffset,
                child: PingDot(size: s.teaserPingSize, color: scheme.error),
              ),
            ],
          ),
          SizedBox(width: s.teaserGap),

          // Metinler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ŞU AN YAYINDA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: s.teaserLabelFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.05 * s.teaserLabelFontSize,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'İTÜ Robotik Zirvesi 2025',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: s.teaserTitleFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.02 * s.teaserTitleFontSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: s.teaserGap),

          // İzleyici sayacı — pill, bg-surface-container-high
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: s.teaserBadgeDotSize,
                  height: s.teaserBadgeDotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.error,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  '1.4k',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: s.teaserBadgeFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// animate-ping — genişleyip kaybolan halka + sabit nokta
class PingDot extends StatefulWidget {
  const PingDot({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<PingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.2,
      height: widget.size * 2.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Halka (ping)
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              return Container(
                width: widget.size + widget.size * 1.6 * t,
                height: widget.size + widget.size * 1.6 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                ),
              );
            },
          ),
          // Sabit nokta
          Container(
            width: widget.size,
            height: widget.size,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: widget.color),
          ),
        ],
      ),
    );
  }
}