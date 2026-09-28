// lib/presentation/screens/auth/widgets/login_brand_header.dart

import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../login_layout_spec.dart';

/// Marka Logosu + "AKADEMİK YAYIN AĞI" rozeti
/// (p-1 rounded-xl bg-surface-container-low + pill badge)
class LoginBrandHeader extends StatelessWidget {
  const LoginBrandHeader({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Column(
      children: [
        // Logo kutusu — shadow-sm
        Container(
          padding: EdgeInsets.all(s.logoPad),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(s.logoRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/unitv_logo.png',
            height: s.logoHeight,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Icon(
              Icons.play_arrow_rounded,
              size: s.logoHeight,
              color: scheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Rozet — bg-surface-container-high, pulse dot + label-sm
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: s.badgeHPadding,
            vertical: s.badgeVPadding,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulsingDot(size: s.badgeDotSize, color: scheme.primary),
              SizedBox(width: s.badgeGap),
              Text(
                'AKADEMİK YAYIN AĞI',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: s.badgeFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1 * s.badgeFontSize, // tracking-widest
                ),
              ),
            ],
          ),
        ),
      ],
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