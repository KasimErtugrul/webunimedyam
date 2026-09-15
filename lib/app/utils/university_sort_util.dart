// lib/app/utils/university_sort_util.dart

import 'package:flutter/material.dart';

import '../../data/models/university_model.dart';
import 'turkish_alphabet_sort_util.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Sıralama kriterleri — filtreler (tip, radyo) buradan ÇIKARILDI
// ═══════════════════════════════════════════════════════════════════════════

enum SortCriteria {
  name('İsim', Icons.text_fields_rounded),
  city('Şehir', Icons.location_on_rounded),
  foundedYear('Kuruluş Yılı', Icons.calendar_today_rounded),
  subscriberCount('Takipçi', Icons.people_rounded),
  viewCount('Görüntülenme', Icons.visibility_rounded),
  videoCount('İçerik', Icons.play_circle_fill_rounded);

  const SortCriteria(this.label, this.icon);

  final String label;
  final IconData icon;
}

// ═══════════════════════════════════════════════════════════════════════════
// Üniversite tipi filtresi (radio group)
// ═══════════════════════════════════════════════════════════════════════════

enum UniversityTypeFilter {
  all('Tümü', Icons.apps_rounded),
  devlet('Devlet', Icons.account_balance_rounded),
  ozel('Vakıf', Icons.school_rounded),
  kktc('KKTC', Icons.flag_rounded),
  vakifMyo('Vakıf MYO', Icons.school_outlined);

  const UniversityTypeFilter(this.label, this.icon);

  final String label;
  final IconData icon;

  bool get isAll => this == UniversityTypeFilter.all;

  /// DB'deki `university_type` değeriyle eşleşiyor mu?
  bool matches(String? type) {
    if (this == all) return true;
    final t = type?.trim().toLowerCase();
    switch (this) {
      case all:
        return true;
      case devlet:
        return t == 'devlet';
      case ozel:
        return t == 'ozel' || t == 'özel';
      case kktc:
        return t == 'kktc';
      case vakifMyo:
        return t == 'vakif_myo';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Yön
// ═══════════════════════════════════════════════════════════════════════════

enum SortDirection {
  ascending,
  descending;

  bool get isAscending => this == SortDirection.ascending;
  SortDirection get flipped =>
      isAscending ? SortDirection.descending : SortDirection.ascending;
  String get arrow => isAscending ? '↑' : '↓';
}

// ═══════════════════════════════════════════════════════════════════════════
// Tek sıralama: kriter + yön
// ═══════════════════════════════════════════════════════════════════════════

@immutable
class SortOption {
  const SortOption({
    required this.criteria,
    this.direction = SortDirection.descending,
  });

  final SortCriteria criteria;
  final SortDirection direction;

  /// Chip'lerde gösterilecek etiket: "İsim ↑"
  String get label => '${criteria.label} ${direction.arrow}';

  /// Yön olmadan sadece kriter adı: "İsim"
  String get labelOnly => criteria.label;

  IconData get icon => criteria.icon;

  SortOption copyWith({
    SortCriteria? criteria,
    SortDirection? direction,
  }) {
    return SortOption(
      criteria: criteria ?? this.criteria,
      direction: direction ?? this.direction,
    );
  }

  SortOption flipped() => copyWith(direction: direction.flipped);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOption &&
          runtimeType == other.runtimeType &&
          criteria == other.criteria &&
          direction == other.direction;

  @override
  int get hashCode => Object.hash(criteria, direction);

  @override
  String toString() => 'SortOption(${criteria.name}, ${direction.name})';
}

// ═══════════════════════════════════════════════════════════════════════════
// Çoklu sıralama
// ═══════════════════════════════════════════════════════════════════════════

class UniversitySortUtil {
  const UniversitySortUtil._();

  /// Listedeki sıra önceliği belirler:
  /// ilk [SortOption] birincil anahtar, ikincisi tie-breaker, vs.
  ///
  /// Boş `sorts` veya 2'den az elemanlı liste → hiç sıralama yapmaz,
  /// girdiyi olduğu gibi döner (yeni liste yaratmaz).
  static List<UniversityModel> multiSort(
    List<UniversityModel> list,
    List<SortOption> sorts,
  ) {
    if (sorts.isEmpty || list.length < 2) return list;

    final sorted = List<UniversityModel>.of(list);
    sorted.sort((a, b) {
      for (final sort in sorts) {
        final cmp = _compare(a, b, sort.criteria);
        if (cmp != 0) {
          return sort.direction.isAscending ? cmp : -cmp;
        }
      }
      return 0;
    });
    return sorted;
  }

  static int _compare(UniversityModel a, UniversityModel b, SortCriteria c) {
    return switch (c) {
      SortCriteria.name =>
        turkishAlphabetCompare(a.name ?? '', b.name ?? ''),
      SortCriteria.city => (a.city ?? '')
          .toLowerCase()
          .compareTo((b.city ?? '').toLowerCase()),
      SortCriteria.foundedYear =>
        (a.foundedYear ?? 0).compareTo(b.foundedYear ?? 0),
      SortCriteria.subscriberCount =>
        (a.subscriberCount ?? 0).compareTo(b.subscriberCount ?? 0),
      SortCriteria.viewCount =>
        (a.viewCount ?? 0).compareTo(b.viewCount ?? 0),
      SortCriteria.videoCount =>
        (a.videoCount ?? 0).compareTo(b.videoCount ?? 0),
    };
  }
}