// lib/presentation/screens/auth/register_screen/widgets/register_terms_checkbox.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../register_layout_spec.dart';

// ⚠️ register_sizes.dart'ın gerçek konumuna göre düzeltin:

/// Koşullar checkbox'ı — 20x20 kutu, işaretliyken bg-primary + check,
/// metinde altı çizili "Kullanım Koşulları" / "Gizlilik Politikası".
class RegisterTermsCheckbox extends StatelessWidget {
  const RegisterTermsCheckbox({
    super.key,
    required this.sizes,
    required this.value,
    required this.onChanged,
    this.onOpenTerms,
    this.onOpenPrivacy,
  });

  final RegisterSizes sizes;
  final bool value;
  final ValueChanged<bool> onChanged;

  /// Verilirse link tıklamasında önce bu çalışır.
  final VoidCallback? onOpenTerms;
  final VoidCallback? onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes;

    return Padding(
      padding: EdgeInsets.only(top: s.termsTopGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Özel checkbox
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Padding(
              // mt-0.5 → metinle hizalı
              padding: EdgeInsets.only(top: 2.h),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: s.termsBoxSize,
                height: s.termsBoxSize,
                decoration: BoxDecoration(
                  color: value ? scheme.primary : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(s.termsBoxRadius),
                ),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: value ? 1 : 0,
                  child: Icon(
                    Icons.check_rounded,
                    size: s.termsIconSize,
                    color: scheme.onPrimary,
                    weight: 3,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: s.termsGap),

          // Metin — body-sm, altı çizili dokunulabilir linkler
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: s.termsFontSize,
                  height: 1.35,
                  letterSpacing: 0.01 * s.termsFontSize,
                ),
                children: [
                  _link(
                    context,
                    'Kullanım Koşulları',
                    onOpenTerms,
                    fallback: () => Get.toNamed('/terms'), // rotanızı bağlayın
                  ),
                  const TextSpan(text: '\'nı ve '),
                  _link(
                    context,
                    'Gizlilik Politikası',
                    onOpenPrivacy,
                    fallback: () =>
                        Get.toNamed('/privacy'), // rotanızı bağlayın
                  ),
                  const TextSpan(text: '\'nı okudum, onaylıyorum.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Altı çizili, dokunulabilir link.
  /// Öncelik sırası: [callback] → [fallback]. `??` yerine `??`'sız
  /// çözüm: iki VoidCallback'i onTap düzeyinde birleştiriyoruz;
  /// void dönüş tipiyle hiç işlem yapmıyoruz.
  WidgetSpan _link(
    BuildContext context,
    String text,
    VoidCallback? callback, {
    required VoidCallback fallback,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final s = sizes; // ✅ artık field'dan geliyor, build-local değil

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: callback ?? fallback, // ✅ VoidCallback ?? VoidCallback → geçerli
        behavior: HitTestBehavior.opaque,
        child: Text(
          text,
          style: TextStyle(
            color: scheme.onSurface,
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w500,
            fontSize: s.termsFontSize,
            height: 1.35,
            letterSpacing: 0.01 * s.termsFontSize,
          ),
        ),
      ),
    );
  }
}
