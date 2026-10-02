// lib/presentation/screens/player/player_screen_widgets/engagement_bar/engagement_action_widget.dart
import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../../../../../core/responsive.dart';

class _Sizes {
  final double minHeight;
  final double borderRadius;
  final double horizontalPadding;
  final double iconSize;
  final double loadingIndicatorSize;
  final double loadingStrokeWidth;
  final double textFontSize;
  final double textSpacing;

  const _Sizes._({
    required this.minHeight,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.iconSize,
    required this.loadingIndicatorSize,
    required this.loadingStrokeWidth,
    required this.textFontSize,
    required this.textSpacing,
  });

  factory _Sizes.of(BuildContext context) {
    // WEB (masaüstü tarayıcı, >=1024px): tablet ölçekleri + web ince ayarları.
    if (Responsive.isWeb(context)) {
      return const _Sizes._(
        minHeight: 46,
        borderRadius: 16,
        horizontalPadding: 16,
        iconSize: 22,
        loadingIndicatorSize: 20,
        loadingStrokeWidth: 2.5,
        textFontSize: 14,
        textSpacing: 8,
      );
    }
    if (Responsive.isTablet(context)) {
      return const _Sizes._(
        minHeight: 46,
        borderRadius: 16,
        horizontalPadding: 16,
        iconSize: 22,
        loadingIndicatorSize: 20,
        loadingStrokeWidth: 2.5,
        textFontSize: 14,
        textSpacing: 8,
      );
    }
    return const _Sizes._(
      minHeight: 40,
      borderRadius: 14,
      horizontalPadding: 12,
      iconSize: 20,
      loadingIndicatorSize: 18,
      loadingStrokeWidth: 2.0,
      textFontSize: 13,
      textSpacing: 6,
    );
  }
}

/// Beğen / Paylaş / Kaydet gibi ana aksiyon butonu.
///
/// Her zaman kenarlıklı, dolgulu bir buton olarak görünür:
///  - pasif : surfaceContainerHigh dolgu + ince kenarlık
///  - aktif : primary tonlu dolgu + primary kenarlık
class EngagementActionWidget extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final bool loading;
  final VoidCallback onTap;

  /// Ekran okuyucular için buton adı (ör. "Beğen").
  final String? semanticLabel;

  const EngagementActionWidget({
    super.key,
    required this.icon,
    required this.count,
    required this.active,
    required this.loading,
    required this.onTap,
    this.semanticLabel,
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
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;

    final color = active ? primary : AppTheme.textPri(context);
    final bgColor = active
        ? primary.withValues(alpha: 0.14)
        : scheme.surfaceContainerHigh;
    final borderColor = active
        ? primary.withValues(alpha: 0.55)
        : scheme.outlineVariant.withValues(alpha: 0.4);
    final countText = _fmt(count);
    final radius = BorderRadius.circular(s.borderRadius);

    return Semantics(
      button: true,
      selected: active,
      label: semanticLabel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        constraints: BoxConstraints(minHeight: s.minHeight),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
          border: Border.all(color: borderColor, width: 1),
        ),
        // Material + InkWell dekorasyonun ÜSTÜNDE: ripple görünür kalır.
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
                      width: s.loadingIndicatorSize,
                      height: s.loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth: s.loadingStrokeWidth,
                        color: color,
                      ),
                    )
                  else
                    AnimatedScale(
                      scale: active ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Icon(icon, color: color, size: s.iconSize),
                    ),
                  if (countText.isNotEmpty) ...[
                    SizedBox(width: s.textSpacing),
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: Text(
                          countText,
                          key: ValueKey(count),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: color,
                            fontSize: s.textFontSize,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w600,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
