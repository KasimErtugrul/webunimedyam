// lib/presentation/screens/settings/widgets/settings_privacy_notice.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../settings_layout_spec.dart';

/// "Gizli Profil Aktif" bilgi kutusu (bg-surface-container-high).
/// Sadece gizli profil modunda gösterilir; kararı çağıran taraf verir.
class SettingsPrivacyNotice extends StatelessWidget {
  final SettingsLayoutSpec spec;
  const SettingsPrivacyNotice({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(spec.noticePadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(spec.noticeRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: spec.noticeIconSize,
            color: scheme.primary,
          ),
          SizedBox(width: spec.noticeGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gizli Profil Aktif',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: spec.noticeTitleFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profiliniz gizli modda. Üniversite kulüpleri veya diğer '
                  'öğrenciler sadece izin verdiğiniz aktivitelerinizi '
                  '(yorumlar veya halka açık listeler) görebilir.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: spec.noticeBodyFontSize,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 250.ms);
  }
}