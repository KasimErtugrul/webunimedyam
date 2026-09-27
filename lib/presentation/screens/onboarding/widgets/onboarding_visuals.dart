import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/sizes.dart';

// ═══════════════════════════════════════════════════════════
// ONBOARDING GÖRSELLERİ — Stitch tasarımındaki 5 adımın bire
// bir karşılıkları. TÜM renkler Theme.of(context).colorScheme
// üzerinden alındığı için light & dark temada otomatik uyumlu.
// ═══════════════════════════════════════════════════════════

/// Tasarımdaki `border-white/5` (dark) karşılığı; light temada
/// outlineVariant bazlı ince çizgi kullanılır.
Color onboardingHairline(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return AppTheme.isDark(context)
      ? Colors.white.withValues(alpha: 0.05)
      : scheme.outlineVariant.withValues(alpha: 0.45);
}

// ─────────────────────────────────────────────────────────────
// Görsel kart kabuğu — rounded-3xl, surface-container-low,
// border, shadow-xl ve arkada blur-3xl primary glow blob.
// ─────────────────────────────────────────────────────────────
class _VisualCard extends StatelessWidget {
  const _VisualCard({required this.sizes, required this.child});

  final OnboardingSizes sizes;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = AppTheme.isDark(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(sizes.visualPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(sizes.visualRadius),
        border: Border.all(color: onboardingHairline(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _GlowBlob(size: sizes.glowSize),
          // Çok küçük ekranlarda içerik taşmasın (güvenli ölçekleme)
          FittedBox(fit: BoxFit.scaleDown, child: child),
        ],
      ),
    );
  }
}

/// `bg-primary/10 blur-3xl` glow'unin gradyan bazlı karşılığı.
class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.16),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Ortak parçalar
// ─────────────────────────────────────────────────────────────
class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.sizes,
    required this.icon,
    required this.size,
    required this.iconSize,
    this.circle = false,
    this.backgroundColor,
    this.borderColor,
    this.radius,
  });

  final OnboardingSizes sizes;
  final IconData icon;
  final double size;
  final double iconSize;
  final bool circle;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainer,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle
            ? null
            : BorderRadius.circular(radius ?? sizes.tileRadius),
        border: Border.all(
          color: borderColor ?? scheme.primary.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: scheme.primary),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.sizes,
    required this.label,
    this.icon,
    this.leading,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.fontWeight = FontWeight.w500,
  });

  final OnboardingSizes sizes;
  final String label;
  final IconData? icon;
  final Widget? leading;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? scheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.pillHPadding,
        vertical: sizes.pillVPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999), // rounded-full
        border: Border.all(color: borderColor ?? onboardingHairline(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: sizes.pillGap)],
          if (icon != null) ...[
            Icon(icon, size: sizes.pillIconSize, color: fg),
            SizedBox(width: sizes.pillGap),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: sizes.pillFontSize,
              fontWeight: fontWeight,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// `animate-pulse` — Adım 1'deki yanıp sönen nokta.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.size});

  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _pulse,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.35).animate(_curve),
      child: ScaleTransition(
        scale: Tween<double>(begin: 1, end: 0.65).animate(_curve),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}

/// `animate-[spin_30s_linear_infinite]` — Adım 2'deki çark.
class _DashedCircle extends StatefulWidget {
  const _DashedCircle({required this.sizes});

  final OnboardingSizes sizes;

  @override
  State<_DashedCircle> createState() => _DashedCircleState();
}

class _DashedCircleState extends State<_DashedCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RotationTransition(
      turns: _rotation,
      child: SizedBox(
        width: widget.sizes.spinnerSize,
        height: widget.sizes.spinnerSize,
        child: CustomPaint(
          painter: _DashedCirclePainter(
            color: scheme.primary.withValues(alpha: 0.40),
          ),
          child: Center(
            child: Icon(
              Icons.sync_rounded,
              size: widget.sizes.spinnerIconSize,
              color: scheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color}) : strokeWidth = 2.0;

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    final arcRect = (Offset.zero & size).deflate(strokeWidth / 2);
    const dashCount = 14;
    final sweep = 2 * math.pi / dashCount;

    for (var i = 0; i < dashCount; i++) {
      canvas.drawArc(arcRect, i * sweep, sweep * 0.55, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Adım 5 — "Canlı Kampüs Radyosu" ekolayzır animasyonu.
class _EqualizerBars extends StatefulWidget {
  const _EqualizerBars({required this.sizes});

  final OnboardingSizes sizes;

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  static const List<double> _phases = [0.0, 0.18, 0.36];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _barHeight(double progress, double phase) {
    final s = widget.sizes;
    final t = (progress + phase) % 1.0;
    final wave = 0.5 + 0.5 * math.sin(2 * math.pi * t);
    return s.eqBarMinHeight + (s.eqBarMaxHeight - s.eqBarMinHeight) * wave;
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < _phases.length; i++)
              Container(
                width: widget.sizes.eqBarWidth,
                height: _barHeight(_controller.value, _phases[i]),
                margin: EdgeInsets.symmetric(
                  horizontal: widget.sizes.eqBarWidth / 2,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(widget.sizes.eqBarWidth),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADIM 1 — Karşılama: live_tv ikonu + üniversite rozeti
// ─────────────────────────────────────────────────────────────
class StepWelcomeVisual extends StatelessWidget {
  const StepWelcomeVisual({super.key, required this.sizes});

  final OnboardingSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _VisualCard(
      sizes: sizes,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconTile(
            sizes: sizes,
            icon: Icons.live_tv_rounded,
            size: sizes.heroTileSize,
            iconSize: sizes.heroIconSize,
            borderColor: scheme.primary.withValues(alpha: 0.30),
          ),
          SizedBox(height: sizes.visualGap),
          _Pill(
            sizes: sizes,
            leading: _PulsingDot(size: sizes.dotSize),
            label: '219 Üniversite Tek Ekranda',
            fontWeight: FontWeight.w600,
            foregroundColor: scheme.onSurface,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADIM 2 — A'dan Z'ye harf şeridi + dönen çark
// ─────────────────────────────────────────────────────────────
class StepRandomVisual extends StatelessWidget {
  const StepRandomVisual({super.key, required this.sizes});

  final OnboardingSizes sizes;

  Widget _letter(
    BuildContext context,
    String text, {
    bool highlighted = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: sizes.pillFontSize,
        fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
        color: highlighted ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _separator(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sizes.pillGap),
      child: Text(
        '•',
        style: TextStyle(
          fontSize: sizes.pillFontSize,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _VisualCard(
      sizes: sizes,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Harf şeridi
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.innerCardHPadding,
              vertical: sizes.innerCardVPadding,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(sizes.tileRadius),
              border: Border.all(color: onboardingHairline(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _letter(context, 'A', highlighted: true),
                _separator(context),
                _letter(context, 'B'),
                _separator(context),
                _letter(context, 'C', highlighted: true),
                _separator(context),
                _letter(context, '...'),
                _separator(context),
                _letter(context, 'Z', highlighted: true),
              ],
            ),
          ),
          SizedBox(height: sizes.visualGap),
          _DashedCircle(sizes: sizes), // → aşağıda generic olmayan kullanım
          SizedBox(height: sizes.visualGap),
          _Pill(
            sizes: sizes,
            icon: Icons.shuffle_rounded,
            label: 'Rastgele Üniversite Keşfet',
            foregroundColor: scheme.primary,
            backgroundColor: scheme.primary.withValues(alpha: 0.10),
            borderColor: scheme.primary.withValues(alpha: 0.20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADIM 3 — Bildirim kartı + sensors rozeti
// ─────────────────────────────────────────────────────────────
class StepNotificationsVisual extends StatelessWidget {
  const StepNotificationsVisual({super.key, required this.sizes});

  final OnboardingSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _VisualCard(
      sizes: sizes,
      child: SizedBox(
        width: sizes.stackWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bildirim kartı
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: sizes.innerCardHPadding,
                vertical: sizes.innerCardVPadding,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(sizes.tileRadius),
                border: Border.all(color: onboardingHairline(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: AppTheme.isDark(context) ? 0.25 : 0.05,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _IconTile(
                    sizes: sizes,
                    icon: Icons.notifications_active_rounded,
                    size: sizes.notifTileSize,
                    iconSize: sizes.notifIconSize,
                    radius: sizes.logoRadius, // rounded-xl
                    backgroundColor: scheme.primary.withValues(alpha: 0.15),
                    borderColor: scheme.primary.withValues(alpha: 0.30),
                  ),
                  SizedBox(width: sizes.innerGap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Canlı Yayın Başladı',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.notifTitleFontSize,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Takip ettiğin kampüsten yeni yayın',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: sizes.notifBodyFontSize,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: sizes.innerGap),
                  Container(
                    width: sizes.dotSize,
                    height: sizes.dotSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: sizes.visualGapSm),
            _Pill(
              sizes: sizes,
              icon: Icons.sensors_rounded,
              label: 'Anında Bildirim Desteği',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// ADIM 4 — favorite / bookmark / chat_bubble üçlüsü
// ─────────────────────────────────────────────────────────────
class StepInteractionsVisual extends StatelessWidget {
  const StepInteractionsVisual({super.key, required this.sizes});

  final OnboardingSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rowWidth = sizes.actionTileSize * 3 + sizes.innerGap * 2;

    return _VisualCard(
      sizes: sizes,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconTile(
                sizes: sizes,
                icon: Icons.favorite_rounded,
                size: sizes.actionTileSize,
                iconSize: sizes.actionIconSize,
              ),
              SizedBox(width: sizes.innerGap),
              _IconTile(
                sizes: sizes,
                icon: Icons.bookmark_border_rounded,
                size: sizes.actionTileSize,
                iconSize: sizes.actionIconSize,
              ),
              SizedBox(width: sizes.innerGap),
              _IconTile(
                sizes: sizes,
                icon: Icons.chat_bubble_outline_rounded,
                size: sizes.actionTileSize,
                iconSize: sizes.actionIconSize,
              ),
            ],
          ),
          SizedBox(height: sizes.visualGap),
          Container(
            width: rowWidth,
            padding: EdgeInsets.symmetric(
              horizontal: sizes.innerCardHPadding,
              vertical: sizes.innerCardVPadding,
            ),
            decoration: BoxDecoration(
              color: scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(sizes.tileRadius),
              border: Border.all(color: onboardingHairline(context)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Etkileşim',
                  style: TextStyle(
                    fontSize: sizes.pillFontSize,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Aktif Katılım',
                  style: TextStyle(
                    fontSize: sizes.pillFontSize,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
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

// ─────────────────────────────────────────────────────────────
// ADIM 5 — Hesap avatarı + canlı radyo satırı (ekolayzır)
// ─────────────────────────────────────────────────────────────
class StepAccountVisual extends StatelessWidget {
  const StepAccountVisual({super.key, required this.sizes});

  final OnboardingSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _VisualCard(
      sizes: sizes,
      child: SizedBox(
        width: sizes.stackWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconTile(
              sizes: sizes,
              icon: Icons.account_circle_outlined,
              size: sizes.avatarSize,
              iconSize: sizes.avatarIconSize,
              circle: true,
              borderColor: scheme.primary.withValues(alpha: 0.30),
            ),
            SizedBox(height: sizes.visualGapSm),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: sizes.innerCardHPadding,
                vertical: sizes.innerCardVPadding,
              ),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: BorderRadius.circular(sizes.tileRadius),
                border: Border.all(color: onboardingHairline(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.radio_rounded,
                    size: sizes.radioIconSize,
                    color: scheme.primary,
                  ),
                  SizedBox(width: sizes.iconTextGap),
                  Expanded(
                    child: Text(
                      'Canlı Kampüs Radyosu',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: sizes.pillFontSize,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  SizedBox(width: sizes.innerGap),
                  _EqualizerBars(sizes: sizes),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}