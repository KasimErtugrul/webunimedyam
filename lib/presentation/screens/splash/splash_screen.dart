/* // lib/presentation/screens/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/splash_controller.dart';
import 'splash_sizes.dart';
import 'widgets/splash_brand_hero.dart';
import 'widgets/splash_live_badge.dart';
import 'widgets/splash_network_grid.dart';
import 'widgets/splash_progress_section.dart';

// ═══════════════════════════════════════════════════════════
// SPLASH SCREEN — Stitch "Splash Screen - ÜniTV" tasarımının
// bire bir karşılığı. Tüm renkler AppTheme/ColorScheme üzerinden
// geldiği için light & dark tema otomatik desteklenir.
//
// Katman yapısı (body seviyesinde bounded Stack — SingleChildScrollView
// dersiyle uyumlu; Stack asla unbounded bağlamın içinde değil):
//   1. Ambient glow (animate-pulse primary + primary-container)
//   2. Kampüs ağ grid'i (opacity 0.10)
//   3. İçerik: üst etiket / hero / ilerleme
// ═══════════════════════════════════════════════════════════

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller'ı başlat (lazy init tetiklenir; yönlendirme oradan yönetilir)
    Get.find<SplashController>();

    // KURAL 5 — TEK DALLANMA NOKTASI (üçlü ölçek: web → tablet → telefon)
    final SplashSizes sizes = Responsive.isWeb(context)
        ? const SplashWebSizes()
        : Responsive.isTablet(context)
        ? const SplashTabletSizes()
        : const SplashPhoneSizes();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Dynamic Ambient Glow Layer ───────────────────
          const _AmbientGlowLayer(),

          // ── 2. Decorative Campus Network Grid (opacity-10) ──
          const Center(
            child: SplashNetworkGrid(opacity: 0.10),
          ),

          // ── 3. Main Splash Container (z-10) ─────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.pageHPadding,
                vertical: sizes.pageVPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: sizes.heroMaxWidth * 1.4),
                  child: Column(
                    children: [
                      // Top Micro Tag
                      SplashLiveBadge(sizes: sizes)
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(
                            begin: -0.15,
                            end: 0,
                            duration: 500.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      // Central Hero (my-space-xl, ortalanmış)
                      Expanded(
                        child: Center(
                          child: SplashBrandHero(sizes: sizes)
                              .animate()
                              .fadeIn(delay: 150.ms, duration: 450.ms)
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 550.ms,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                      ),

                      // Bottom Progress + Credentials
                      SizedBox(
                        width: sizes.bottomMaxWidth,
                        child: SplashProgressSection(sizes: sizes),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 450.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AMBIENT GLOW — w-80 primary/10 blur-3xl animate-pulse +
// w-56 primary-container/15 blur-2xl (ekran merkezli)
// ═══════════════════════════════════════════════════════════

class _AmbientGlowLayer extends StatelessWidget {
  const _AmbientGlowLayer();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final sizes = Responsive.isWeb(context)
        ? const SplashWebSizes()
        : Responsive.isTablet(context)
        ? const SplashTabletSizes()
        : const SplashPhoneSizes();

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: [
          // animate-pulse: nefes alan birincil glow
          _PulsingGlow(
            size: sizes.glowPrimarySize,
            color: scheme.primary.withValues(alpha: 0.10),
          ),
          // Sabit ikincil glow (primary-container/15)
          SizedBox(
            width: sizes.glowSecondarySize,
            height: sizes.glowSecondarySize,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primaryContainer.withValues(alpha: 0.15),
                    scheme.primaryContainer.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingGlow extends StatefulWidget {
  const _PulsingGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  State<_PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<_PulsingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.4).animate(
          CurvedAnimation(parent: _c, curve: Curves.easeInOut),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [widget.color, widget.color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
} */
