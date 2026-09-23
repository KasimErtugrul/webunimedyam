// lib/presentation/screens/signup_preferences/widgets/notifications_step.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_intro_card.dart';

/// ADIM 3 — Bildirimler. İzin isteği sırasındaki yarı saydam
/// yükleniyor katmanı (mevcut davranış) aynen korunur.
class NotificationsStep extends StatelessWidget {
  const NotificationsStep({
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
      final selected = controller.selectedNotifications.value;
      final isRequesting =
          controller.isRequestingNotificationPermission.value;

      return Stack(
        children: [
          SingleChildScrollView(
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
                  icon: Icons.notifications_active_rounded,
                  title: 'Bildirimler',
                  description:
                      'Yeni video yüklendiğinde haberdar olmak ister misin? Onaylarsan sistem izin sorusu çıkacak.',
                ),
                SizedBox(height: s.introBottomGap),
                OptionCard(
                  sizes: s,
                  icon: Icons.notifications_rounded,
                  title: 'Bildirimleri Aç',
                  subtitle: selected == false
                      ? 'İzin verilmedi — istersen tekrar dene'
                      : 'Yeni içerik geldiğinde bildirim al',
                  selected: selected == true,
                  onTap: isRequesting
                      ? () {}
                      : () async {
                          final granted =
                              await controller.requestNotifications();
                          if (granted) onSelected();
                        },
                ),
              ],
            ),
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