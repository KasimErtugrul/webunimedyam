// lib/presentation/screens/settings/widgets/settings_pickers.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../data/models/user_settings_model.dart';
import '../settings_layout_spec.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ORTAK SHEET İSKELETİ
// ═══════════════════════════════════════════════════════════════════════════

void _showSheet({
  required BuildContext context,
  required SettingsLayoutSpec spec,
  required String title,
  String? subtitle,
  required Widget child,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppTheme.card(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(spec.sheetRadius),
      ),
    ),
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: spec.sheetHandleSpacing),
            Container(
              width: spec.sheetHandleWidth,
              height: spec.sheetHandleHeight,
              decoration: BoxDecoration(
                color: AppTheme.textSec(context).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(spec.sheetHandleHeight),
              ),
            ),
            SizedBox(height: spec.sheetHandleSpacing),
            Text(
              title,
              style: TextStyle(
                fontSize: spec.sheetTitleFontSize,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPri(context),
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: spec.sheetSubtitleFontSize,
                    color: AppTheme.textSec(context),
                  ),
                ),
              ),
            ],
            SizedBox(height: spec.sheetOptionSpacing),
            child,
            SizedBox(height: spec.sheetPaddingBottom),
          ],
        ),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// VARSAYILAN KALİTE PICKER (tasarımdaki "1080p (FHD) ⌄" butonu için)
// ═══════════════════════════════════════════════════════════════════════════

void showSettingsQualityPicker({
  required BuildContext context,
  required SettingsLayoutSpec spec,
  required String current, // model değeri: 'auto' | '360p' | ...
  required ValueChanged<String> onChanged,
}) {
  const options = <(String, String, String)>[
    ('auto', 'Otomatik', 'Bağlantı hızına göre ayarlanır'),
    ('360p', '360p (SD)', 'Düşük veri kullanımı'),
    ('480p', '480p (SD)', 'Düşük veri kullanımı'),
    ('720p', '720p (HD)', 'Dengeli kalite'),
    ('1080p', '1080p (FHD)', 'En yüksek kalite'),
  ];

  _showSheet(
    context: context,
    spec: spec,
    title: 'Varsayılan Kalite',
    subtitle: 'Hücresel ve Wi-Fi için üst sınır',
    child: Column(
      children: [
        for (final (value, label, subtitle) in options) ...[
          _SheetOption(
            spec: spec,
            icon: Icons.hd_rounded,
            color: const Color(0xFF64748B),
            title: label,
            subtitle: subtitle,
            isCurrent: value == current,
            onTap: () {
              Get.back();
              onChanged(value);
            },
          ),
          if (value != options.last.$1) SizedBox(height: 8),
        ],
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// OPSİYON SATIRI
// ═══════════════════════════════════════════════════════════════════════════

class _SheetOption extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isCurrent;
  final bool isEnabled;
  final String? disabledReason;
  final Widget? preview;
  final VoidCallback? onTap;

  const _SheetOption({
    required this.spec,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isCurrent,
    this.isEnabled = true,
    this.disabledReason,
    this.preview,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Material(
          color: isCurrent
              ? color.withValues(alpha: isDark ? 0.18 : 0.10)
              : AppTheme.surface(context).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: spec.sheetOptionIconBoxSize,
                    height: spec.sheetOptionIconBoxSize,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        spec.sheetOptionIconBoxRadius,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: spec.sheetOptionIconSize,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: AppTheme.textPri(context),
                            fontSize: spec.sheetOptionTitleFontSize,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          isEnabled ? subtitle : (disabledReason ?? subtitle),
                          style: TextStyle(
                            color: AppTheme.textSec(context),
                            fontSize: spec.sheetOptionSubtitleFontSize,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (preview != null) ...[
                    SizedBox(width: 12),
                    preview!,
                  ] else if (isCurrent) ...[
                    Icon(Icons.check_circle_rounded, color: color, size: 22),
                  ] else if (!isEnabled) ...[
                    Icon(
                      Icons.lock_outline,
                      color: AppTheme.textSec(context),
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TEMA PICKER
// ═══════════════════════════════════════════════════════════════════════════

void showSettingsThemePicker({
  required BuildContext context,
  required SettingsLayoutSpec spec,
  required String current,
  required ValueChanged<String> onChanged,
}) {
  _showSheet(
    context: context,
    spec: spec,
    title: 'Tema',
    subtitle: 'Uygulama görünümünü seç',
    child: Column(
      children: [
        _themeOption(context, spec, 'system', 'Sistem', current, onChanged),
        SizedBox(height: 8),
        _themeOption(context, spec, 'light', 'Açık', current, onChanged),
        SizedBox(height: 8),
        _themeOption(context, spec, 'dark', 'Koyu', current, onChanged),
      ],
    ),
  );
}

Widget _themeOption(
  BuildContext context,
  SettingsLayoutSpec spec,
  String value,
  String label,
  String current,
  ValueChanged<String> onChanged,
) {
  const colors = {
    'system': (Icons.brightness_auto_rounded, Color(0xFF8B5CF6)),
    'light': (Icons.light_mode_rounded, Color(0xFFF59E0B)),
    'dark': (Icons.dark_mode_rounded, Color(0xFF6366F1)),
  };
  final (icon, color) = colors[value]!;

  return _SheetOption(
    spec: spec,
    icon: icon,
    color: color,
    title: label,
    subtitle: value == 'system'
        ? 'Cihaz ayarını takip et'
        : value == 'light'
        ? 'Her zaman açık tema'
        : 'Her zaman koyu tema',
    isCurrent: value == current,
    preview: _ThemePreview(spec: spec, mode: value),
    onTap: () {
      Get.back();
      onChanged(value);
    },
  );
}

class _ThemePreview extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final String mode;
  const _ThemePreview({required this.spec, required this.mode});

  @override
  Widget build(BuildContext context) {
    const light = Color(0xFFF5F5F5);
    const dark = Color(0xFF1A1A1A);

    Widget swatch(Color color, {bool top = true}) => Container(
      width: 18,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.vertical(
          top: top ? Radius.circular(4) : Radius.zero,
          bottom: top ? Radius.zero : Radius.circular(4),
        ),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
    );

    return SizedBox(
      width: 18,
      height: 28,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          children: [
            if (mode == 'system') ...[
              swatch(light),
              swatch(dark, top: false),
            ] else if (mode == 'light')
              Expanded(child: swatch(light, top: false)),
            if (mode == 'dark') Expanded(child: swatch(dark, top: false)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANA SAYFA LAYOUT PICKER
// ═══════════════════════════════════════════════════════════════════════════

void showSettingsHomeLayoutPicker({
  required BuildContext context,
  required SettingsLayoutSpec spec,
  required String current,
  required ValueChanged<String> onChanged,
}) {
  _showSheet(
    context: context,
    spec: spec,
    title: 'Ana Sayfa Görünümü',
    subtitle: 'Videoların nasıl görüneceğini seç',
    child: Column(
      children: [
        _layoutOption(
          context,
          spec,
          'list',
          'Liste Görünümü',
          'Videolar alt alta listelenir',
          Icons.view_list_rounded,
          const Color(0xFF14B8A6),
          current,
          onChanged,
        ),
        SizedBox(height: 8),
        _layoutOption(
          context,
          spec,
          'wheel',
          'Wheel Görünümü',
          'Videolar çark şeklinde döner',
          Icons.donut_large_rounded,
          const Color(0xFF8B5CF6),
          current,
          onChanged,
        ),
      ],
    ),
  );
}

Widget _layoutOption(
  BuildContext context,
  SettingsLayoutSpec spec,
  String value,
  String title,
  String subtitle,
  IconData icon,
  Color color,
  String current,
  ValueChanged<String> onChanged,
) {
  return _SheetOption(
    spec: spec,
    icon: icon,
    color: color,
    title: title,
    subtitle: subtitle,
    isCurrent: value == current,
    preview: _LayoutPreview(spec: spec, mode: value, color: color),
    onTap: () {
      Get.back();
      onChanged(value);
    },
  );
}

class _LayoutPreview extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final String mode;
  final Color color;
  const _LayoutPreview({
    required this.spec,
    required this.mode,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 28,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.textSec(context).withValues(alpha: 0.15),
          width: 0.6,
        ),
      ),
      child: mode == 'list' ? _listPreview() : _wheelPreview(),
    );
  }

  Widget _listPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < 3; i++) ...[
          if (i > 0) SizedBox(height: 2),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4 + i * 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ],
    );
  }

  Widget _wheelPreview() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          left: 2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GÖRÜNÜRLÜK PICKER
// ═══════════════════════════════════════════════════════════════════════════

Future<void> showSettingsVisibilitySheet({
  required BuildContext context,
  required SettingsLayoutSpec spec,
  required String title,
  required String subtitle,
  required VisibilityOption current,
  required VisibilityOption? ceiling,
  required Future<void> Function(VisibilityOption) onChanged,
}) async {
  const order = [VisibilityOption.private, VisibilityOption.public];

  bool isAllowed(VisibilityOption option) {
    if (ceiling == null) return true;
    return order.indexOf(option) <= order.indexOf(ceiling);
  }

  _showSheet(
    context: context,
    spec: spec,
    title: title,
    subtitle: subtitle,
    child: Column(
      children: [
        for (final option in VisibilityOption.values) ...[
          _visibilityOption(
            context: context,
            spec: spec,
            option: option,
            isCurrent: option == current,
            isAllowed: isAllowed(option),
            ceiling: ceiling,
            onTap: () async {
              if (!isAllowed(option)) return;
              Get.back();
              await onChanged(option);
            },
          ),
          if (option != VisibilityOption.values.last) SizedBox(height: 8),
        ],
      ],
    ),
  );
}

Widget _visibilityOption({
  required BuildContext context,
  required SettingsLayoutSpec spec,
  required VisibilityOption option,
  required bool isCurrent,
  required bool isAllowed,
  required VisibilityOption? ceiling,
  required VoidCallback onTap,
}) {
  final (icon, color) = switch (option) {
    VisibilityOption.public => (Icons.public_rounded, const Color(0xFF10B981)),
    VisibilityOption.private => (Icons.lock_rounded, const Color(0xFFF59E0B)),
  };

  return _SheetOption(
    spec: spec,
    icon: icon,
    color: color,
    title: option.label,
    subtitle: option.sublabel,
    isCurrent: isCurrent,
    isEnabled: isAllowed,
    disabledReason: ceiling != null
        ? 'Profil "${ceiling.label}" olduğu için seçilemiyor'
        : null,
    onTap: onTap,
  );
}