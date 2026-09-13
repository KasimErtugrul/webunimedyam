// lib/presentation/screens/player/player_screen_widgets/expandable_description_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

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

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final textStyle = TextStyle(
      color: AppTheme.textSec(context),
      fontSize: s.fontSize.sp,
      height: s.lineHeight,
    );
    final primary = Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: textStyle),
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
                SizedBox(height: s.buttonSpacing.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _expanded ? 'Daha az göster' : 'Devamını gör',
                      style: TextStyle(
                        color: primary,
                        fontSize: s.buttonFontSize.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: s.buttonIconSpacing.w),
                    AnimatedRotation(
                      duration: _kAnimDuration,
                      turns: _expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: s.buttonIconSize.sp,
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