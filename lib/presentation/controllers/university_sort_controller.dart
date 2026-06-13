// lib/presentation/controllers/university_sort_controller.dart

import 'dart:async'; // ← YENİ: Timer için eklendi
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/university_sort_util.dart';
import '../../../data/models/university_model.dart';

class UniversitySortController extends GetxController {
  final sortCriteria = SortCriteria.name.obs;
  final sortDirection = SortDirection.ascending.obs;
  final hasRadioFilter = false.obs;

  // Arama state'leri
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  // ← YENİ: Debounce (gecikme) timer'ı
  Timer? _debounce;

  void setCriteria(SortCriteria criteria) {
    sortCriteria.value = criteria;
  }

  void setDirection(SortDirection direction) {
    sortDirection.value = direction;
  }

  void toggleRadioFilter() {
    hasRadioFilter.value = !hasRadioFilter.value;
  }

  // ← GÜNCELLENDİ: Debounce mantığı eklendi
  void updateSearchQuery(String query) {
    // Eğer daha önce bekleyen bir timer varsa iptal et (kullanıcı hala yazıyor demektir)
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Kullanıcı yazmayı bıraktıktan 350ms sonra aramayı tetikle
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = query;
    });
  }

  // ← GÜNCELLENDİ: Temizlerken timer'ı da iptal et
  void clearSearch() {
    _debounce?.cancel(); // Bekleyen arama varsa hemen iptal et
    searchController.clear();
    searchQuery.value = '';
  }

  void reset() {
    sortCriteria.value = SortCriteria.name;
    sortDirection.value = SortDirection.ascending;
    hasRadioFilter.value = false;
    clearSearch(); // Sıfırlarken aramayı da temizle
  }

  /// Ana veriyi alıp UI'a hazır hale getirir.
  List<UniversityModel> applySortAndFilter(List<UniversityModel> originalList) {
    var list = originalList;

    // 1. Arama filtresi (Ad veya Şehir içeriyorsa)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((u) {
        final nameMatch = (u.name ?? '').toLowerCase().contains(query);
        final cityMatch = (u.city ?? '').toLowerCase().contains(query);
        return nameMatch || cityMatch;
      }).toList();
    }

    // 2. Radyo filtresi
    list = UniversitySortUtil.filterByRadio(list, hasRadioFilter.value);

    // 3. Sıralama
    list = UniversitySortUtil.sort(
      list,
      sortCriteria.value,
      sortDirection.value,
    );

    return list;
  }

  // ← YENİ: Controller ölürken timer'ı temizle (Memory leak önlemi)
  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
