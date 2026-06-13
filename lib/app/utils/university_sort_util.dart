// lib/app/utils/university_sort_util.dart

import '../../data/models/university_model.dart';

enum SortCriteria {
  name,
  city,
  foundedYear,
  subscriberCount,
  viewCount,
  videoCount,
}

enum SortDirection {
  ascending,
  descending,
}

class UniversitySortUtil {
  /// Üniversite listesini seçilen kriter ve yöne göre sıralar.
  static List<UniversityModel> sort(
    List<UniversityModel> list,
    SortCriteria criteria,
    SortDirection direction,
  ) {
    final sortedList = List<UniversityModel>.from(list);

    sortedList.sort((a, b) {
      int result = 0;
      switch (criteria) {
        case SortCriteria.name:
          result = (a.name ?? '').toLowerCase().compareTo((b.name ?? '').toLowerCase());
          break;
        case SortCriteria.city:
          result = (a.city ?? '').toLowerCase().compareTo((b.city ?? '').toLowerCase());
          break;
        case SortCriteria.foundedYear:
          result = (a.foundedYear ?? 0).compareTo(b.foundedYear ?? 0);
          break;
        case SortCriteria.subscriberCount:
          result = (a.subscriberCount ?? 0).compareTo(b.subscriberCount ?? 0);
          break;
        case SortCriteria.viewCount:
          result = (a.viewCount ?? 0).compareTo(b.viewCount ?? 0);
          break;
        case SortCriteria.videoCount:
          result = (a.videoCount ?? 0).compareTo(b.videoCount ?? 0);
          break;
      }
      return direction == SortDirection.ascending ? result : -result;
    });

    return sortedList;
  }

  /// Sadece radyo kanalı olan üniversiteleri filtreler.
  static List<UniversityModel> filterByRadio(
    List<UniversityModel> list,
    bool hasRadio,
  ) {
    if (!hasRadio) return list;
    return list
        .where((u) => u.radioLink != null && u.radioLink!.isNotEmpty)
        .toList();
  }
}