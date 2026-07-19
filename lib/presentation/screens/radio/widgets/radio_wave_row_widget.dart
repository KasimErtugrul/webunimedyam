// lib/presentation/screens/radio/widgets/radio_wave_row_widget.dart
// ═══════════════════════════════════════════════════════════════════════════════
// ✨ SIFIRDAN YENİDEN TASARLANMIŞ DALGA ANİMASYONU
// Konsept: "Modern Neon Wave with Gradient Bars"
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double barWidth = 4;
  static const double barSpacing = 2.5;
  static const double barBorderRadius = 3;
  static const double heightScale = 1.2;
  static const double opacityActive = 0.9;
  static const double opacityInactive = 0.15;
}

class _TabletSizes {
  static const double barWidth = 6;
  static const double barSpacing = 3;
  static const double barBorderRadius = 4;
  static const double heightScale = 1.5;
  static const double opacityActive = 0.9;
  static const double opacityInactive = 0.15;
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
  static const int _barCount = 7;

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;
  late final AnimationController _glowController;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // ✨ Dalga animasyonları - her bar için farklı hız ve gecikme
    _controllers = List.generate(_barCount, (i) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + i * 60 + (i % 2 == 0 ? 0 : 100)),
      );
    });

    _animations = _controllers.map((ctrl) {
      return Tween<double>(begin: 4, end: 24).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOutSine),
      );
    }).toList();

    // ✨ Glow efekti
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    if (widget.isActive) {
      for (final c in _controllers) {
        c.repeat(reverse: true);
      }
      _glowController.repeat(reverse: true);
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
      if (widget.isActive) {
        _glowController.repeat(reverse: true);
      } else {
        _glowController.stop();
        _glowController.animateTo(0);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PHONE - ✨ YENİ ✨
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
  // TABLET - ✨ YENİ ✨
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
      height: 32.h,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_barCount, (i) {
              return AnimatedBuilder(
                animation: _animations[i],
                builder: (_, __) {
                  final barHeight = _animations[i].value * heightScale;
                  return Container(
                    width: barWidth,
                    height: barHeight,
                    margin: EdgeInsets.symmetric(horizontal: barSpacing),
                    decoration: BoxDecoration(
                      gradient: widget.isActive
                          ? LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppTheme.primaryColor.withValues(
                                  alpha: opacityActive * 0.5,
                                ),
                                AppTheme.primaryColor.withValues(
                                  alpha: opacityActive * (0.7 + _glowAnimation.value * 0.3),
                                ),
                                Colors.white.withValues(
                                  alpha: opacityActive * _glowAnimation.value * 0.5,
                                ),
                              ],
                            )
                          : null,
                      color: widget.isActive
                          ? null
                          : AppTheme.primaryColor.withValues(alpha: opacityInactive),
                      borderRadius: BorderRadius.circular(borderRadius),
                      boxShadow: widget.isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3 * _glowAnimation.value,
                                ),
                                blurRadius: 4 + _glowAnimation.value * 4,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              );
            }),
          );
        },
      ),
    );
  }
}