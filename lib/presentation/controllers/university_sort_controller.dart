// lib/presentation/controllers/university_sort_controller.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/university_sort_util.dart';
import '../../../data/models/university_model.dart';

class UniversitySortController extends GetxController {
  /// Aktif çoklu sıralama listesi. Boşsa "isim sıralaması" varsayılan
  /// davranış olarak kabul edilir (bkz. UniversitiesTabWidget).
  final activeSorts = <SortOption>[].obs;

  /// Arama state'i + metin alanı controller'ı.
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  Timer? _debounce;
  static const _debounceDuration = Duration(milliseconds: 350);

  // ─── Sıralama ─────────────────────────────────────────────────────────────

  void addOrRemoveSort(SortCriteria criteria) {
    final i = activeSorts.indexWhere((s) => s.criteria == criteria);
    if (i != -1) {
      activeSorts.removeAt(i);
    } else {
      activeSorts.add(
        SortOption(
          criteria: criteria,
          direction: SortDirection.descending,
        ),
      );
    }
  }

  void toggleDirection(SortCriteria criteria) {
    final i = activeSorts.indexWhere((s) => s.criteria == criteria);
    if (i == -1) return;

    final current = activeSorts[i];
    activeSorts[i] = current.copyWith(
      direction: current.direction == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending,
    );
  }

  void removeSort(SortCriteria criteria) {
    activeSorts.removeWhere((s) => s.criteria == criteria);
  }

  void clearSorts() => activeSorts.clear();

  // ─── Arama ────────────────────────────────────────────────────────────────

  void updateSearchQuery(String query) {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      searchQuery.value = query.trim();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    searchController.clear();
    searchQuery.value = '';
  }

  // ─── Toplu işlem ──────────────────────────────────────────────────────────

  /// Sıralama kriterlerini sıfırlar. Arama kutusuna dokunmaz —
  /// sort sheet'teki "Sıfırla" butonunun beklenen davranışı budur.
  void resetSorts() => clearSorts();

  /// Hem sıralama hem aramayı sıfırlar. Boş durum ekranındaki
  /// "Temizle" aksiyonu için.
  void resetAll() {
    clearSorts();
    clearSearch();
  }

  // ─── Uygulama ─────────────────────────────────────────────────────────────

  /// Arama filtresi + çoklu sıralama uygular.
  /// Sıralama yoksa sadece filtre uygulanır, liste aynı referansla döner.
  List<UniversityModel> applySortAndFilter(
    List<UniversityModel> originalList,
  ) {
    var list = originalList;

    final q = searchQuery.value;
    if (q.isNotEmpty) {
      final needle = q.toLowerCase();
      list = list.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final city = (u.city ?? '').toLowerCase();
        return name.contains(needle) || city.contains(needle);
      }).toList();
    }

    if (activeSorts.isNotEmpty) {
      list = UniversitySortUtil.multiSort(list, activeSorts);
    }

    return list;
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}