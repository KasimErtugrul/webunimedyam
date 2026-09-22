// lib/presentation/screens/home/tabs/universities_tab/widgets/universities_alphabet_list.dart
//
// Üniversiteler sekmesinin A-Z hızlı indeksli listesi.
//
// Sağdaki A-Z şeridi wheel_slider paketi KALDIRILARAK bu dosyada özel
// yazılan bir "harf rayı"dır:
//   • Ray sabittir: ilk harf (A) en üstte, son harf (Z) en altta durur;
//     seçili harf ortada sabitlenmez.
//   • Aktif harf büyüteç gibi belirginleşir (font + scale + renk).
//   • Ray sabit olduğu için liste ↔ ray senkronu yalnızca "aktif indeks"
//     güncellemesidir; scroll controller/animasyon senkronu gerekmez.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const double listPadHorizontal = 16;

  // A-Z harf rayı.
  static const double railActiveFont = 15;
  static const double railNearFont = 11;
  static const double railFarFont = 8.5;
  static const double railActiveScale = 1.3;
  static const double railNearScale = 1.1;
  static const double railBubbleSize = 38;
  static const double railBubbleFont = 15;
}

class _TabletSizes {
  static const double sidebarWidth = 34;
  static const double listPadHorizontal = 24;

  // A-Z harf rayı.
  static const double railActiveFont = 18;
  static const double railNearFont = 13.5;
  static const double railFarFont = 10.5;
  /*   static const double railActiveScale = 1.3;
  static const double railNearScale = 1.1; */
  static const double railBubbleSize = 48;
  static const double railBubbleFont = 18;
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
          return _AlphabetRail(
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
// SAĞ A-Z HARF RAYI (özel impl — wheel_slider yok)
// ═══════════════════════════════════════════════════════════════════
//
// Harfler eşit yükseklikli slotlara bölünür: A ilk slotta (en üst), Z son
// slotta (en alt). Aktif harf "büyüteç" gibi büyür; komşuları hafifçe
// şişer, uzaklaştıkça küçülüp sönükleşir. Parmakla taramada (scrub) liste
// canlı takip eder ve parmağın solunda harf balonu görünür.

class _AlphabetRail extends StatefulWidget {
  final List<String> letters;
  final String currentLetter;

  /// Kullanıcı raya dokununca/sürükleyince hedef harf; alttaki listeyi
  /// o harfe taşımak için çağrılır.
  final ValueChanged<String> onLetterSettled;

  const _AlphabetRail({
    required this.letters,
    required this.currentLetter,
    required this.onLetterSettled,
  });

  @override
  State<_AlphabetRail> createState() => _AlphabetRailState();
}

class _AlphabetRailState extends State<_AlphabetRail> {
  int _activeIndex = 0;

  // Kullanıcı parmağıyla tararken görsel aktiflik _dragIndex'ten alınır;
  // liste kaynaklı güncellemeler bu sırada yok sayılır.
  bool _dragging = false;
  int? _dragIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = _indexOf(widget.currentLetter);
  }

  int _indexOf(String letter) {
    final i = widget.letters.indexOf(letter);
    return i == -1 ? 0 : i;
  }

  @override
  void didUpdateWidget(covariant _AlphabetRail oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Harf kümesi değiştiyse (arama/filtre) aktifi tazele.
    if (!identical(oldWidget.letters, widget.letters)) {
      _activeIndex = _indexOf(widget.currentLetter);
      if (_dragIndex != null && _dragIndex! >= widget.letters.length) {
        _dragging = false;
        _dragIndex = null;
      }
      return;
    }

    // Liste kendi kayarak harfi değiştirdiyse büyüteci oraya taşı.
    // (Ray sabit olduğu için senkron = indeks güncellemesi.)
    if (!_dragging && oldWidget.currentLetter != widget.currentLetter) {
      final newIndex = _indexOf(widget.currentLetter);
      if (newIndex != _activeIndex) {
        setState(() => _activeIndex = newIndex);
      }
    }
  }

  // ── Jestler ────────────────────────────────────────────────────────

  int _indexFromY(double y, double slotH) => (y / slotH).floor();

  void _select(int index) {
    final count = widget.letters.length;
    if (count == 0) return;
    var i = index;
    if (i < 0) i = 0;
    if (i > count - 1) i = count - 1;

    if (_dragging) {
      if (_dragIndex != i) {
        HapticFeedback.selectionClick();
        setState(() => _dragIndex = i);
      }
    } else {
      if (_activeIndex != i) {
        HapticFeedback.selectionClick();
        setState(() => _activeIndex = i);
      }
    }
    widget.onLetterSettled(widget.letters[i]);
  }

  void _onScrubStart(double y, double slotH) {
    setState(() => _dragging = true);
    _select(_indexFromY(y, slotH));
  }

  void _onScrubMove(double y, double slotH) {
    _select(_indexFromY(y, slotH));
  }

  void _onScrubEnd() {
    if (!_dragging) return;
    final last = _dragIndex;
    setState(() {
      _dragging = false;
      _dragIndex = null;
      if (last != null) _activeIndex = last;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final width = isTablet
        ? _TabletSizes.sidebarWidth
        : _PhoneSizes.sidebarWidth.w;

    double activeFont = isTablet
        ? _TabletSizes.railActiveFont
        : _PhoneSizes.railActiveFont.sp;
    double nearFont = isTablet
        ? _TabletSizes.railNearFont
        : _PhoneSizes.railNearFont.sp;
    double farFont = isTablet
        ? _TabletSizes.railFarFont
        : _PhoneSizes.railFarFont.sp;
    final activeScale = _PhoneSizes.railActiveScale;
    final nearScale = _PhoneSizes.railNearScale;

    final bubbleSize = isTablet
        ? _TabletSizes.railBubbleSize
        : _PhoneSizes.railBubbleSize.w;
    final bubbleFont = isTablet
        ? _TabletSizes.railBubbleFont
        : _PhoneSizes.railBubbleFont.sp;

    return LayoutBuilder(
      builder: (context, c) {
        final height = c.maxHeight > 0 ? c.maxHeight : 300.0;
        final letters = widget.letters;
        final count = letters.length;
        if (count == 0) return const SizedBox.shrink();

        final slotH = height / count;

        // Çok harf + kısa ray: herkesin okunur kalması için fontları
        // slot yüksekliğine oranla küçült.
        if (slotH < farFont * 1.5) {
          farFont = math.max(6.0, math.min(farFont, slotH * 0.6));
          nearFont = farFont * 1.3;
          activeFont = farFont * 1.75;
        }

        final visualIndex = _dragIndex ?? _activeIndex;
        final bubbleTop = ((visualIndex + 0.5) * slotH - bubbleSize / 2)
            .clamp(0.0, math.max(0.0, height - bubbleSize))
            .toDouble();

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _select(_indexFromY(d.localPosition.dy, slotH)),
          onPanStart: (d) => _onScrubStart(d.localPosition.dy, slotH),
          onPanUpdate: (d) => _onScrubMove(d.localPosition.dy, slotH),
          onPanEnd: (_) => _onScrubEnd(),
          onPanCancel: _onScrubEnd,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Harfler: eşit yükseklikli slotlar — A üstte, Z altta.
                Column(
                  children: [
                    for (var i = 0; i < count; i++)
                      Expanded(
                        child: Center(
                          child: _RailLetter(
                            letter: letters[i],
                            distance: (i - visualIndex).abs(),
                            activeFont: activeFont,
                            nearFont: nearFont,
                            farFont: farFont,
                            activeScale: activeScale,
                            nearScale: nearScale,
                          ),
                        ),
                      ),
                  ],
                ),

                // Tarama sırasında parmağın solundaki harf balonu.
                if (_dragging && _dragIndex != null)
                  Positioned(
                    left: -bubbleSize - 10,
                    top: bubbleTop,
                    child: _RailBubble(
                      letter: letters[visualIndex],
                      size: bubbleSize,
                      fontSize: bubbleFont,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RailLetter extends StatelessWidget {
  final String letter;
  final int distance;
  final double activeFont;
  final double nearFont;
  final double farFont;
  final double activeScale;
  final double nearScale;

  const _RailLetter({
    required this.letter,
    required this.distance,
    required this.activeFont,
    required this.nearFont,
    required this.farFont,
    required this.activeScale,
    required this.nearScale,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = distance == 0;

    final fontSize = isActive
        ? activeFont
        : distance == 1
        ? nearFont
        : farFont;

    // Büyüteç: aktif belirgin şekilde büyür, komşusu hafifçe.
    final scale = isActive
        ? activeScale
        : distance == 1
        ? nearScale
        : 1.0;

    final opacity = isActive
        ? 1.0
        : distance == 1
        ? 0.85
        : distance == 2
        ? 0.62
        : 0.42;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
          color: isActive
              ? AppTheme.primaryColor
              : AppTheme.textSec(context).withValues(alpha: opacity),
        ),
        child: Text(letter),
      ),
    );
  }
}

class _RailBubble extends StatelessWidget {
  final String letter;
  final double size;
  final double fontSize;

  const _RailBubble({
    required this.letter,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}