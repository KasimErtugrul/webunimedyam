// lib/presentation/screens/search/widgets/highlight_text_widget.dart

import 'package:flutter/material.dart';


// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

// Bu widget'ta sabitler kullanılmıyor, doğrudan parametrelerle çalışıyor.
// Ancak KURAL 6'ya uygun olarak phone/tablet ayrımı yapılıyor.

// ═══════════════════════════════════════════════════════════
// WIDGET
// ═══════════════════════════════════════════════════════════

class HighlightTextWidget extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final int maxLines;

  const HighlightTextWidget({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    // KURAL 5 — TEK DALLANMA NOKTASI
    // Bu widget'ta phone/tablet farkı yok, doğrudan render ediliyor.
    // Ancak KURAL 6'ya uygun olarak ayrı bir widget olarak tanımlandı.
    
    if (highlight.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerHighlight, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + highlight.length),
          style: style.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = idx + highlight.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}