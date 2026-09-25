// lib/presentation/screens/auth/widgets/login_text_field.dart

import 'package:flutter/material.dart';
import '../login_layout_spec.dart';


/// Tasarımdaki input satırının bire bir karşılığı:
/// üstte label-md etiket → altta h-12 gövde (bg-surface-container-high,
/// rounded-lg, solda absolute ikon, odakta bg-surface-bright dolgusu).
class LoginTextField extends StatefulWidget {
  const LoginTextField({
    super.key,
    required this.sizes,
    required this.label,
    required this.icon,
    required this.controller,
    this.focusNode,
    this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.validator,
    this.onSubmitted,
  });

  final LoginSizes sizes;
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<String>? autofillHints;
  final bool enableSuggestions;
  final bool autocorrect;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  FocusNode? _ownFocus;
  bool _focused = false;

  FocusNode get _effectiveFocus =>
      widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _effectiveFocus.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _effectiveFocus.removeListener(_handleFocus);
    _ownFocus?.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (mounted) setState(() => _focused = _effectiveFocus.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = widget.sizes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // label-md — text-on-surface-variant
        Text(
          widget.label,
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: s.fieldLabelFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.02 * s.fieldLabelFontSize,
          ),
        ),
        SizedBox(height: s.fieldLabelGap),

        TextFormField(
          controller: widget.controller,
          focusNode: _effectiveFocus,
          obscureText: widget.obscure,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: s.fieldFontSize,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: scheme.primary,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: scheme.outline, // placeholder:text-outline
              fontSize: s.fieldFontSize,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            // focus:bg-surface-bright
            fillColor:
                _focused ? scheme.surfaceBright : scheme.surfaceContainerHigh,
            constraints: BoxConstraints(minHeight: s.fieldHeight),
            contentPadding: EdgeInsets.fromLTRB(
              0,
              14,
              widget.suffix != null ? s.toggleRight : s.fieldPaddingRightEmail,
              14,
            ),
            // Soldaki absolute ikon: left-4 + 20px ikon → metin pl-11 (44)
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: s.fieldIconLeft),
              child: Icon(
                widget.icon,
                size: s.fieldIconSize,
                color: scheme.outline,
              ),
            ),
            prefixIconConstraints: BoxConstraints(
              minWidth: s.fieldIconLeft + s.fieldIconSize + 8,
              minHeight: s.fieldIconSize,
            ),
            suffixIcon: widget.suffix,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide(color: scheme.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(s.fieldRadius),
              borderSide: BorderSide(color: scheme.error, width: 1.5),
            ),
            errorStyle: TextStyle(
              color: scheme.error,
              fontSize: s.fieldLabelFontSize - 1,
            ),
          ),
        ),
      ],
    );
  }
}