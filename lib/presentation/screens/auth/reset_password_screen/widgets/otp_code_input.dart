// lib/presentation/screens/auth/widgets/otp_code_input.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/themes/app_theme.dart';

/// 6 haneli OTP kodunu kutulara böler; yapıştırma (paste) ve otomatik
/// ilerleme destekli. Kod tamamlandığında [onCompleted] **verildiyse**
/// tetiklenir.
class OtpCodeInput extends StatefulWidget {
  static const int length = 6;

  final OtpCodeInputSpec spec;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  const OtpCodeInput({
    super.key,
    required this.spec,
    this.onCompleted,
    this.enabled = true,
  });

  @override
  State<OtpCodeInput> createState() => OtpCodeInputState();
}

class OtpCodeInputState extends State<OtpCodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _autoSubmitted = false;

  String get code => _controllers.map((c) => c.text).join();
  bool get isComplete => code.length == OtpCodeInput.length;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(OtpCodeInput.length, (_) => TextEditingController());
    _focusNodes = List.generate(OtpCodeInput.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _autoSubmitted = false;
    _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < OtpCodeInput.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final focusIndex =
          (digits.length - 1).clamp(0, OtpCodeInput.length - 1);
      _focusNodes[focusIndex].requestFocus();
      _maybeComplete();
      return;
    }

    if (value.isNotEmpty && index < OtpCodeInput.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    _maybeComplete();
  }

  void _maybeComplete() {
    if (widget.onCompleted == null) return;
    if (_autoSubmitted) return;
    if (!isComplete) return;
    _autoSubmitted = true;
    FocusScope.of(context).unfocus();
    widget.onCompleted!(code);
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final borderColor = AppTheme.isDark(context)
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.12);
    final fillColor = AppTheme.isDark(context)
        ? AppTheme.darkBackground.withValues(alpha: 0.6)
        : AppTheme.lightBackground;

    return Semantics(
      label: 'Doğrulama kodu, 6 hane',
      textField: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(OtpCodeInput.length, (index) {
          return SizedBox(
            width: spec.otpBoxWidth,
            height: spec.otpBoxHeight,
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: OtpCodeInput.length,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                color: AppTheme.textPri(context),
                fontSize: spec.otpFontSize,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: fillColor,
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(spec.otpBoxRadius),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(spec.otpBoxRadius),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 1.8,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(spec.otpBoxRadius),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
              onChanged: (value) => _onChanged(index, value),
            ),
          );
        }),
      ),
    );
  }
}

/// OTP kutularının görsel spec'i — ekranın geri kalanından bağımsız.
@immutable
class OtpCodeInputSpec {
  final double otpBoxWidth;
  final double otpBoxHeight;
  final double otpBoxRadius;
  final double otpFontSize;

  const OtpCodeInputSpec({
    required this.otpBoxWidth,
    required this.otpBoxHeight,
    required this.otpBoxRadius,
    required this.otpFontSize,
  });
}