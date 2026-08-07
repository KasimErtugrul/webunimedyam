
// ─── Visibility Option Row ──────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_settings_model.dart';
import '../utils/settings_sizes.dart';

class SettingsVisibilityOptionRow extends StatelessWidget {
  final SettingsSizes sizes;
  final VisibilityOption option;
  final bool isCurrent;
  final bool isAllowed;
  final VisibilityOption? ceiling;
  final VoidCallback onTap;

  const SettingsVisibilityOptionRow({
    super.key,
    required this.sizes,
    required this.option,
    required this.isCurrent,
    required this.isAllowed,
    required this.ceiling,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (iconData, color) = _iconAndColor(option);
    final dimmed = !isAllowed;

    return Opacity(
      opacity: dimmed ? sizes.disabledOpacity : 1.0,
      child: ListTile(
        enabled: isAllowed,
        onTap: isAllowed ? onTap : null,
        leading: Container(
          width: sizes.sheetOptionLeadingContainerSize,
          height: sizes.sheetOptionLeadingContainerSize,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              sizes.sheetOptionLeadingBorderRadius,
            ),
          ),
          child: Icon(
            iconData,
            color: color,
            size: sizes.sheetOptionLeadingIconSize,
          ),
        ),
        title: Text(
          option.label,
          style: TextStyle(
            color: AppTheme.textPri(context),
            fontSize: sizes.sheetOptionTitleFontSize,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          dimmed
              ? 'Profil "${ceiling!.label}" olduğu için seçilemiyor'
              : option.sublabel,
          style: TextStyle(
            color: AppTheme.textSec(context),
            fontSize: sizes.sheetOptionSubtitleFontSize,
          ),
        ),
        trailing: isCurrent
            ? Icon(
                Icons.check_rounded,
                color: AppTheme.primaryColor,
                size: sizes.sheetOptionTrailingIconSize,
              )
            : dimmed
            ? Icon(
                Icons.lock_outline,
                color: AppTheme.textSec(context),
                size: sizes.sheetOptionTrailingLockSize,
              )
            : null,
      ),
    );
  }

  (IconData, Color) _iconAndColor(VisibilityOption o) {
    switch (o) {
      case VisibilityOption.public:
        return (Icons.public_outlined, Colors.green);
      case VisibilityOption.private:
        return (Icons.lock_outline, Colors.orange);
    }
  }
}
