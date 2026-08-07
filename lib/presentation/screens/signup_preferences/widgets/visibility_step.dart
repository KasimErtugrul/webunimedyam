
// ═══════════════════════════════════════════════════════════════════════
// 4) Profil / Aktivite Görünürlüğü
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/user_settings_model.dart';
import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_scaffold.dart';

class VisibilityStep extends StatelessWidget {
  final SignupPreferencesSizes sizes;
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const VisibilityStep({super.key, 
    required this.sizes,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedVisibility.value;
      return StepScaffold(
        sizes: sizes,
        headerIcon: Icons.visibility_rounded,
        title: 'Profil ve Aktivite Görünürlüğü',
        description:
            'İzleme geçmişin, beğenilerin, favorilerin ve yorumların diğer kullanıcılara açık olsun mu?',
        options: [
          OptionCard(
            sizes: sizes,
            icon: Icons.public_rounded,
            title: VisibilityOption.public.label,
            subtitle: VisibilityOption.public.sublabel,
            selected: selected == VisibilityOption.public,
            onTap: () {
              controller.chooseVisibility(VisibilityOption.public);
              onSelected();
            },
          ),
          OptionCard(
            sizes: sizes,
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