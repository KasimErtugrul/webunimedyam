import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';

import '../../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
 final PageController _pageController = PageController();
  int _currentPage = 0;
  late final OnboardingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OnboardingController>();  // ← güvenli
  }

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
    controller.complete();
  }

  @override
  Widget build(BuildContext context) {
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
                    fontSize: 14.sp,
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
                  return Padding(
                    padding: EdgeInsets.all(32.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            color: Theme.of(context).colorScheme.primary,
                            size: 60.sp,
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Text(
                          page['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          page['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: 16.sp,
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
              padding: EdgeInsets.all(32.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme.textSec(
                                  context,
                                ).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Başla'
                            : 'Devam Et',
                        style: TextStyle(fontSize: 16.sp),
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