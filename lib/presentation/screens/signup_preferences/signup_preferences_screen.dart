// lib/presentation/screens/signup_preferences/signup_preferences_screen.dart
//
// Kayıt sonrası (email OTP doğrulaması ya da Google ile ilk giriş sonrası)
// bir kez gösterilen, temel tercihleri toplayan sayfa. Her adımda yapılan
// seçim anında SignupPreferencesController üzerinden hem uygulamaya hem de
// Supabase'e yazılır (bkz. SettingsController._updateSettings).

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/responsive.dart';
import '../../../app/themes/app_theme.dart';
import '../../../data/models/user_settings_model.dart';
import '../../controllers/signup_preferences_controller.dart';

class _PhoneSizes {
  static const double skipFontSize = 14;
  static const double pagePadding = 32;
  static const double iconContainerSize = 96;
  static const double iconSize = 48;
  static const double iconSpacing = 28;
  static const double titleFontSize = 22;
  static const double titleSpacing = 8;
  static const double descriptionFontSize = 15;
  static const double descriptionSpacing = 28;
  static const double optionSpacing = 12;
  static const double optionPadding = 16;
  static const double optionRadius = 14;
  static const double bottomPadding = 32;
  static const double dotsSpacing = 4;
  static const double dotActiveWidth = 24;
  static const double dotInactiveWidth = 8;
  static const double dotHeight = 8;
  static const double dotBorderRadius = 4;
  static const double dotsBottomSpacing = 24;
  static const double buttonHeight = 48;
  static const double buttonFontSize = 16;
}

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
    return Responsive.isTablet(context)
        ? _buildBody(context, isTablet: true)
        : _buildBody(context, isTablet: false);
  }

  Widget _buildBody(BuildContext context, {required bool isTablet}) {
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
                        fontSize: _PhoneSizes.skipFontSize.sp,
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
                  _ThemeStep(controller: controller, onSelected: _next),
                  _AutoplayStep(controller: controller, onSelected: _next),
                  _NotificationsStep(controller: controller, onSelected: _next),
                  _VisibilityStep(controller: controller, onSelected: _next),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(_PhoneSizes.bottomPadding.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageCount,
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          _PhoneSizes.buttonHeight.h,
                        ),
                      ),
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pageCount - 1 ? 'Bitir' : 'Devam Et',
                        style: TextStyle(fontSize: _PhoneSizes.buttonFontSize.sp),
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

// ═══════════════════════════════════════════════════════════════════════
// Ortak "seçilebilir kart" bileşeni
// ═══════════════════════════════════════════════════════════════════════

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_PhoneSizes.optionRadius.r),
      child: Container(
        padding: EdgeInsets.all(_PhoneSizes.optionPadding.w),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.12)
              : AppTheme.card(context),
          borderRadius: BorderRadius.circular(_PhoneSizes.optionRadius.r),
          border: Border.all(
            color: selected
                ? primary
                : AppTheme.textSec(context).withValues(alpha: 0.2),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? primary : AppTheme.textSec(context)),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPri(context),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppTheme.textSec(context),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: primary),
          ],
        ),
      ),
    );
  }
}

class _StepScaffold extends StatelessWidget {
  final IconData headerIcon;
  final String title;
  final String description;
  final List<Widget> options;

  const _StepScaffold({
    required this.headerIcon,
    required this.title,
    required this.description,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_PhoneSizes.pagePadding.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: _PhoneSizes.iconContainerSize.w,
              height: _PhoneSizes.iconContainerSize.h,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                headerIcon,
                color: Theme.of(context).colorScheme.primary,
                size: _PhoneSizes.iconSize.sp,
              ),
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
            ),
          ),
          SizedBox(height: _PhoneSizes.descriptionSpacing.h),
          for (int i = 0; i < options.length; i++) ...[
            if (i > 0) SizedBox(height: _PhoneSizes.optionSpacing.h),
            options[i],
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 1) Tema
// ═══════════════════════════════════════════════════════════════════════

class _ThemeStep extends StatelessWidget {
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const _ThemeStep({required this.controller, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTheme.value;
      return _StepScaffold(
        headerIcon: Icons.palette_rounded,
        title: 'Uygulama Teması',
        description: 'Sana en uygun görünümü seç. İstediğin zaman Ayarlar\'dan değiştirebilirsin.',
        options: [
          _OptionCard(
            icon: Icons.dark_mode_rounded,
            title: 'Koyu',
            subtitle: 'Göz yormayan koyu tema',
            selected: selected == 'dark',
            onTap: () {
              controller.chooseTheme('dark');
              onSelected();
            },
          ),
          _OptionCard(
            icon: Icons.light_mode_rounded,
            title: 'Açık',
            subtitle: 'Aydınlık, klasik görünüm',
            selected: selected == 'light',
            onTap: () {
              controller.chooseTheme('light');
              onSelected();
            },
          ),
          _OptionCard(
            icon: Icons.settings_suggest_rounded,
            title: 'Sistem',
            subtitle: 'Telefonunun ayarını takip et',
            selected: selected == 'system',
            onTap: () {
              controller.chooseTheme('system');
              onSelected();
            },
          ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 2) Otomatik oynatma
// ═══════════════════════════════════════════════════════════════════════

class _AutoplayStep extends StatelessWidget {
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const _AutoplayStep({required this.controller, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedAutoplay.value;
      return _StepScaffold(
        headerIcon: Icons.play_circle_rounded,
        title: 'Otomatik Oynatma',
        description: 'Bir video bitince sıradaki video otomatik başlasın mı?',
        options: [
          _OptionCard(
            icon: Icons.play_arrow_rounded,
            title: 'Açık',
            subtitle: 'Sıradaki video otomatik oynatılsın',
            selected: selected == true,
            onTap: () {
              controller.chooseAutoplay(true);
              onSelected();
            },
          ),
          _OptionCard(
            icon: Icons.pause_rounded,
            title: 'Kapalı',
            subtitle: 'Videoyu ben başlatmak istiyorum',
            selected: selected == false,
            onTap: () {
              controller.chooseAutoplay(false);
              onSelected();
            },
          ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 3) Bildirimler
// ═══════════════════════════════════════════════════════════════════════

class _NotificationsStep extends StatelessWidget {
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const _NotificationsStep({required this.controller, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedNotifications.value;
      final isRequesting = controller.isRequestingNotificationPermission.value;
      return Stack(
        children: [
          _StepScaffold(
            headerIcon: Icons.notifications_active_rounded,
            title: 'Bildirimler',
            description:
                'Yeni video yüklendiğinde haberdar olmak ister misin? '
                'Onaylarsan sistem izin sorusu çıkacak.',
            options: [
              _OptionCard(
                icon: Icons.notifications_rounded,
                title: 'Bildirimleri Aç',
                subtitle: selected == false
                    ? 'İzin verilmedi — istersen tekrar dene'
                    : 'Yeni içerik geldiğinde bildirim al',
                selected: selected == true,
                onTap: isRequesting
                    ? () {}
                    : () async {
                        final granted = await controller.requestNotifications();
                        if (granted) onSelected();
                      },
              ),
            ],
          ),
          if (isRequesting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.05),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// 4) Profil / Aktivite Görünürlüğü
// ═══════════════════════════════════════════════════════════════════════

class _VisibilityStep extends StatelessWidget {
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const _VisibilityStep({required this.controller, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedVisibility.value;
      return _StepScaffold(
        headerIcon: Icons.visibility_rounded,
        title: 'Profil ve Aktivite Görünürlüğü',
        description:
            'İzleme geçmişin, beğenilerin, favorilerin ve yorumların diğer kullanıcılara açık olsun mu?',
        options: [
          _OptionCard(
            icon: Icons.public_rounded,
            title: VisibilityOption.public.label,
            subtitle: VisibilityOption.public.sublabel,
            selected: selected == VisibilityOption.public,
            onTap: () {
              controller.chooseVisibility(VisibilityOption.public);
              onSelected();
            },
          ),
          _OptionCard(
            icon: Icons.lock_rounded,
            title: VisibilityOption.private.label,
            subtitle: VisibilityOption.private.sublabel,
            selected: selected == VisibilityOption.private,
            onTap: () {
              controller.chooseVisibility(VisibilityOption.private);
              onSelected();
            },
          ),
        ],
      );
    });
  }
}
