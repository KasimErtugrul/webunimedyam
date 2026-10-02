// lib/presentation/screens/auth/login_screen/widgets/login_terms_notice.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/app_routes.dart';
import '../../../../../core/widgets/hover_tap.dart';

/// Google ile giriş/kayıt için sözleşme bildirimi. E-posta kaydındaki tik
/// kutusunun karşılığı: yeni hesap Google ile açılırsa onay bu cümleyle
/// alınır (zaman + sürüm sunucuya AuthRepository.recordTermsAcceptance ile
/// yazılır).
class LoginTermsNotice extends StatelessWidget {
  const LoginTermsNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = TextStyle(
      fontSize: 12,
      height: 1.4,
      color: scheme.onSurfaceVariant,
    );
    final link = base.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Google ile devam ederek ', style: base),
        TapCursor(
          onTap: () => Get.toNamed(AppRoutes.terms),
          child: Text('Kullanım Koşulları', style: link),
        ),
        Text(' ve ', style: base),
        TapCursor(
          onTap: () => Get.toNamed(AppRoutes.privacy),
          child: Text('Gizlilik Politikası', style: link),
        ),
        Text("'nı kabul etmiş olursun.", style: base),
      ],
    );
  }
}
