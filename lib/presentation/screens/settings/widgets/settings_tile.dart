// lib/presentation/screens/settings/widgets/settings_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../settings_layout_spec.dart';

/// Kart içi genel satır: [ikon?] Başlık (+titleIcon)/alt-başlık [trailing?]
class SettingsRow extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData? icon;
  final String title;
  final Widget? titleIcon;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// Satır zemini (ör. Gizli Profil Modu satırı surface-container-high).
  final Color? color;

  const SettingsRow({
    super.key,
    required this.spec,
    required this.title,
    this.icon,
    this.titleIcon,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: color ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spec.rowPaddingH.w,
            vertical: spec.rowPaddingV.h,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: spec.rowIconSize.sp,
                  color: scheme.onSurfaceVariant,
                ),
                SizedBox(width: 12.w),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: spec.rowTitleFontSize.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (titleIcon != null) ...[
                          SizedBox(width: 6.w),
                          titleIcon!,
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: spec.rowGap.h),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: spec.rowSubtitleFontSize.sp,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 12.w),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Switch'li satır — tasarımdaki toggle: ON = primary/on-primary,
/// OFF = surface-variant/on-surface-variant (tema üzerinden).
class SettingsSwitchRow extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData? icon;
  final String title;
  final Widget? titleIcon;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? color;

  const SettingsSwitchRow({
    super.key,
    required this.spec,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.titleIcon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SettingsRow(
      spec: spec,
      icon: icon,
      title: title,
      titleIcon: titleIcon,
      subtitle: subtitle,
      color: color,
      onTap: () => onChanged(!value),
      trailing: Transform.scale(
        scale: spec.switchScale,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.onSurfaceVariant;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.surfaceVariant;
          }),
          trackOutlineColor:
              const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}

/// Aktivite izin durumu butonu:
/// Gizli → surface-container-highest zemin + primary,
/// Herkese Açık → surface-container-low zemin + on-surface-variant.
class SettingsStateButton extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final bool isPrivate;
  final VoidCallback onTap;

  const SettingsStateButton({
    super.key,
    required this.spec,
    required this.isPrivate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = isPrivate ? scheme.primary : scheme.onSurfaceVariant;
    return Material(
      color: isPrivate
          ? scheme.surfaceContainerHighest
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(spec.stateButtonRadius.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(spec.stateButtonRadius.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spec.stateButtonPaddingH.w,
            vertical: spec.stateButtonPaddingV.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                size: spec.stateButtonIconSize.sp,
                color: fg,
              ),
              SizedBox(width: 6.w),
              Text(
                isPrivate ? 'Gizli' : 'Herkese Açık',
                style: TextStyle(
                  color: fg,
                  fontSize: spec.stateButtonFontSize.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "124 MB temizle" rozeti; temizleme sonrası tasarımdaki gibi
/// "Temizlendi (0 KB)" yazar ve primary-container renge flaş yapar.
class SettingsCacheBadge extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final bool cleared;

  const SettingsCacheBadge({
    super.key,
    required this.spec,
    required this.cleared,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spec.cacheBadgePaddingH.w,
        vertical: spec.cacheBadgePaddingV.h,
      ),
      decoration: BoxDecoration(
        color: cleared
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(spec.cacheBadgeRadius.r),
      ),
      child: Text(
        cleared ? 'Temizlendi (0 KB)' : '124 MB temizle',
        style: TextStyle(
          color: cleared ? scheme.onPrimaryContainer : scheme.primary,
          fontSize: spec.cacheBadgeFontSize.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}