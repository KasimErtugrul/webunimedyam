// lib/presentation/screens/auth/widgets/register_campus_card.dart

import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/widgets/hover_tap.dart';
import '../register_layout_spec.dart';

/// Akademik Durum — Smart Expandable Card:
/// başlık satırı (ikon + seçim etiketleri + dönen chevron),
/// altında statü chip'leri ve üniversite dropdown'ı.
class RegisterCampusCard extends StatefulWidget {
  const RegisterCampusCard({
    super.key,
    required this.sizes,
    required this.selectedStatus,
    required this.selectedUniversity,
    required this.onStatusChanged,
    required this.onUniversityChanged,
  });

  final RegisterSizes sizes;
  final String selectedStatus;
  final String? selectedUniversity;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String?> onUniversityChanged;

  @override
  State<RegisterCampusCard> createState() => _RegisterCampusCardState();
}

class _RegisterCampusCardState extends State<RegisterCampusCard> {
  // Tasarımda başlangıçta açık (isExpanded = true)
  bool _isExpanded = true;

  static const List<String> _statuses = ['Öğrenci', 'Mezun', 'Ziyaretçi'];

  static const List<({String value, String label})> _universities = [
    (value: 'Boğaziçi Üniversitesi', label: 'Boğaziçi Üniversitesi (BÜTV)'),
    (
      value: 'İstanbul Teknik Üniversitesi',
      label: 'İstanbul Teknik Üniversitesi (İTÜ Medya)',
    ),
    (
      value: 'Orta Doğu Teknik Üniversitesi',
      label: 'Orta Doğu Teknik Üniversitesi (ODTÜ)',
    ),
    (
      value: 'Yıldız Teknik Üniversitesi',
      label: 'Yıldız Teknik Üniversitesi (YTÜ)',
    ),
    (value: 'Ankara Üniversitesi', label: 'Ankara Üniversitesi (İLEF)'),
    (value: 'Ege Üniversitesi', label: 'Ege Üniversitesi (Ege TV Kampüs)'),
    (value: 'Diğer / Kampüs Dışı', label: 'Diğer Üniversite / Liste Dışı'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Akademik Durum',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: s.labelFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02 * s.labelFontSize,
          ),
        ),
        SizedBox(height: s.fieldGroupGap),

        // Kart — rounded-xl bg-surface-container p-4 shadow-sm
        Container(
          padding: EdgeInsets.all(s.campusCardPadding),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(s.campusCardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: AppTheme.isDark(context) ? 0.15 : 0.05,
                ),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Toggle başlığı ───────────────────────────
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(s.campusCardRadius / 2),
                child: Row(
                  children: [
                    // w-9 h-9 rounded-lg bg-surface-container-high
                    Container(
                      width: s.campusIconBoxSize,
                      height: s.campusIconBoxSize,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(
                          s.campusIconBoxRadius,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: s.campusIconSize,
                        color: scheme.primary,
                      ),
                    ),
                    SizedBox(width: s.chipVPadding + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.selectedUniversity ?? 'Üniversiteni Seç',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              // JS: üniversite seçilince text-primary
                              color: widget.selectedUniversity != null
                                  ? scheme.primary
                                  : scheme.onSurface,
                              fontSize: s.campusTitleFontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.01 * s.campusTitleFontSize,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.selectedStatus} Statüsü',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              // JS: seçim yapılana kadar sabit metin,
                              // sonrasında "X Statüsü"
                              color: scheme.outline,
                              fontSize: s.campusSubFontSize,
                              letterSpacing: 0.01 * s.campusSubFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: s.chipVPadding),
                    // Chevron — w-8 h-8 rounded-full, -90° döner
                    AnimatedRotation(
                      turns: _isExpanded ? 0 : -0.25, // -90deg
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Container(
                        width: s.chevronSize,
                        height: s.chevronSize,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.expand_more_rounded,
                          size: s.chevronIconSize,
                          color: scheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Collapsible Content ──────────────────────
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 250),
                sizeCurve: Curves.easeInOut,
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(width: double.infinity),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: s.campusTopGap),

                    // Status Chips — yatay kaydırılabilir
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          for (var i = 0; i < _statuses.length; i++) ...[
                            if (i > 0) SizedBox(width: s.chipSpacing),
                            _StatusChip(
                              sizes: s,
                              label: _statuses[i],
                              icon: switch (_statuses[i]) {
                                'Öğrenci' => Icons.school_rounded,
                                'Mezun' => Icons.workspace_premium_rounded,
                                _ => Icons.person_rounded,
                              },
                              active: widget.selectedStatus == _statuses[i],
                              onTap: () => widget.onStatusChanged(_statuses[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: s.chipVPadding + 2),

                    // University Dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(s.dropdownRadius),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: s.dropdownHPadding,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.selectedUniversity,
                          isExpanded: true,
                          dropdownColor: scheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(s.dropdownRadius),
                          icon: Icon(
                            Icons.unfold_more_rounded,
                            size: s.dropdownIconSize,
                            color: scheme.outline,
                          ),
                          hint: Text(
                            'Üniversite Listenizden Seçin',
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: s.dropdownFontSize,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          items: [
                            for (final uni in _universities)
                              DropdownMenuItem(
                                value: uni.value,
                                child: Text(
                                  uni.label,
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: s.dropdownFontSize,
                                  ),
                                ),
                              ),
                          ],
                          onChanged: widget.onUniversityChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Statü chip'i — aktif: bg-secondary-container/20 text-secondary bold,
/// pasif: bg-surface-container-high text-on-surface-variant.
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.sizes,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final RegisterSizes sizes;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return TapCursor(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: s.chipHPadding,
          vertical: s.chipVPadding,
        ),
        decoration: BoxDecoration(
          color: active
              ? scheme.secondaryContainer.withValues(alpha: 0.20)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: s.chipIconSize,
              color: active ? scheme.secondary : scheme.onSurfaceVariant,
            ),
            SizedBox(width: s.chipGap),
            Text(
              label,
              style: TextStyle(
                color: active ? scheme.secondary : scheme.onSurfaceVariant,
                fontSize: s.chipFontSize,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.02 * s.chipFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
