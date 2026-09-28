// lib/presentation/screens/auth/widgets/register_campus_preview.dart

import 'package:flutter/material.dart';

import '../../../../../app/themes/app_theme.dart';
import '../register_layout_spec.dart';


/// "82+ Üniversite Medyası" atmosfer önizleme kartı:
/// bg-surface-container, rounded-xl, p-4, görsel + verified + alt metin.
class RegisterCampusPreview extends StatelessWidget {
  const RegisterCampusPreview({super.key, required this.sizes});

  final RegisterSizes sizes;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Container(
      margin: EdgeInsets.only(bottom: s.headerBottomGap),
      padding: EdgeInsets.all(s.previewPadding),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(s.previewRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: AppTheme.isDark(context) ? 0.15 : 0.05,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Görsel — w-14 h-14 rounded-lg (asset; yoksa gradyan fallback)
          ClipRRect(
            borderRadius: BorderRadius.circular(s.previewImageRadius),
            child: SizedBox(
              width: s.previewImageSize,
              height: s.previewImageSize,
              child: Image.asset(
                'assets/images/register_campus.jpg', // TODO: kendi asset'iniz
                width: s.previewImageSize,
                height: s.previewImageSize,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        scheme.primaryContainer,
                        scheme.primary.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.mic_rounded,
                    size: s.previewImageSize * 0.45,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: s.previewGap),

          // Metinler
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '82+ Üniversite Medyası',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: s.previewTitleFontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.02 * s.previewTitleFontSize,
                        ),
                      ),
                    ),
                    SizedBox(width: s.previewVerifiedIconSize * 0.6),
                    Icon(
                      Icons.verified_rounded,
                      size: s.previewVerifiedIconSize + 2,
                      color: scheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Senin kampüsün, senin sesin, tek platformda.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: s.previewSubFontSize,
                    letterSpacing: 0.01 * s.previewSubFontSize,
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