// lib/presentation/screens/home/tabs/universities_tab/widgets/universities_alphabet_list.dart
//
// Üniversiteler sekmesinin A-Z hızlı indeksli listesi.
// NOT: Artık UniversitiesTabLayoutSpec'e bağımlı DEĞİL — sidebar ölçüleri
// (genişlik, hap, font boyutları) bu dosyadaki phone/tablet sabitlerinden
// gelir. Kart, dışarıdan verilen itemBuilder ile üretilir.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../../app/themes/app_theme.dart';
import '../../../../../../core/responsive.dart';
import '../../../../../../data/models/university_model.dart';
import '../../../../../controllers/university_alphabet_controller.dart';

// ═══════════════════════════════════════════════════════════════════
// ÖLÇÜ SABİTLERİ
// ═══════════════════════════════════════════════════════════════════

class _PhoneSizes {
  static const double sidebarWidth = 26;
  static const double sidebarPill = 22;
  static const double sidebarActiveFontSize = 12;
  static const double sidebarInactiveFontSize = 9;
  static const double sidebarVerticalPadding = 8;
  static const double listPadHorizontal = 16;
}

class _TabletSizes {
  static const double sidebarWidth = 34;
  static const double sidebarPill = 28;
  static const double sidebarActiveFontSize = 14;
  static const double sidebarInactiveFontSize = 11;
  static const double sidebarVerticalPadding = 10;
  static const double listPadHorizontal = 24;
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
  ) itemBuilder;

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
          return _AlphabetSidebar(
            letters: letters,
            currentLetter: _controller.currentLetter.value,
            onTapLetter: _controller.jumpToLetter,
            onDragLetter: _controller.dragToLetter,
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SAĞ A-Z ŞERİDİ
// ═══════════════════════════════════════════════════════════════════

class _AlphabetSidebar extends StatelessWidget {
  final List<String> letters;
  final String currentLetter;
  final ValueChanged<String> onTapLetter;
  final ValueChanged<String> onDragLetter;

  const _AlphabetSidebar({
    required this.letters,
    required this.currentLetter,
    required this.onTapLetter,
    required this.onDragLetter,
  });

  void _handlePosition(Offset local, double height, ValueChanged<String> cb) {
    if (letters.isEmpty || height <= 0) return;
    final itemHeight = height / letters.length;
    final index =
        (local.dy / itemHeight).floor().clamp(0, letters.length - 1);
    cb(letters[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final width = isTablet
        ? _TabletSizes.sidebarWidth
        : _PhoneSizes.sidebarWidth.w;
    final pill =
        isTablet ? _TabletSizes.sidebarPill : _PhoneSizes.sidebarPill.w;
    final activeFont = isTablet
        ? _TabletSizes.sidebarActiveFontSize
        : _PhoneSizes.sidebarActiveFontSize.sp;
    final inactiveFont = isTablet
        ? _TabletSizes.sidebarInactiveFontSize
        : _PhoneSizes.sidebarInactiveFontSize.sp;
    final vPad = isTablet
        ? _TabletSizes.sidebarVerticalPadding
        : _PhoneSizes.sidebarVerticalPadding.h;

    return LayoutBuilder(
      builder: (context, c) {
        final height = c.maxHeight;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) =>
              _handlePosition(d.localPosition, height, onTapLetter),
          onVerticalDragUpdate: (d) =>
              _handlePosition(d.localPosition, height, onDragLetter),
          child: Container(
            width: width,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: vPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: letters.map((letter) {
                final isActive = letter == currentLetter;
                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? pill : 0,
                      height: pill,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.primaryColor
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: isActive ? activeFont : inactiveFont,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive
                              ? Colors.white
                              : AppTheme.textSec(context)
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}