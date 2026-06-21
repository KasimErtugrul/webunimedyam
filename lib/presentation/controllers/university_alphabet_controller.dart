// lib/presentation/controllers/university_alphabet_controller.dart

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/utils/turkish_alphabet_sort_util.dart';
import '../../data/models/university_model.dart';

/// Üniversiteler sekmesindeki A-Z hızlı navigasyonunu yönetir.
///
/// İki yönlü senkronizasyon sağlar:
/// 1. Sağdaki harfe dokunulduğunda/sürüklendiğinde liste o harfe kayar.
/// 2. Liste elle kaydırıldığında, o anda görünen üniversitenin harfi
///    otomatik olarak vurgulanır.
///
/// Sidebar artık listenin ÜSTÜNE bindirilmiyor (Stack değil); bu controller
/// sadece kaydırma/konum hesaplarını yönetir, yerleşim widget tarafında
/// ayrı bir sütun olarak yapılır.
class UniversityAlphabetController extends GetxController {
  final ScrollController scrollController = ScrollController();

  /// Şu an vurgulanması gereken harf.
  final currentLetter = ''.obs;

  /// Listede bulunan benzersiz harfler, sırasıyla.
  final availableLetters = <String>[].obs;

  // ignore: unused_field
  List<UniversityModel> _universities = [];
  double _itemExtent = 1;

  /// harf -> bu harfle başlayan ilk üniversitenin index'i.
  final Map<String, int> _letterStartIndex = {};

  /// Index'e göre ikili arama yapabilmek için index sırasına göre dizilmiş hâli.
  List<MapEntry<String, int>> _sections = [];

  bool _programmaticScroll = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onUserScroll);
  }

  /// Liste her değiştiğinde (arama, sıralama, ilk yükleme) çağrılır.
  /// [itemExtent] kart için kullanılan sabit yükseklik (örn. 168.h).
  void setData(List<UniversityModel> universities, double itemExtent) {
    try {
      _universities = universities;
      _itemExtent = itemExtent <= 0 ? 1 : itemExtent;

      _letterStartIndex.clear();
      final letters = <String>[];
      for (var i = 0; i < universities.length; i++) {
        final letter = getTurkishInitialTag(universities[i].name);
        if (!_letterStartIndex.containsKey(letter)) {
          _letterStartIndex[letter] = i;
          letters.add(letter);
        }
      }
      _sections = _letterStartIndex.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      availableLetters.value = letters;

      if (letters.isEmpty) {
        currentLetter.value = '';
      } else if (!letters.contains(currentLetter.value)) {
        currentLetter.value = letters.first;
      }
    } catch (e, stacktrace) {
      log(
        'Üniversite alfabe verileri ayarlanırken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  void _onUserScroll() {
    try {
      if (_programmaticScroll || _sections.isEmpty) return;
      final approxIndex = (scrollController.offset / _itemExtent).round();
      final letter = _letterForIndex(approxIndex);
      if (letter != null && letter != currentLetter.value) {
        currentLetter.value = letter;
      }
    } catch (e, stacktrace) {
      log(
        'Kullanıcı kaydırması işlenirken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
    }
  }

  /// [index]'in ait olduğu harf bölümünü bulur (en yakın <= index).
  String? _letterForIndex(int index) {
    try {
      String? found;
      for (final entry in _sections) {
        if (entry.value <= index) {
          found = entry.key;
        } else {
          break;
        }
      }
      return found ?? (_sections.isNotEmpty ? _sections.first.key : null);
    } catch (e, stacktrace) {
      log(
        'Index için harf bulunurken hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      return null;
    }
  }

  /// Sidebar'da bir harfe dokunulduğunda: listeyi yumuşak şekilde kaydır.
  void jumpToLetter(String letter) {
    _scrollToLetter(letter, animated: true);
  }

  /// Sidebar üzerinde parmak sürüklenirken: anında (animasyonsuz) kaydır.
  void dragToLetter(String letter) {
    _scrollToLetter(letter, animated: false);
  }

  void _scrollToLetter(String letter, {required bool animated}) {
    try {
      final index = _letterStartIndex[letter];
      if (index == null || !scrollController.hasClients) return;

      currentLetter.value = letter;
      _programmaticScroll = true;

      final maxExtent = scrollController.position.maxScrollExtent;
      final target = (index * _itemExtent).clamp(0.0, maxExtent);

      if (animated) {
        scrollController
            .animateTo(
              target,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
            )
            .whenComplete(() => _programmaticScroll = false);
      } else {
        scrollController.jumpTo(target);
        _programmaticScroll = false;
      }
    } catch (e, stacktrace) {
      log(
        'Harfe kaydırma işlemi sırasında hata oluştu: $e',
        error: e,
        stackTrace: stacktrace,
      );
      _programmaticScroll = false;
    }
  }

  @override
  void onClose() {
    try {
      scrollController.removeListener(_onUserScroll);
      scrollController.dispose();
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
