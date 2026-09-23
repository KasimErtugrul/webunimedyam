// lib/presentation/screens/splash/widgets/splash_live_badge.dart

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../splash_sizes.dart';

/// Üst mikro etiket — "CANLI KAMPÜS BAĞLANTISI"
/// bg-surface-container-low/80, px-4 py-1.5, rounded-full, ping dot
class SplashLiveBadge extends StatelessWidget {
  const SplashLiveBadge({super.key, required this.sizes});

  final SplashSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.only(top: s.tagTopPadding),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: s.tagPillHPadding,
          vertical: s.tagPillVPadding,
        ),
        decoration: BoxDecoration(
          // bg-surface-container-low/80 + backdrop-blur-md (alfa karşılığı)
          color: scheme.surfaceContainerLow.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: AppTheme.isDark(context) ? 0.20 : 0.06,
              ),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PingDot(size: s.tagDotSize, color: scheme.primary),
            SizedBox(width: s.tagGap),
            Text(
              'CANLI KAMPÜS BAĞLANTISI',
              style: TextStyle(
                color: scheme.primary,
                fontSize: s.tagFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1 * s.tagFontSize, // tracking-widest
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// animate-ping — genişleyen halka + sabit nokta
class _PingDot extends StatefulWidget {
  const _PingDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot> with SingleTickerProviderStateMixin {
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