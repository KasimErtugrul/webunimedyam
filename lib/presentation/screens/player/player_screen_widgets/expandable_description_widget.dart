// ═══════════════════════════════════════════════════════════════════════════
// Genişletilebilir Açıklama
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';

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

  @override
  Widget build(BuildContext context) {
    // Metin stilini tek bir yerde tanımlıyoruz ki hesaplama ile UI aynı olsun
    final TextStyle textStyle = TextStyle(
      color: AppTheme.textSec(context),
      fontSize: 13.sp,
      height: 1.55,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        // TextPainter ile metnin gerçek yüksekliğini ve satır sayısını hesapla
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: 3, // Maksimum satır sayımız
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        // Metin 3 satırdan fazla mı? (Taşma var mı?)
        final bool isOverflowing = textPainter.didExceedMaxLines;

        return GestureDetector(
          onTap: isOverflowing
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Metin Alanı (Animasyonlu) ────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter, // Üstten sabit, alttan açılır
                child: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),

              // ─── Devamını Gör Butonu (Sadece taşma varsa) ─────────
              if (isOverflowing) ...[
                SizedBox(height: 4.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Daha az göster' : 'Devamını gör',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _expanded ? 0.5 : 0, // Açılınca ok aşağı döner
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 16.sp,
                        color: Theme.of(context).colorScheme.primary,
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
