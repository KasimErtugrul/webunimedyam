// lib/presentation/screens/signup_preferences/widgets/signup_header.dart

import 'package:flutter/material.dart';

import '../../../../app/themes/app_theme.dart';
import '../utils/singup_preferences_sizes.dart';

/// Sabit üst bar — geri butonu + logo + "ÜniTV" + "Atla" + avatar.
/// bg-surface/80 blur karşılığı: surface + hafif alt gölge (h-16).
class SignupHeader extends StatelessWidget {
  const SignupHeader({
    super.key,
    required this.sizes,
    required this.onBack,
    required this.onSkip,
  });

  final SignupPreferencesSizes sizes;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.20 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s.headerHPadding),
        child: SizedBox(
          height: s.headerHeight,
          child: Row(
            children: [
              // Geri butonu — w-11 h-11 rounded-full
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: SizedBox(
                    width: s.backButtonSize,
                    height: s.backButtonSize,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: s.backButtonIconSize,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SizedBox(width: s.headerGap),

              // Logo (asset; yoksa primary play ikonu)
              Image.asset(
                'assets/images/unitv_logo.png', // TODO: kendi asset'iniz
                height: s.logoHeight,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.play_arrow_rounded,
                  size: s.logoHeight,
                  color: scheme.primary,
                ),
              ),
              SizedBox(width: s.headerGap),

              // ÜniTV — headline-sm tracking-tight
              Text(
                'ÜniTV',
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: s.headerTitleFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.01 * s.headerTitleFontSize,
                ),
              ),

              const Spacer(),

              // Atla — label-md primary
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.primary,
                  minimumSize: Size(0, s.backButtonSize),
                  padding: EdgeInsets.symmetric(
                    horizontal: s.pillHPadding,
                    vertical: s.pillVPadding,
                  ),
                ),
                child: Text(
                  'Atla',
                  style: TextStyle(
                    fontSize: s.skipFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.02 * s.skipFontSize,
                  ),
                ),
              ),
              SizedBox(width: s.pillGap),

              // Avatar — w-8 h-8 bg-primary + person
              Container(
                width: s.avatarSize,
                height: s.avatarSize,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: s.avatarIconSize,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}