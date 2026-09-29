// lib/presentation/screens/auth/widgets/register_top_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../register_layout_spec.dart';

/// Geri butonu (w-10 h-10 rounded-full bg-surface-container).
/// Eski "CANLI AĞ" pill'i kaldırıldı.
class RegisterTopBar extends StatelessWidget {
  const RegisterTopBar({super.key, required this.sizes});

  final RegisterSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.topBarVPadding),
      child: Row(
        children: [
          // Geri butonu
          Material(
            color: scheme.surfaceContainer,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: Get.back,
              child: SizedBox(
                width: s.backButtonSize,
                height: s.backButtonSize,
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: s.backButtonIconSize,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
