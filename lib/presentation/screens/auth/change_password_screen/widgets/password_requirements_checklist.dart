// lib/presentation/screens/auth/widgets/password_requirements_checklist.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/change_password_controller.dart';
import '../change_password_layout_spec.dart';

/// Tasarımdaki 2x2 ölçüt listesi:
///   (•) En az 8 karakter   (•) Büyük harf (A-Z)
///   (•) Rakam (0-9)        (•) Özel sembol (!@#$)
class PasswordRequirementsChecklist extends GetView<ChangePassController> {
  final ChangePasswordLayoutSpec spec;
  const PasswordRequirementsChecklist({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _Requirement(
                  met: controller.hasMinLength.value,
                  label: 'En az 8 karakter',
                  spec: spec,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Requirement(
                  met: controller.hasUppercase.value,
                  label: 'Büyük harf (A-Z)',
                  spec: spec,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _Requirement(
                  met: controller.hasDigit.value,
                  label: 'Rakam (0-9)',
                  spec: spec,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _Requirement(
                  met: controller.hasSpecial.value,
                  label: 'Özel sembol (!@#\$%^&*)',
                  spec: spec,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  final bool met;
  final String label;
  final ChangePasswordLayoutSpec spec;
  const _Requirement({
    required this.met,
    required this.label,
    required this.spec,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 18,
          color: met
              ? Theme.of(context).colorScheme.primary
              : AppTheme.textSec(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: spec.smallFontSize,
              color: met
                  ? AppTheme.textPri(context)
                  : AppTheme.textSec(context),
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
