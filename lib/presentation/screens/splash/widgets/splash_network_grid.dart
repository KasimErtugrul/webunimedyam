// lib/presentation/screens/splash/widgets/splash_network_grid.dart

import 'package:flutter/material.dart';

/// Tasarımdaki SVG viewBox (0 0 360 600) bire bir çizilir:
/// - r140 kesikli çember (dash 4-8, width 1)
/// - r190 kesikli çember (dash 2-6, width 0.75)
/// - çapraz iki düz çizgi (opacity 0.3, width 0.5)
/// SVG'nin `preserveAspectRatio: xMidYMid meet` davranışı korunur.
class SplashNetworkGrid extends StatelessWidget {
  const SplashNetworkGrid({super.key, required this.opacity});

  /// Tasarımda konteyner: opacity-10
  final double opacity;

  static const double _viewWidth = 360;
  static const double _viewHeight = 600;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // meet: iki eksenden küçük ölçek + ortalama
            final scale = (constraints.maxWidth / _viewWidth)
                .clamp(0.0, constraints.maxHeight / _viewHeight);
            return CustomPaint(
              size: Size(_viewWidth * scale, _viewHeight * scale),
              painter: _GridPainter(color: primary),
            );
          },
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 360;

    // Kesikli çemberler
    _dashedCircle(canvas, size,
        center: Offset(180 * scale, 240 * scale),
        radius: 140 * scale,
        dash: 4 * scale,
        gap: 8 * scale,
        strokeWidth: 1 * scale,
        color: color);
    _dashedCircle(canvas, size,
        center: Offset(180 * scale, 240 * scale),
        radius: 190 * scale,
        dash: 2 * scale,
        gap: 6 * scale,
        strokeWidth: 0.75 * scale,
        color: color);

    // Çapraz düz çizgiler (stroke-opacity 0.3)
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 0.5 * scale
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(40 * scale, 120 * scale),
        Offset(320 * scale, 360 * scale), linePaint);
    canvas.drawLine(Offset(40 * scale, 360 * scale),
        Offset(320 * scale, 120 * scale), linePaint);
  }

  void _dashedCircle(
    Canvas canvas,
    Size size, {
    required Offset center,
    required double radius,
    required double dash,
    required double gap,
    required double strokeWidth,
    required Color color,
  }) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => oldDelegate.color != color;
}