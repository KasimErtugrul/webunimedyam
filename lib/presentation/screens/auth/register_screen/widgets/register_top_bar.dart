// lib/presentation/screens/auth/widgets/register_top_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../register_layout_spec.dart';



/// Geri butonu (w-10 h-10 rounded-full bg-surface-container) +
/// "CANLI AĞ" pill'i (pulse dot).
class RegisterTopBar extends StatelessWidget {
  const RegisterTopBar({super.key, required this.sizes});

  final RegisterSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.topBarVPadding),
      child: Row(
        children: [
          // Geri butonu
          Material(
            color: scheme.surfaceContainer,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: Get.back,
              child: SizedBox(
                width: s.backButtonSize,
                height: s.backButtonSize,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: s.backButtonIconSize,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
          const Spacer(),
          // Canlı Ağ pill'i
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: s.livePillHPadding,
              vertical: s.livePillVPadding,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PulsingDot(size: s.livePillDotSize, color: scheme.primary),
                SizedBox(width: s.livePillGap),
                Text(
                  'CANLI AĞ',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: s.livePillFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.05 * s.livePillFontSize, // tracking-wider
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

/// animate-pulse — yumuşak yanıp sönen nokta
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
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