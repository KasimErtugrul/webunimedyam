// lib/presentation/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/onboarding_controller.dart';
import 'utils/sizes.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/onboarding_visuals.dart';

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful) — Stitch onboarding tasarımının bire
// bir Flutter karşılığı (5 adım). Tüm renkler AppTheme üzerinden
// geldiği için light & dark tema otomatik desteklenir.
// ═══════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final OnboardingController controller;

  // Tasarımdaki 5 adımın metin içeriği (bire bir)
  static const List<({String title, String description})> _steps = [
    (
      title: 'UniTv\'ye Hoş Geldin',
      description:
          'Türkiye\'nin 219 üniversitesinden videolar, canlı yayınlar ve Shorts\'lar artık tek bir uygulamada. Kampüs hayatının nabzını burada tut.',
    ),
    (
      title: 'İstediğin Üniversiteyi Anında Bul',
      description:
          'A\'dan Z\'ye tüm üniversiteler bir dokunuş uzağında. Ne izleyeceğine karar veremiyorsan çarkı çevir, rastgele bir kampüsü keşfet.',
    ),
    (
      title: 'Hiçbir Şeyi Kaçırma',
      description:
          'Canlı yayınlar başladığında ve takip ettiğin üniversiteler yeni video yüklediğinde anında haberdar ol.',
    ),
    (
      title: 'Takip Et, Favorilere Ekle, Yorum Yap',
      description:
          'Sevdiğin üniversiteleri takip et, videoları favorilerine kaydet, yorumlarla diğer öğrencilerle sohbete katıl.',
    ),
    (
      title: 'Hesabını Oluştur, Deneyimini Kişiselleştir',
      description:
          'Favorilerin, takip listen ve bildirimlerin seni bekliyor. Üstelik arka planda canlı radyo da dinleyebilirsin. Hemen başla.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<OnboardingController>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Tasarım davranışı: "Atla" → son adıma gider (goToSlide(4)),
  // son adımda buton kendini gizler.
  void _skipToLast() {
    _pageController.animateToPage(
      _steps.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openAuth() async {
    await controller.completeSilently();
    // Not: Kayıt ekranı ayrı bir rotaysa AppRoutes.register kullanın;
    // mevcut yapıda giriş/kayıt aynı rotadan açılıyor.
    Get.toNamed(AppRoutes.login);
  }

  Future<void> _continueAsGuest() async {
    await controller.complete();
  }

  Widget _buildVisual(int index, OnboardingSizes sizes) {
    switch (index) {
      case 0:
        return StepWelcomeVisual(sizes: sizes);
      case 1:
        return StepRandomVisual(sizes: sizes);
      case 2:
        return StepNotificationsVisual(sizes: sizes);
      case 3:
        return StepInteractionsVisual(sizes: sizes);
      case 4:
      default:
        return StepAccountVisual(sizes: sizes);
    }
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final OnboardingSizes sizes = Responsive.isTablet(context)
        ? const OnboardingTabletSizes()
        : const OnboardingPhoneSizes();

    final bool isLast = _currentPage == _steps.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _Header(sizes: sizes, skipVisible: !isLast, onSkip: _skipToLast),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    sizes: sizes,
                    index: index,
                    totalCount: _steps.length,
                    title: _steps[index].title,
                    description: _steps[index].description,
                    visual: _buildVisual(index, sizes),
                  );
                },
              ),
            ),
            _Footer(
              sizes: sizes,
              currentPage: _currentPage,
              pageCount: _steps.length,
              onNext: _nextPage,
              onDotTap: _goToPage,
              onRegister: _openAuth,
              onLogin: _openAuth,
              onGuest: _continueAsGuest,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// HEADER — Logo (play_arrow + UniTv) ve "Atla" butonu
// ═══════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header({
    required this.sizes,
    required this.skipVisible,
    required this.onSkip,
  });

  final OnboardingSizes sizes;
  final bool skipVisible;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.headerHPadding,
        vertical: sizes.headerVPadding,
      ),
      child: Row(
        children: [
          // Logo — w-8 h-8 rounded-xl bg-primary/10 border-primary/25
          Container(
            width: sizes.logoSize,
            height: sizes.logoSize,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(sizes.logoRadius),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              color: scheme.primary,
              size: sizes.logoIconSize,
            ),
          ),
          SizedBox(width: sizes.logoGap),
          // UniTv — "Tv" primary renkte
          Text.rich(
            TextSpan(
              text: 'Uni',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: sizes.logoFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.02 * sizes.logoFontSize, // tracking-tight
              ),
              children: [
                TextSpan(
                  text: 'Tv',
                  style: TextStyle(color: scheme.primary),
                ),
              ],
            ),
          ),
          const Spacer(),
          // "Atla" — son adımda opaklık 0 + pointer kapalı (tasarımdaki gibi)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: skipVisible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !skipVisible,
              child: TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurfaceVariant,
                  padding: EdgeInsets.symmetric(
                    horizontal: sizes.pillHPadding,
                    vertical: sizes.pillVPadding,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Atla',
                  style: TextStyle(
                    fontSize: sizes.skipFontSize,
                    fontWeight: FontWeight.w500,
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
// FOOTER — Adım 1-4: dots + "İleri" / Adım 5: Kayıt Ol + Giriş Yap
// ═══════════════════════════════════════════════════════════

class _Footer extends StatelessWidget {
  const _Footer({
    required this.sizes,
    required this.currentPage,
    required this.pageCount,
    required this.onNext,
    required this.onDotTap,
    required this.onRegister,
    required this.onLogin,
    required this.onGuest,
  });

  final OnboardingSizes sizes;
  final int currentPage;
  final int pageCount;
  final VoidCallback onNext;
  final ValueChanged<int> onDotTap;
  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final VoidCallback onGuest;

  bool get _isLast => currentPage == pageCount - 1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        sizes.pageHPadding,
        sizes.footerTopPadding,
        sizes.pageHPadding,
        sizes.footerBottomPadding,
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: Alignment.bottomCenter,
        child: _isLast ? _buildActionStack(context) : _buildNavRow(context),
      ),
    );
  }

  // Adım 1-4 — dots (solda) + İleri butonu (sağda), h-14 satır
  Widget _buildNavRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      key: const ValueKey('onboarding-nav'),
      height: sizes.navRowHeight,
      child: Row(
        children: [
          _Dots(
            sizes: sizes,
            currentPage: currentPage,
            pageCount: pageCount,
            onDotTap: onDotTap,
          ),
          const Spacer(),
          _TapScale(
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 4,
                shadowColor: scheme.primary.withValues(alpha: 0.20),
                padding: EdgeInsets.symmetric(horizontal: sizes.buttonHPadding),
                minimumSize: Size(0, sizes.buttonHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizes.buttonRadius),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'İleri',
                    style: TextStyle(
                      fontSize: sizes.buttonFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: sizes.pillGap + 2),
                  Icon(Icons.arrow_forward_rounded, size: sizes.buttonIconSize),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Adım 5 — Kayıt Ol (primary) + Giriş Yap (surface) + misafir
  Widget _buildActionStack(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      key: const ValueKey('onboarding-actions'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TapScale(
          child: SizedBox(
            height: sizes.buttonHeight,
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                elevation: 4,
                shadowColor: scheme.primary.withValues(alpha: 0.20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizes.buttonRadius),
                ),
              ),
              child: Text(
                'Kayıt Ol',
                style: TextStyle(
                  fontSize: sizes.buttonFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: sizes.buttonsGap),
        _TapScale(
          pressedScale: 0.98,
          child: SizedBox(
            height: sizes.buttonHeight,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.surfaceContainer,
                foregroundColor: scheme.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(sizes.buttonRadius),
                  side: BorderSide(color: onboardingHairline(context)),
                ),
              ),
              child: Text(
                'Giriş Yap',
                style: TextStyle(
                  fontSize: sizes.buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        // Tasarımda yer almıyor; orijinal akıştaki misafir girişi korundu.
        // İstenmezse bu TextButton kaldırılabilir.
        TextButton(
          onPressed: onGuest,
          style: TextButton.styleFrom(foregroundColor: scheme.onSurfaceVariant),
          child: Text(
            'Misafir Olarak Devam Et',
            style: TextStyle(
              fontSize: sizes.skipFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DOTS — aktif: w-6 pill primary, pasif: w-2 surface-highest
// ─────────────────────────────────────────────────────────────
class _Dots extends StatelessWidget {
  const _Dots({
    required this.sizes,
    required this.currentPage,
    required this.pageCount,
    required this.onDotTap,
  });

  final OnboardingSizes sizes;
  final int currentPage;
  final int pageCount;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final active = index == currentPage;
        return GestureDetector(
          onTap: () => onDotTap(index),
          behavior: HitTestBehavior.opaque,
          child: Semantics(
            button: true,
            label: '${index + 1}. Adım',
            child: Padding(
              padding: EdgeInsets.only(
                right: index == pageCount - 1 ? 0 : sizes.dotGap,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                width: active ? sizes.dotActiveWidth : sizes.dotInactiveWidth,
                height: sizes.dotHeight,
                decoration: BoxDecoration(
                  color: active
                      ? scheme.primary
                      : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(sizes.dotHeight),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAP SCALE — tasarımdaki active:scale-95 / active:scale-[0.98]
// ─────────────────────────────────────────────────────────────
class _TapScale extends StatefulWidget {
  const _TapScale({required this.child, this.pressedScale = 0.95});

  final Widget child;
  final double pressedScale;

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    value: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press() => _controller.animateTo(
    widget.pressedScale,
    duration: const Duration(milliseconds: 90),
    curve: Curves.easeOut,
  );

  void _release() => _controller.animateTo(
    1,
    duration: const Duration(milliseconds: 140),
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }
}