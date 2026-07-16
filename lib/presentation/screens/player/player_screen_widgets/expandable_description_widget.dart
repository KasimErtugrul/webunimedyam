// ═══════════════════════════════════════════════════════════════════════════
// Genişletilebilir Açıklama
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

// ═══════════════════════════════════════════════════════════
// KURAL 3 — SABİTLER
// ═══════════════════════════════════════════════════════════

class _PhoneSizes {
  // Metin stili
  static const double descriptionFontSize = 13;
  static const double descriptionLineHeight = 1.55;

  // Buton
  static const double buttonSpacing = 4;
  static const double buttonFontSize = 12;
  static const double buttonIconSize = 16;
  static const double buttonIconSpacing = 2;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 300);
}

class _TabletSizes {
  // Metin stili - tablet için daha büyük
  static const double descriptionFontSize = 16;
  static const double descriptionLineHeight = 1.6;

  // Buton - tablet için daha büyük
  static const double buttonSpacing = 6;
  static const double buttonFontSize = 14;
  static const double buttonIconSize = 20;
  static const double buttonIconSpacing = 4;

  // Animasyon
  static const Duration animDuration = Duration(milliseconds: 300);
}

// ═══════════════════════════════════════════════════════════
// ANA WIDGET (Stateful)
// ═══════════════════════════════════════════════════════════

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
    // KURAL 5 — TEK DALLANMA NOKTASI
    return Responsive.isTablet(context)
        ? _buildTablet(context)
        : _buildPhone(context);
  }

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 1 — PHONE TASARIMI (BİREBİR AYNI)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPhone(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      color: AppTheme.textSec(context),
      fontSize: _PhoneSizes.descriptionFontSize.sp,
      height: _PhoneSizes.descriptionLineHeight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        return GestureDetector(
          onTap: isOverflowing
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: _PhoneSizes.animDuration,
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              if (isOverflowing) ...[
                SizedBox(height: _PhoneSizes.buttonSpacing.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Daha az göster' : 'Devamını gör',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: _PhoneSizes.buttonFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: _PhoneSizes.buttonIconSpacing.w),
                    AnimatedRotation(
                      duration: _PhoneSizes.animDuration,
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: _PhoneSizes.buttonIconSize.sp,
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

  // ═══════════════════════════════════════════════════════════════════════
  // KURAL 2 — TABLET TASARIMI (BAĞIMSIZ)
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTablet(BuildContext context) {
    final TextStyle textStyle = TextStyle(
      color: AppTheme.textSec(context),
      fontSize: _TabletSizes.descriptionFontSize,
      height: _TabletSizes.descriptionLineHeight,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
          maxLines: 3,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final bool isOverflowing = textPainter.didExceedMaxLines;

        return GestureDetector(
          onTap: isOverflowing
              ? () => setState(() => _expanded = !_expanded)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSize(
                duration: _TabletSizes.animDuration,
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: Text(
                  widget.text,
                  style: textStyle,
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
              if (isOverflowing) ...[
                SizedBox(height: _TabletSizes.buttonSpacing),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Daha az göster' : 'Devamını gör',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: _TabletSizes.buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: _TabletSizes.buttonIconSpacing),
                    AnimatedRotation(
                      duration: _TabletSizes.animDuration,
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: _TabletSizes.buttonIconSize,
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