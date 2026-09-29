// lib/presentation/screens/auth/widgets/register_footer_strip.dart

import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../register_layout_spec.dart';


/// Mikro kampüs şeridi — bg-surface-container-lowest, headset ikonu,
/// "ÜNİ RADYO • 24/7 KESİNTİSİZ YAYIN" ve üniversite avatarları.
class RegisterFooterStrip extends StatelessWidget {
  const RegisterFooterStrip({super.key, required this.sizes});

  final RegisterSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    // -space-x-1.5 → sonraki avatarlar overlap kadar sola kayar
    final avatars = [
      ('İTÜ', scheme.primary),
      ('BÜ', scheme.secondary),
      ('OD', scheme.tertiary),
    ];
    final stackWidth =
        s.stripAvatarSize + (avatars.length - 1) * (s.stripAvatarSize - s.stripAvatarOverlap);

    return Container(
      margin: EdgeInsets.only(top: s.stripTopGap),
      padding: EdgeInsets.all(s.stripPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(s.stripRadius),
      ),
      child: Row(
        children: [
          Icon(
            Icons.headset_mic_rounded,
            size: s.stripIconSize,
            color: scheme.secondary,
          ),
          SizedBox(width: s.fieldGroupGap),
          Expanded(
            child: Text(
              'ÜNİ RADYO • 24/7 KESİNTİSİZ YAYIN',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: s.stripFontSize,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.05 * s.stripFontSize, // tracking-wider
              ),
            ),
          ),
          SizedBox(width: s.stripPadding),
          SizedBox(
            width: stackWidth,
            height: s.stripAvatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < avatars.length; i++)
                  Positioned(
                    left: i * (s.stripAvatarSize - s.stripAvatarOverlap),
                    child: _Avatar(
                      size: s.stripAvatarSize,
                      fontSize: s.stripAvatarFontSize,
                      background: scheme.surfaceContainerHigh,
                      label: avatars[i].$1,
                      color: avatars[i].$2,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.size,
    required this.fontSize,
    required this.background,
    required this.label,
    required this.color,
  });

  final double size;
  final double fontSize;
  final Color background;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.isDark(context)
              ? AppTheme.darkSurfaceContainerLowest
              : Colors.white,
          width: 1.5, // üst üste binen avatarları ayıran halka
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}