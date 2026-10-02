// lib/presentation/screens/auth/widgets/register_footer_links.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../core/widgets/hover_tap.dart';
import '../register_layout_spec.dart';

/// "Zaten hesabın var mı? Giriş Yap →" — mt-space-xl py-space-sm.
class RegisterFooterLinks extends StatelessWidget {
  const RegisterFooterLinks({super.key, required this.sizes});

  final RegisterSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: s.footerVPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Zaten hesabın var mı?',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: s.footerFontSize,
              height: 20 / 14,
            ),
          ),
          SizedBox(width: s.footerGap),
          TapCursor(
            onTap: () => Get.offNamed(AppRoutes.login),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Giriş Yap',
                  style: TextStyle(
                    color: scheme.primary,
                    fontSize: s.footerLinkFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.01 * s.footerLinkFontSize,
                  ),
                ),
                SizedBox(width: s.footerGap / 2),
                Icon(
                  Icons.login_rounded,
                  size: s.footerLinkIconSize,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
