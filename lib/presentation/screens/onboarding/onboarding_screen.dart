import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../../../app/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.play_circle_outline_rounded,
      'title': 'ÇOMÜ TV\'ye Hoş Geldiniz',
      'description':
          'Çanakkale Onsekiz Mart Üniversitesi\'nin resmi video platformuna hoş geldiniz. Üniversitemizin tüm etkinlik ve içeriklerine buradan ulaşabilirsiniz.',
    },
    {
      'icon': Icons.video_library_rounded,
      'title': 'Zengin İçerik',
      'description':
          'Konferanslar, seminerler, mezuniyet törenleri ve daha fazlası. Üniversitemizin ürettiği tüm video içeriklerine tek bir yerden erişin.',
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
    {
      'icon': Icons.people_rounded,
      'title': 'Topluluk',
      'description':
          'Videolara yorum yapın, fikirlerinizi paylaşın. ÇOMÜ ailesinin bir parçası olun.',
    },
  ];

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
    final authRepository = Get.find<AuthRepository>();
    await authRepository.completeOnboarding();
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text(
                  'Geç',
                  style: TextStyle(color: AppTheme.textSecondary),
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
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha:0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            color: AppTheme.primaryColor,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary.withValues(alpha:0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Başla'
                            : 'Devam Et',
                        style: const TextStyle(fontSize: 16),
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