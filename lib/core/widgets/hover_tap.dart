// lib/core/widgets/hover_tap.dart
//
// WEB etkileşim yardımcıları.
//
// Flutter web'de GestureDetector imleci otomatik olarak "el" yapmaz —
// yalnızca InkWell yapar. Kod tabanındaki kart/öğe tıklamaları GestureDetector
// üzerine kurulu olduğu için masaüstünde her şey düz ok (default) imleçle
// görünüyordu. Bu iki yardımcı, tüm dokunma hedeflerine tek noktadan:
//   1. SystemMouseCursors.click (el imleci),
//   2. hover durumu (kartlarda hover'da gölge/kaldırma animasyonu için)
// kazandırır.
//
// Kullanım:
//   HoverTap(
//     onTap: () => ...,
//     builder: (context, hovered) => AnimatedContainer(
//       transform: hovered ? Matrix4.translationValues(0, -2, 0) : ...,
//       child: ...,
//     ),
//   )
//
// ya da hover görselliği gerekmeyen basit tıklamalar için:
//   TapCursor(onTap: ..., child: ...)

import 'package:flutter/material.dart';

/// Hover durumu bildiren, el imleçli tıklama alanı.
class HoverTap extends StatefulWidget {
  const HoverTap({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPress,
    this.cursor = SystemMouseCursors.click,
    this.behavior = HitTestBehavior.deferToChild,
  });

  /// [hovered] true olduğunda işaretçi öğenin üzerindedir.
  final Widget Function(BuildContext context, bool hovered) builder;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final MouseCursor cursor;
  final HitTestBehavior behavior;

  @override
  State<HoverTap> createState() => _HoverTapState();
}

class _HoverTapState extends State<HoverTap> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null || widget.onLongPress != null
          ? widget.cursor
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        behavior: widget.behavior,
        child: widget.builder(context, _hovered),
      ),
    );
  }
}

/// Yalnızca el imleci + tıklama; hover durumu gerekmez.
class TapCursor extends StatelessWidget {
  const TapCursor({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.cursor = SystemMouseCursors.click,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final MouseCursor cursor;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: onTap != null || onLongPress != null ? cursor : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        behavior: behavior,
        child: child,
      ),
    );
  }
}
