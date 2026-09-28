// lib/presentation/screens/signup_preferences/widgets/theme_mockups.dart

import 'package:flutter/material.dart';

import '../utils/singup_preferences_sizes.dart';

// ═══════════════════════════════════════════════════════════
// Tasarımdaki 3 mini UI mockup'ının bire bir karşılıkları.
// HEPSİ Theme.of(context) üzerinden renk alır → light temada
// mockup'lar da light rolleriyle doğru görünür (mockup "içerik
// önizlemesi" olduğundan tasarım rollerini aynen kullanır).
// ═══════════════════════════════════════════════════════════

/// Ortak mini satır çizgisi
class _Bar extends StatelessWidget {
  const _Bar({
    required this.width,
    required this.height,
    required this.color,
  }) : radius = null;

  final double width;
  final double height;
  final Color color;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius ?? height),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// KOYU TEMA MOCKUP — bg-surface-container-lowest
// ─────────────────────────────────────────────────────────────
class ThemeDarkMockup extends StatelessWidget {
  const ThemeDarkMockup({super.key, required this.sizes});

  final SignupPreferencesSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      padding: EdgeInsets.all(s.mPad),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(s.mockupRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Üst bar: dot + bar | avatar dairesi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _Bar(width: s.mDot, height: s.mDot, color: scheme.primary),
                  SizedBox(width: s.mMiniGap),
                  _Bar(
                      width: s.mBarW,
                      height: s.mBarH,
                      color: scheme.surfaceContainerHighest),
                ],
              ),
              _Bar(
                  width: s.mCircle,
                  height: s.mCircle,
                  color: scheme.surfaceContainerHigh),
            ],
          ),
          // Video satırı: thumb + metin çizgileri
          Row(
            children: [
              Container(
                width: s.mThumbW,
                height: s.mThumbH,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(s.mThumbRadius),
                ),
                child: Icon(Icons.play_arrow_rounded,
                    size: s.mThumbIcon, color: scheme.primary),
              ),
              SizedBox(width: s.mMiniGap + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bar(
                        width: double.infinity,
                        height: s.mLineH,
                        color: scheme.surfaceContainerHighest),
                    SizedBox(height: s.mMiniGap - 2),
                    FractionallySizedBox(
                      widthFactor: 0.75,
                      child: _Bar(
                          width: double.infinity,
                          height: s.mLineH,
                          color: scheme.surfaceContainerHigh),
                    ),
                    SizedBox(height: s.mMiniGap - 2),
                    FractionallySizedBox(
                      widthFactor: 0.33,
                      alignment: Alignment.centerLeft,
                      child: _Bar(
                          width: double.infinity,
                          height: s.mLineHSm,
                          color: scheme.primary.withValues(alpha: 0.40)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Alt navigasyon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Bar(width: s.mNavW, height: s.mNavH, color: scheme.primary),
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.surfaceContainerHighest),
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.surfaceContainerHighest),
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.surfaceContainerHighest),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AÇIK TEMA MOCKUP — bg-surface-bright
// ─────────────────────────────────────────────────────────────
class ThemeLightMockup extends StatelessWidget {
  const ThemeLightMockup({super.key, required this.sizes});

  final SignupPreferencesSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      padding: EdgeInsets.all(s.mPad),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceBright,
        borderRadius: BorderRadius.circular(s.mockupRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _Bar(
                      width: s.mDot,
                      height: s.mDot,
                      color: scheme.primaryContainer),
                  SizedBox(width: s.mMiniGap),
                  _Bar(
                      width: s.mBarW,
                      height: s.mBarH,
                      color: scheme.surfaceContainerHighest),
                ],
              ),
              _Bar(
                  width: s.mCircle,
                  height: s.mCircle,
                  color: scheme.surfaceContainerHighest),
            ],
          ),
          Row(
            children: [
              Container(
                width: s.mThumbW,
                height: s.mThumbH,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(s.mThumbRadius),
                ),
                child: Icon(Icons.play_arrow_rounded,
                    size: s.mThumbIcon, color: scheme.primaryContainer),
              ),
              SizedBox(width: s.mMiniGap + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Bar(
                        width: double.infinity,
                        height: s.mLineH,
                        color: scheme.surfaceContainerHighest),
                    SizedBox(height: s.mMiniGap - 2),
                    FractionallySizedBox(
                      widthFactor: 0.75,
                      child: _Bar(
                          width: double.infinity,
                          height: s.mLineH,
                          color: scheme.outlineVariant),
                    ),
                    SizedBox(height: s.mMiniGap - 2),
                    FractionallySizedBox(
                      widthFactor: 0.33,
                      alignment: Alignment.centerLeft,
                      child: _Bar(
                          width: double.infinity,
                          height: s.mLineHSm,
                          color:
                              scheme.primaryContainer.withValues(alpha: 0.40)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.primaryContainer),
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.outlineVariant),
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.outlineVariant),
              _Bar(
                  width: s.mNavW,
                  height: s.mNavH,
                  color: scheme.outlineVariant),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SİSTEM TEMA MOCKUP — split dual + merkez glow çizgisi
// ─────────────────────────────────────────────────────────────
class ThemeSystemMockup extends StatelessWidget {
  const ThemeSystemMockup({super.key, required this.sizes});

  final SignupPreferencesSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s.mockupRadius),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // ── Sol yarı: koyu ──────────────────────────
              Expanded(
                child: Container(
                  color: scheme.surfaceContainerLowest,
                  padding: EdgeInsets.all(s.mPad),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Bar(
                              width: s.mDot,
                              height: s.mDot,
                              color: scheme.primary),
                          SizedBox(width: s.mMiniGap),
                          _Bar(
                              width: s.mBarWShort,
                              height: s.mBarH,
                              color: scheme.surfaceContainerHighest),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: s.mIconBox,
                            height: s.mIconBox,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(s.mThumbRadius),
                            ),
                            child: Icon(Icons.nightlight_round,
                                size: s.mMiniIcon, color: scheme.primary),
                          ),
                          SizedBox(width: s.mMiniGap),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Bar(
                                    width: double.infinity,
                                    height: s.mLineHSm,
                                    color:
                                        scheme.surfaceContainerHighest),
                                SizedBox(height: s.mMiniGap - 2),
                                FractionallySizedBox(
                                  widthFactor: 0.66,
                                  child: _Bar(
                                      width: double.infinity,
                                      height: s.mLineHSm,
                                      color:
                                          scheme.surfaceContainerHigh),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _Bar(
                          width: s.mIconBox,
                          height: s.mNavH,
                          color: scheme.primary),
                    ],
                  ),
                ),
              ),
              // ── Sağ yarı: açık ──────────────────────────
              Expanded(
                child: Container(
                  color: scheme.surfaceBright,
                  padding: EdgeInsets.all(s.mPad),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _Bar(
                          width: s.mBarWShort,
                          height: s.mBarH,
                          color: scheme.surfaceContainerHighest),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _Bar(
                                    width: double.infinity,
                                    height: s.mLineHSm,
                                    color: scheme.surfaceContainerHighest),
                                SizedBox(height: s.mMiniGap - 2),
                                FractionallySizedBox(
                                  widthFactor: 0.66,
                                  child: _Bar(
                                      width: double.infinity,
                                      height: s.mLineHSm,
                                      color: scheme.outlineVariant),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: s.mMiniGap),
                          Container(
                            width: s.mIconBox,
                            height: s.mIconBox,
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(s.mThumbRadius),
                            ),
                            child: Icon(Icons.sunny,
                                size: s.mMiniIcon,
                                color: scheme.primaryContainer),
                          ),
                        ],
                      ),
                      _Bar(
                          width: s.mIconBox,
                          height: s.mNavH,
                          color: scheme.outlineVariant),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Merkez glow çizgisi — w-0.5 bg-primary/40 + glow
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 2,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.40),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}