// lib/presentation/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/onboarding_controller.dart';
import 'utils/sizes.dart';
import 'widgets/onboarding_page.dart';


// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
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

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.play_circle_outline_rounded,
      'title': 'UniTv\'ye Hoş Geldiniz',
      'description':
          'Üniversitelerin resmi video platformu UniTv\'ye hoş geldiniz. Tüm üniversitelerin etkinlik ve içeriklerine buradan ulaşabilirsiniz.',
    },
    {
      'icon': Icons.casino_rounded,
      'title': 'Üniversite Çarkını Çevir',
      'description':
          'Keşfet sekmesindeki üniversite çarkıyla rastgele bir üniversiteyi keşfedin, yeni içeriklerle tanışın. UniTv\'ye özel bu eğlenceli keşif deneyimini kaçırmayın.',
    },
    {
      'icon': Icons.radio_rounded,
      'title': 'Canlı Radyo Dinleyin',
      'description':
          'Uygulamadan ayrılmadan canlı radyo yayınını dinleyin. Video izlerken bile arka planda radyonuzu açık tutabilirsiniz.',
    },
    {
      'icon': Icons.smartphone_rounded,
      'title': 'Shorts ile Hızlı İçerik',
      'description':
          'Kısa ve akıcı Shorts videolarıyla üniversitemizden en güncel anları saniyeler içinde yakalayın.',
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Favorilerinizi Kaydedin',
      'description':
          'Beğendiğiniz videoları favorilerinize ekleyin, istediğiniz zaman kolayca bulun. Ücretsiz hesap oluşturarak kişisel listenizi oluşturun.',
    },
    {
      'icon': Icons.notifications_rounded,
      'title': 'Anında Haberdar Olun',
      'description':
          'Yeni video yüklendiğinde anında bildirim alın. Hiçbir etkinliği ve içeriği kaçırmayın.',
    },
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<OnboardingController>();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    controller.complete();
  }

  Future<void> _goToAuth() async {
    await controller.completeSilently();
    Get.toNamed(AppRoutes.login);
  }

  Future<void> _continueAsGuest() async {
    await _completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    final OnboardingSizes sizes = Responsive.isTablet(context)
        ? const OnboardingTabletSizes()
        : const OnboardingPhoneSizes();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  'Geç',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: sizes.skipFontSize,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPage(
                    sizes: sizes,
                    icon: page['icon'] as IconData,
                    title: page['title'] as String,
                    description: page['description'] as String,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(sizes.bottomPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: sizes.dotsSpacing,
                        ),
                        width: _currentPage == index
                            ? sizes.dotActiveWidth
                            : sizes.dotInactiveWidth,
                        height: sizes.dotHeight,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(context)
                                  .withValues(alpha: 0.3),
                          borderRadius:
                              BorderRadius.circular(sizes.dotBorderRadius),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sizes.dotsBottomSpacing),
                  if (_currentPage == _pages.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            sizes.buttonHeight,
                          ),
                        ),
                        onPressed: _goToAuth,
                        child: Text(
                          'Giriş Yap / Kayıt Ol',
                          style: TextStyle(fontSize: sizes.buttonFontSize),
                        ),
                      ),
                    ),
                    SizedBox(height: sizes.isTablet ? 12 : 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            sizes.buttonHeight,
                          ),
                        ),
                        onPressed: _continueAsGuest,
                        child: Text(
                          'Misafir Olarak Devam Et',
                          style: TextStyle(fontSize: sizes.buttonFontSize),
                        ),
                      ),
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            sizes.buttonHeight,
                          ),
                        ),
                        onPressed: _nextPage,
                        child: Text(
                          'Devam Et',
                          style: TextStyle(fontSize: sizes.buttonFontSize),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
