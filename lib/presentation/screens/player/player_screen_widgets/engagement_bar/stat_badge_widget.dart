// lib/presentation/screens/player/player_screen_widgets/engagement_bar/stat_badge_widget.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final double minHeight;
  final double borderRadius;
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

  const _Sizes._({
    required this.minHeight,
    required this.borderRadius,
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
  });

  factory _Sizes.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, >=1024px): tablet ölçekleri + web ince ayarları.
    if (Responsive.isWeb(context)) {
      return const _Sizes._(
        minHeight: 46,
        borderRadius: 16,
        horizontalPadding: 14,
        iconSize: 19,
        loadingSize: 16,
        loadingStrokeWidth: 2,
        iconTextSpacing: 6,
        skeletonWidth: 28,
        skeletonHeight: 10,
        skeletonRadius: 5,
        skeletonOpacity: 0.15,
        textFontSize: 14,
      );
    }
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        minHeight: 46,
        borderRadius: 16,
        horizontalPadding: 14,
        iconSize: 19,
        loadingSize: 16,
        loadingStrokeWidth: 2,
        iconTextSpacing: 6,
        skeletonWidth: 28,
        skeletonHeight: 10,
        skeletonRadius: 5,
        skeletonOpacity: 0.15,
        textFontSize: 14,
      );
    }
    return const _Sizes._(
      minHeight: 40,
      borderRadius: 14,
      horizontalPadding: 10,
      iconSize: 17,
      loadingSize: 14,
      loadingStrokeWidth: 1.5,
      iconTextSpacing: 5,
      skeletonWidth: 22,
      skeletonHeight: 8,
      skeletonRadius: 4,
      skeletonOpacity: 0.15,
      textFontSize: 13,
    );
  }
}

const Duration _kAnimDuration = Duration(milliseconds: 200);

/// İzlenme / yorum sayısı gibi istatistik butonu.
///
/// Aksiyon butonlarının (beğen/paylaş/kaydet) "ikincil" hali: şeffaf zemin +
/// ince kenarlık. [onTap] verilirse dokunulabilir (ripple'lı) bir butondur.
class StatBadgeWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool loading;
  final VoidCallback? onTap;
  final String? semanticLabel;

  const StatBadgeWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.loading,
    this.onTap,
    this.semanticLabel,
  });

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}B';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final s = _Sizes.of(context);
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    final radius = BorderRadius.circular(s.borderRadius);

    final iconColor = AppTheme.textSec(context);
    final textColor = AppTheme.textPri(context).withValues(alpha: 0.85);

    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: Container(
        constraints: BoxConstraints(minHeight: s.minHeight),
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: radius,
            splashColor: primary.withValues(alpha: 0.12),
            highlightColor: primary.withValues(alpha: 0.06),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s.horizontalPadding),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox(
                      width: s.loadingSize,
                      height: s.loadingSize,
                      child: CircularProgressIndicator(
                        strokeWidth: s.loadingStrokeWidth,
                        color: iconColor.withValues(alpha: 0.5),
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
                        color: iconColor.withValues(alpha: s.skeletonOpacity),
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
                          fontWeight: FontWeight.w600,
                          height: 1.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
