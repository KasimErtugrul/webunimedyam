// lib/presentation/screens/signup_preferences/widgets/step_intro_card.dart

import 'package:flutter/material.dart';

import '../utils/singup_preferences_sizes.dart';

/// Ambient intro kartı — rounded-xl bg-surface-container-low p-4,
/// sağ üstte primary/10 blur blob, ikon kutusu + başlık + açıklama.
class StepIntroCard extends StatelessWidget {
  const StepIntroCard({
    super.key,
    required this.sizes,
    required this.icon,
    required this.title,
    required this.description,
  });

  final SignupPreferencesSizes sizes;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Decorative glow — -right-8 -top-8 w-32 blur-2xl
        Positioned(
          top: -s.introGlowOffset,
          right: -s.introGlowOffset,
          child: IgnorePointer(
            child: SizedBox(
              width: s.introGlowSize,
              height: s.introGlowSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      scheme.primary.withValues(alpha: 0.10),
                      scheme.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(s.introPadding),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(s.introRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // w-10 h-10 rounded-lg bg-surface-container-high
              Container(
                width: s.introIconBoxSize,
                height: s.introIconBoxSize,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(s.introIconBoxRadius),
                ),
                child: Icon(icon, size: s.introIconSize, color: scheme.primary),
              ),
              SizedBox(width: s.introIconTextGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: s.introTitleFontSize,
                        fontWeight: FontWeight.w800,
                        height: 34 / 26,
                        letterSpacing: -0.025 * s.introTitleFontSize,
                      ),
                    ),
                    SizedBox(height: s.introTitleDescGap),
                    Text(
                      description,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: s.introDescFontSize,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}