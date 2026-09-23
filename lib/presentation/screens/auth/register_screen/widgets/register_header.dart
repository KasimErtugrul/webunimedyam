// lib/presentation/screens/auth/widgets/register_header.dart

import 'package:flutter/material.dart';


import '../register_layout_spec.dart';

/// "ÜniTV Kampüs Kaydı" etiketi + "Hesap Oluştur" başlığı + açıklama.
/// (Tasarımda SOLA hizalı — ortalanmış DEĞİL.)
class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key, required this.sizes});

  final RegisterSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.only(bottom: s.headerBottomGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiket — school ikonu (FILL) + uppercase tracking-wider
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_rounded,
                size: s.headerLabelIconSize,
                color: scheme.primary,
              ),
              SizedBox(width: s.headerGroupGap),
              Text(
                'ÜniTV Kampüs Kaydı',
                style: TextStyle(
                  color: scheme.primary,
                  fontSize: s.headerLabelFontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05 * s.headerLabelFontSize,
                ),
              ),
            ],
          ),
          SizedBox(height: s.headerGroupGap),

          // Başlık — headline-xl-mobile
          Text(
            'Hesap Oluştur',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: s.titleFontSize,
              fontWeight: FontWeight.w800,
              height: 34 / 26,
              letterSpacing: -0.025 * s.titleFontSize, // tracking-tight
            ),
          ),
          SizedBox(height: s.headerGroupGap),

          // Açıklama — body-md, leading-relaxed
          Text(
            'Tüm üniversite arşivlerine, radyo yayınlarına ve öğrenci topluluklarına tek hesaptan eriş.',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: s.descFontSize,
              height: s.descLineHeight,
            ),
          ),
        ],
      ),
    );
  }
}