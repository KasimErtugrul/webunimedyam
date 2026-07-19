/* // lib/presentation/screens/radio/widgets/radio_visualizer_wrapper.dart
// ═══════════════════════════════════════════════════════════════════════════════
// RadioVisualizer için dispose-safe wrapper
// AnimatedSwitcher ile kullanıldığında oluşan "_lifecycleState != defunct"
// hatasını önler.
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:radio_player/radio_player.dart';

import '../../../../app/themes/app_theme.dart';

class RadioVisualizerWrapper extends StatefulWidget {
  final bool isActive;
  final int barCount;
  final double barWidth;
  final double barSpacing;
  final double barMaxHeight;
  final double barBorderRadius;
  final double barAlpha;

  const RadioVisualizerWrapper({
    super.key,
    required this.isActive,
    required this.barCount,
    required this.barWidth,
    required this.barSpacing,
    required this.barMaxHeight,
    required this.barBorderRadius,
    required this.barAlpha,
  });

  @override
  State<RadioVisualizerWrapper> createState() => _RadioVisualizerWrapperState();
}

class _RadioVisualizerWrapperState extends State<RadioVisualizerWrapper> {
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _mounted = true;
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return RadioVisualizer(
      fallbackEnabledIOS: true,
      fallbackTimeout: const Duration(milliseconds: 500),
      builder: (context, data) {
        if (!_mounted) return const SizedBox.shrink();
        if (data.isEmpty) return const SizedBox.shrink();

        return IgnorePointer(
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: data.take(widget.barCount).map((value) {
                final height = (value / 255) * widget.barMaxHeight;
                return Container(
                  width: widget.barWidth,
                  height: height,
                  margin: EdgeInsets.symmetric(horizontal: widget.barSpacing),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.3),
                        AppTheme.primaryColor.withValues(alpha: widget.barAlpha),
                        Colors.white.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.barBorderRadius),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
} */