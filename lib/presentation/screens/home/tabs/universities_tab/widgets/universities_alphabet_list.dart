// lib/presentation/screens/home/tabs/universities_tab/widgets/universities_alphabet_list.dart
//
// Üniversiteler sekmesinin A-Z hızlı indeksli listesi.
// NOT: Artık UniversitiesTabLayoutSpec'e bağımlı DEĞİL — sidebar ölçüleri
// (genişlik, hap, font boyutları) bu dosyadaki phone/tablet sabitlerinden
// gelir. Kart, dışarıdan verilen itemBuilder ile üretilir.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:wheel_slider/wheel_slider.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/university_alphabet_controller.dart';

// ═══════════════════════════════════════════════════════════════════
// ÖLÇÜ SABİTLERİ
// ═══════════════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double sidebarWidth = 26;
  /*   static const double sidebarPill = 22;
  static const double sidebarActiveFontSize = 12;
  static const double sidebarInactiveFontSize = 9;
  static const double sidebarVerticalPadding = 8; */
  static const double listPadHorizontal = 16;

  // Wheel (harf çemberi) ölçüleri.
  static const double wheelItemExtent = 26;
  static const double wheelActiveFontSize = 16;
  static const double wheelNearFontSize = 11;
  static const double wheelFarFontSize = 8;
}

class _TabletSizes {
  static const double sidebarWidth = 34;
  /*   static const double sidebarPill = 28;
  static const double sidebarActiveFontSize = 14;
  static const double sidebarInactiveFontSize = 11;
  static const double sidebarVerticalPadding = 10; */
  static const double listPadHorizontal = 24;

  // Wheel (harf çemberi) ölçüleri.
  static const double wheelItemExtent = 32;
  static const double wheelActiveFontSize = 19;
  static const double wheelNearFontSize = 13;
  static const double wheelFarFontSize = 10;
}

// ═══════════════════════════════════════════════════════════════════
// WIDGET
// ═══════════════════════════════════════════════════════════════════

class UniversitiesAlphabetList extends StatefulWidget {
  final List<UniversityModel> universities;

  /// Bir satırın (kart + alt boşluk) toplam yüksekliği. Controller,
  /// kaydırma konumunu "offset = index * itemExtent" kabulüyle hesapladığı
  /// için bu değer tek ve sabit olmalıdır.
  final double itemExtent;

  /// Kart üreticisi — sekme kendi kart tasarımını buradan enjekte eder.
  final Widget Function(
    BuildContext context,
    int index,
    UniversityModel university,
  )
  itemBuilder;

  const UniversitiesAlphabetList({
    super.key,
    required this.universities,
    required this.itemExtent,
    required this.itemBuilder,
  });

  @override
  State<UniversitiesAlphabetList> createState() =>
      _UniversitiesAlphabetListState();
}

class _UniversitiesAlphabetListState extends State<UniversitiesAlphabetList> {
  static const _tag = 'uni_alpha_list';
  late final UniversityAlphabetController _controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<UniversityAlphabetController>(tag: _tag)) {
      Get.put(UniversityAlphabetController(), tag: _tag);
    }
    _controller = Get.find<UniversityAlphabetController>(tag: _tag);
    _controller.setData(widget.universities, widget.itemExtent);
  }

  @override
  void didUpdateWidget(covariant UniversitiesAlphabetList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.universities, widget.universities) ||
        oldWidget.itemExtent != widget.itemExtent) {
      _controller.setData(widget.universities, widget.itemExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final hPad = isTablet
        ? _TabletSizes.listPadHorizontal
        : _PhoneSizes.listPadHorizontal.w;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            controller: _controller.scrollController,
            // RefreshIndicator kısa listelerde de çalışabilsin.
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            // DİKKAT: padding sıfır kalmalı — controller, offset → index
            // dönüşümünü "offset = index * itemExtent" kabulüyle yapıyor.
            padding: EdgeInsets.zero,
            itemExtent: widget.itemExtent,
            itemCount: widget.universities.length,
            itemBuilder: (context, i) => Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: widget.itemBuilder(context, i, widget.universities[i]),
            ),
          ),
        ),
        Obx(() {
          final letters = _controller.availableLetters;
          if (letters.isEmpty) return const SizedBox.shrink();
          return _AlphabetWheelSidebar(
            letters: letters,
            currentLetter: _controller.currentLetter.value,
            onLetterSettled: _controller.dragToLetter,
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SAĞ A-Z ÇEMBERİ (wheel_slider)
// ═══════════════════════════════════════════════════════════════════
//
// Artık tüm harfler sabit boyutta dizilmiyor: seçili harf ortada büyük,
// ondan uzaklaşan harfler hem font küçülerek hem de paketin doğal 3B
// perspektif eğriliğiyle (perspective) küçülüp sönükleşerek gösteriliyor.
// Kullanıcı çemberi kaydırdıkça (veya listeyi kaydırıp harfi
// değiştirdikçe) alttaki üniversite listesiyle iki yönlü senkron kalır.

class _AlphabetWheelSidebar extends StatefulWidget {
  final List<String> letters;
  final String currentLetter;

  /// Çemberdeki harf değiştiğinde (kaydırma/dokunma sonucu) çağrılır;
  /// alttaki üniversite listesini o harfe taşımak için kullanılır.
  final ValueChanged<String> onLetterSettled;

  const _AlphabetWheelSidebar({
    required this.letters,
    required this.currentLetter,
    required this.onLetterSettled,
  });

  @override
  State<_AlphabetWheelSidebar> createState() => _AlphabetWheelSidebarState();
}

class _AlphabetWheelSidebarState extends State<_AlphabetWheelSidebar> {
  FixedExtentScrollController? _wheelController;
  int _selectedIndex = 0;

  // Liste kaydırılınca dışarıdan tetiklenen programatik çember hareketi
  // sırasında onValueChanged'in listeyi tekrar tetiklemesini (döngü) engeller.
  bool _externalSync = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _indexOf(widget.currentLetter);
    _wheelController = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  int _indexOf(String letter) {
    final i = widget.letters.indexOf(letter);
    if (i != -1) return i;
    return 0;
  }

  @override
  void didUpdateWidget(covariant _AlphabetWheelSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Harf listesi değiştiyse (arama/filtre) controller'ı sıfırdan kur.
    if (!identical(oldWidget.letters, widget.letters)) {
      final newIndex = _indexOf(widget.currentLetter);
      _wheelController?.dispose();
      _wheelController = FixedExtentScrollController(initialItem: newIndex);
      setState(() => _selectedIndex = newIndex);
      return;
    }

    // Harf, üniversite listesinin kendi kaydırmasıyla değiştiyse
    // (yani bizim onValueChanged'imizden gelmiyorsa) çemberi de oraya taşı.
    if (oldWidget.currentLetter != widget.currentLetter) {
      final newIndex = _indexOf(widget.currentLetter);
      if (newIndex != _selectedIndex) {
        _externalSync = true;
        final controller = _wheelController;
        if (controller != null && controller.hasClients) {
          controller
              .animateToItem(
                newIndex,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
              )
              .whenComplete(() => _externalSync = false);
        } else {
          _externalSync = false;
        }
        setState(() => _selectedIndex = newIndex);
      }
    }
  }

  void _handleValueChanged(dynamic value) {
    final index = (value as num).round().clamp(0, widget.letters.length - 1);
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (_externalSync) return;
    widget.onLetterSettled(widget.letters[index]);
  }

  @override
  void dispose() {
    _wheelController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final width = isTablet
        ? _TabletSizes.sidebarWidth
        : _PhoneSizes.sidebarWidth.w;
    final itemExtent = isTablet
        ? _TabletSizes.wheelItemExtent
        : _PhoneSizes.wheelItemExtent.h;
    final activeFont = isTablet
        ? _TabletSizes.wheelActiveFontSize
        : _PhoneSizes.wheelActiveFontSize.sp;
    final nearFont = isTablet
        ? _TabletSizes.wheelNearFontSize
        : _PhoneSizes.wheelNearFontSize.sp;
    final farFont = isTablet
        ? _TabletSizes.wheelFarFontSize
        : _PhoneSizes.wheelFarFontSize.sp;

    return LayoutBuilder(
      builder: (context, c) {
        final height = c.maxHeight > 0 ? c.maxHeight : 300.0;
        final letters = widget.letters;

        return Container(
          width: width,
          height: height,
          color: const Color.fromARGB(82, 100, 100, 100),
          child: WheelSlider.customWidget(
            key: ValueKey(letters.length),
            controller: _wheelController,
            totalCount: letters.length,
            initValue: _selectedIndex,
            itemSize: itemExtent,
            verticalListHeight: height,
            verticalListWidth: width,
            horizontal: false,
            isInfinite: false,
            perspective: 0.0025,
            squeeze: 1.0,
            showPointer: false,
            isVibrate: true,
            hapticFeedbackType: HapticFeedbackType.lightImpact,
            scrollPhysics: const BouncingScrollPhysics(),
            enableAnimation: true,
            animationDuration: const Duration(milliseconds: 250),
            animationType: Curves.easeOutCubic,
            onValueChanged: _handleValueChanged,
            children: List.generate(letters.length, (i) {
              final distance = (i - _selectedIndex).abs();
              final isActive = distance == 0;

              final fontSize = isActive
                  ? activeFont
                  : distance == 1
                  ? nearFont
                  : farFont;

              final opacity = isActive
                  ? 1.0
                  : distance == 1
                  ? 0.75
                  : 0.45;

              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    color: isActive
                        ? AppTheme.primaryColor
                        : AppTheme.textSec(context).withValues(alpha: opacity),
                  ),
                  child: Text(letters[i]),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
