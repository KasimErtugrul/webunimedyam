// lib/presentation/screens/player/player_screen_widgets/engagement_bar/stat_badge_widget.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final double verticalPadding;
  final double horizontalPadding;
  final double iconSize;
  final double loadingSize;
  final double loadingStrokeWidth;
  final double iconTextSpacing;
  final double skeletonWidth;
  final double skeletonHeight;
  final double skeletonRadius;
  final double skeletonOpacity;
  final double textFontSize;
  final double textLineHeight;
  final double textDecorationThickness;
  final double textDecorationOpacity;

  const _Sizes._({
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.iconSize,
    required this.loadingSize,
    required this.loadingStrokeWidth,
    required this.iconTextSpacing,
    required this.skeletonWidth,
    required this.skeletonHeight,
    required this.skeletonRadius,
    required this.skeletonOpacity,
    required this.textFontSize,
    required this.textLineHeight,
    required this.textDecorationThickness,
    required this.textDecorationOpacity,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        verticalPadding: 6,
        horizontalPadding: 3,
        iconSize: 18,
        loadingSize: 18,
        loadingStrokeWidth: 2,
        iconTextSpacing: 5,
        skeletonWidth: 30,
        skeletonHeight: 10,
        skeletonRadius: 5,
        skeletonOpacity: 0.15,
        textFontSize: 14,
        textLineHeight: 1.2,
        textDecorationThickness: 1.5,
        textDecorationOpacity: 0.3,
      );
    }
    return const _Sizes._(
      verticalPadding: 4,
      horizontalPadding: 2,
      iconSize: 15,
      loadingSize: 15,
      loadingStrokeWidth: 1.5,
      iconTextSpacing: 4,
      skeletonWidth: 24,
      skeletonHeight: 8,
      skeletonRadius: 4,
      skeletonOpacity: 0.15,
      textFontSize: 12,
      textLineHeight: 1.2,
      textDecorationThickness: 1.2,
      textDecorationOpacity: 0.3,
    );
  }
}

const Duration _kAnimDuration = Duration(milliseconds: 200);

class StatBadgeWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool loading;
  final bool tappable;

  const StatBadgeWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.loading,
    this.tappable = false,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    final iconColor = tappable
        ? primary.withValues(alpha: 0.7)
        : AppTheme.textSec(context);
    final textColor = tappable ? primary : AppTheme.textSec(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: s.verticalPadding,
        horizontal: s.horizontalPadding,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (loading)
            SizedBox(
              width: s.loadingSize,
              height: s.loadingSize,
              child: CircularProgressIndicator(
                strokeWidth: s.loadingStrokeWidth,
                color: AppTheme.textSec(context).withValues(alpha: 0.5),
              ),
            )
          else
            Icon(icon, color: iconColor, size: s.iconSize),
          SizedBox(width: s.iconTextSpacing),
          if (loading)
            Container(
              width: s.skeletonWidth,
              height: s.skeletonHeight,
              decoration: BoxDecoration(
                color: AppTheme.textSec(context)
                    .withValues(alpha: s.skeletonOpacity),
                borderRadius: BorderRadius.circular(s.skeletonRadius),
              ),
            )
          else
            AnimatedSwitcher(
              duration: _kAnimDuration,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _fmt(count),
                key: ValueKey(count),
                style: TextStyle(
                  color: textColor,
                  fontSize: s.textFontSize,
                  fontWeight: tappable ? FontWeight.w600 : FontWeight.normal,
                  height: s.textLineHeight,
                  decoration: tappable
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: primary
                      .withValues(alpha: s.textDecorationOpacity),
                  decorationThickness: s.textDecorationThickness,
                ),
              ),
            ),
        ],
      ),
    );
  }
}