// lib/presentation/screens/signup_preferences/widgets/signup_progress_tracker.dart

import 'package:flutter/material.dart';

import '../utils/singup_preferences_sizes.dart';

/// Progress tracker — üst satır (sol etiket [+ ping] / sağ etiket) +
/// 5 segmentli bar. Aktif segment: primary + glow
/// (shadow 0 0 8 rgba(78,222,163,.4)).
class SignupProgressTracker extends StatelessWidget {
  const SignupProgressTracker({
    super.key,
    required this.sizes,
    required this.currentStep,
    required this.totalSteps,
    required this.leftLabel,
    required this.rightLabel,
    this.showPulse = false,
  });

  final SignupPreferencesSizes sizes;
  final int currentStep;
  final int totalSteps;
  final String leftLabel;
  final String rightLabel;
  final bool showPulse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: s.headerHPadding,
        vertical: s.progressVPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Etiket satırı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showPulse) ...[
                      _PingDot(size: s.progressDotSize, color: scheme.primary),
                      SizedBox(width: s.progressLabelGap),
                    ],
                    Flexible(
                      child: Text(
                        leftLabel.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: s.progressLabelFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.05 * s.progressLabelFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: s.progressLabelGap),
              Flexible(
                child: Text(
                  rightLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: s.progressLabelFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.04 * s.progressLabelFontSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s.progressLabelGap),

          // Segmentler — h-1.5, gap-1.5, flex-1
          Row(
            children: List.generate(totalSteps, (i) {
              final active = i <= currentStep;
              return Expanded(
                child: Container(
                  height: s.segmentHeight,
                  margin: EdgeInsets.only(
                    right: i == totalSteps - 1 ? 0 : s.segmentGap,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(s.segmentHeight),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
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