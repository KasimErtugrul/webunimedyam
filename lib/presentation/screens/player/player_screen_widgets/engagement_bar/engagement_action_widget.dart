// lib/presentation/screens/player/player_screen_widgets/engagement_bar/engagement_action_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final double borderRadius;
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final double textFontSize;
  final double textSpacing;

  const _Sizes._({
    required this.borderRadius,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.loadingIndicatorSize,
    required this.loadingStrokeWidth,
    required this.textFontSize,
    required this.textSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        borderRadius: 22,
        horizontalPadding: 14,
        verticalPadding: 10,
        iconSize: 22,
        loadingIndicatorSize: 22,
        loadingStrokeWidth: 2.5,
        textFontSize: 14,
        textSpacing: 7,
      );
    }
    return const _Sizes._(
      borderRadius: 20,
      horizontalPadding: 12,
      verticalPadding: 8,
      iconSize: 20,
      loadingIndicatorSize: 20,
      loadingStrokeWidth: 2.0,
      textFontSize: 13,
      textSpacing: 6,
    );
  }
}

class EngagementActionWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool loading;
  final VoidCallback onTap;

  const EngagementActionWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.active,
    required this.loading,
    required this.onTap,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    if (n == 0) return '';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final primary = Theme.of(context).colorScheme.primary;

    final color = active ? primary : AppTheme.textSec(context);
    final bgColor = active
        ? primary.withValues(alpha: 0.12)
        : Colors.transparent;
    final countText = _fmt(count);

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(s.borderRadius.r),
      splashColor: primary.withValues(alpha: 0.1),
      highlightColor: primary.withValues(alpha: 0.05),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: s.horizontalPadding.w,
          vertical: s.verticalPadding.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(s.borderRadius.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              SizedBox(
                width: s.loadingIndicatorSize.sp,
                height: s.loadingIndicatorSize.sp,
                child: CircularProgressIndicator(
                  strokeWidth: s.loadingStrokeWidth.w,
                  color: color,
                ),
              )
            else
              AnimatedScale(
                scale: active ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Icon(icon, color: color, size: s.iconSize.sp),
              ),
            if (countText.isNotEmpty) ...[
              SizedBox(width: s.textSpacing.w),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: Text(
                  countText,
                  key: ValueKey(count),
                  style: TextStyle(
                    color: color,
                    fontSize: s.textFontSize.sp,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}