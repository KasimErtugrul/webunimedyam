// lib/presentation/screens/onboarding/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/themes/app_theme.dart';
import '../../../core/responsive.dart';
import '../../controllers/onboarding_controller.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Skip button
  static const double skipFontSize = 14;

  // Page content
  static const double pagePadding = 32;
  static const double iconContainerSize = 120;
  static const double iconSize = 60;
  static const double iconSpacing = 40;
  static const double titleFontSize = 24;
  static const double titleSpacing = 16;
  static const double descriptionFontSize = 16;
  static const double descriptionLineHeight = 1.6;

  // Bottom
  static const double bottomPadding = 32;
  static const double dotsSpacing = 4;
  static const double dotActiveWidth = 24;
  static const double dotInactiveWidth = 8;
  static const double dotHeight = 8;
  static const double dotBorderRadius = 4;
  static const double dotsBottomSpacing = 32;
  static const double buttonHeight = 48;
  static const double buttonFontSize = 16;
}

class _TabletSizes {
  // Skip button
  static const double skipFontSize = 16;

  // Page content
  static const double pagePadding = 48;
  static const double iconContainerSize = 160;
  static const double iconSize = 80;
  static const double iconSpacing = 48;
  static const double titleFontSize = 32;
  static const double titleSpacing = 20;
  static const double descriptionFontSize = 20;
  static const double descriptionLineHeight = 1.7;

  // Bottom
  static const double bottomPadding = 40;
  static const double dotsSpacing = 6;
  static const double dotActiveWidth = 32;
  static const double dotInactiveWidth = 10;
  static const double dotHeight = 10;
  static const double dotBorderRadius = 5;
  static const double dotsBottomSpacing = 40;
  static const double buttonHeight = 56;
  static const double buttonFontSize = 18;
}

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

  /// Son sayfada "Giriş Yap / Kayıt Ol" seçildiğinde: onboarding'i
  /// tamamlanmış say (bir daha gösterilmesin), sonra Login ekranına git.
  /// Kullanıcı daha önce kayıtlıysa orada giriş yapıp Home'a; yeni
  /// kullanıcıysa Kayıt Ol'a geçip Signup → OTP → İlgi alanı seçimi →
  /// Home akışını izler.
  Future<void> _goToAuth() async {
    await controller.completeSilently();
    Get.toNamed(AppRoutes.login);
  }

  /// Son sayfada "Misafir Olarak Devam Et" seçildiğinde: mevcut davranış
  /// (onboarding tamamlanır, doğrudan Home'a gidilir).
  Future<void> _continueAsGuest() async {
    await _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
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
                    fontSize: _PhoneSizes.skipFontSize.sp,
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
                  return _OnboardingPagePhone(
                    icon: page['icon'] as IconData,
                    title: page['title'] as String,
                    description: page['description'] as String,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_PhoneSizes.bottomPadding.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: _PhoneSizes.dotsSpacing.w,
                        ),
                        width: _currentPage == index
                            ? _PhoneSizes.dotActiveWidth.w
                            : _PhoneSizes.dotInactiveWidth.w,
                        height: _PhoneSizes.dotHeight.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(
                                  context,
                                ).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            _PhoneSizes.dotBorderRadius.r,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _PhoneSizes.dotsBottomSpacing.h),
                  if (_currentPage == _pages.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            _PhoneSizes.buttonHeight.h,
                          ),
                        ),
                        onPressed: _goToAuth,
                        child: Text(
                          'Giriş Yap / Kayıt Ol',
                          style: TextStyle(
                            fontSize: _PhoneSizes.buttonFontSize.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            _PhoneSizes.buttonHeight.h,
                          ),
                        ),
                        onPressed: _continueAsGuest,
                        child: Text(
                          'Misafir Olarak Devam Et',
                          style: TextStyle(
                            fontSize: _PhoneSizes.buttonFontSize.sp,
                          ),
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
                            _PhoneSizes.buttonHeight.h,
                          ),
                        ),
                        onPressed: _nextPage,
                        child: Text(
                          'Devam Et',
                          style: TextStyle(
                            fontSize: _PhoneSizes.buttonFontSize.sp,
                          ),
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

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
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
                    fontSize: _TabletSizes.skipFontSize,
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
                  return _OnboardingPageTablet(
                    icon: page['icon'] as IconData,
                    title: page['title'] as String,
                    description: page['description'] as String,
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_TabletSizes.bottomPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(
                          horizontal: _TabletSizes.dotsSpacing,
                        ),
                        width: _currentPage == index
                            ? _TabletSizes.dotActiveWidth
                            : _TabletSizes.dotInactiveWidth,
                        height: _TabletSizes.dotHeight,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(
                                  context,
                                ).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            _TabletSizes.dotBorderRadius,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: _TabletSizes.dotsBottomSpacing),
                  if (_currentPage == _pages.length - 1) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            _TabletSizes.buttonHeight,
                          ),
                        ),
                        onPressed: _goToAuth,
                        child: Text(
                          'Giriş Yap / Kayıt Ol',
                          style: TextStyle(
                            fontSize: _TabletSizes.buttonFontSize,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(
                            double.infinity,
                            _TabletSizes.buttonHeight,
                          ),
                        ),
                        onPressed: _continueAsGuest,
                        child: Text(
                          'Misafir Olarak Devam Et',
                          style: TextStyle(
                            fontSize: _TabletSizes.buttonFontSize,
                          ),
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
                            _TabletSizes.buttonHeight,
                          ),
                        ),
                        onPressed: _nextPage,
                        child: Text(
                          'Devam Et',
                          style: TextStyle(
                            fontSize: _TabletSizes.buttonFontSize,
                          ),
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET (PHONE)
// ═══════════════════════════════════════════════════════════════════════

class _OnboardingPagePhone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPagePhone({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_PhoneSizes.pagePadding.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _PhoneSizes.iconContainerSize.w,
            height: _PhoneSizes.iconContainerSize.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: _PhoneSizes.iconSize.sp,
            ),
          ),
          SizedBox(height: _PhoneSizes.iconSpacing.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _PhoneSizes.titleFontSize.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: _PhoneSizes.titleSpacing.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _PhoneSizes.descriptionFontSize.sp,
              height: _PhoneSizes.descriptionLineHeight,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// KURAL 6 — ALT SEVİYE WIDGET (TABLET)
// ═══════════════════════════════════════════════════════════════════════

class _OnboardingPageTablet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingPageTablet({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(_TabletSizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _TabletSizes.iconContainerSize,
            height: _TabletSizes.iconContainerSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: _TabletSizes.iconSize,
            ),
          ),
          SizedBox(height: _TabletSizes.iconSpacing),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPri(context),
              fontSize: _TabletSizes.titleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: _TabletSizes.titleSpacing),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSec(context),
              fontSize: _TabletSizes.descriptionFontSize,
              height: _TabletSizes.descriptionLineHeight,
            ),
          ),
        ],
      ),
    );
  }
}