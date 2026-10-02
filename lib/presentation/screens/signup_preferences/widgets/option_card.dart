// lib/presentation/screens/signup_preferences/widgets/option_card.dart

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/widgets/hover_tap.dart';
import '../utils/singup_preferences_sizes.dart';

/// Ortak "seçilebilir kart" — tasarım diline göre:
/// seçili: bg-surface-container-high + shadow-md + primary radio glow;
/// seçili değil: bg-surface-container-low + shadow-sm.
/// Sağda radio indicator (seçiliyken primary + check), opsiyonel
/// "Önerilen" rozeti ve opsiyonel mini mockup önizlemesi.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.sizes,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badgeText,
    this.mockup,
  });

  final SignupPreferencesSizes sizes;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badgeText;
  final Widget? mockup;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return TapCursor(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(s.cardPadding),
        decoration: BoxDecoration(
          color: selected
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(s.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: selected
                    ? (AppTheme.isDark(context) ? 0.30 : 0.10)
                    : (AppTheme.isDark(context) ? 0.12 : 0.04),
              ),
              blurRadius: selected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Üst satır: ikon + metinler + radio ─────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // İkon dairesi — seçili: bg-lowest/primary,
                // değil: bg-highest/onSurfaceVariant
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: s.optionIconCircleSize,
                  height: s.optionIconCircleSize,
                  decoration: BoxDecoration(
                    color: selected
                        ? scheme.surfaceContainerLowest
                        : scheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: s.optionIconSize,
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: s.headerGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: s.optionTitleFontSize,
                                fontWeight: FontWeight.w600,
                                height: 24 / 18,
                                letterSpacing: -0.01 * s.optionTitleFontSize,
                              ),
                            ),
                          ),
                          if (badgeText != null) ...[
                            SizedBox(width: s.optionBadgeGap),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: s.optionBadgeHPadding,
                                vertical: s.optionBadgeVPadding,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusFull,
                                ),
                              ),
                              child: Text(
                                badgeText!,
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontSize: s.optionBadgeFontSize,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.04 * s.optionBadgeFontSize,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: s.optionSubtitleFontSize,
                          letterSpacing: 0.01 * s.optionSubtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: s.headerGap),
                _RadioIndicator(sizes: s, selected: selected),
              ],
            ),

            // ── Mini mockup (opsiyonel) ────────────────────────
            if (mockup != null) ...[
              SizedBox(height: s.headerMockupGap),
              SizedBox(
                width: double.infinity,
                height: s.mockupHeight,
                child: mockup!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Radio state indicator — seçili: primary + on-primary check + glow;
/// değil: bg-highest, gizli check (yer tutar).
class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.sizes, required this.selected});

  final SignupPreferencesSizes sizes;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: s.radioSize,
      height: s.radioSize,
      decoration: BoxDecoration(
        color: selected ? scheme.primary : scheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.5),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: selected ? 1 : 0,
        child: Icon(
          Icons.check_rounded,
          size: s.radioIconSize,
          color: scheme.onPrimary,
          weight: 3,
        ),
      ),
    );
  }
}
