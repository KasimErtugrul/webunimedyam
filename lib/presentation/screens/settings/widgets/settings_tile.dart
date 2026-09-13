// lib/presentation/screens/settings/widgets/settings_tiles.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_settings_model.dart';
import '../settings_layout_spec.dart';
import 'settings_pickers.dart';

// ─── Genel Tile ─────────────────────────────────────────────────────────────

class SettingsTile extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.spec,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spec.tilePaddingH.w,
            vertical: spec.tilePaddingV.h,
          ),
          child: Row(
            children: [
              _IconBox(
                spec: spec,
                icon: icon,
                color: iconColor,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor ?? AppTheme.textPri(context),
                        fontSize: spec.tileTitleFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: AppTheme.textSec(context),
                          fontSize: spec.tileSubtitleFontSize.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textSec(context).withValues(alpha: 0.5),
                    size: spec.tileTrailingIconSize.sp,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Switch Tile ────────────────────────────────────────────────────────────

class SettingsSwitchTile extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.spec,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      spec: spec,
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      onTap: () => onChanged(!value),
      trailing: Transform.scale(
        scale: 0.9,
        child: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppTheme.primaryColor,
          activeThumbColor: Colors.white,
        ),
      ),
    );
  }
}

// ─── Visibility Tile ────────────────────────────────────────────────────────

class SettingsVisibilityTile extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VisibilityOption current;
  final VisibilityOption? ceiling;
  final Future<void> Function(VisibilityOption) onChanged;

  const SettingsVisibilityTile({
    super.key,
    required this.spec,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.current,
    required this.ceiling,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      spec: spec,
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      onTap: () => showSettingsVisibilitySheet(
        context: context,
        spec: spec,
        title: title,
        subtitle: subtitle,
        current: current,
        ceiling: ceiling,
        onChanged: onChanged,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _VisibilityBadge(spec: spec, option: current),
          SizedBox(width: 6.w),
          Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textSec(context).withValues(alpha: 0.5),
            size: spec.tileTrailingIconSize.sp,
          ),
        ],
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final VisibilityOption option;
  const _VisibilityBadge({required this.spec, required this.option});

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (option) {
      VisibilityOption.public => (
          Icons.public_outlined,
          const Color(0xFF10B981),
          'Herkese',
        ),
      VisibilityOption.private => (
          Icons.lock_outline,
          const Color(0xFFF59E0B),
          'Gizli',
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spec.visBadgePaddingH.w,
        vertical: spec.visBadgePaddingV.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(spec.visBadgeRadius.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: spec.visBadgeIconSize.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: spec.visBadgeFontSize.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Icon Box ───────────────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData icon;
  final Color color;

  const _IconBox({
    required this.spec,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: spec.tileIconBoxSize.w,
      height: spec.tileIconBoxSize.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(spec.tileIconBoxRadius.r),
      ),
      child: Icon(icon, color: color, size: spec.tileIconSize.sp),
    );
  }
}