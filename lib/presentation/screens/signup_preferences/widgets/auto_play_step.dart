
// ═══════════════════════════════════════════════════════════════════════
// 2) Otomatik oynatma
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_scaffold.dart';

class AutoplayStep extends StatelessWidget {
  final SignupPreferencesSizes sizes;
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const AutoplayStep({super.key, 
    required this.sizes,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedAutoplay.value;
      return StepScaffold(
        sizes: sizes,
        headerIcon: Icons.play_circle_rounded,
        title: 'Otomatik Oynatma',
        description:
            'Bir video bitince sıradaki video otomatik başlasın mı?',
        options: [
          OptionCard(
            sizes: sizes,
            icon: Icons.play_arrow_rounded,
            title: 'Açık',
            subtitle: 'Sıradaki video otomatik oynatılsın',
            selected: selected == true,
            onTap: () {
              controller.chooseAutoplay(true);
              onSelected();
            },
          ),
          OptionCard(
            sizes: sizes,
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
