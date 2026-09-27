// lib/presentation/screens/home/widgets/tabs/universities_tab/widgets/universities_sort_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../app/utils/university_sort_util.dart';
import '../../../../../controllers/university_sort_controller.dart';
import '../universities_tab_layout_spec.dart';

Future<void> showUniversitiesSortSheet(
  BuildContext context,
  UniversitiesTabLayoutSpec spec,
) {
  final sortController = Get.find<UniversitySortController>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SortSheet(spec: spec, sortController: sortController),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// SHEET
// ═══════════════════════════════════════════════════════════════════════════

class _SortSheet extends StatefulWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversitySortController sortController;

  const _SortSheet({required this.spec, required this.sortController});

  @override
  State<_SortSheet> createState() => _SortSheetState();
}

class _SortSheetState extends State<_SortSheet> {
  bool _typeExpanded = false;

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final sortController = widget.sortController;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppTheme.card(context),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(spec.sheetRadius),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            // Handle
            Container(
              width: spec.sheetHandleW,
              height: spec.sheetHandleH,
              decoration: BoxDecoration(
                color: AppTheme.textSec(context).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(spec.sheetHandleH),
              ),
            ),
            SizedBox(height: 14),

            // Başlık + Sıfırla
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Filtrele & Sırala',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: spec.sheetTitleFontSize,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPri(context),
                      ),
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: sortController.resetSortsAndFilters,
                    icon: Icon(Icons.refresh_rounded, size: 18),
                    label: Text(
                      'Sıfırla',
                      style: TextStyle(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),

            // ─── FİLTRELER ────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding),
              child: const _SectionHeader(title: 'FİLTRELER'),
            ),
            SizedBox(height: 10),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding),
              child: _TypeFilterTile(
                spec: spec,
                sortController: sortController,
                expanded: _typeExpanded,
                onToggle: () => setState(() => _typeExpanded = !_typeExpanded),
              ),
            ),

            SizedBox(height: 8),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding),
              child: _RadioFilterTile(
                spec: spec,
                sortController: sortController,
              ),
            ),

            SizedBox(height: 18),

            // ─── SIRALAMA ─────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spec.sheetHPadding),
              child: const _SectionHeader(title: 'SIRALAMA'),
            ),
            SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                spec.sheetHPadding,
                0,
                spec.sheetHPadding,
                20,
              ),
              itemCount: SortCriteria.values.length,
              itemBuilder: (_, i) {
                final c = SortCriteria.values[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: spec.sheetOptionSpacing),
                  child: _SortOptionTile(
                    spec: spec,
                    criteria: c,
                    sortController: sortController,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Section Header
// ═══════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSec(context),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Üniversite Tipi — expandable radio group
// ═══════════════════════════════════════════════════════════════════════════

class _TypeFilterTile extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversitySortController sortController;
  final bool expanded;
  final VoidCallback onToggle;

  const _TypeFilterTile({
    required this.spec,
    required this.sortController,
    required this.expanded,
    required this.onToggle,
  });

  static const _typeColor = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = sortController.typeFilter.value;
      final isFiltered = !selected.isAll;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header tile (tıklanabilir, expand tetikler) ──
          Material(
            color: isFiltered
                ? _typeColor.withValues(alpha: 0.12)
                : AppTheme.surface(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    Container(
                      width: spec.sheetOptionIconBox,
                      height: spec.sheetOptionIconBox,
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                          spec.sheetOptionIconBoxRadius,
                        ),
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: spec.sheetOptionIconSize,
                        color: _typeColor,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Üniversite Tipi',
                            style: TextStyle(
                              fontSize: spec.sheetOptionFontSize,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPri(context),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            selected.label,
                            style: TextStyle(
                              fontSize: (spec.sheetOptionFontSize - 2),
                              color: isFiltered
                                  ? _typeColor
                                  : AppTheme.textSec(context),
                              fontWeight: isFiltered
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.textSec(context),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Radio group (expand) ──
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            child: expanded
                ? Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Column(
                      children: UniversityTypeFilter.values
                          .map((f) => _TypeRadioRow(
                                spec: spec,
                                filter: f,
                                selected: sortController.typeFilter.value == f,
                                color: _typeColor,
                                onTap: () => sortController.setTypeFilter(f),
                              ))
                          .toList(),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );
    });
  }
}

class _TypeRadioRow extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversityTypeFilter filter;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeRadioRow({
    required this.spec,
    required this.filter,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? color.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            child: Row(
              children: [
                // Radio circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? color
                          : AppTheme.textSec(context)
                              .withValues(alpha: 0.4),
                      width: 1.8,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        )
                      : null,
                ),
                SizedBox(width: 10),
                Icon(
                  filter.icon,
                  size: 16,
                  color: selected
                      ? color
                      : AppTheme.textSec(context),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: spec.sheetOptionFontSize,
                      color: selected
                          ? color
                          : AppTheme.textPri(context),
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Radyo Yayını — switch filtresi
// ═══════════════════════════════════════════════════════════════════════════

class _RadioFilterTile extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final UniversitySortController sortController;

  const _RadioFilterTile({
    required this.spec,
    required this.sortController,
  });

  static const _radioColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final value = sortController.onlyWithRadio.value;

      return Material(
        color: value
            ? _radioColor.withValues(alpha: 0.12)
            : AppTheme.surface(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => sortController.setOnlyWithRadio(!value),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: spec.sheetOptionIconBox,
                  height: spec.sheetOptionIconBox,
                  decoration: BoxDecoration(
                    color: _radioColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      spec.sheetOptionIconBoxRadius,
                    ),
                  ),
                  child: Icon(
                    Icons.radio_rounded,
                    size: spec.sheetOptionIconSize,
                    color: _radioColor,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Radyo Yayını',
                        style: TextStyle(
                          fontSize: spec.sheetOptionFontSize,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPri(context),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        value
                            ? 'Sadece radyosu olanlar'
                            : 'Tüm üniversiteler',
                        style: TextStyle(
                          fontSize: (spec.sheetOptionFontSize - 2),
                          color: value
                              ? _radioColor
                              : AppTheme.textSec(context),
                          fontWeight:
                              value ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: value,
                    onChanged: (v) => sortController.setOnlyWithRadio(v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: _radioColor,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: AppTheme.textSec(context)
                        .withValues(alpha: 0.25),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Sıralama kriter satırı
// ═══════════════════════════════════════════════════════════════════════════

class _SortOptionTile extends StatelessWidget {
  final UniversitiesTabLayoutSpec spec;
  final SortCriteria criteria;
  final UniversitySortController sortController;

  const _SortOptionTile({
    required this.spec,
    required this.criteria,
    required this.sortController,
  });

  String get _title => switch (criteria) {
        SortCriteria.name => 'İsim',
        SortCriteria.city => 'Şehir',
        SortCriteria.foundedYear => 'Kuruluş Yılı',
        SortCriteria.subscriberCount => 'Takipçi Sayısı',
        SortCriteria.viewCount => 'Görüntülenme Sayısı',
        SortCriteria.videoCount => 'İçerik Sayısı',
      };

  IconData get _icon => switch (criteria) {
        SortCriteria.name => Icons.text_fields_rounded,
        SortCriteria.city => Icons.location_on_rounded,
        SortCriteria.foundedYear => Icons.calendar_today_rounded,
        SortCriteria.subscriberCount => Icons.people_rounded,
        SortCriteria.viewCount => Icons.visibility_rounded,
        SortCriteria.videoCount => Icons.play_circle_fill_rounded,
      };

  Color get _color => switch (criteria) {
        SortCriteria.name => const Color(0xFF8B5CF6),
        SortCriteria.city => const Color(0xFF3B82F6),
        SortCriteria.foundedYear => const Color(0xFFF59E0B),
        SortCriteria.subscriberCount => const Color(0xFFEC4899),
        SortCriteria.viewCount => const Color(0xFF06B6D4),
        SortCriteria.videoCount => const Color(0xFF10B981),
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = sortController.activeSorts.any(
        (s) => s.criteria == criteria,
      );
      final sortOption = sortController.activeSorts.firstWhereOrNull(
        (s) => s.criteria == criteria,
      );
      final isAscending =
          sortOption?.direction == SortDirection.ascending;

      return Material(
        color: isActive
            ? _color.withValues(alpha: 0.10)
            : AppTheme.surface(context).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => sortController.addOrRemoveSort(criteria),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: spec.sheetOptionIconBox,
                  height: spec.sheetOptionIconBox,
                  decoration: BoxDecoration(
                    color: _color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      spec.sheetOptionIconBoxRadius,
                    ),
                  ),
                  child: Icon(
                    _icon,
                    size: spec.sheetOptionIconSize,
                    color: _color,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _title,
                    style: TextStyle(
                      fontSize: spec.sheetOptionFontSize,
                      fontWeight:
                          isActive ? FontWeight.w700 : FontWeight.w600,
                      color: isActive
                          ? _color
                          : AppTheme.textPri(context),
                    ),
                  ),
                ),
                if (isActive)
                  IconButton(
                    icon: Icon(
                      isAscending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color: _color,
                      size: 20,
                    ),
                    tooltip: isAscending
                        ? 'Artan → Azalan'
                        : 'Azalan → Artan',
                    onPressed: () =>
                        sortController.toggleDirection(criteria),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? _color : Colors.transparent,
                    border: Border.all(
                      color: isActive
                          ? _color
                          : AppTheme.textSec(context)
                              .withValues(alpha: 0.35),
                      width: 1.8,
                    ),
                  ),
                  child: isActive
                      ? Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}