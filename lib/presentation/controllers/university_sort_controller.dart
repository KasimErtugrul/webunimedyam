// lib/presentation/controllers/university_sort_controller.dart

import 'dart:async';
import 'dart:developer';
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
    try {
      final existingIndex = activeSorts.indexWhere(
        (s) => s.criteria == criteria,
      );
      if (existingIndex != -1) {
        activeSorts.removeAt(existingIndex);
      } else {
        activeSorts.add(
          SortOption(criteria: criteria, direction: SortDirection.descending),
        );
      }
    } catch (e, stacktrace) {
      log(
        'Sıralama ekleme/kaldırma işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void toggleDirection(SortCriteria criteria) {
    try {
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
    } catch (e, stacktrace) {
      log(
        'Sıralama yönü değiştirilirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void removeSort(SortCriteria criteria) {
    try {
      activeSorts.removeWhere((s) => s.criteria == criteria);
    } catch (e, stacktrace) {
      log(
        'Sıralama kaldırılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void clearSorts() {
    try {
      activeSorts.clear();
    } catch (e, stacktrace) {
      log(
        'Sıralamalar temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void updateSearchQuery(String query) {
    try {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 350), () {
        searchQuery.value = query;
      });
    } catch (e, stacktrace) {
      log(
        'Arama sorgusu güncellenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void clearSearch() {
    try {
      _debounce?.cancel();
      searchController.clear();
      searchQuery.value = '';
    } catch (e, stacktrace) {
      log(
        'Arama temizlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void reset() {
    try {
      activeSorts.clear();
      clearSearch();
    } catch (e, stacktrace) {
      log(
        'Sıralama ve arama sıfırlanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  List<UniversityModel> applySortAndFilter(List<UniversityModel> originalList) {
    try {
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
    } catch (e, stacktrace) {
      log(
        'Sıralama ve filtre uygulanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return originalList;
    }
  }

  @override
  void onClose() {
    try {
      _debounce?.cancel();
      searchController.dispose();
    } catch (e, stacktrace) {
      log(
        'Controller kapatılırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
    super.onClose();
  }
}
