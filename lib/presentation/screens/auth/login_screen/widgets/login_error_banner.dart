// lib/presentation/screens/auth/widgets/login_error_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../controllers/auth/login_controller.dart';
import '../login_layout_spec.dart';

class LoginErrorBanner extends GetView<LoginController> {
  const LoginErrorBanner({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.errorMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();

      final scheme = Theme.of(context).colorScheme;
      final s = sizes;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(s.errorPadding),
        margin: EdgeInsets.only(bottom: s.cardGap),
        decoration: BoxDecoration(
          color: scheme.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(s.errorRadius),
          border: Border.all(color: scheme.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: scheme.error,
                  fontSize: s.errorFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms)
          .slideY(begin: -0.15, end: 0, curve: Curves.easeOut);
    });
  }
}