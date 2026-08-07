// lib/presentation/screens/signup_preferences/signup_preferences_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/responsive.dart';
import '../../../app/themes/app_theme.dart';
import '../../controllers/signup_preferences_controller.dart';
import 'utils/singup_preferences_sizes.dart';
import 'widgets/auto_play_step.dart';
import 'widgets/notifications_step.dart';
import 'widgets/theme_step.dart';
import 'widgets/visibility_step.dart';


// ═══════════════════════════════════════════════════════════
// ANA WIDGET (TEK DALLANMA NOKTASI)
// ═══════════════════════════════════════════════════════════

class SignupPreferencesScreen extends StatefulWidget {
  const SignupPreferencesScreen({super.key});

  @override
  State<SignupPreferencesScreen> createState() =>
      _SignupPreferencesScreenState();
}

class _SignupPreferencesScreenState extends State<SignupPreferencesScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final SignupPreferencesController controller;

  static const int _pageCount = 4;

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
    final SignupPreferencesSizes sizes = Responsive.isTablet(context)
        ? const SignupPreferencesTabletSizes()
        : const SignupPreferencesPhoneSizes();

    return Scaffold(
      backgroundColor: AppTheme.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentPage > 0
                      ? IconButton(
                          onPressed: _back,
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: AppTheme.textSec(context),
                          ),
                          tooltip: 'Geri',
                        )
                      : SizedBox(width: 48.w),
                  TextButton(
                    onPressed: controller.skip,
                    child: Text(
                      'Atla',
                      style: TextStyle(
                        color: AppTheme.textSec(context),
                        fontSize: sizes.skipFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  ThemeStep(
                    sizes: sizes,
                    controller: controller,
                    onSelected: _next,
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
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(sizes.bottomPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageCount,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          sizes.buttonHeight,
                        ),
                      ),
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pageCount - 1 ? 'Bitir' : 'Devam Et',
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

