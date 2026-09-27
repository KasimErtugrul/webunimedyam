/* // lib/presentation/screens/splash/widgets/splash_brand_hero.dart

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../splash_sizes.dart';

/// Merkezi hero: aura + logo vessel + HD badge + "ÜniTV" başlığı +
/// aksan pill'i + slogan + üniversite/yayın istatistik pill'i.
class SplashBrandHero extends StatelessWidget {
  const SplashBrandHero({super.key, required this.sizes});

  final SplashSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Logo sunumu (aura + vessel + HD badge) ────────────
        _LogoGroup(sizes: s),

        SizedBox(height: s.titleGap),

        // ── ÜniTV başlığı — headline-xl, "TV" primary ─────────
        Text.rich(
          TextSpan(
            text: 'Üni',
            children: [
              TextSpan(text: 'TV', style: TextStyle(color: scheme.primary)),
            ],
          ),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: s.titleFontSize,
            fontWeight: FontWeight.w800,
            height: 40 / 32,
            letterSpacing: -0.03 * s.titleFontSize, // tracking-tight
          ),
        ),

        SizedBox(height: s.titleGap),

        // ── Aksan pill'i — bg-surface-container-highest/60 ────
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: s.accentHPadding,
            vertical: s.accentVPadding,
          ),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.60),
            borderRadius: BorderRadius.circular(s.accentRadius),
          ),
          child: Text(
            'Kampüs Medya & Video Ağı',
            style: TextStyle(
              color: scheme.secondaryFixedDim,
              fontSize: s.accentFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.02 * s.accentFontSize, // tracking-wide
            ),
          ),
        ),

        SizedBox(height: s.sloganTopGap),

        // ── Slogan ────────────────────────────────────────────
        Text(
          'Türkiye Üniversitelerinin Resmi Video & Canlı Yayın Ekosistemi',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: s.sloganFontSize,
            height: 20 / 14,
          ),
        ),

        SizedBox(height: s.statTopGap),

        // ── Kampüs ölçek istatistik pill'i ────────────────────
        _StatPill(sizes: s),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Logo grubu — aura (-inset-4 blur-xl) + vessel (p-4,
// surface-container-low, shadow-xl) + HD mikro-badge
// ─────────────────────────────────────────────────────────────
class _LogoGroup extends StatelessWidget {
  const _LogoGroup({required this.sizes});

  final SplashSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    final vesselWidth = s.logoImageWidth + 2 * s.logoPad;
    final vesselHeight = s.logoImageHeight + 2 * s.logoPad;
    final groupWidth = vesselWidth + 2 * s.auraExtent;
    final groupHeight = vesselHeight + 2 * s.auraExtent;

    return SizedBox(
      width: groupWidth,
      height: groupHeight,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Radial Pulsing Aura — from-primary/30 to-secondary/10, blur-xl
          Positioned.fill(
            child: _Aura(
              radius: s.auraRadius,
              primary: scheme.primary,
              secondary: scheme.secondary,
            ),
          ),

          // Logo Backdrop Vessel
          Container(
            width: vesselWidth,
            height: vesselHeight,
            padding: EdgeInsets.all(s.logoPad),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(s.logoRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: AppTheme.isDark(context) ? 0.35 : 0.12,
                  ),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // İç üst gradyan — from-primary/10 via-transparent
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            scheme.primary.withValues(alpha: 0.10),
                            scheme.primary.withValues(alpha: 0.0),
                            scheme.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Logo — w-44 h-auto drop-shadow
                Center(
                  child: Image.asset(
                    'assets/images/unitv_logo.png', // TODO: kendi asset'iniz
                    width: s.logoImageWidth,
                    height: s.logoImageHeight,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.play_arrow_rounded,
                      size: s.logoImageHeight,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating HD badge — -bottom-2.5 -right-2 (aura payı içinde)
          Positioned(
            bottom: s.auraExtent - s.hdBadgeBottom,
            right: s.auraExtent - s.hdBadgeRight,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: s.hdBadgeHPadding,
                vertical: s.hdBadgeVPadding,
              ),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sensors_rounded,
                      size: s.hdBadgeIconSize, color: scheme.onPrimary),
                  SizedBox(width: s.hdBadgeVPadding),
                  Text(
                    'HD',
                    style: TextStyle(
                      color: scheme.onPrimary,
                      fontSize: s.hdBadgeFontSize,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.05 * s.hdBadgeFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// blur-xl aura karşılığı: iki katmanlı yumuşak gradyan (merkezde
/// primary/25, kenara secondary/10'a karışıp şeffaflaşır).
class _Aura extends StatelessWidget {
  const _Aura({
    required this.radius,
    required this.primary,
    required this.secondary,
  });

  final double radius;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              primary.withValues(alpha: 0.28),
              secondary.withValues(alpha: 0.12),
              secondary.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.18),
                blurRadius: 28,
                spreadRadius: 6,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// İstatistik pill'i — 219+ Üni | 10.000+ Yayın
// bg-surface-container/70, p-3, rounded-xl
// ─────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  const _StatPill({required this.sizes});

  final SplashSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      padding: EdgeInsets.all(s.statPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(s.statRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.18 : 0.05,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            sizes: s,
            icon: Icons.account_balance_rounded,
            iconColor: scheme.primary,
            label: '219+ Üni',
          ),
          Container(
            width: s.statDividerWidth,
            height: s.statDividerHeight,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(s.statDividerWidth),
            ),
          ),
          _StatItem(
            sizes: s,
            icon: Icons.smart_display_rounded,
            iconColor: scheme.secondary,
            label: '10.000+ Yayın',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.sizes,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final SplashSizes sizes;
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s.statItemHPadding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: s.statIconSize, color: iconColor),
          SizedBox(width: s.statItemHPadding / 2),
          Text(
            label,
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: s.statFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.02 * s.statFontSize,
            ),
          ),
        ],
      ),
    );
  }
} */