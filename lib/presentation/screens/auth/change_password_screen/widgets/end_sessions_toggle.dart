// lib/presentation/screens/auth/widgets/end_sessions_toggle.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../controllers/change_password_controller.dart';
import '../change_password_layout_spec.dart';

/// "Diğer oturumları sonlandır" satırı + Material switch.
class EndSessionsToggle extends GetView<ChangePassController> {
  final ChangePasswordLayoutSpec spec;
  const EndSessionsToggle({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diğer oturumları sonlandır',
                  style: TextStyle(
                    color: AppTheme.textPri(context),
                    fontSize: spec.labelFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tüm diğer mobil ve web oturumları kapatılır',
                  style: TextStyle(
                    color: AppTheme.textSec(context),
                    fontSize: spec.smallFontSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Switch(
            value: controller.endOtherSessions.value,
            onChanged: controller.setEndOtherSessions,
            // Tasarımdaki gibi: yeşil track + beyaz thumb
            thumbColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? Colors.white : null,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? scheme.primary : null,
            ),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
