// lib/presentation/screens/auth/widgets/otp_resend_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../app/themes/app_theme.dart';

/// Sadece sunum katmanı: cooldown ve loading durumunu **dışarıdan** alır.
/// Çağıran taraf `Obx` ile sarıp controller'dan besler.
class OtpResendButton extends StatelessWidget {
  final int cooldownSeconds;
  final bool isLoading;
  final VoidCallback onResend;
  final double fontSize;

  const OtpResendButton({
    super.key,
    required this.cooldownSeconds,
    required this.isLoading,
    required this.onResend,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final canResend = cooldownSeconds == 0 && !isLoading;

    final String label;
    if (cooldownSeconds > 0) {
      label = 'Kodu tekrar gönder ($cooldownSeconds sn)';
    } else if (isLoading) {
      label = 'Gönderiliyor...';
    } else {
      label = 'Kodu tekrar gönder';
    }

    return Center(
      child: TextButton(
        onPressed: canResend ? onResend : null,
        child: Text(
          label,
          style: TextStyle(
            color: canResend
                ? AppTheme.primaryColor
                : AppTheme.textSec(context),
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}