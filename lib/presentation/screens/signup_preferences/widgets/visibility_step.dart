// lib/presentation/screens/signup_preferences/widgets/visibility_step.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/models/user_settings_model.dart';
import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_intro_card.dart';

/// ADIM 4 — Profil / Aktivite Görünürlüğü (kodda var, korundu).
class VisibilityStep extends StatelessWidget {
  const VisibilityStep({
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
      final selected = controller.selectedVisibility.value;

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
              icon: Icons.visibility_rounded,
              title: 'Profil ve Aktivite Görünürlüğü',
              description:
                  'İzleme geçmişin, beğenilerin, favorilerin ve yorumların diğer kullanıcılara açık olsun mu?',
            ),
            SizedBox(height: s.introBottomGap),
            OptionCard(
              sizes: s,
              icon: Icons.public_rounded,
              title: VisibilityOption.public.label,
              subtitle: VisibilityOption.public.sublabel,
              selected: selected == VisibilityOption.public,
              onTap: () {
                controller.chooseVisibility(VisibilityOption.public);
                onSelected();
              },
            ),
            SizedBox(height: s.cardGap),
            OptionCard(
              sizes: s,
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
        ),
      );
    });
  }
}