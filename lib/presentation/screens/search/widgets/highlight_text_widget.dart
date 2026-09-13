// lib/presentation/screens/search/widgets/highlight_text_widget.dart
import 'package:flutter/material.dart';

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
    if (highlight.trim().isEmpty || text.isEmpty) {
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

    while (start < text.length) {
      final idx = lowerText.indexOf(lowerHighlight, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      final end = (idx + highlight.length).clamp(0, text.length);
      spans.add(
        TextSpan(
          text: text.substring(idx, end),
          style: style.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      start = end;
    }

    if (spans.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}