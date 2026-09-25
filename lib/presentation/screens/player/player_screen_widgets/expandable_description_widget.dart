// lib/presentation/screens/player/player_screen_widgets/expandable_description_widget.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// Video açıklamasında geçen http(s):// veya www. ile başlayan URL'leri
// yakalamak için kullanılan regex. Satır sonu boşluk/yeni satır karakterine
// kadar olan her şeyi URL kabul eder; sondaki noktalama işaretleri (., ,,
// ), ] gibi) ayrıca ayıklanır ki cümle sonundaki nokta URL'nin parçası
// sanılmasın.
final RegExp _kUrlRegExp = RegExp(
  r'((https?:\/\/|www\.)[^\s]+)',
  caseSensitive: false,
);
final RegExp _kTrailingPunctuation = RegExp(r'[\.,;:!\?\)\]]+$');

class _Sizes {
  final double fontSize;
  final double lineHeight;
  final double buttonSpacing;
  final double buttonFontSize;
  final double buttonIconSize;
  final double buttonIconSpacing;

  const _Sizes._({
    required this.fontSize,
    required this.lineHeight,
    required this.buttonSpacing,
    required this.buttonFontSize,
    required this.buttonIconSize,
    required this.buttonIconSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        fontSize: 16,
        lineHeight: 1.6,
        buttonSpacing: 6,
        buttonFontSize: 14,
        buttonIconSize: 20,
        buttonIconSpacing: 4,
      );
    }
    return const _Sizes._(
      fontSize: 13,
      lineHeight: 1.55,
      buttonSpacing: 4,
      buttonFontSize: 12,
      buttonIconSize: 16,
      buttonIconSpacing: 2,
    );
  }
}

const Duration _kAnimDuration = Duration(milliseconds: 300);

class ExpandableDescriptionWidget extends StatefulWidget {
  final String text;
  const ExpandableDescriptionWidget({super.key, required this.text});

  @override
  State<ExpandableDescriptionWidget> createState() =>
      _ExpandableDescriptionWidgetState();
}

class _ExpandableDescriptionWidgetState
    extends State<ExpandableDescriptionWidget> {
  bool _expanded = false;

  // Text.rich içindeki linkli TextSpan'lara bağlanan tıklama
  // recognizer'ları. Her build'de yeniden oluşturulduğu için öncekiler
  // dispose edilip liste temizlenir (bellek sızıntısını önlemek için).
  final List<TapGestureRecognizer> _linkRecognizers = [];

  @override
  void dispose() {
    for (final recognizer in _linkRecognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  /// Açıklama metnini, içindeki URL'ler tıklanabilir link olacak şekilde
  /// TextSpan parçalarına ayırır. Link olmayan kısımlar düz metin olarak
  /// kalır; böylece metnin geri kalanına dokunmak sekmeyi (Devamını gör /
  /// Daha az göster) genişletip daraltmaya devam eder — link tıklamaları
  /// kendi recognizer'ları sayesinde bu davranışı tetiklemez.
  List<InlineSpan> _buildSpans(TextStyle textStyle, TextStyle linkStyle) {
    for (final recognizer in _linkRecognizers) {
      recognizer.dispose();
    }
    _linkRecognizers.clear();

    final text = widget.text;
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _kUrlRegExp.allMatches(text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, match.start)));
      }

      var url = match.group(0)!;
      var trailing = '';
      final trailingMatch = _kTrailingPunctuation.firstMatch(url);
      if (trailingMatch != null) {
        trailing = trailingMatch.group(0)!;
        url = url.substring(0, url.length - trailing.length);
      }

      if (url.isEmpty) {
        // Regex teorik olarak boş eşleşme vermez ama garanti olsun.
        spans.add(TextSpan(text: match.group(0), style: textStyle));
      } else {
        final recognizer = TapGestureRecognizer()..onTap = () => _openLink(url);
        _linkRecognizers.add(recognizer);
        spans.add(
          TextSpan(text: url, style: linkStyle, recognizer: recognizer),
        );
        if (trailing.isNotEmpty) {
          spans.add(TextSpan(text: trailing));
        }
      }

      cursor = match.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return spans;
  }

  Future<void> _openLink(String rawUrl) async {
    var url = rawUrl;
    if (!url.toLowerCase().startsWith('http://') &&
        !url.toLowerCase().startsWith('https://')) {
      url = 'https://$url';
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final textStyle = TextStyle(
      color: AppTheme.textSec(context),
      fontSize: s.fontSize,
      height: s.lineHeight,
    );
    final primary = Theme.of(context).colorScheme.primary;
    final linkStyle = textStyle.copyWith(
      color: primary,
      decoration: TextDecoration.underline,
      decorationColor: primary,
    );
    final spans = _buildSpans(textStyle, linkStyle);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(style: textStyle, children: spans),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isOverflowing = textPainter.didExceedMaxLines;

        return GestureDetector(
          onTap: isOverflowing
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: _kAnimDuration,
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Text.rich(
                  TextSpan(style: textStyle, children: spans),
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              if (isOverflowing) ...[
                SizedBox(height: s.buttonSpacing),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Daha az göster' : 'Devamını gör',
                      style: TextStyle(
                        color: primary,
                        fontSize: s.buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: s.buttonIconSpacing),
                    AnimatedRotation(
                      duration: _kAnimDuration,
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: s.buttonIconSize,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}