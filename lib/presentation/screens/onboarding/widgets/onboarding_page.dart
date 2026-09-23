import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/sizes.dart';

// ═══════════════════════════════════════════════════════════
// ONBOARDING PAGE — Tasarımdaki <section> yapısının bire bir
// karşılığı: üstte ortalanmış görsel kart (flex-1, max 300px),
// altta SOLA HİZALI "ADIM N / 5" etiketi + başlık + açıklama.
// ═══════════════════════════════════════════════════════════

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.sizes,
    required this.index,
    required this.totalCount,
    required this.title,
    required this.description,
    required this.visual,
  });

  final OnboardingSizes sizes;
  final int index;
  final int totalCount;
  final String title;
  final String description;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.pageHPadding,
        sizes.pageTopPadding,
        sizes.pageHPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Minimal Visual — flex-1, max-h, ortalanmış
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: sizes.visualMaxWidth,
                  maxHeight: sizes.visualMaxHeight,
                ),
                child: visual,
              ),
            ),
          ),

          // Typography — py-4, sola hizalı
          Padding(
            padding: EdgeInsets.symmetric(vertical: sizes.typographyTopGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // text-xs font-bold uppercase tracking-widest text-primary
                Text(
                  'ADIM ${index + 1} / $totalCount',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: sizes.labelFontSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: sizes.labelFontSize * 0.1, // tracking-widest
                  ),
                ),
                SizedBox(height: sizes.labelSpacing),
                // text-2xl font-extrabold tracking-tight
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: sizes.titleFontSize,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -sizes.titleFontSize * 0.025, // tracking-tight
                  ),
                ),
                SizedBox(height: sizes.titleSpacing),
                // text-sm leading-relaxed text-on-surface-variant
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.descriptionFontSize,
                    height: sizes.descriptionLineHeight,
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