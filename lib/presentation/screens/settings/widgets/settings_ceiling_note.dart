// lib/presentation/screens/settings/widgets/settings_ceiling_note.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/models/user_settings_model.dart';
import '../settings_layout_spec.dart';

class SettingsCeilingNote extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final VisibilityOption profileVisibility;

  const SettingsCeilingNote({
    super.key,
    required this.spec,
    required this.profileVisibility,
  });

  @override
  Widget build(BuildContext context) {
    if (profileVisibility == VisibilityOption.public) {
      return const SizedBox.shrink();
    }

    final isPrivate = profileVisibility == VisibilityOption.private;
    final color = isPrivate ? const Color(0xFFF59E0B) : const Color(0xFF3B82F6);
    final icon = isPrivate ? Icons.lock_outline : Icons.people_outlined;
    final msg = isPrivate
        ? 'Profil gizli — aktiviteler en fazla "Gizli" yapılabilir.'
        : 'Profil herkese açık değil — bazı seçenekler kısıtlanabilir.';

    return Container(
      margin: EdgeInsets.symmetric(vertical: spec.noteMarginV.h),
      padding: EdgeInsets.symmetric(
        horizontal: spec.notePaddingH.w,
        vertical: spec.notePaddingV.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(spec.noteRadius.r),
        border: Border.all(
          color: color.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: spec.noteIconSize.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: color,
                fontSize: spec.noteFontSize.sp,
                height: spec.noteLineHeight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1, end: 0);
  }
}