
// ═══════════════════════════════════════════════════════════════════════
// 1) Tema
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_scaffold.dart';

class ThemeStep extends StatelessWidget {
  final SignupPreferencesSizes sizes;
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const ThemeStep({super.key, 
    required this.sizes,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedTheme.value;
      return StepScaffold(
        sizes: sizes,
        headerIcon: Icons.palette_rounded,
        title: 'Uygulama Teması',
        description:
            'Sana en uygun görünümü seç. İstediğin zaman Ayarlar\'dan değiştirebilirsin.',
        options: [
          OptionCard(
            sizes: sizes,
            icon: Icons.dark_mode_rounded,
            title: 'Koyu',
            subtitle: 'Göz yormayan koyu tema',
            selected: selected == 'dark',
            onTap: () {
              controller.chooseTheme('dark');
              onSelected();
            },
          ),
          OptionCard(
            sizes: sizes,
            icon: Icons.light_mode_rounded,
            title: 'Açık',
            subtitle: 'Aydınlık, klasik görünüm',
            selected: selected == 'light',
            onTap: () {
              controller.chooseTheme('light');
              onSelected();
            },
          ),
          OptionCard(
            sizes: sizes,
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
