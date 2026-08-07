

// ═══════════════════════════════════════════════════════════════════════
// 3) Bildirimler
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import 'option_card.dart';
import 'step_scaffold.dart';

class NotificationsStep extends StatelessWidget {
  final SignupPreferencesSizes sizes;
  final SignupPreferencesController controller;
  final VoidCallback onSelected;

  const NotificationsStep({super.key, 
    required this.sizes,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedNotifications.value;
      final isRequesting = controller.isRequestingNotificationPermission.value;
      return Stack(
        children: [
          StepScaffold(
            sizes: sizes,
            headerIcon: Icons.notifications_active_rounded,
            title: 'Bildirimler',
            description:
                'Yeni video yüklendiğinde haberdar olmak ister misin? '
                'Onaylarsan sistem izin sorusu çıkacak.',
            options: [
              OptionCard(
                sizes: sizes,
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
