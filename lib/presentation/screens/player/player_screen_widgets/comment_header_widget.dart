// lib/presentation/screens/player/player_screen_widgets/comment_header_widget.dart
import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../../../../core/responsive.dart';

class _Sizes {
  final double titleFontSize;
  final double badgePaddingH;
  final double badgePaddingV;
  final double badgeRadius;
  final double badgeFontSize;
  final double badgeSpacing;
  final double badgeOpacity;
  final double emptyTopPadding;
  final double emptyFontSize;
  final double dividerHeight;
  final double dividerThickness;
  final double dividerOpacity;
  final double dividerTopSpacing;

  const _Sizes._({
    required this.titleFontSize,
    required this.badgePaddingH,
    required this.badgePaddingV,
    required this.badgeRadius,
    required this.badgeFontSize,
    required this.badgeSpacing,
    required this.badgeOpacity,
    required this.emptyTopPadding,
    required this.emptyFontSize,
    required this.dividerHeight,
    required this.dividerThickness,
    required this.dividerOpacity,
    required this.dividerTopSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        titleFontSize: 20,
        badgePaddingH: 10,
        badgePaddingV: 4,
        badgeRadius: 14,
        badgeFontSize: 14,
        badgeSpacing: 10,
        badgeOpacity: 0.15,
        emptyTopPadding: 6,
        emptyFontSize: 14,
        dividerHeight: 1,
        dividerThickness: 1,
        dividerOpacity: 0.08,
        dividerTopSpacing: 16,
      );
    }
    return const _Sizes._(
      titleFontSize: 16,
      badgePaddingH: 8,
      badgePaddingV: 3,
      badgeRadius: 12,
      badgeFontSize: 12,
      badgeSpacing: 8,
      badgeOpacity: 0.15,
      emptyTopPadding: 4,
      emptyFontSize: 12,
      dividerHeight: 1,
      dividerThickness: 1,
      dividerOpacity: 0.08,
      dividerTopSpacing: 12,
    );
  }
}

class CommentsHeaderWidget extends StatelessWidget {
  final int count;
  const CommentsHeaderWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Yorumlar',
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: s.titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: s.badgeSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: s.badgePaddingH,
                  vertical: s.badgePaddingV,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: s.badgeOpacity),
                  borderRadius: BorderRadius.circular(s.badgeRadius),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: primary,
                    fontSize: s.badgeFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (count == 0)
          Padding(
            padding: EdgeInsets.only(top: s.emptyTopPadding),
            child: Text(
              'Henüz yorum yapılmamış. İlk sen yaz!',
              style: TextStyle(
                color: AppTheme.textSec(context),
                fontSize: s.emptyFontSize,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        SizedBox(height: s.dividerTopSpacing),
        Divider(
          height: s.dividerHeight,
          thickness: s.dividerThickness,
          color: AppTheme.textSec(context).withValues(alpha: s.dividerOpacity),
        ),
      ],
    );
  }
}