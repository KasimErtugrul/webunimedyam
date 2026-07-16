// lib/presentation/screens/radio/widgets/radio_wave_row_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double barWidth = 4;
  static const double barSpacing = 2;
  static const double barBorderRadius = 2;
  static const double heightScale = 1.0;
  static const double opacityActive = 0.8;
  static const double opacityInactive = 0.2;
  // barCount artık burada tanımlanmıyor, sabit _barCount kullanılıyor
}

class _TabletSizes {
  static const double barWidth = 6;
  static const double barSpacing = 3;
  static const double barBorderRadius = 3;
  static const double heightScale = 1.4;
  static const double opacityActive = 0.8;
  static const double opacityInactive = 0.2;
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

class RadioWaveRowWidget extends StatefulWidget {
  final bool isActive;
  const RadioWaveRowWidget({super.key, required this.isActive});

  @override
  State<RadioWaveRowWidget> createState() => _RadioWaveRowWidgetState();
}

class _RadioWaveRowWidgetState extends State<RadioWaveRowWidget>
    with TickerProviderStateMixin {
  static const int _barCount = 5; // ✅ artık kullanılıyor

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + i * 80),
      );
    });
    _animations = _controllers.map((ctrl) {
      return Tween<double>(begin: 4, end: 22).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
    }).toList();

    if (widget.isActive) {
      for (final c in _controllers) {
        c.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(RadioWaveRowWidget old) {
    super.didUpdateWidget(old);
    if (widget.isActive != old.isActive) {
      for (final c in _controllers) {
        if (widget.isActive) {
          c.repeat(reverse: true);
        } else {
          c.stop();
          c.animateTo(0);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
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
    return _buildContent(
      barWidth: _PhoneSizes.barWidth.w,
      barSpacing: _PhoneSizes.barSpacing.w,
      borderRadius: _PhoneSizes.barBorderRadius.r,
      heightScale: _PhoneSizes.heightScale,
      opacityActive: _PhoneSizes.opacityActive,
      opacityInactive: _PhoneSizes.opacityInactive,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    return _buildContent(
      barWidth: _TabletSizes.barWidth,
      barSpacing: _TabletSizes.barSpacing,
      borderRadius: _TabletSizes.barBorderRadius,
      heightScale: _TabletSizes.heightScale,
      opacityActive: _TabletSizes.opacityActive,
      opacityInactive: _TabletSizes.opacityInactive,
    );
  }

  // ─── Ortak İçerik ────────────────────────────────────────────────────────

  Widget _buildContent({
    required double barWidth,
    required double barSpacing,
    required double borderRadius,
    required double heightScale,
    required double opacityActive,
    required double opacityInactive,
  }) {
    return SizedBox(
      height: 28.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_barCount, (i) {  // ✅ _barCount kullanıldı
          return AnimatedBuilder(
            animation: _animations[i],
            builder: (_, __) => Container(
              width: barWidth,
              height: _animations[i].value * heightScale,
              margin: EdgeInsets.symmetric(horizontal: barSpacing),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(
                  alpha: widget.isActive ? opacityActive : opacityInactive,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          );
        }),
      ),
    );
  }
}