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

  /// Üniversite tipi filtresi (radio group).
  final typeFilter = UniversityTypeFilter.all.obs;

  /// Sadece radyo yayını olan üniversiteleri göster (switch).
  final onlyWithRadio = false.obs;

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

  // ─── Filtreler ────────────────────────────────────────────────────────────

  void setTypeFilter(UniversityTypeFilter filter) {
    typeFilter.value = filter;
  }

  void clearTypeFilter() {
    typeFilter.value = UniversityTypeFilter.all;
  }

  void setOnlyWithRadio(bool value) {
    onlyWithRadio.value = value;
  }

  void toggleOnlyWithRadio() {
    onlyWithRadio.value = !onlyWithRadio.value;
  }

  void clearOnlyWithRadio() {
    onlyWithRadio.value = false;
  }

  /// En az bir filtre aktif mi?
  bool get hasActiveFilters =>
      !typeFilter.value.isAll || onlyWithRadio.value;

  /// Aktif filtre sayısı — hero badge gibi yerlerde kullanılabilir.
  int get activeFilterCount {
    var n = 0;
    if (!typeFilter.value.isAll) n++;
    if (onlyWithRadio.value) n++;
    return n;
  }

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

  /// Sadece sıralamayı sıfırlar.
  void resetSorts() => clearSorts();

  /// Sadece filtreleri sıfırlar (tip + radyo).
  void resetFilters() {
    clearTypeFilter();
    clearOnlyWithRadio();
  }

  /// Sıralama + filtreleri sıfırlar. Sheet'teki "Sıfırla" butonu için.
  void resetSortsAndFilters() {
    clearSorts();
    resetFilters();
  }

  /// Sıralama + filtre + arama hepsini sıfırlar. Boş durum ekranı için.
  void resetAll() {
    resetSortsAndFilters();
    clearSearch();
  }

  // ─── Uygulama ─────────────────────────────────────────────────────────────

  /// Filtreleri (tip + radyo) + arama + sıralamayı uygular.
  /// Hiçbir filtre/sıralama yoksa liste aynı referansla döner.
  List<UniversityModel> applySortAndFilter(
    List<UniversityModel> originalList,
  ) {
    var list = originalList;

    // 1) Üniversite tipi filtresi
    final tf = typeFilter.value;
    if (!tf.isAll) {
      list = list.where((u) => tf.matches(u.universityType)).toList();
    }

    // 2) Radyo filtresi
    if (onlyWithRadio.value) {
      list = list.where((u) => u.radioLink?.isNotEmpty == true).toList();
    }

    // 3) Arama
    final q = searchQuery.value;
    if (q.isNotEmpty) {
      final needle = q.toLowerCase();
      list = list.where((u) {
        final name = (u.name ?? '').toLowerCase();
        final city = (u.city ?? '').toLowerCase();
        return name.contains(needle) || city.contains(needle);
      }).toList();
    }

    // 4) Sıralama
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