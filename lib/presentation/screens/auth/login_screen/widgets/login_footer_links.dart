// lib/presentation/screens/auth/widgets/login_footer_links.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../../app/routes/app_routes.dart';
import '../login_layout_spec.dart';

/// "Henüz hesabın yok mu? Kayıt Ol >" — mt-space-xl, ortalanmış
/// (misafir linki artık kart içindeki LoginGuestButton; burada YOK)
class LoginFooterLinks extends StatelessWidget {
  const LoginFooterLinks({super.key, required this.sizes});

  final LoginSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Henüz hesabın yok mu?',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: s.footerFontSize,
            height: 20 / 14,
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.register),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kayıt Ol',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: s.footerLinkFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.01 * s.footerLinkFontSize, // label-lg
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: s.footerChevronSize,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}