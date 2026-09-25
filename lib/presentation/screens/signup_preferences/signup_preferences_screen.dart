// lib/presentation/screens/signup_preferences/signup_preferences_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/signup_preferences_controller.dart';
import 'utils/singup_preferences_sizes.dart';
import 'widgets/auto_play_step.dart';
import 'widgets/notifications_step.dart';
import 'widgets/signup_header.dart';
import 'widgets/signup_progress_tracker.dart';
import 'widgets/theme_step.dart';
import 'widgets/university_step.dart';
import 'widgets/visibility_step.dart';

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI) — 5 adımlı akış:
// 1 Tema · 2 Otomatik Oynatma · 3 Bildirimler · 4 Görünürlük
// 5 Üniversite Seçimi (tasarım ekranı)
// ═══════════════════════════════════════════════════════════

class SignupPreferencesScreen extends StatefulWidget {
  const SignupPreferencesScreen({super.key});

  @override
  State<SignupPreferencesScreen> createState() =>
      _SignupPreferencesScreenState();
}

/// Adım başına üst takip + footer meta verisi
typedef _StepMeta = ({
  String leftLabel,
  String rightLabel,
  bool showPulse,
  String buttonLabel,
  IconData buttonIcon,
  String caption,
});

class _SignupPreferencesScreenState extends State<SignupPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final SignupPreferencesController controller;

  static const int _pageCount = 5;

  // Tasarım metinleri — adım bazlı
  static const List<_StepMeta> _meta = [
    (
      leftLabel: 'ADIM 1 / 5',
      rightLabel: 'Kişiselleştirme',
      showPulse: false,
      buttonLabel: 'Devam Et',
      buttonIcon: Icons.arrow_forward_rounded,
      caption:
          'Seçtiğin tema canlı yayın sohbeti ve kampüs akışında anında uygulanır.',
    ),
    (
      leftLabel: 'ADIM 2 / 5',
      rightLabel: 'Kişiselleştirme',
      showPulse: false,
      buttonLabel: 'Devam Et',
      buttonIcon: Icons.arrow_forward_rounded,
      caption: 'Tercihi dilediğin zaman ayarlardan değiştirebilirsin.',
    ),
    (
      leftLabel: 'ADIM 3 / 5',
      rightLabel: 'Kişiselleştirme',
      showPulse: false,
      buttonLabel: 'Devam Et',
      buttonIcon: Icons.arrow_forward_rounded,
      caption: 'Bildirim tercihini profil ayarlarından güncelleyebilirsin.',
    ),
    (
      leftLabel: 'ADIM 4 / 5',
      rightLabel: 'Kişiselleştirme',
      showPulse: false,
      buttonLabel: 'Devam Et',
      buttonIcon: Icons.arrow_forward_rounded,
      caption: 'Görünürlüğünü profil ayarlarından her zaman değiştirebilirsin.',
    ),
    (
      leftLabel: 'Son Adım',
      rightLabel: 'ADIM 5 / 5',
      showPulse: true,
      buttonLabel: 'Bitir ve Keşfetmeye Başla',
      buttonIcon: Icons.rocket_launch_rounded,
      caption:
          'Üniversite tercihini profil ayarlarından her zaman değiştirebilirsin.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<SignupPreferencesController>();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _back() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (_currentPage < _pageCount - 1) {
      _goToPage(_currentPage + 1);
    } else {
      controller.finish();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final SignupPreferencesSizes sizes = Responsive.isTablet(context)
        ? const SignupPreferencesTabletSizes()
        : const SignupPreferencesPhoneSizes();

    final meta = _meta[_currentPage];
    final isLast = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Sabit üst bar (geri + logo + ÜniTV + Atla + avatar) ──
            SignupHeader(sizes: sizes, onBack: _back, onSkip: controller.skip),

            // ── Progress tracker (Adım N / 5 + segmentler) ──────────
            SignupProgressTracker(
              sizes: sizes,
              currentStep: _currentPage,
              totalSteps: _pageCount,
              leftLabel: meta.leftLabel,
              rightLabel: meta.rightLabel,
              showPulse: meta.showPulse,
            ),

            // ── Adımlar ─────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  ThemeStep(
                    sizes: sizes,
                    controller: controller,
                    onSelected: _next, // mevcut davranış korundu
                  ),
                  AutoplayStep(
                    sizes: sizes,
                    controller: controller,
                    onSelected: _next,
                  ),
                  NotificationsStep(
                    sizes: sizes,
                    controller: controller,
                    onSelected: _next,
                  ),
                  VisibilityStep(
                    sizes: sizes,
                    controller: controller,
                    onSelected: _next,
                  ),
                  UniversityStep(sizes: sizes, controller: controller),
                ],
              ),
            ),

            // ── Footer: adım 1-4 düz, adım 5 dock stilinde ──────────
            _StepFooter(
              sizes: sizes,
              meta: meta,
              isLast: isLast,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// FOOTER — Tasarım 1 (Tema): buton + caption / Tasarım 2
// (Üniversite): floating dock (blur yüzey + gölge yukarı)
// ═══════════════════════════════════════════════════════════

class _StepFooter extends StatelessWidget {
  const _StepFooter({
    required this.sizes,
    required this.meta,
    required this.isLast,
    required this.onNext,
  });

  final SignupPreferencesSizes sizes;
  final _StepMeta meta;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    final button = SizedBox(
      height: s.buttonHeight,
      child: ElevatedButton(
        style:
            ElevatedButton.styleFrom(
              backgroundColor: isLast
                  ? scheme.primaryContainer
                  : scheme.primary,
              foregroundColor: isLast
                  ? scheme.onPrimaryContainer
                  : scheme.onPrimary,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  isLast ? s.dockButtonRadius : s.buttonRadius,
                ),
              ),
            ).copyWith(
              elevation: WidgetStateProperty.all(isLast ? 0 : 0),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              // gölge dıştan: isLast → primaryContainer/35
            ),
        onPressed: onNext,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLast) ...[
              Icon(meta.buttonIcon, size: s.rocketIconSize),
              SizedBox(width: s.headerGap),
            ],
            Text(
              meta.buttonLabel,
              style: TextStyle(
                fontSize: s.buttonFontSize,
                fontWeight: FontWeight.w700,
                height: 24 / 18,
                letterSpacing: -0.01 * s.buttonFontSize,
              ),
            ),
            if (!isLast) ...[
              SizedBox(width: s.headerGap),
              Icon(meta.buttonIcon, size: s.buttonIconSize),
            ],
          ],
        ),
      ),
    );

    if (!isLast) {
      // Adım 1-4 — içerik sonundaki "Devam Et" + caption
      return Padding(
        padding: EdgeInsets.fromLTRB(
          s.footerHPadding,
          s.dockVPadding,
          s.footerHPadding,
          s.dockVPadding + 4,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(s.buttonRadius),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: button,
            ),
            SizedBox(height: s.pillBottomGap),
            Text(
              meta.caption,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: s.captionFontSize,
                letterSpacing: 0.01 * s.captionFontSize,
              ),
            ),
          ],
        ),
      );
    }

    // Adım 5 — floating sticky action dock
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.45 : 0.10,
            ),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: s.dockHPadding,
            vertical: s.dockVPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(s.dockButtonRadius),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primaryContainer.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: button,
              ),
              SizedBox(height: s.pillVPadding + 2),
              Text(
                meta.caption,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: s.dockCaptionFontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.04 * s.dockCaptionFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
