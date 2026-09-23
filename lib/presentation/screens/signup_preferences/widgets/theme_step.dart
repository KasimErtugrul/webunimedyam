// lib/presentation/screens/signup_preferences/widgets/theme_step.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_intro_card.dart';
import 'theme_mockups.dart';

/// ADIM 1 — Tema Seçimi (tasarım: "Uygulama Temanı Seç").
/// 3 kart + mini mockup + "Önerilen" rozeti (Koyu Tema).
class ThemeStep extends StatelessWidget {
  const ThemeStep({
    super.key,
    required this.sizes,
    required this.controller,
    required this.onSelected,
  });

  final SignupPreferencesSizes sizes;
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final s = sizes;

    return Obx(() {
      final selected = controller.selectedTheme.value;

      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          s.headerHPadding,
          s.pillVPadding,
          s.headerHPadding,
          s.footerTopGap,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepIntroCard(
              sizes: s,
              icon: Icons.palette_rounded,
              title: 'Uygulama Temanı Seç',
              description:
                  'ÜniTV deneyimini göz zevkine göre özelleştir. Bu tercihi dilediğin zaman Ayarlar menüsünden değiştirebilirsin.',
            ),
            SizedBox(height: s.introBottomGap),

            // Koyu Tema (varsayılan seçili + Önerilen)
            OptionCard(
              sizes: s,
              icon: Icons.dark_mode_rounded,
              title: 'Koyu Tema',
              badgeText: 'Önerilen',
              subtitle: 'Gece dersleri ve OLED ekranlar için ideal derinlik',
              selected: selected == 'dark',
              mockup: ThemeDarkMockup(sizes: s),
              onTap: () {
                controller.chooseTheme('dark');
                onSelected(); // mevcut otomatik ilerleme davranışı
              },
            ),
            SizedBox(height: s.cardGap),

            // Açık Tema
            OptionCard(
              sizes: s,
              icon: Icons.light_mode_rounded,
              title: 'Açık Tema',
              subtitle: 'Güneşli kampüs bahçelerinde net ve berrak okuma',
              selected: selected == 'light',
              mockup: ThemeLightMockup(sizes: s),
              onTap: () {
                controller.chooseTheme('light');
                onSelected();
              },
            ),
            SizedBox(height: s.cardGap),

            // Sistem Teması
            OptionCard(
              sizes: s,
              icon: Icons.brightness_auto_rounded,
              title: 'Sistem Teması',
              subtitle: 'Cihazının gündüz/gece döngüsü ile senkronize kal',
              selected: selected == 'system',
              mockup: ThemeSystemMockup(sizes: s),
              onTap: () {
                controller.chooseTheme('system');
                onSelected();
              },
            ),
          ],
        ),
      );
    });
  }
}