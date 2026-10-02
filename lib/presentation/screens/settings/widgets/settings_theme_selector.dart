// lib/presentation/screens/settings/widgets/settings_theme_selector.dart
import 'package:flutter/material.dart';

import '../../../../core/widgets/hover_tap.dart';
import '../settings_layout_spec.dart';

/// "Tema Seçimi" 3'lü segment kontrolü (Koyu / Açık / Sistem).
/// Seçili sekme: bg-primary-container + on-primary (tasarım birebir).
class SettingsThemeSelector extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final String current; // 'dark' | 'light' | 'system'
  final ValueChanged<String> onChanged;

  const SettingsThemeSelector({
    super.key,
    required this.spec,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(spec.segmentContainerPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(spec.segmentContainerRadius),
      ),
      child: Row(
        children: [
          _tab(context, scheme, 'dark', 'Koyu', Icons.dark_mode_rounded),
          SizedBox(width: spec.segmentContainerPadding),
          _tab(context, scheme, 'light', 'Açık', Icons.light_mode_rounded),
          SizedBox(width: spec.segmentContainerPadding),
          _tab(context, scheme, 'system', 'Sistem', Icons.settings_brightness),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    ColorScheme scheme,
    String value,
    String label,
    IconData icon,
  ) {
    final selected = current == value;
    return Expanded(
      child: TapCursor(
        onTap: () => onChanged(value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: spec.segmentTabPaddingH,
            vertical: spec.segmentTabPaddingV,
          ),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(spec.segmentTabRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: spec.segmentTabIconSize,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                    fontSize: spec.segmentTabFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Ana Sayfa Akış Şekli" pill toggle (Liste / Çark).
/// Seçili: bg-primary + on-primary + shadow-sm (tasarım birebir).
class SettingsFeedModeToggle extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final String current; // 'list' | 'wheel'
  final ValueChanged<String> onChanged;

  const SettingsFeedModeToggle({
    super.key,
    required this.spec,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(spec.feedPillPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _item(context, scheme, 'list', 'Liste', Icons.view_list),
          SizedBox(width: spec.feedGap),
          _item(context, scheme, 'wheel', 'Çark', Icons.view_carousel),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    ColorScheme scheme,
    String value,
    String label,
    IconData icon,
  ) {
    final selected = current == value;
    return TapCursor(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: spec.feedItemPaddingH,
          vertical: spec.feedItemPaddingV,
        ),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: spec.feedItemIconSize,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                fontSize: spec.feedItemFontSize,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
