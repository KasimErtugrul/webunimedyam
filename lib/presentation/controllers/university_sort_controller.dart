// lib/presentation/controllers/university_sort_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/university_sort_util.dart';
import '../../../data/models/university_model.dart';

class UniversitySortController extends GetxController {
  // Çoklu sıralama listesi
  final activeSorts = <SortOption>[].obs;
  
  // Arama state'leri
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  Timer? _debounce;

  void addOrRemoveSort(SortCriteria criteria) {
    final existingIndex = activeSorts.indexWhere((s) => s.criteria == criteria);
    if (existingIndex != -1) {
      activeSorts.removeAt(existingIndex);
    } else {
      activeSorts.add(SortOption(criteria: criteria, direction: SortDirection.descending));
    }
  }

  void toggleDirection(SortCriteria criteria) {
    final index = activeSorts.indexWhere((s) => s.criteria == criteria);
    if (index != -1) {
      final current = activeSorts[index];
      activeSorts[index] = SortOption(
        criteria: current.criteria,
        direction: current.direction == SortDirection.ascending
            ? SortDirection.descending
            : SortDirection.ascending,
      );
    }
  }

  void removeSort(SortCriteria criteria) {
    activeSorts.removeWhere((s) => s.criteria == criteria);
  }

  void clearSorts() {
    activeSorts.clear();
  }

  void updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      searchQuery.value = query;
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
  }

  void reset() {
    activeSorts.clear();
    clearSearch();
  }

  List<UniversityModel> applySortAndFilter(List<UniversityModel> originalList) {
    var list = originalList;

    // 1. Arama filtresi
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((u) {
        final nameMatch = (u.name ?? '').toLowerCase().contains(query);
        final cityMatch = (u.city ?? '').toLowerCase().contains(query);
        return nameMatch || cityMatch;
      }).toList();
    }

    // 2. Çoklu Sıralama
    list = UniversitySortUtil.multiSort(list, activeSorts);

    return list;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}