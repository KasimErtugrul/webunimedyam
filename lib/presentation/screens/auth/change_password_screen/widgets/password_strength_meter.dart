// lib/presentation/screens/auth/widgets/password_strength_meter.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/change_password_controller.dart';
import '../change_password_layout_spec.dart';

/// "Şifre Gücü" satırı + 4 dilimli gösterge.
class PasswordStrengthMeter extends GetView<ChangePassController> {
  final ChangePasswordLayoutSpec spec;
  const PasswordStrengthMeter({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.strength.value;
      final color = colorFor(context, s);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Şifre Gücü',
                style: TextStyle(
                  color: AppTheme.textSec(context),
                  fontSize: spec.smallFontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                controller.strengthLabel,
                style: TextStyle(
                  color: s == 0 ? AppTheme.textPri(context) : color,
                  fontSize: spec.smallFontSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: List.generate(4, (i) {
              final active = i < s;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i == 3 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: active
                        ? color
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ],
      );
    });
  }

  /// Tasarımın Tailwind ölçeğiyle uyumlu güç renkleri (4. dilim = marka).
  static Color colorFor(BuildContext context, int strength) {
    switch (strength) {
      case 4:
        return AppTheme.primaryColor; // #4EDEA3
      case 3:
        return const Color(0xFFA3E635); // lime-400
      case 2:
        return const Color(0xFFFBBF24); // amber-400
      case 1:
        return const Color(0xFFEF4444); // red-500
      default:
        return AppTheme.textSec(context);
    }
  }
}
