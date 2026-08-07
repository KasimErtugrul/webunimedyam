// ─── Ceiling Note ────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../data/models/user_settings_model.dart';
import '../utils/settings_sizes.dart';

class SettingsCeilingNote extends StatelessWidget {
  final SettingsSizes sizes;
  final VisibilityOption profileVisibility;
  const SettingsCeilingNote({
    super.key,
    required this.sizes,
    required this.profileVisibility,
  });

  @override
  Widget build(BuildContext context) {
    if (profileVisibility == VisibilityOption.public) {
      return const SizedBox.shrink();
    }

    final isPrivate = profileVisibility == VisibilityOption.private;
    final color = isPrivate ? Colors.orange : Colors.blue;
    final icon = isPrivate ? Icons.lock_outline : Icons.people_outlined;
    final msg = isPrivate
        ? 'Profil gizli — aktiviteler en fazla "Gizli" yapılabilir.'
        : 'Profil arkadaşlara açık — aktiviteler en fazla "Arkadaşlara açık" yapılabilir.';

    return Container(
      margin: EdgeInsets.fromLTRB(
        sizes.noteMarginLeft,
        sizes.noteMarginTop,
        sizes.noteMarginRight,
        sizes.noteMarginBottom,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: sizes.notePaddingHorizontal,
        vertical: sizes.notePaddingVertical,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(sizes.noteBorderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: sizes.noteBorderWidth,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: sizes.noteIconSize, color: color),
          SizedBox(width: sizes.noteIconSpacing),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: color,
                fontSize: sizes.noteFontSize,
                height: sizes.noteLineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
