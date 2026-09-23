// lib/presentation/screens/settings/widgets/settings_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../settings_layout_spec.dart';

/// Tasarımdaki bölüm: [ikon + başlık (+ sağa yaslı opsiyonel rozet)]
/// altında surface-container kart.
/// `divided: true` → satırlar arasına inset'li 1px ayraç.
/// `padding` verilirse kart içeriği pad'lenmiş tek kolon olur (Görünüm kartı).
class SettingsSection extends StatelessWidget {
  final SettingsLayoutSpec spec;
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget? aboveCard;
  final List<Widget> children;
  final bool divided;
  final EdgeInsetsGeometry? padding;

  const SettingsSection({
    super.key,
    required this.spec,
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
    this.aboveCard,
    this.divided = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final Widget cardBody;
    if (padding != null) {
      cardBody = Padding(padding: padding!, child: Column(children: children));
    } else {
      cardBody = Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) _divider(scheme),
            children[i],
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spec.sectionHeaderGap.h),
          child: Row(
            children: [
              Icon(
                icon,
                size: spec.sectionIconSize.sp,
                color: scheme.primary,
              ),
              SizedBox(width: spec.sectionIconGap.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: spec.sectionTitleFontSize.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.01 * spec.sectionTitleFontSize,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        if (aboveCard != null) aboveCard!,
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
            borderRadius: BorderRadius.circular(spec.cardRadius.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: cardBody,
        ),
      ],
    );
  }

  Widget _divider(ColorScheme scheme) => Container(
        height: 1,
        margin: EdgeInsets.symmetric(horizontal: spec.dividerInset.w),
        color: scheme.surfaceVariant.withValues(alpha: 0.4),
      );
}