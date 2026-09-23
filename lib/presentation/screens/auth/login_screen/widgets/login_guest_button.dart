// lib/presentation/screens/auth/widgets/login_guest_button.dart

import 'package:flutter/material.dart';

import '../login_layout_spec.dart';

/// Misafir girişi — transparent, h-11, text-on-surface-variant,
/// explore ikonu, hover'da surface-container tonu
class LoginGuestButton extends StatelessWidget {
  const LoginGuestButton({
    super.key,
    required this.sizes,
    required this.onPressed,
  });

  final LoginSizes sizes;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return SizedBox(
      width: double.infinity,
      height: s.guestButtonHeight,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          backgroundColor: Colors.transparent,
          overlayColor: scheme.surfaceContainer, // hover:bg-surface-container
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(s.fieldRadius),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_rounded, size: s.guestIconSize),
            SizedBox(width: s.guestGap),
            Text(
              'Giriş yapmadan göz at (Misafir)',
              style: TextStyle(
                fontSize: s.guestFontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.02 * s.guestFontSize, // label-md
              ),
            ),
          ],
        ),
      ),
    );
  }
}