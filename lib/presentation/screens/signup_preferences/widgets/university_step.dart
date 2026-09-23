// lib/presentation/screens/signup_preferences/widgets/university_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../controllers/signup_preferences_controller.dart';
import '../utils/singup_preferences_sizes.dart';
import '../utils/signup_universities.dart';

/// ADIM 5 — Üniversite Seçimi (TAM LİSTE, fonksiyonel sürüm).
///
/// Tasarım dili Stitch'ten korunur (pill badge, arama alanı, sayaç,
/// 2 kolonlu kart grid'i, glow + check badge, boş durum) ama gerçek
/// kullanım için şu iyileştirmeler yapıldı:
///   • TÜM üniversiteler listelenir (controller.universities — 200+),
///     alfabetik ve Türkçe duyarlı sıralı.
///   • Türkçe normalize arama: "canakkale" → "Çanakkale" bulur.
///   • Şehir filtre çipleri (veriden otomatik türetilir).
///   • "Seçilenler" görünümü — yapılan seçimleri tek bakışta gözden geçirme.
///   • Sabit üst bölge: arama/filtre/sayaç kaydırma sırasında görünür kalır,
///     yalnızca grid kayar (uzun listede kritik UX).
///   • Amblem: emblemUrl varsa network görsel; yoksa renk-hash'li
///     baş harf avatarı — asset bağımlılığı yok.
class UniversityStep extends StatefulWidget {
  const UniversityStep({
    super.key,
    required this.sizes,
    required this.controller,
  });

  final SignupPreferencesSizes sizes;
  final SignupPreferencesController controller;

  @override
  State<UniversityStep> createState() => _UniversityStepState();
}

class _UniversityStepState extends State<UniversityStep> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchFocused = false;

  String? _selectedCity;      // null = tüm şehirler
  bool _onlySelected = false; // "Seçilenler" görünümü

  SignupPreferencesController get _c => widget.controller;
  SignupPreferencesSizes get _s => widget.sizes;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      if (mounted) setState(() => _searchFocused = _searchFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _c.universitySearchQuery.value = '';
    _searchFocus.requestFocus();
  }

  void _resetFilters() {
    _searchController.clear();
    _c.universitySearchQuery.value = '';
    setState(() {
      _selectedCity = null;
      _onlySelected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = _s;

    return Obx(() {
      final all = _c.universities;
      final query = normalizeTr(_c.universitySearchQuery.value.trim());
      final selectedIds = _c.selectedUniversityIds;
      final selectedCount = selectedIds.length;

      // ── Şehir listesi (veriden türetilir) ──────────────────
      final cities = all.map((u) => u.city).toSet().toList()
        ..sort(compareTr);

      // ── Filtreleme ─────────────────────────────────────────
      Iterable<SignupUniversity> filtered = all;
      if (_selectedCity != null) {
        filtered = filtered.where((u) => u.city == _selectedCity);
      }
      if (_onlySelected) {
        filtered = filtered.where((u) => selectedIds.contains(u.id));
      }
      if (query.isNotEmpty) {
        filtered = filtered.where((u) =>
            normalizeTr(u.fullName).contains(query) ||
            normalizeTr(u.shortName).contains(query) ||
            normalizeTr(u.city).contains(query));
      }
      final results = filtered.toList()
        ..sort((a, b) => compareTr(a.fullName, b.fullName));

      final hasActiveFilter =
          query.isNotEmpty || _selectedCity != null || _onlySelected;

      // Kart yüksekliği (grid taşmasını önler)
      final cardExtent = s.uniEmblemSize +
          s.uniCardPadding * 2 +
          s.headerGap +
          s.uniNameFontSize * 1.35 +
          2.h +
          s.uniFullNameFontSize * 2 * 1.25 +
          s.headerGap +
          s.uniTagVPadding * 2 +
          s.uniTagFontSize * 1.5;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ══ SABİT ÜST BÖLGE (kaymaz) ══════════════════════════
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s.headerHPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Kişiselleştirilmiş Akış" pill'i
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s.pillHPadding,
                    vertical: s.pillVPadding,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_rounded,
                          size: s.pillIconSize, color: scheme.secondary),
                      SizedBox(width: s.pillGap),
                      Text(
                        'Kişiselleştirilmiş Akış',
                        style: TextStyle(
                          color: scheme.secondary,
                          fontSize: s.pillFontSize,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.04 * s.pillFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: s.pillBottomGap),
                Text(
                  'Hangi Üniversiteleri Takip Etmek İstersin?',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: s.introTitleFontSize,
                    fontWeight: FontWeight.w800,
                    height: 34 / 26,
                    letterSpacing: -0.025 * s.introTitleFontSize,
                  ),
                ),
                SizedBox(height: s.titleDescGap),
                Text(
                  'İstediğin kadar üniversite seçebilirsin. Hiç seçmeden de devam edebilirsin; seçim zorunlu değildir.',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: s.introDescFontSize,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: s.sectionGap),

          // ── Arama ─────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s.headerHPadding),
            child: SizedBox(
              height: s.searchHeight,
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocus,
                onChanged: (v) => _c.universitySearchQuery.value = v,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchFocus.unfocus(),
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: s.introDescFontSize,
                ),
                cursorColor: scheme.primary,
                decoration: InputDecoration(
                  hintText: 'Üniversite adı veya şehir ara...',
                  hintStyle: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: s.introDescFontSize,
                  ),
                  filled: true,
                  fillColor: _searchFocused
                      ? scheme.surfaceContainerHigh
                      : scheme.surfaceContainer,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: s.searchIconLeft),
                    child: Icon(
                      Icons.search_rounded,
                      size: s.searchIconSize,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  prefixIconConstraints: BoxConstraints(
                    minWidth: s.searchPaddingLeft,
                    minHeight: s.searchIconSize,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.only(right: s.clearRight),
                          icon: Icon(
                            Icons.close_rounded,
                            size: s.clearIconSize,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(s.searchRadius),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(s.searchRadius),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(s.searchRadius),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: s.sectionGap),

          // ── Şehir çipleri (yatay kaydırılabilir) ──────────────
          if (cities.length > 1)
            SizedBox(
              height: s.chipVPadding * 2 + s.pillFontSize * 1.6,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: s.headerHPadding),
                children: [
                  _FilterChip(
                    sizes: s,
                    label: 'Tümü',
                    icon: Icons.public_rounded,
                    active: _selectedCity == null && !_onlySelected,
                    onTap: () => setState(() {
                      _selectedCity = null;
                      _onlySelected = false;
                    }),
                  ),
                  for (final city in cities) ...[
                    SizedBox(width: s.chipSpacing),
                    _FilterChip(
                      sizes: s,
                      label: city,
                      icon: Icons.location_on_outlined,
                      active: _selectedCity == city && !_onlySelected,
                      onTap: () => setState(() {
                        _selectedCity = _selectedCity == city ? null : city;
                        _onlySelected = false;
                      }),
                    ),
                  ],
                ],
              ),
            ),
          if (cities.length > 1) SizedBox(height: s.sectionGap),

          // ── Sayaç + Seçilenler + Seçimi Temizle/Tümünü Seç ────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s.headerHPadding),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: s.counterIconSize,
                  color: selectedCount > 0
                      ? scheme.primary
                      : scheme.onSurfaceVariant,
                ),
                SizedBox(width: s.pillGap),
                Flexible(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: selectedCount > 0
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontSize: s.counterFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.01 * s.counterFontSize,
                    ),
                    child: Text(
                      selectedCount == 0
                          ? 'Üniversite Seçilmedi'
                          : '$selectedCount Üniversite Seçildi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),

                // "Seçilenler (N)" görünüm anahtarı
                if (selectedCount > 0) ...[
                  _FilterChip(
                    sizes: s,
                    label: 'Seçilenler ($selectedCount)',
                    icon: Icons.checklist_rounded,
                    active: _onlySelected,
                    onTap: () =>
                        setState(() => _onlySelected = !_onlySelected),
                  ),
                  SizedBox(width: s.chipSpacing),
                ],

                // Tümünü Seç / Seçimi Temizle
                InkWell(
                  onTap: () {
                    if (selectedCount == 0) {
                      _c.selectAllUniversities();
                    } else {
                      _c.clearUniversitySelection();
                    }
                  },
                  borderRadius: BorderRadius.circular(s.searchRadius),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: s.pillHPadding,
                      vertical: s.pillVPadding,
                    ),
                    child: Text(
                      selectedCount == 0 ? 'Tümünü Seç' : 'Seçimi Temizle',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: s.clearAllFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.02 * s.clearAllFontSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: s.sectionGap),

          // ══ KAYAN BÖLGE: GRID / BOŞ DURUM ═════════════════════
          Expanded(
            child: results.isEmpty
                ? _EmptyState(
                    sizes: s,
                    // Arama/filtre boş mu, "Seçilenler" boş mu?
                    onlySelectedEmpty: _onlySelected && selectedCount == 0,
                    hasFilter: hasActiveFilter,
                    onShowAll: _resetFilters,
                  )
                : GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      s.headerHPadding,
                      0,
                      s.headerHPadding,
                      8.h,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: s.gridGap,
                      mainAxisSpacing: s.gridGap,
                      mainAxisExtent: cardExtent,
                    ),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final uni = results[i];
                      return Obx(() {
                        final isSelected =
                            _c.selectedUniversityIds.contains(uni.id);
                        return UniversityCard(
                          sizes: s,
                          university: uni,
                          selected: isSelected,
                          onTap: () => _c.toggleUniversity(uni.id),
                        );
                      });
                    },
                  ),
          ),
        ],
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════
// FİLTRE ÇİPİ — şehir / Tümü / Seçilenler
// Aktif: bg-secondary-container/20 + text-secondary (tasarım chip'i)
// Pasif: bg-surface-container-high + text-on-surface-variant
// ═══════════════════════════════════════════════════════════

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.sizes,
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final SignupPreferencesSizes sizes;
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return GestureDetector(
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
          border: Border.all(
            color: active
                ? scheme.secondary.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
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

// ═══════════════════════════════════════════════════════════
// ÜNİVERSİTE KARTI — tasarım görseli + baş harf avatarı
// Seçili: surfaceContainer + primary/10 glow + primary check badge
// Seçili değil: surfaceContainerLow + soluk add badge
// ═══════════════════════════════════════════════════════════

class UniversityCard extends StatelessWidget {
  const UniversityCard({
    super.key,
    required this.sizes,
    required this.university,
    required this.selected,
    required this.onTap,
  });

  final SignupPreferencesSizes sizes;
  final SignupUniversity university;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(s.uniCardPadding),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: selected
              ? scheme.surfaceContainer
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(s.uniCardRadius),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // selection-glow — bg-primary/10
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: selected ? 1 : 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(s.uniCardRadius),
                    ),
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UniversityAvatar(
                  sizes: s,
                  university: university,
                  selected: selected,
                ),
                SizedBox(height: s.headerGap),

                Text(
                  university.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: s.uniNameFontSize,
                    fontWeight: FontWeight.w600,
                    height: 24 / 18,
                    letterSpacing: -0.01 * s.uniNameFontSize,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  university.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: s.uniFullNameFontSize,
                    height: 1.25,
                    letterSpacing: 0.01 * s.uniFullNameFontSize,
                  ),
                ),

                const Spacer(),

                Row(
                  children: [
                    _Tag(
                      sizes: s,
                      label: university.city,
                      color: scheme.onSurfaceVariant,
                    ),
                    SizedBox(width: s.uniTagGap),
                    _Tag(
                      sizes: s,
                      label: university.isPrivate ? 'Vakıf' : 'Devlet',
                      color: university.isPrivate
                          ? scheme.tertiaryFixedDim
                          : scheme.secondary,
                    ),
                  ],
                ),
              ],
            ),

            // Badge — top-2.5 right-2.5
            Positioned(
              top: s.uniBadgeOffset,
              right: s.uniBadgeOffset,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: s.uniBadgeSize,
                height: s.uniBadgeSize,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.primary
                      : scheme.surfaceContainerHighest
                          .withValues(alpha: 0.40),
                  shape: BoxShape.circle,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  selected ? Icons.check_rounded : Icons.add_rounded,
                  size: s.uniBadgeIconSize,
                  color: selected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                  weight: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// AMBLEM — emblemUrl varsa network görsel; yoksa id-hash'li
// renkli baş harf avatarı (asset bağımlılığı YOK, 200+ üniversite
// için pratik çözüm).
// ═══════════════════════════════════════════════════════════

class _UniversityAvatar extends StatelessWidget {
  const _UniversityAvatar({
    required this.sizes,
    required this.university,
    required this.selected,
  });

  final SignupPreferencesSizes sizes;
  final SignupUniversity university;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    // Tasarım paletinden türetilmiş 6'lı renk çifti — id'e göre
    // deterministik dağılım, her iki temada da okunur.
    final pairs = [
      (scheme.primary.withValues(alpha: 0.15), scheme.primary),
      (scheme.secondary.withValues(alpha: 0.15), scheme.secondary),
      (scheme.tertiary.withValues(alpha: 0.15), scheme.tertiary),
      (scheme.primaryContainer, scheme.onPrimaryContainer),
      (scheme.secondaryContainer, scheme.onSecondaryContainer),
      (scheme.tertiaryContainer, scheme.onTertiaryContainer),
    ];
    final (bg, fg) =
        pairs[university.id.hashCode.abs() % pairs.length];

    Widget content = Image.network(
      university.emblemUrl!,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _initials(bg, fg),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _initials(bg, fg),
    );

    return Container(
      width: s.uniEmblemSize,
      height: s.uniEmblemSize,
      padding: EdgeInsets.all(s.uniEmblemPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(s.uniEmblemRadius),
      ),
      child: university.emblemUrl != null
          ? ClipRRect(
              borderRadius:
                  BorderRadius.circular(s.uniEmblemRadius / 2),
              child: content,
            )
          : _initials(bg, fg),
    );
  }

  Widget _initials(Color bg, Color fg) {
    return Container(
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        university.avatarLabel,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          color: fg,
          fontSize: sizes.uniEmblemIconSize,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.sizes, required this.label, required this.color});

  final SignupPreferencesSizes sizes;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: s.uniTagHPadding,
        vertical: s.uniTagVPadding,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: s.uniTagFontSize,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.04 * s.uniTagFontSize,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOŞ DURUM — iki varyant: arama/filtre sonucu yok YA DA
// "Seçilenler" görünümü boş (henüz seçim yapılmamış).
// ═══════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.sizes,
    required this.onlySelectedEmpty,
    required this.hasFilter,
    required this.onShowAll,
  });

  final SignupPreferencesSizes sizes;
  final bool onlySelectedEmpty;
  final bool hasFilter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    final title = onlySelectedEmpty
        ? 'Henüz Üniversite Seçmedin'
        : 'Üniversite Bulunamadı';
    final desc = onlySelectedEmpty
        ? 'Listeden üniversite seçerek takip etmeye başla; dilediğin zaman profilden değiştirebilirsin.'
        : 'Farklı bir üniversite adı veya şehir girerek yeniden deneyebilirsin.';
    final icon = onlySelectedEmpty
        ? Icons.bookmark_add_outlined
        : Icons.school_rounded;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s.headerHPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: s.emptyIconBox,
              height: s.emptyIconBox,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: s.emptyIconSize,
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: s.pillBottomGap),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: s.emptyTitleFontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.01 * s.emptyTitleFontSize,
              ),
            ),
            SizedBox(height: s.pillVPadding),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: s.emptyDescMaxWidth),
              child: Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: s.emptyDescFontSize,
                  height: 20 / 14,
                ),
              ),
            ),
            if (hasFilter || onlySelectedEmpty) ...[
              SizedBox(height: s.sectionGap),
              TextButton.icon(
                onPressed: onShowAll,
                icon: Icon(Icons.filter_alt_off_rounded,
                    size: s.counterIconSize),
                label: Text(
                  'Tümünü Göster',
                  style: TextStyle(
                    fontSize: s.clearAllFontSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: scheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}