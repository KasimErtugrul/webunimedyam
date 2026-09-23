// lib/presentation/screens/splash/widgets/splash_progress_section.dart

import 'dart:async';

import 'package:flutter/material.dart';

import '../splash_sizes.dart';

/// Alt bölüm: aşamalı ilerleme çubuğu (JS'teki 650ms döngüsünün bire
/// bir karşılığı) + sürüm/uyumluluk bilgileri.
class SplashProgressSection extends StatefulWidget {
  const SplashProgressSection({super.key, required this.sizes});

  final SplashSizes sizes;

  @override
  State<SplashProgressSection> createState() => _SplashProgressSectionState();
}

class _SplashProgressSectionState extends State<SplashProgressSection> {
  static const double _startProgress = 25;
  static const String _startStage = 'Senkronize ediliyor';
  static const Duration _stageInterval = Duration(milliseconds: 650);

  static const List<({double step, String text})> _stages = [
    (step: 45, text: 'Veri akışı hazırlanıyor'),
    (step: 78, text: 'Kampüs kanalları taranıyor'),
    (step: 94, text: 'Yayın odaları açılıyor'),
    (step: 100, text: 'Hazır'),
  ];

  double _progress = _startProgress;
  String _stage = _startStage;
  int _stageIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(_stageInterval, (_) {
      if (_stageIndex < _stages.length) {
        setState(() {
          _progress = _stages[_stageIndex].step;
          _stage = _stages[_stageIndex].text;
          _stageIndex++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.sizes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── İlerleme grubu ────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Etiket satırı — sol: "Yükleniyor...", sağ: aşama metni
            Padding(
              padding: EdgeInsets.symmetric(horizontal: s.progressLabelHPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulsingDot(
                          size: s.progressDotSize, color: scheme.primary),
                      SizedBox(width: s.progressLabelGap),
                      Text(
                        'Yükleniyor...',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: s.progressLabelFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.04 * s.progressLabelFontSize,
                        ),
                      ),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _stage,
                      key: ValueKey(_stage),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: s.progressLabelFontSize,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.04 * s.progressLabelFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: s.stageGap),

            // Track — h-1.5 bg-surface-container-highest
            LayoutBuilder(
              builder: (context, constraints) {
                return ClipRRect(
                  borderRadius:
                      BorderRadius.circular(s.progressTrackHeight),
                  child: Container(
                    height: s.progressTrackHeight,
                    color: scheme.surfaceContainerHighest,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        width: constraints.maxWidth * _progress / 100,
                        // from-primary via-secondary-fixed to-primary
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              scheme.primary,
                              scheme.secondaryFixed,
                              scheme.primary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(s.progressTrackHeight),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        // ── Sürüm / uyumluluk bilgileri ──────────────────────
        SizedBox(height: s.credentialsTopGap),
        Column(
          children: [
            Text(
              'v2.4.1 (Build 8904) • Lisanslı Kampüs Ağı',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: s.versionFontSize,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.04 * s.versionFontSize,
              ),
            ),
            SizedBox(height: s.credentialsGap),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_rounded,
                    size: s.credentialsIconSize, color: scheme.outline),
                SizedBox(width: s.progressLabelGap),
                Text(
                  'YÖK Medya Standartları Uyumlu',
                  style: TextStyle(
                    color: scheme.outline,
                    fontSize: s.versionFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.04 * s.versionFontSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// animate-pulse — yumuşak yanıp sönen nokta
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.35).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}