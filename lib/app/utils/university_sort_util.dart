// lib/app/utils/university_sort_util.dart

import 'package:flutter/material.dart';
import '../../data/models/university_model.dart';
import 'turkish_alphabet_sort_util.dart';

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

class SortOption {
  final SortCriteria criteria;
  final SortDirection direction;

  SortOption({required this.criteria, required this.direction});

  String get label {
    String name;
    switch (criteria) {
      case SortCriteria.name: name = 'İsim'; break;
      case SortCriteria.city: name = 'Şehir'; break;
      case SortCriteria.foundedYear: name = 'Kuruluş Yılı'; break;
      case SortCriteria.subscriberCount: name = 'Takipçi'; break;
      case SortCriteria.viewCount: name = 'Görüntülenme'; break;
      case SortCriteria.videoCount: name = 'İçerik'; break;
    }
    String dir = direction == SortDirection.ascending ? ' ↑' : ' ↓';
    return name + dir;
  }

  IconData get icon {
    switch (criteria) {
      case SortCriteria.name: return Icons.text_fields_rounded;
      case SortCriteria.city: return Icons.location_on_rounded;
      case SortCriteria.foundedYear: return Icons.calendar_today_rounded;
      case SortCriteria.subscriberCount: return Icons.people_rounded;
      case SortCriteria.viewCount: return Icons.visibility_rounded;
      case SortCriteria.videoCount: return Icons.play_circle_fill_rounded;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortOption && runtimeType == other.runtimeType && criteria == other.criteria;

  @override
  int get hashCode => criteria.hashCode;
}

class UniversitySortUtil {
  /// Çoklu sıralamayı uygular. Listedeki sıra önceliği belirler.
  /// Önce isme göre, sonra görüntülenmeye göre gibi.
  static List<UniversityModel> multiSort(
    List<UniversityModel> list,
    List<SortOption> sorts,
  ) {
    if (sorts.isEmpty) return list;
    
    final sortedList = List<UniversityModel>.from(list);

    sortedList.sort((a, b) {
      int result = 0;
      for (final sort in sorts) {
        result = _compare(a, b, sort.criteria);
        if (result != 0) {
          return sort.direction == SortDirection.ascending ? result : -result;
        }
      }
      return result;
    });

    return sortedList;
  }

  static int _compare(UniversityModel a, UniversityModel b, SortCriteria criteria) {
    switch (criteria) {
      case SortCriteria.name:
        return turkishAlphabetCompare(a.name ?? '', b.name ?? '');
      case SortCriteria.city:
        return (a.city ?? '').toLowerCase().compareTo((b.city ?? '').toLowerCase());
      case SortCriteria.foundedYear:
        return (a.foundedYear ?? 0).compareTo(b.foundedYear ?? 0);
      case SortCriteria.subscriberCount:
        return (a.subscriberCount ?? 0).compareTo(b.subscriberCount ?? 0);
      case SortCriteria.viewCount:
        return (a.viewCount ?? 0).compareTo(b.viewCount ?? 0);
      case SortCriteria.videoCount:
        return (a.videoCount ?? 0).compareTo(b.videoCount ?? 0);
    }
  }
}