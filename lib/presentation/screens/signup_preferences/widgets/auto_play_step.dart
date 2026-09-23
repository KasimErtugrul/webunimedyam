// lib/presentation/screens/signup_preferences/widgets/autoplay_step.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_intro_card.dart';

/// ADIM 2 — Otomatik Oynatma (kodda var, tasarımda ayrı ekranı yok
/// → tasarım diliyle aynı yapıya oturtuldu).
class AutoplayStep extends StatelessWidget {
  const AutoplayStep({
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
      final selected = controller.selectedAutoplay.value;

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
              icon: Icons.play_circle_rounded,
              title: 'Otomatik Oynatma',
              description:
                  'Bir video bitince sıradaki video otomatik başlasın mı?',
            ),
            SizedBox(height: s.introBottomGap),
            OptionCard(
              sizes: s,
              icon: Icons.play_arrow_rounded,
              title: 'Açık',
              subtitle: 'Sıradaki video otomatik oynatılsın',
              selected: selected == true,
              onTap: () {
                controller.chooseAutoplay(true);
                onSelected();
              },
            ),
            SizedBox(height: s.cardGap),
            OptionCard(
              sizes: s,
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
        ),
      );
    });
  }
}